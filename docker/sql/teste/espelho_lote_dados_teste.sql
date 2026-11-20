-- =====================================================================
-- DADOS DE TESTE: ESPELHOS EM LOTE + ASSINATURA DO BENEFICIARIO + VENCIMENTO
-- =====================================================================
--
-- PARA QUE SERVE
--   Monta, num banco de desenvolvimento, tudo que e preciso para testar sem
--   passar por pre-guia -> autorizacao -> guia -> utilizacao -> espelho.
--   Cria 6 guias para a MESMA OCS:
--
--   | Guia | Beneficiario           | Situacao                          | Serve para testar                                   |
--   |------|------------------------|-----------------------------------|-----------------------------------------------------|
--   | A    | Soldado Joao da Silva  | UTILIZADA, assinada, espelho SALVO| lista "Espelhos salvos" e envio em lote             |
--   | B    | Soldado Pedro Oliveira | UTILIZADA, assinada, espelho SALVO| lista "Espelhos salvos" e envio em lote             |
--   | C    | Soldado Lucas Santos   | UTILIZADA, SEM assinatura         | assinar com codigo e depois abrir/salvar o espelho  |
--   | D    | Soldado Rafael Costa   | UTILIZADA, assinada, ENVIADO      | NAO pode aparecer em "Espelhos salvos"              |
--   | E    | Soldado Marcos Almeida | ATIVA (vence em ~3 meses)         | fluxo completo: utilizar -> assinar -> espelho      |
--   | F    | Soldado Pedro Oliveira | ATIVA, VENCIDA ha 10 dias         | aparece "Vencida" e nao pode ser utilizada          |
--
--   >>> NAO roda automaticamente (nao esta no 01_schema.sh).         <<<
--   >>> Use so em banco de desenvolvimento/teste, nunca em producao. <<<
--
-- PRE-REQUISITO
--   Banco com V1 a V13 carregados (V12: espelhos em lote; V13: vencimento e
--   assinatura). Se o seu banco ja existia, rode os que faltam, na ordem:
--
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/V12__espelho_envio_em_lote.sql"
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/V13__guia_vencimento_assinatura.sql"
--
-- COMO RODAR (PowerShell, na pasta do repositorio central, container ligado)
--
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/espelho_lote_dados_teste.sql"
--
--   No final aparecem os logins (OCS e beneficiarios). Pode rodar mais de uma
--   vez: cada execucao cria 6 guias novas.
--
-- O QUE ELE FAZ
--   1. Escolhe uma OCS com EXATAMENTE 1 usuario (o login por CNPJ espera 1 so;
--      a CARDIOVITA do seed tem 2 e provavelmente falha) e >= 3 contratos vigentes.
--   2. Define a senha "senha123" (hash BCrypt) da OCS e dos 5 soldados do seed,
--      e garante o perfil PRESTADOR da OCS.
--   3. Cria pre-guia AUTORIZADA + guia oficial + procedimentos + espelho,
--      conforme a tabela acima.
--
-- COMO TESTAR (backend na 8080, frontend no Live Server)
--
--   [ ] ESPELHOS SALVOS / LOTE (login da OCS)
--       - Painel -> "Espelhos salvos": aparecem so A e B (D ja foi enviada; C nao tem espelho)
--       - Marcar so A -> "Enviar para FUSEX": A some, B continua
--
--   [ ] ASSINATURA COM A GUIA C (precisa de DUAS abas/janelas: OCS e beneficiario)
--       1. OCS: abrir a guia C -> secao "Assinatura do beneficiario" com "Gerar codigo"
--          e o botao "Abrir espelho" DESABILITADO (aviso pedindo a assinatura)
--       2. Beneficiario (janela anonima): login lucas.santos@militar.test / senha123
--          -> "Assinar guia": aparece o codigo de 6 digitos (vem depois que a OCS gera)
--       3. OCS: digitar o codigo errado -> "Codigo incorreto. Restam 4 tentativa(s)."
--       4. OCS: digitar o codigo certo -> "Guia assinada"; o espelho libera
--       5. OCS: abrir o espelho, adicionar item, "Salvar espelho" -> aparece em "Espelhos salvos"
--       6. Esperar o codigo expirar (10 min) ou errar 5 vezes: precisa "Gerar novo codigo"
--
--   [ ] FLUXO COMPLETO COM A GUIA E (ATIVA)
--       - OCS: "Marcar como utilizada" -> o codigo ja e gerado e a tela rola para a
--         secao de assinatura; o beneficiario (marcos.almeida@militar.test) ja o ve
--       - Seguir como na guia C
--
--   [ ] VENCIMENTO COM A GUIA F
--       - OCS: o selo mostra "Vencida"; "Marcar como utilizada" nao aparece
--       - Reiniciar o backend (ou esperar 00:05): o STATUS no banco passa a VENCIDA
--         (SELECT CODIGO_GUIA, STATUS FROM GUIA_OFICIAL WHERE CODIGO_GUIA LIKE 'GUIA-TESTE%')
--       - A guia E mostra "Valida ate dd/mm/aaaa" na tela
--
--   [ ] LISURA (login lisura@fusex.test / senha123 - rode antes o lisura_dados_teste.sql)
--       - Na conferencia de um espelho enviado aparece "Guia assinada pelo beneficiario em ..."
--         (guias A, B, D) ou "Sem assinatura do beneficiario registrada" (guias antigas)
--
-- COMO REMOVER (apaga as guias GUIA-TESTE<n>, inclusive as deste script)
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/lisura_remover_dados_teste.sql"
--   (as senhas alteradas nao sao desfeitas)
-- =====================================================================

SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
    v_hoje        DATE := TRUNC(SYSDATE);
    v_prestador   NUMBER;
    v_nome_prest  VARCHAR2(200 CHAR);
    v_cnpj        VARCHAR2(14 CHAR);
    v_usuario_ocs NUMBER;

    TYPE t_exame  IS RECORD (id_exame NUMBER, cod_tuss VARCHAR2(200 CHAR), valor NUMBER(14,2));
    TYPE t_exames IS TABLE OF t_exame INDEX BY PLS_INTEGER;
    v_ex t_exames;
    v_n  PLS_INTEGER := 0;

    -- Cria pre-guia + guia oficial + procedimentos (exames p_primeiro..p_ultimo) e,
    -- se p_espelho nao for nulo, o espelho com um item por exame.
    --   p_status_guia  : ATIVA ou UTILIZADA
    --   p_assinada     : TRUE grava a assinatura do beneficiario na guia
    --   p_validade     : ultimo dia de validade da guia
    --   p_upload_dias  : ha quantos dias a guia foi carregada
    PROCEDURE criar_guia(p_email        VARCHAR2,
                         p_status_guia  VARCHAR2,
                         p_assinada     BOOLEAN,
                         p_espelho      VARCHAR2,
                         p_primeiro     PLS_INTEGER,
                         p_ultimo       PLS_INTEGER,
                         p_dias_espelho NUMBER,
                         p_validade     DATE,
                         p_upload_dias  NUMBER,
                         p_rotulo       VARCHAR2) IS
        v_usuario   NUMBER;
        v_pre       NUMBER;
        v_guia      NUMBER;
        v_esp       NUMBER;
        v_assinatura TIMESTAMP := NULL;
        v_assinante  NUMBER := NULL;
        v_fl_realizado CHAR(1) := CASE WHEN p_status_guia = 'UTILIZADA' THEN 'S' ELSE 'N' END;
        v_dt_realizado TIMESTAMP := NULL;
    BEGIN
        SELECT MIN(ID_USUARIO) INTO v_usuario
          FROM USUARIO
         WHERE LOWER(DS_EMAIL) = LOWER(p_email);

        IF v_usuario IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Beneficiario nao encontrado: ' || p_email);
        END IF;

        IF v_fl_realizado = 'S' THEN
            v_dt_realizado := CAST(v_hoje - 1 AS TIMESTAMP);
        END IF;

        IF p_assinada THEN
            v_assinatura := SYSTIMESTAMP;
            v_assinante  := v_usuario;
        END IF;

        INSERT INTO PRE_GUIA (ID_USUARIO, NM_ANEXO, STATUS)
        VALUES (v_usuario, 'teste-espelho-lote.png', 'AUTORIZADA')
        RETURNING ID_PRE_GUIA INTO v_pre;

        INSERT INTO GUIA_OFICIAL (SOLICITACAO_ID, CODIGO_GUIA, NOME_ARQUIVO, CAMINHO_ARQUIVO,
                                  DATA_UPLOAD, STATUS, DT_VALIDADE, DT_ASSINATURA, ID_USUARIO_ASSINANTE)
        VALUES (v_pre, 'GUIA-TESTE' || v_pre, 'teste-espelho-lote.pdf',
                'uploads/guias/teste-espelho-lote.pdf',
                SYSTIMESTAMP - NUMTODSINTERVAL(p_upload_dias, 'DAY'),
                p_status_guia, p_validade, v_assinatura, v_assinante)
        RETURNING ID_GUIA_OFICIAL INTO v_guia;

        FOR i IN p_primeiro .. p_ultimo LOOP
            INSERT INTO PRE_GUIA_ITEM (ID_PRE_GUIA, ID_EXAME, ID_PRESTADOR, VALOR, STATUS,
                                       FL_REALIZADO, DT_REALIZADO)
            VALUES (v_pre, v_ex(i).id_exame, v_prestador, v_ex(i).valor, 'AUTORIZADA',
                    v_fl_realizado, v_dt_realizado);
        END LOOP;

        IF p_espelho IS NOT NULL THEN
            INSERT INTO ESPELHO (ID_GUIA_OFICIAL, ID_PRESTADOR, STATUS, ATUALIZADO_EM, SALVO_EM, ENVIADO_EM)
            VALUES (v_guia, v_prestador, p_espelho, SYSTIMESTAMP,
                    SYSTIMESTAMP - NUMTODSINTERVAL(p_dias_espelho, 'DAY'),
                    CASE WHEN p_espelho = 'ENVIADO' THEN SYSTIMESTAMP END)
            RETURNING ID_ESPELHO INTO v_esp;

            FOR i IN p_primeiro .. p_ultimo LOOP
                INSERT INTO ESPELHO_ITEM (ID_ESPELHO, COD_TUSS, DT_REALIZACAO, QUANTIDADE, VALOR_UNITARIO)
                VALUES (v_esp, v_ex(i).cod_tuss, v_hoje - 1, 1, v_ex(i).valor);
            END LOOP;
        END IF;

        DBMS_OUTPUT.PUT_LINE(' ' || p_rotulo || ': GUIA-TESTE' || v_pre
                             || ' (id guia ' || v_guia || ') - ' || p_email);
    END criar_guia;
