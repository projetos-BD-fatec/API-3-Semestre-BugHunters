-- =====================================================================
-- DADOS DE TESTE: ESPELHOS SALVOS + ENVIO EM LOTE (OCS)
-- =====================================================================
--
-- PARA QUE SERVE
--   Monta, num banco de desenvolvimento, tudo que é preciso para testar a
--   tela "Espelhos salvos" sem passar por pré-guia -> autorização -> guia ->
--   utilização -> espelho. Cria 4 guias para a MESMA OCS:
--
--   | Guia | Beneficiário          | Situação do espelho       | Serve para testar                      |
--   |------|-----------------------|---------------------------|----------------------------------------|
--   | A    | Soldado João da Silva | SALVO (2 itens, 5 dias)   | lista, selecionar, enviar em lote      |
--   | B    | Soldado Pedro Oliveira| SALVO (1 item, 2 dias)    | lista, selecionar, enviar em lote      |
--   | C    | Soldado Lucas Santos  | AINDA NÃO EXISTE          | criar o espelho na tela e clicar Salvar|
--   | D    | Soldado Rafael Costa  | ENVIADO (1 item)          | NÃO pode aparecer em "Espelhos salvos" |
--
--   >>> NÃO roda automaticamente (não está no 01_schema.sh).          <<<
--   >>> Use só em banco de desenvolvimento/teste, nunca em produção.  <<<
--
-- PRÉ-REQUISITO
--   Banco com V1 a V12 carregados. O V12 cria o status SALVO e a coluna
--   SALVO_EM. Se o seu banco já existia antes do V12, rode ele uma vez:
--
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/V12__espelho_envio_em_lote.sql"
--
-- COMO RODAR (PowerShell, na pasta do repositório central, container ligado)
--
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/espelho_lote_dados_teste.sql"
--
--   No final aparecem o CNPJ e a senha da OCS para o login.
--   Pode rodar mais de uma vez: cada execução cria 4 guias novas.
--
-- O QUE ELE FAZ
--   1. Escolhe uma OCS que tem EXATAMENTE 1 usuário (o login por CNPJ do
--      AuthService espera 1 só; OCS com 2 usuários, como a CARDIOVITA do
--      seed, provavelmente falha no login) e pelo menos 3 contratos vigentes.
--   2. Define a senha desse usuário como "senha123" (hash BCrypt) e garante
--      o perfil PRESTADOR.
--   3. Cria pré-guia AUTORIZADA + guia oficial UTILIZADA + procedimentos
--      realizados + espelho, conforme a tabela acima.
--
-- COMO TESTAR (backend na 8080, frontend no Live Server)
--   1. Login na aba da OCS: CNPJ e senha impressos no final do script.
--   2. Painel do prestador -> botão "Espelhos salvos".
--
--   Checklist:
--   [ ] Aparecem só as guias A e B (D, já enviada, NÃO aparece; C ainda não tem espelho)
--   [ ] Nome, PRECCP (123456789 / 234567891) e data de cada uma corretos
--   [ ] Botão "Enviar para FUSEX" desabilitado sem seleção
--   [ ] "Selecionar todos" marca tudo; desmarcar uma deixa a caixa em estado parcial
--   [ ] Resumo embaixo mostra a quantidade e o total em R$ dos selecionados
--   [ ] Clicar no nome abre o espelho (ainda editável, selo "Salvo")
--   [ ] Painel -> guia C -> "Abrir espelho" -> adicionar item -> "Salvar espelho":
--       selo vira "Salvo" e a guia C passa a aparecer na lista
--   [ ] Marcar só A -> Enviar -> confirmar: A some da lista, B continua
--   [ ] Marcar o resto -> Enviar: lista fica vazia
--   [ ] Login lisura@fusex.test / senha123 (rode antes o lisura_dados_teste.sql
--       ou use a senha do seed) -> Lisura: os espelhos enviados aparecem na fila
--   [ ] Abrir o espelho de uma guia já enviada: tudo somente leitura
--   [ ] Excluir o único item de um espelho SALVO: ele volta a "Rascunho" e
--       sai da lista de salvos
--
-- COMO REMOVER (apaga as guias GUIA-TESTE<n>, inclusive as deste script)
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/lisura_remover_dados_teste.sql"
--   (a senha da OCS e os usuários não são alterados de volta)
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

    -- Cria pré-guia + guia UTILIZADA + procedimentos realizados (exames p_primeiro..p_ultimo)
    -- e, se p_status_espelho não for nulo, o espelho com um item por exame.
    PROCEDURE criar_guia(p_email           VARCHAR2,
                         p_status_espelho  VARCHAR2,
                         p_primeiro        PLS_INTEGER,
                         p_ultimo          PLS_INTEGER,
                         p_dias_atras      NUMBER,
                         p_rotulo          VARCHAR2) IS
        v_usuario NUMBER;
        v_pre     NUMBER;
        v_guia    NUMBER;
        v_esp     NUMBER;
    BEGIN
        SELECT MIN(ID_USUARIO) INTO v_usuario
          FROM USUARIO
         WHERE LOWER(DS_EMAIL) = LOWER(p_email);

        IF v_usuario IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Beneficiário não encontrado: ' || p_email);
        END IF;

        INSERT INTO PRE_GUIA (ID_USUARIO, NM_ANEXO, STATUS)
        VALUES (v_usuario, 'teste-espelho-lote.png', 'AUTORIZADA')
        RETURNING ID_PRE_GUIA INTO v_pre;

        INSERT INTO GUIA_OFICIAL (SOLICITACAO_ID, CODIGO_GUIA, NOME_ARQUIVO, CAMINHO_ARQUIVO, STATUS)
        VALUES (v_pre, 'GUIA-TESTE' || v_pre, 'teste-espelho-lote.pdf',
                'uploads/guias/teste-espelho-lote.pdf', 'UTILIZADA')
        RETURNING ID_GUIA_OFICIAL INTO v_guia;

        FOR i IN p_primeiro .. p_ultimo LOOP
            INSERT INTO PRE_GUIA_ITEM (ID_PRE_GUIA, ID_EXAME, ID_PRESTADOR, VALOR, STATUS,
                                       FL_REALIZADO, DT_REALIZADO)
            VALUES (v_pre, v_ex(i).id_exame, v_prestador, v_ex(i).valor, 'AUTORIZADA',
                    'S', CAST(v_hoje - 1 AS TIMESTAMP));
        END LOOP;

        IF p_status_espelho IS NOT NULL THEN
            INSERT INTO ESPELHO (ID_GUIA_OFICIAL, ID_PRESTADOR, STATUS, ATUALIZADO_EM, SALVO_EM, ENVIADO_EM)
            VALUES (v_guia, v_prestador, p_status_espelho, SYSTIMESTAMP,
                    SYSTIMESTAMP - NUMTODSINTERVAL(p_dias_atras, 'DAY'),
                    CASE WHEN p_status_espelho = 'ENVIADO' THEN SYSTIMESTAMP END)
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
    -- 1. OCS: 1 só usuário e pelo menos 3 contratos vigentes
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
            'Nenhuma OCS com 1 usuário e 3 contratos vigentes. Confira se o V7 a V10 foram carregados.');
    END IF;

    SELECT NM_PRESTADOR, NR_DOCUMENTO INTO v_nome_prest, v_cnpj
      FROM PRESTADOR WHERE ID_PRESTADOR = v_prestador;

    -- -----------------------------------------------------------------
    -- 2. Senha da OCS = senha123 (hash BCrypt) e perfil PRESTADOR
    -- -----------------------------------------------------------------
    SELECT ID_USUARIO INTO v_usuario_ocs
      FROM USUARIO WHERE ID_PRESTADOR = v_prestador;

    UPDATE USUARIO
       SET DS_SENHA_HASH = '$2a$10$O92AsuVxibC/OiLrSsUyW.XzoeLHyVwUi4E4oY2TDZYiKzCKAEQfu',
           FL_ATIVO = 'S'
     WHERE ID_USUARIO = v_usuario_ocs;

    INSERT INTO USUARIO_PERFIL (ID_USUARIO, CD_PERFIL)
    SELECT v_usuario_ocs, 'PRESTADOR' FROM DUAL
     WHERE NOT EXISTS (SELECT 1 FROM USUARIO_PERFIL
                        WHERE ID_USUARIO = v_usuario_ocs AND CD_PERFIL = 'PRESTADOR');

    -- -----------------------------------------------------------------
    -- 3. Três exames com contrato vigente para essa OCS
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
    -- 4. As quatro guias
    -- -----------------------------------------------------------------
    criar_guia('joao.silva@militar.test',     'SALVO',   1, 2, 5, 'A (espelho SALVO)   ');
    criar_guia('pedro.oliveira@militar.test', 'SALVO',   3, 3, 2, 'B (espelho SALVO)   ');
    criar_guia('lucas.santos@militar.test',   NULL,      1, 1, 0, 'C (sem espelho)     ');
    criar_guia('rafael.costa@militar.test',   'ENVIADO', 2, 2, 7, 'D (espelho ENVIADO) ');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' LOGIN DA OCS (aba da OCS na tela de login)');
    DBMS_OUTPUT.PUT_LINE('   OCS:   ' || v_nome_prest);
    DBMS_OUTPUT.PUT_LINE('   CNPJ:  ' || v_cnpj);
    DBMS_OUTPUT.PUT_LINE('   Senha: senha123');
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

EXIT
