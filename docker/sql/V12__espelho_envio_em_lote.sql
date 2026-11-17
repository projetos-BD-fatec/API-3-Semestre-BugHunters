-- Envio de espelhos em lote.
-- A OCS passa a SALVAR o espelho (fica em posse dela) e depois envia ao FUSEx
-- quantos/quais quiser de uma vez. Fluxo: RASCUNHO -> SALVO -> ENVIADO.

ALTER TABLE ESPELHO ADD (SALVO_EM TIMESTAMP(6));

ALTER TABLE ESPELHO DROP CONSTRAINT CK_ESPELHO_STATUS;

ALTER TABLE ESPELHO ADD CONSTRAINT CK_ESPELHO_STATUS
    CHECK (STATUS IN ('RASCUNHO','SALVO','ENVIADO'));

-- Lista "espelhos salvos" da OCS (filtra por prestador + status)
CREATE INDEX IX_ESPELHO_PREST_STATUS ON ESPELHO (ID_PRESTADOR, STATUS);
