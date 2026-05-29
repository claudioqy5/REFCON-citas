-- ============================================================
-- SCRIPT DE CREACIÓN DE TABLAS — REFCON-citas SaaS
-- Ejecutar en el SQL Server del VPS para inicializar la BD
-- ============================================================

-- 1. Crear base de datos si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SistemaRecordatoriosSaaS')
BEGIN
    CREATE DATABASE SistemaRecordatoriosSaaS;
END
GO

USE SistemaRecordatoriosSaaS;
GO

-- 2. Crear Tabla Establecimientos (Tenants)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Establecimientos]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Establecimientos] (
        [EstablecimientoID] INT IDENTITY(1,1) NOT NULL,
        [CodigoUnico] NVARCHAR(100) NOT NULL,
        [NombreEstablecimiento] NVARCHAR(250) NOT NULL,
        [Estado] NVARCHAR(50) NOT NULL DEFAULT 'Activo',
        [FechaRegistro] DATETIME NULL,
        CONSTRAINT [PK_Establecimientos] PRIMARY KEY CLUSTERED ([EstablecimientoID] ASC)
    );
    PRINT 'Tabla Establecimientos creada.';
END
GO

-- 3. Crear Tabla Usuarios
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Usuarios]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Usuarios] (
        [UsuarioID] INT IDENTITY(1,1) NOT NULL,
        [EstablecimientoID] INT NOT NULL,
        [NombreCompleto] NVARCHAR(250) NOT NULL,
        [Email] NVARCHAR(250) NOT NULL,
        [ContrasenaHash] NVARCHAR(MAX) NOT NULL,
        [Estado] NVARCHAR(50) NOT NULL DEFAULT 'Activo',
        [Rol] NVARCHAR(50) NOT NULL DEFAULT 'User',
        [UsuarioReferencial] NVARCHAR(250) NULL,
        [ClaveReferencial] NVARCHAR(250) NULL,
        CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED ([UsuarioID] ASC),
        CONSTRAINT [FK_Usuarios_Establecimientos_EstablecimientoID] FOREIGN KEY ([EstablecimientoID]) 
            REFERENCES [dbo].[Establecimientos] ([EstablecimientoID]) ON DELETE CASCADE
    );
    PRINT 'Tabla Usuarios creada.';
END
GO

-- 4. Crear Tabla Pacientes
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pacientes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Pacientes] (
        [PacienteID] INT IDENTITY(1,1) NOT NULL,
        [EstablecimientoID] INT NOT NULL,
        [Dni] NVARCHAR(50) NOT NULL,
        [NombreCompleto] NVARCHAR(250) NOT NULL,
        [Celular] NVARCHAR(50) NOT NULL,
        CONSTRAINT [PK_Pacientes] PRIMARY KEY CLUSTERED ([PacienteID] ASC),
        CONSTRAINT [FK_Pacientes_Establecimientos_EstablecimientoID] FOREIGN KEY ([EstablecimientoID]) 
            REFERENCES [dbo].[Establecimientos] ([EstablecimientoID]) ON DELETE CASCADE
    );

    -- Índice único para DNI por Establecimiento (Multi-tenancy)
    CREATE UNIQUE NONCLUSTERED INDEX [IX_Pacientes_EstablecimientoID_Dni]
        ON [dbo].[Pacientes] ([EstablecimientoID] ASC, [Dni] ASC);

    PRINT 'Tabla Pacientes creada con índice único.';
END
GO

-- 5. Crear Tabla PeticionesEnvio
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PeticionesEnvio]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PeticionesEnvio] (
        [PeticionID] INT IDENTITY(1,1) NOT NULL,
        [EstablecimientoID] INT NOT NULL,
        [UsuarioID] INT NOT NULL,
        [FechaPeticion] DATETIME NULL,
        [EstadoProceso] NVARCHAR(50) NOT NULL DEFAULT 'Pendiente',
        [FechaFinalizacion] DATETIME NULL,
        CONSTRAINT [PK_PeticionesEnvio] PRIMARY KEY CLUSTERED ([PeticionID] ASC),
        CONSTRAINT [FK_PeticionesEnvio_Establecimientos_EstablecimientoID] FOREIGN KEY ([EstablecimientoID]) 
            REFERENCES [dbo].[Establecimientos] ([EstablecimientoID]),
        CONSTRAINT [FK_PeticionesEnvio_Usuarios_UsuarioID] FOREIGN KEY ([UsuarioID]) 
            REFERENCES [dbo].[Usuarios] ([UsuarioID])
    );
    PRINT 'Tabla PeticionesEnvio creada.';
END
GO

-- 6. Crear Tabla HistorialMensajes
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HistorialMensajes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[HistorialMensajes] (
        [MensajeID] INT IDENTITY(1,1) NOT NULL,
        [PeticionID] INT NOT NULL,
        [EstablecimientoID] INT NOT NULL,
        [PacienteID] INT NOT NULL,
        [IdCita] NVARCHAR(100) NOT NULL,
        [IdReferencia] NVARCHAR(100) NULL,
        [Especialidad] NVARCHAR(250) NOT NULL,
        [FechaCita] DATETIME NOT NULL,
        [FechaHoraEnvio] DATETIME NULL,
        [CuerpoMensaje] NVARCHAR(MAX) NOT NULL,
        [EstadoEnvio] NVARCHAR(50) NOT NULL DEFAULT 'Enviado',
        [EstablecimientoDestino] NVARCHAR(250) NULL,
        [Consultorio] NVARCHAR(250) NULL,
        [Medico] NVARCHAR(250) NULL,
        CONSTRAINT [PK_HistorialMensajes] PRIMARY KEY CLUSTERED ([MensajeID] ASC),
        CONSTRAINT [FK_HistorialMensajes_PeticionesEnvio_PeticionID] FOREIGN KEY ([PeticionID]) 
            REFERENCES [dbo].[PeticionesEnvio] ([PeticionID]) ON DELETE CASCADE,
        CONSTRAINT [FK_HistorialMensajes_Establecimientos_EstablecimientoID] FOREIGN KEY ([EstablecimientoID]) 
            REFERENCES [dbo].[Establecimientos] ([EstablecimientoID]),
        CONSTRAINT [FK_HistorialMensajes_Pacientes_PacienteID] FOREIGN KEY ([PacienteID]) 
            REFERENCES [dbo].[Pacientes] ([PacienteID])
    );
    PRINT 'Tabla HistorialMensajes creada.';
END
GO
