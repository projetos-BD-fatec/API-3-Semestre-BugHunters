
-- =====================================================
-- V13 - FLUXO DO COLABORADOR FUSEX
-- =====================================================
--
-- Registra as decisões sobre solicitações de pré-guias:
-- - Funcionário responsável pela análise
-- - Data e horário da decisão
-- - Motivo da recusa
-- =====================================================

-- 1. Adicionar campos de análise à tabela PRE_GUIA

ALTER TABLE PRE_GUIA ADD (
    ID_ANALISADO_POR NUMBER(19),
    DT_ANALISE TIMESTAMP,
    MOTIVO_RECUSA VARCHAR2(1000)
);

-- 2. Criar relacionamento com o usuário responsável

ALTER TABLE PRE_GUIA
ADD CONSTRAINT FK_PRE_GUIA_ANALISADOR
FOREIGN KEY (ID_ANALISADO_POR)
REFERENCES USUARIO (ID_USUARIO);

-- =====================================================
-- FIM DA MIGRAÇÃO V13
-- =====================================================
