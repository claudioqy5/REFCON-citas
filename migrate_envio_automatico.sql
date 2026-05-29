-- Agregar la columna para controlar el envío automático
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[Establecimientos]') 
    AND name = N'EnvioAutomatico'
)
BEGIN
    ALTER TABLE [dbo].[Establecimientos] 
    ADD [EnvioAutomatico] BIT NOT NULL DEFAULT 0;
END
GO
