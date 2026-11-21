-- =====================================================================
-- V14 - US16 / SCRUM-62 - Valores processados na liquidacao
--
-- O V13 (US17) criou a etapa de liquidacao com data e responsavel.
-- A US16 pede mais: "processar os valores aprovados". Esta migracao
-- guarda o valor efetivamente liquidado junto com quem liquidou.
--
-- De onde vem o valor: da propria Lisura. Para cada item do espelho
-- ela grava VALOR_FINAL_UNITARIO em LISURA_REVISAO_ITEM; os itens
-- conformes, que nao exigem revisao, valem o proprio valor cobrado.
-- O total e a soma de (valor final x quantidade). Nada e digitado.
-- =====================================================================

SET SERVEROUTPUT ON


-- ---------------------------------------------------------------------
-- 1) Valor liquidado
--
-- Fica na GUIA_OFICIAL, ao lado da data e do responsavel, porque e o
-- resultado de um mesmo ato: a guia foi liquidada por fulano, em tal
-- data, no valor tal.
-- ---------------------------------------------------------------------

ALTER TABLE GUIA_OFICIAL ADD (
    VALOR_LIQUIDADO NUMBER(14,2)
);

COMMENT ON COLUMN GUIA_OFICIAL.VALOR_LIQUIDADO IS 'US16: total aprovado processado na liquidacao, somado a partir das revisoes da Lisura.';


-- ---------------------------------------------------------------------
-- 2) Guias liquidadas antes desta migracao
--
-- Se alguem ja liquidou uma guia com o codigo anterior, a linha tem data
-- e responsavel mas nao tem valor. A constraint do passo 3 exige as tres
-- colunas juntas, e o Oracle valida as linhas existentes ao criar uma
-- CHECK: sem este preenchimento, o ALTER falharia com ORA-02293.
--
-- O valor e calculado igual ao do backend: para cada item do espelho, o
-- valor final da Lisura ou, nos itens sem revisao, o proprio cobrado.
-- ---------------------------------------------------------------------

UPDATE GUIA_OFICIAL g
   SET VALOR_LIQUIDADO = (
           SELECT NVL(SUM(NVL(r.VALOR_FINAL_UNITARIO, ei.VALOR_UNITARIO) * ei.QUANTIDADE), 0)
             FROM ESPELHO e
             JOIN ESPELHO_ITEM ei
               ON ei.ID_ESPELHO = e.ID_ESPELHO
             LEFT JOIN LISURA_REVISAO_ITEM r
               ON r.ID_ESPELHO_ITEM = ei.ID_ESPELHO_ITEM
            WHERE e.ID_GUIA_OFICIAL = g.ID_GUIA_OFICIAL)
 WHERE g.LIQUIDADO_EM IS NOT NULL
   AND g.VALOR_LIQUIDADO IS NULL;

-- Guia liquidada que nao tenha espelho ficaria com NULL e barraria a
-- constraint. Nao deveria existir, mas o zero evita travar a migracao.
UPDATE GUIA_OFICIAL
   SET VALOR_LIQUIDADO = 0
 WHERE LIQUIDADO_EM IS NOT NULL
   AND VALOR_LIQUIDADO IS NULL;

COMMIT;


-- ---------------------------------------------------------------------
-- 3) As tres colunas da liquidacao andam juntas
--
-- A CK_GUIA_LIQUIDACAO do V13 cobria data e responsavel. Agora o valor
-- entra na mesma regra: ou a guia esta liquidada por inteiro, ou nao
-- esta. Isso impede meia-liquidacao gravada por engano.
-- ---------------------------------------------------------------------

ALTER TABLE GUIA_OFICIAL DROP CONSTRAINT CK_GUIA_LIQUIDACAO;

ALTER TABLE GUIA_OFICIAL ADD CONSTRAINT CK_GUIA_LIQUIDACAO
    CHECK ( (LIQUIDADO_EM IS     NULL AND ID_USUARIO_LIQUIDACAO IS     NULL AND VALOR_LIQUIDADO IS     NULL)
         OR (LIQUIDADO_EM IS NOT NULL AND ID_USUARIO_LIQUIDACAO IS NOT NULL AND VALOR_LIQUIDADO IS NOT NULL) );

ALTER TABLE GUIA_OFICIAL ADD CONSTRAINT CK_GUIA_VALOR_LIQUIDADO
    CHECK (VALOR_LIQUIDADO IS NULL OR VALOR_LIQUIDADO >= 0);


-- ---------------------------------------------------------------------
-- 4) Nota sobre o MAPA (US15) - criterio nao atendido
--
-- Os criterios 1 e 3 da US16 exigem que so guias "com MAPA gerado"
-- possam ser liquidadas. Esta migracao NAO cria essa regra, e nao e
-- por esquecimento: a US15 ainda nao tem formato nem campos definidos
-- (o DoR dela registra as duas perguntas em aberto com o cliente).
--
-- Quando a US15 existir, o caminho e:
--   - a tabela/coluna que marca o MAPA gerado entra numa migracao sua;
--   - a checagem no backend ja tem lugar reservado e isolado, em
--     LiquidacaoService.validarMapaGerado().
-- ---------------------------------------------------------------------

COMMIT;
