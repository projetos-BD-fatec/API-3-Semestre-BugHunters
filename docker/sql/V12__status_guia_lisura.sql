-- =====================================================================
-- V12 - Status da decisão final da Lisura na GUIA_OFICIAL (SCRUM-53)
--
--   LISURA_APROVADA: analista confirmou a Lisura (aprovada para pagamento)
--   LISURA_RECUSADA: analista recusou a Lisura (glosada/recusada)
--
-- Os dois cabem no VARCHAR2(20) da coluna STATUS; só a CHECK muda.
-- =====================================================================

ALTER TABLE GUIA_OFICIAL DROP CONSTRAINT CK_GUIA_OFICIAL_STATUS;

ALTER TABLE GUIA_OFICIAL ADD CONSTRAINT CK_GUIA_OFICIAL_STATUS
    CHECK (STATUS IN ('ATIVA','UTILIZADA','VENCIDA','CANCELADA',
                      'LISURA_APROVADA','LISURA_RECUSADA'));
