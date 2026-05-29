-- ============================================================
-- Script de migración: Integración n8n con Base de Datos
-- Ejecutar en el VPS en la BD: SistemaRecordatoriosSaaS
-- ============================================================

-- 1. Hacer UsuarioID nullable en PeticionesEnvio
--    (Permite ejecuciones automáticas por cron sin usuario autenticado)
ALTER TABLE PeticionesEnvio
    ALTER COLUMN UsuarioID INT NULL;

-- 2. Agregar campos de trazabilidad al resultado del flujo
ALTER TABLE PeticionesEnvio
    ADD TotalPacientesNuevos INT NULL,       -- Cuántos pacientes nuevos encontró REFCON
        TotalEnviados         INT NULL,       -- Cuántos mensajes se enviaron OK
        TotalErrores          INT NULL,       -- Cuántos mensajes fallaron
        MensajeError          NVARCHAR(500) NULL,  -- Descripción del error si el flujo falló
        EtapaError            NVARCHAR(100) NULL;  -- Etapa donde falló: RefconLogin | ObtenerPacientes | SinPacientes | EnviarWhatsApp

-- 3. Verificar cambios
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PeticionesEnvio'
ORDER BY ORDINAL_POSITION;