BEGIN
    -- -----------------------------------------------------------------
    -- 1. OCS: 1 so usuario e pelo menos 3 contratos vigentes
    -- -----------------------------------------------------------------
    SELECT MIN(p.ID_PRESTADOR) INTO v_prestador
      FROM PRESTADOR p
     WHERE p.TP_PRESTADOR = 'OCS'
       AND p.FL_ATIVO = 'S'
       AND p.NR_DOCUMENTO IS NOT NULL
       AND (SELECT COUNT(*) FROM USUARIO u WHERE u.ID_PRESTADOR = p.ID_PRESTADOR) = 1
       AND (SELECT COUNT(*)
              FROM EXAME_PRESTADOR ep
             WHERE ep.ID_PRESTADOR = p.ID_PRESTADOR
               AND ep.STATUS = 'ATIVO'
               AND ep.DT_INICIO_VIGENCIA <= v_hoje - 2
               AND (ep.DT_FIM_VIGENCIA IS NULL OR ep.DT_FIM_VIGENCIA >= v_hoje)) >= 3;

    IF v_prestador IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Nenhuma OCS com 1 usuario e 3 contratos vigentes. Confira se o V7 a V10 foram carregados.');
    END IF;

    SELECT NM_PRESTADOR, NR_DOCUMENTO INTO v_nome_prest, v_cnpj
      FROM PRESTADOR WHERE ID_PRESTADOR = v_prestador;

    -- -----------------------------------------------------------------
    -- 2. Senha senha123 (hash BCrypt) da OCS e dos soldados; perfil PRESTADOR
    -- -----------------------------------------------------------------
    SELECT ID_USUARIO INTO v_usuario_ocs
      FROM USUARIO WHERE ID_PRESTADOR = v_prestador;

    UPDATE USUARIO
       SET DS_SENHA_HASH = '$2a$10$O92AsuVxibC/OiLrSsUyW.XzoeLHyVwUi4E4oY2TDZYiKzCKAEQfu',
           FL_ATIVO = 'S'
     WHERE ID_USUARIO = v_usuario_ocs
        OR LOWER(DS_EMAIL) IN ('joao.silva@militar.test', 'pedro.oliveira@militar.test',
                               'lucas.santos@militar.test', 'rafael.costa@militar.test',
                               'marcos.almeida@militar.test');

    INSERT INTO USUARIO_PERFIL (ID_USUARIO, CD_PERFIL)
    SELECT v_usuario_ocs, 'PRESTADOR' FROM DUAL
     WHERE NOT EXISTS (SELECT 1 FROM USUARIO_PERFIL
                        WHERE ID_USUARIO = v_usuario_ocs AND CD_PERFIL = 'PRESTADOR');

    -- -----------------------------------------------------------------
    -- 3. Tres exames com contrato vigente para essa OCS
    -- -----------------------------------------------------------------
    FOR r IN (
        SELECT e.ID_EXAME, e.COD_TUSS, MAX(ep.VALOR_CONTRATUAL) AS VALOR
          FROM EXAME_PRESTADOR ep
          JOIN EXAME e ON e.ID_EXAME = ep.ID_EXAME
         WHERE ep.ID_PRESTADOR = v_prestador
           AND ep.STATUS = 'ATIVO'
           AND ep.DT_INICIO_VIGENCIA <= v_hoje - 2
           AND (ep.DT_FIM_VIGENCIA IS NULL OR ep.DT_FIM_VIGENCIA >= v_hoje)
         GROUP BY e.ID_EXAME, e.COD_TUSS
         ORDER BY e.ID_EXAME
         FETCH FIRST 3 ROWS ONLY
    ) LOOP
        v_n := v_n + 1;
        v_ex(v_n).id_exame := r.ID_EXAME;
        v_ex(v_n).cod_tuss := r.COD_TUSS;
        v_ex(v_n).valor    := r.VALOR;
    END LOOP;

    IF v_n < 3 THEN
        RAISE_APPLICATION_ERROR(-20003, 'A OCS escolhida tem menos de 3 exames distintos com contrato.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' Guias criadas:');

    -- -----------------------------------------------------------------
    -- 4. As seis guias (validade normal = hoje + 3 meses, como o backend faz)
    -- -----------------------------------------------------------------
    criar_guia('joao.silva@militar.test',     'UTILIZADA', TRUE,  'SALVO',   1, 2, 5, ADD_MONTHS(v_hoje, 3), 1,   'A (espelho SALVO)    ');
    criar_guia('pedro.oliveira@militar.test', 'UTILIZADA', TRUE,  'SALVO',   3, 3, 2, ADD_MONTHS(v_hoje, 3), 1,   'B (espelho SALVO)    ');
    criar_guia('lucas.santos@militar.test',   'UTILIZADA', FALSE, NULL,      1, 1, 0, ADD_MONTHS(v_hoje, 3), 1,   'C (falta assinar)    ');
    criar_guia('rafael.costa@militar.test',   'UTILIZADA', TRUE,  'ENVIADO', 2, 2, 7, ADD_MONTHS(v_hoje, 3), 1,   'D (espelho ENVIADO)  ');
    criar_guia('marcos.almeida@militar.test', 'ATIVA',     FALSE, NULL,      1, 2, 0, ADD_MONTHS(v_hoje, 3), 0,   'E (ATIVA, valida)    ');
    criar_guia('pedro.oliveira@militar.test', 'ATIVA',     FALSE, NULL,      3, 3, 0, v_hoje - 10,           100, 'F (ATIVA, VENCIDA)   ');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' LOGIN DA OCS (aba da OCS na tela de login)');
    DBMS_OUTPUT.PUT_LINE('   OCS:   ' || v_nome_prest);
    DBMS_OUTPUT.PUT_LINE('   CNPJ:  ' || v_cnpj);
    DBMS_OUTPUT.PUT_LINE('   Senha: senha123');
    DBMS_OUTPUT.PUT_LINE(' LOGIN DOS BENEFICIARIOS (aba de usuario), senha123:');
    DBMS_OUTPUT.PUT_LINE('   joao.silva@militar.test, pedro.oliveira@militar.test,');
    DBMS_OUTPUT.PUT_LINE('   lucas.santos@militar.test, rafael.costa@militar.test,');
    DBMS_OUTPUT.PUT_LINE('   marcos.almeida@militar.test');
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

EXIT
