-- =====================================================================
-- DADOS DE TESTE DA LISURA (SCRUM-49 a SCRUM-52)
-- =====================================================================
--
-- PARA QUE SERVE
--   Cria, num banco de desenvolvimento, uma guia cujo espelho JÁ FOI
--   ENVIADO pela OCS. Sem isso a tela da Lisura fica vazia, porque chegar
--   nesse estado pelo fluxo normal exige: pré-guia -> autorização -> guia
--   oficial -> OCS marca a guia como utilizada -> OCS monta o espelho ->
--   OCS envia o espelho.
--
--   >>> NÃO roda automaticamente (não está no 01_schema.sh).          <<<
--   >>> Use só em banco de desenvolvimento/teste, nunca em produção.  <<<
--
-- PRÉ-REQUISITO
--   Banco com os scripts V1 a V11 já carregados (o V11 cria a tabela
--   LISURA_REVISAO_ITEM).
--
-- COMO RODAR (PowerShell, na pasta do repositório central, com o
-- container oracle-db ligado — a pasta docker/sql fica montada em /sql):
--
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/lisura_dados_teste.sql"
--
--   No final aparece o ID DA GUIA criada. Pode rodar mais de uma vez:
--   cada execução cria uma guia nova (GUIA-TESTE<n>).
--
-- O QUE ELE FAZ
--   1. Define a senha do usuário da Lisura do seed como "senha123":
--        lisura@fusex.test / senha123   (perfil LISURA)
--      O hash gravado no V7 não confere com "senha123", por isso o ajuste.
--   2. Escolhe o primeiro prestador (OCS) que tem contratos ativos em
--      EXAME_PRESTADOR (no seed atual: CARDIOVITA).
--   3. Cria uma PRE_GUIA autorizada para o beneficiário
--      joao.silva@militar.test (usuário comum, sem perfil especial).
--   4. Cria a GUIA_OFICIAL (status UTILIZADA, código GUIA-TESTE<n>).
--   5. Cria o ESPELHO já ENVIADO pela OCS, com 4 itens que cobrem todos
--      os casos da tela:
--
--      | Item | Valor cobrado            | Qtd | Situação na Lisura   | Na guia (PRE_GUIA_ITEM)        |
--      |------|--------------------------|-----|----------------------|--------------------------------|
--      | 1    | igual ao contrato        | 1   | Conforme (sem cor)   | sim, realização confirmada     |
--      | 2    | contrato + R$ 25,00      | 2   | Acima (vermelho)     | sim, realização confirmada     |
--      | 3    | 80% do contrato          | 1   | Abaixo (amarelo)     | sim, realização NÃO confirmada |
--      | 4    | R$ 150,00                | 1   | Sem contrato (amarelo)| não está na guia              |
--
--      A data de realização dos itens é 2 dias antes de hoje.
--
-- COMO TESTAR DEPOIS DE RODAR (backend na porta 8080 e frontend no Live Server)
--   1. Login (aba "Sou usuário"): lisura@fusex.test / senha123
--   2. Na tela inicial, botão "Lisura" -> lista de espelhos enviados
--      (só aparece para perfis FUSEX, LISURA ou ADMIN)
--   3. "Conferir" na guia GUIA-TESTE<n> -> tela de conferência
--
--   Checklist da tela de conferência:
--   [ ] item acima do contrato em vermelho; abaixo e sem contrato em amarelo
--   [ ] cabeçalho com o código da guia e aviso de "2 procedimento(s) cobrado(s)
--       sem confirmação de realização"
--   [ ] totais: cobrado, contratual, diferença (cobrado - contratual) e valor final
--   [ ] item acima: "Acatar contratual" -> Salvar -> mostra o valor do contrato
--   [ ] item abaixo: "Manter cobrado" -> Salvar
--   [ ] item sem contrato: "Acatar contratual" desabilitado; Salvar sem valor
--       mostra "Informe o valor ajustado."; com valor -> Salvar
--   [ ] selo do topo muda para "Revisão concluída" e o valor final fecha a soma
--   [ ] F5: as revisões continuam lá (gravadas em LISURA_REVISAO_ITEM)
--   [ ] "Alterar" num item revisado e salvar outro valor substitui a revisão
--   [ ] beneficiário comum (sem perfil FUSEX/LISURA/ADMIN) não vê o botão
--       Lisura, e as rotas /lisura respondem 403 para ele
--
-- OBSERVAÇÕES
--   - O espelho é gravado com SYSTIMESTAMP do container (UTC): o "Enviado em"
--     aparece 3h adiantado. É só no dado de teste.
--   - O hash de senha do V7 não confere com "senha123" para nenhum usuário;
--     este script só ajusta o lisura@fusex.test.
--
-- COMO REMOVER (apaga só as guias GUIA-TESTE<n> e o que depende delas)
--   docker exec oracle-db sqlplus -s fatec_user/fatec_user_123@localhost:1521/FREEPDB1 "@/sql/teste/lisura_remover_dados_teste.sql"
-- =====================================================================

