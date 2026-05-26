USE SistemaRecordatoriosSaaS;
GO

-- 1. Limpieza de datos previos en orden jerárquico correcto
ALTER TABLE HistorialMensajes NOCHECK CONSTRAINT ALL;
ALTER TABLE Pacientes NOCHECK CONSTRAINT ALL;
ALTER TABLE PeticionesEnvio NOCHECK CONSTRAINT ALL;
ALTER TABLE Usuarios NOCHECK CONSTRAINT ALL;

DELETE FROM HistorialMensajes;
DELETE FROM Pacientes;
DELETE FROM PeticionesEnvio;
DELETE FROM Usuarios;
DELETE FROM Establecimientos;

ALTER TABLE HistorialMensajes CHECK CONSTRAINT ALL;
ALTER TABLE Pacientes CHECK CONSTRAINT ALL;
ALTER TABLE PeticionesEnvio CHECK CONSTRAINT ALL;
ALTER TABLE Usuarios CHECK CONSTRAINT ALL;
ALTER TABLE Establecimientos CHECK CONSTRAINT ALL;

DBCC CHECKIDENT ('Establecimientos', RESEED, 0);
DBCC CHECKIDENT ('Usuarios', RESEED, 0);
DBCC CHECKIDENT ('Pacientes', RESEED, 0);
DBCC CHECKIDENT ('PeticionesEnvio', RESEED, 0);
DBCC CHECKIDENT ('HistorialMensajes', RESEED, 0);
GO

-- 2. INSERTAR ESTABLECIMIENTOS DE SALUD
INSERT INTO Establecimientos (CodigoUnico, NombreEstablecimiento, Estado, FechaRegistro)
VALUES 
('EST-001', 'Administracion Central', 'Activo', GETDATE()),
('EST-002', 'Clinica Dental San Apolonia', 'Activo', GETDATE()),
('EST-003', 'Centro Medico Pediatrico KidsHealth', 'Activo', GETDATE()),
('EST-004', 'Hospital Regional del Sur (Inactivo)', 'Suspendido', GETDATE());
GO

-- 3. INSERTAR USUARIOS
INSERT INTO Usuarios (EstablecimientoID, NombreCompleto, Email, ContrasenaHash, Estado)
VALUES 
(1, 'Super Administrador', 'admin@saas.com', 'admin123', 'Activo'),          
(2, 'Dra. Beatríz Mendoza', 'beatriz@dental.com', 'dental123', 'Activo'),      
(3, 'Dr. Carlos Pinedo', 'carlos@kidshealth.com', 'kids123', 'Activo'),       
(4, 'Enfermera Sofía Larrea', 'sofia@hospital.com', 'hosp123', 'Activo');      
GO

-- 4. INSERTAR PACIENTES (Alineado con Dni, NombreCompleto, Celular)
-- Pacientes para Clínica Dental (EstablecimientoID = 2)
INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
VALUES 
(2, '40506070', 'Hernán Oswaldo Quello Huanca', '+51987654321'),
(2, '70809010', 'María Alejandra Torres', '+51912345678'),
(2, '10203040', 'Roberto Carlos Vizcarra', '+51955667788'),
(2, '90807060', 'Lucía Fernanda Beltrán', '+51933221100');

-- Pacientes para Pediatría KidsHealth (EstablecimientoID = 3)
INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
VALUES 
(3, '50607080', 'Mateo (Padre: Jorge Chávez)', '+51944882211'),
(3, '30405060', 'Valentina (Madre: Diana Ross)', '+51966554433'),
(3, '80901020', 'Santiago (Madre: Inés Melchor)', '+51922883377');
GO

-- 5. INSERTAR PETICIONES DE ENVÍO (Alineado con PeticionesEnvio)
INSERT INTO PeticionesEnvio (EstablecimientoID, UsuarioID, FechaPeticion, EstadoProceso, FechaFinalizacion)
VALUES 
(2, 2, GETDATE() - 1, 'Completado', GETDATE() - 1),
(3, 3, GETDATE() - 2, 'Completado', GETDATE() - 2);
GO

-- 6. INSERTAR HISTORIAL DE MENSAJES ENVIADOS (Alineado con HistorialMensajes)
-- Mensajes para Clínica Dental (EstablecimientoID = 2, PeticionID = 1, PacienteID = 1, 2, 3)
INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio)
VALUES 
(1, 2, 1, 'CITA-101', 'REF-001', 'Odontología General', GETDATE(), GETDATE() - 1, 'Hola Hernán Oswaldo, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado'),
(1, 2, 2, 'CITA-102', 'REF-002', 'Ortodoncia', GETDATE() + 1, GETDATE() - 1, 'Hola María Alejandra, le recordamos su cita dental mañana en Clinica Dental San Apolonia.', 'Enviado'),
(1, 2, 3, 'CITA-103', 'REF-003', 'Endodoncia', GETDATE() + 1, GETDATE() - 1, 'Hola Roberto Carlos, le recordamos su cita dental mañana en Clinica Dental San Apolonia.', 'Error');

-- Mensajes para Pediatría KidsHealth (EstablecimientoID = 3, PeticionID = 2, PacienteID = 5, 6)
INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio)
VALUES 
(2, 3, 5, 'CITA-201', 'REF-004', 'Pediatría de Control', GETDATE(), GETDATE() - 2, 'Hola Jorge Chávez, le recordamos la cita de control de Mateo hoy en KidsHealth.', 'Enviado'),
(2, 3, 6, 'CITA-202', 'REF-005', 'Vacunación', GETDATE() + 2, GETDATE() - 2, 'Hola Diana Ross, le recordamos la cita de vacunación de Valentina en KidsHealth.', 'Enviado');
GO