SET SERVEROUTPUT ON
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
    v_hoje       DATE := TRUNC(SYSDATE);
    v_prestador  NUMBER;
    v_usuario    NUMBER;
    v_pre_guia   NUMBER;
    v_guia       NUMBER;
    v_espelho    NUMBER;
    v_exame_sem  NUMBER;
    v_tuss_sem   VARCHAR2(200 CHAR);
    v_i          PLS_INTEGER := 0;
    v_valor      NUMBER(14,2);
    v_qtd        NUMBER;
BEGIN
    -- -----------------------------------------------------------------
    -- 1. Senha do analista da Lisura = senha123 (hash BCrypt)
    -- -----------------------------------------------------------------
    UPDATE USUARIO
       SET DS_SENHA_HASH = '$2a$10$O92AsuVxibC/OiLrSsUyW.XzoeLHyVwUi4E4oY2TDZYiKzCKAEQfu',
           FL_ATIVO = 'S'
     WHERE LOWER(DS_EMAIL) = 'lisura@fusex.test';

    -- -----------------------------------------------------------------
    -- 2. OCS: primeiro prestador com contratos ativos
    -- -----------------------------------------------------------------
    SELECT MIN(ID_PRESTADOR) INTO v_prestador
      FROM EXAME_PRESTADOR
     WHERE STATUS = 'ATIVO';

    -- -----------------------------------------------------------------
    -- 3. Beneficiário: usuário comum (sem OCS e sem perfil especial
    --    como ADMIN/LISURA), de preferência o joao.silva@militar.test
    -- -----------------------------------------------------------------
    SELECT MIN(u.ID_USUARIO) INTO v_usuario
      FROM USUARIO u
     WHERE LOWER(u.DS_EMAIL) = 'joao.silva@militar.test';

    IF v_usuario IS NULL THEN
        SELECT MIN(u.ID_USUARIO) INTO v_usuario
          FROM USUARIO u
         WHERE u.ID_PRESTADOR IS NULL
           AND NOT EXISTS (SELECT 1 FROM USUARIO_PERFIL p WHERE p.ID_USUARIO = u.ID_USUARIO);
    END IF;

    -- Pré-guia autorizada
    INSERT INTO PRE_GUIA (ID_USUARIO, NM_ANEXO, STATUS)
    VALUES (v_usuario, 'teste-lisura.png', 'AUTORIZADA')
    RETURNING ID_PRE_GUIA INTO v_pre_guia;

    -- -----------------------------------------------------------------
    -- 4. Guia oficial já utilizada pela OCS
    -- -----------------------------------------------------------------
    INSERT INTO GUIA_OFICIAL (SOLICITACAO_ID, CODIGO_GUIA, NOME_ARQUIVO, CAMINHO_ARQUIVO, STATUS)
    VALUES (v_pre_guia, 'GUIA-TESTE' || v_pre_guia, 'teste-lisura.pdf', 'uploads/guias/teste-lisura.pdf', 'UTILIZADA')
    RETURNING ID_GUIA_OFICIAL INTO v_guia;

    -- -----------------------------------------------------------------
    -- 5. Espelho já ENVIADO pela OCS
    -- -----------------------------------------------------------------
    INSERT INTO ESPELHO (ID_GUIA_OFICIAL, ID_PRESTADOR, STATUS, ATUALIZADO_EM, ENVIADO_EM)
    VALUES (v_guia, v_prestador, 'ENVIADO', SYSTIMESTAMP, SYSTIMESTAMP)
    RETURNING ID_ESPELHO INTO v_espelho;

    -- Itens 1 a 3: exames COM contrato vigente para esse prestador
    FOR r IN (
        SELECT e.ID_EXAME, e.COD_TUSS, ep.VALOR_CONTRATUAL
          FROM EXAME_PRESTADOR ep
          JOIN EXAME e ON e.ID_EXAME = ep.ID_EXAME
         WHERE ep.ID_PRESTADOR = v_prestador
           AND ep.STATUS = 'ATIVO'
           AND ep.DT_INICIO_VIGENCIA <= v_hoje - 2
           AND (ep.DT_FIM_VIGENCIA IS NULL OR ep.DT_FIM_VIGENCIA >= v_hoje)
         ORDER BY e.ID_EXAME
         FETCH FIRST 3 ROWS ONLY
    ) LOOP
        v_i := v_i + 1;
        v_qtd := 1;

        IF v_i = 1 THEN
            v_valor := r.VALOR_CONTRATUAL;                  -- item 1: conforme
        ELSIF v_i = 2 THEN
            v_valor := r.VALOR_CONTRATUAL + 25;             -- item 2: acima do contrato
            v_qtd := 2;
        ELSE
            v_valor := ROUND(r.VALOR_CONTRATUAL * 0.8, 2);  -- item 3: abaixo do contrato
        END IF;

        -- Procedimento na guia: itens 1 e 2 com realização confirmada pela OCS;
        -- item 3 sem confirmação (gera o alerta "Realização não confirmada")
        INSERT INTO PRE_GUIA_ITEM (ID_PRE_GUIA, ID_EXAME, ID_PRESTADOR, VALOR, STATUS, FL_REALIZADO, DT_REALIZADO)
        VALUES (v_pre_guia, r.ID_EXAME, v_prestador, r.VALOR_CONTRATUAL, 'AUTORIZADA',
                CASE WHEN v_i < 3 THEN 'S' ELSE 'N' END,
                CASE WHEN v_i < 3 THEN CAST(v_hoje - 2 AS TIMESTAMP) END);

        INSERT INTO ESPELHO_ITEM (ID_ESPELHO, COD_TUSS, DT_REALIZACAO, QUANTIDADE, VALOR_UNITARIO)
        VALUES (v_espelho, r.COD_TUSS, v_hoje - 2, v_qtd, v_valor);
    END LOOP;

    -- Item 4: exame SEM contrato para esse prestador, cobrado no espelho
    -- mas que não está na guia (gera "Sem valor contratual" e "Procedimento fora da guia")
    SELECT ID_EXAME, COD_TUSS INTO v_exame_sem, v_tuss_sem
      FROM EXAME e
     WHERE NOT EXISTS (
            SELECT 1 FROM EXAME_PRESTADOR ep
             WHERE ep.ID_EXAME = e.ID_EXAME
               AND ep.ID_PRESTADOR = v_prestador)
     ORDER BY ID_EXAME
     FETCH FIRST 1 ROWS ONLY;

    INSERT INTO ESPELHO_ITEM (ID_ESPELHO, COD_TUSS, DT_REALIZACAO, QUANTIDADE, VALOR_UNITARIO)
    VALUES (v_espelho, v_tuss_sem, v_hoje - 2, 1, 150);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' Guia de teste criada. ID DA GUIA = ' || v_guia || ' (GUIA-TESTE' || v_pre_guia || ')');
    DBMS_OUTPUT.PUT_LINE(' Login: lisura@fusex.test / senha123');
    DBMS_OUTPUT.PUT_LINE(' Abra: pages/lisura/conferencia-espelho.html?idGuia=' || v_guia);
    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/

EXIT
