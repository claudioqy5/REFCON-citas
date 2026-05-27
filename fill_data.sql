USE SistemaRecordatoriosSaaS;
GO

-- 1. Desactivar llaves foráneas temporalmente para limpieza segura
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
GO

-- =====================================================================
-- 2. INSERTAR ESTABLECIMIENTOS DE SALUD (TENANTS)
-- =====================================================================
SET IDENTITY_INSERT Establecimientos ON;

INSERT INTO Establecimientos (EstablecimientoID, CodigoUnico, NombreEstablecimiento, Estado, FechaRegistro)
VALUES 
(1, 'EST-001', 'Administración Central', 'Activo', GETDATE()),
(2, 'EST-002', 'Clínica Dental San Apolonia', 'Activo', GETDATE()),
(3, 'EST-003', 'Centro Médico Pediátrico KidsHealth', 'Activo', GETDATE()),
(4, 'EST-004', 'Hospital Regional del Sur (Inactivo)', 'Suspendido', GETDATE());

SET IDENTITY_INSERT Establecimientos OFF;
GO

-- =====================================================================
-- 3. INSERTAR USUARIOS
-- =====================================================================
SET IDENTITY_INSERT Usuarios ON;

INSERT INTO Usuarios (UsuarioID, EstablecimientoID, NombreCompleto, Email, ContrasenaHash, Estado, Rol)
VALUES 
(1, 1, 'Super Administrador', 'admin@saas.com',   '$2a$11$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'Activo', 'Admin'),
(2, 2, 'Dra. Beatríz Mendoza', 'beatriz@dental.com', '$2a$11$92IXUNpkjO0rOQ5byMi.YeIcqdlRFq.yXV0.82S4eNGjBBstEtXKC', 'Activo', 'User'),
(3, 3, 'Dr. Carlos Pinedo', 'carlos@kidshealth.com', '$2a$11$92IXUNpkjO0rOQ5byMi.YegIwlQVGYOzfYCSOvPX6O9rDGJo4Yj3O', 'Activo', 'User'),
(4, 4, 'Enfermera Sofía Larrea', 'sofia@hospital.com', '$2a$11$92IXUNpkjO0rOQ5byMi.Ye6WL7QJsczKKnxF2qqQkZV9oMHe.UAHS', 'Activo', 'User');

SET IDENTITY_INSERT Usuarios OFF;
GO

-- =====================================================================
-- 4. INSERTAR PACIENTES
-- =====================================================================
SET IDENTITY_INSERT Pacientes ON;

-- Pacientes para Clínica Dental San Apolonia (EstablecimientoID = 2)
INSERT INTO Pacientes (PacienteID, EstablecimientoID, Dni, NombreCompleto, Celular)
VALUES 
(1,  2, '40506070', 'Hernán Oswaldo Quello Huanca', '+51987654321'),
(2,  2, '70809010', 'María Alejandra Torres', '+51912345678'),
(3,  2, '10203040', 'Roberto Carlos Vizcarra', '+51955667788'),
(4,  2, '90807060', 'Lucía Fernanda Beltrán', '+51933221100'),
(5,  2, '44556677', 'Carlos Alberto Ruiz Ramos', '+51944332211'),
(6,  2, '77889900', 'Ana Sofía Benítez Castro', '+51999888777'),
(7,  2, '12345678', 'Jorge Luis Pardo Mendoza', '+51911223344'),
(8,  2, '87654321', 'Elena del Pilar Rivas', '+51988776655'),
(9,  2, '23456789', 'Ricardo Alfonso Peña Soler', '+51922334455'),
(10, 2, '98765432', 'Carmen Rosa Flores Díaz', '+51977665544'),
(11, 2, '34567890', 'Daniel Estefano Ortiz Vega', '+51933445566'),
(12, 2, '45678901', 'Gabriela Inés Prado Silva', '+51944556677');

-- Pacientes para Pediatría KidsHealth (EstablecimientoID = 3)
INSERT INTO Pacientes (PacienteID, EstablecimientoID, Dni, NombreCompleto, Celular)
VALUES 
(13, 3, '50607080', 'Mateo (Padre: Jorge Chávez)', '+51944882211'),
(14, 3, '30405060', 'Valentina (Madre: Diana Ross)', '+51966554433'),
(15, 3, '80901020', 'Santiago (Madre: Inés Melchor)', '+51922883377'),
(16, 3, '55667788', 'Thiago (Padre: Marcos Ramos)', '+51955443322'),
(17, 3, '99001122', 'Mía (Madre: Lucía Domínguez)', '+51911335577'),
(18, 3, '33445566', 'Liam (Padre: Gonzalo Palacios)', '+51922446688'),
(19, 3, '77665544', 'Emma (Madre: Patricia Lujan)', '+51988664422'),
(20, 3, '88990011', 'Lucas (Padre: Alberto Soto)', '+51977553311'),
(21, 3, '11223344', 'Sofía (Madre: Verónica Aguilar)', '+51966442200'),
(22, 3, '22334455', 'Mateo Ignacio (Padre: Renzo Vega)', '+51955331199'),
(23, 3, '66778899', 'Valentina Paz (Madre: Karinna Paz)', '+51944220088');

SET IDENTITY_INSERT Pacientes OFF;
GO

-- =====================================================================
-- 5. INSERTAR PETICIONES DE ENVÍO
-- =====================================================================
SET IDENTITY_INSERT PeticionesEnvio ON;

INSERT INTO PeticionesEnvio (PeticionID, EstablecimientoID, UsuarioID, FechaPeticion, EstadoProceso, FechaFinalizacion)
VALUES 
(1, 2, 2, GETDATE() - 5, 'Completado', GETDATE() - 5),
(2, 2, 2, GETDATE() - 4, 'Completado', GETDATE() - 4),
(3, 2, 2, GETDATE() - 3, 'Completado', GETDATE() - 3),
(4, 2, 2, GETDATE() - 2, 'Completado', GETDATE() - 2),
(5, 2, 2, GETDATE() - 1, 'Completado', GETDATE() - 1),
(6, 2, 2, GETDATE(),     'Completado', GETDATE()),
(7, 3, 3, GETDATE() - 3, 'Completado', GETDATE() - 3),
(8, 3, 3, GETDATE() - 2, 'Completado', GETDATE() - 2),
(9, 3, 3, GETDATE() - 1, 'Completado', GETDATE() - 1),
(10,3, 3, GETDATE(),     'Procesando', NULL);

SET IDENTITY_INSERT PeticionesEnvio OFF;
GO

-- =====================================================================
-- 6. INSERTAR HISTORIAL DE MENSAJES ENVIADOS
-- =====================================================================
SET IDENTITY_INSERT HistorialMensajes ON;

-- Mensajes para Clínica Dental (EstablecimientoID = 2)
INSERT INTO HistorialMensajes (MensajeID, PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino)
VALUES 
(1,  1, 2, 1,  'CITA-101', 'REF-001', 'Odontología General', GETDATE() - 5, GETDATE() - 5, 'Hola Hernán, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA'),
(2,  1, 2, 2,  'CITA-102', 'REF-002', 'Ortodoncia', GETDATE() - 5, GETDATE() - 5, 'Hola María, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA'),
(3,  2, 2, 3,  'CITA-103', 'REF-003', 'Endodoncia', GETDATE() - 4, GETDATE() - 4, 'Hola Roberto, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Error', 'HOSPITAL MARIA AUXILIADORA'),
(4,  2, 2, 4,  'CITA-104', 'REF-004', 'Odontopediatría', GETDATE() - 4, GETDATE() - 4, 'Hola Lucía, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL DE EMERGENCIAS PEDIATRICAS'),
(5,  3, 2, 5,  'CITA-105', 'REF-005', 'Odontología General', GETDATE() - 3, GETDATE() - 3, 'Hola Carlos, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA'),
(6,  3, 2, 6,  'CITA-106', 'REF-006', 'Periodoncia', GETDATE() - 3, GETDATE() - 3, 'Hola Ana Sofía, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL ARZOBISPO LOAYZA'),
(7,  4, 2, 7,  'CITA-107', 'REF-007', 'Ortodoncia', GETDATE() - 2, GETDATE() - 2, 'Hola Jorge Luis, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA'),
(8,  4, 2, 8,  'CITA-108', 'REF-008', 'Endodoncia', GETDATE() - 2, GETDATE() - 2, 'Hola Elena, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA'),
(9,  5, 2, 9,  'CITA-109', 'REF-009', 'Cirugía Maxilofacial', GETDATE() - 1, GETDATE() - 1, 'Hola Ricardo, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL NACIONAL DOS DE MAYO'),
(10, 5, 2, 10, 'CITA-110', 'REF-010', 'Odontología General', GETDATE() - 1, GETDATE() - 1, 'Hola Carmen, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Error', 'HOSPITAL MARIA AUXILIADORA'),
(11, 6, 2, 11, 'CITA-111', 'REF-011', 'Ortodoncia', GETDATE(),     GETDATE(),     'Hola Daniel, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA'),
(12, 6, 2, 12, 'CITA-112', 'REF-012', 'Rehabilitación Oral', GETDATE(),     GETDATE(),     'Hola Gabriela, le recordamos su cita dental hoy en Clinica Dental San Apolonia.', 'Enviado', 'HOSPITAL NACIONAL DOCENTE MADRE NIÑO SAN BARTOLOME');

-- Mensajes para Pediatría KidsHealth (EstablecimientoID = 3)
INSERT INTO HistorialMensajes (MensajeID, PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino)
VALUES 
(13, 7, 3, 13, 'CITA-201', 'REF-201', 'Pediatría de Control', GETDATE() - 3, GETDATE() - 3, 'Hola Jorge, le recordamos la cita de control de Mateo hoy en KidsHealth.', 'Enviado', 'CENTRO DE SALUD MENTAL COMUNITARIO SAN GABRIEL ALTO'),
(14, 7, 3, 14, 'CITA-202', 'REF-202', 'Vacunación', GETDATE() - 3, GETDATE() - 3, 'Hola Diana, le recordamos la cita de vacunación de Valentina hoy en KidsHealth.', 'Enviado', 'CENTRO DE SALUD MENTAL COMUNITARIO SAN GABRIEL ALTO'),
(15, 8, 3, 15, 'CITA-203', 'REF-203', 'Pediatría de Control', GETDATE() - 2, GETDATE() - 2, 'Hola Inés, le recordamos la cita de control de Santiago hoy en KidsHealth.', 'Enviado', 'CENTRO DE SALUD MENTAL COMUNITARIO SAN GABRIEL ALTO'),
(16, 8, 3, 16, 'CITA-204', 'REF-204', 'Nutrición Infantil', GETDATE() - 2, GETDATE() - 2, 'Hola Marcos, le recordamos la cita de nutrición de Thiago hoy en KidsHealth.', 'Enviado', 'CENTRO DE SALUD SAN GABRIEL ALTO'),
(17, 9, 3, 17, 'CITA-205', 'REF-205', 'Pediatría General', GETDATE() - 1, GETDATE() - 1, 'Hola Lucía, le recordamos la cita de Mía hoy en KidsHealth.', 'Enviado', 'HOSPITAL DE EMERGENCIAS VILLA EL SALVADOR'),
(18, 9, 3, 18, 'CITA-206', 'REF-206', 'Vacunación', GETDATE() - 1, GETDATE() - 1, 'Hola Gonzalo, le recordamos la cita de vacunación de Liam hoy en KidsHealth.', 'Error', 'CENTRO DE SALUD MENTAL COMUNITARIO SAN GABRIEL ALTO'),
(19, 9, 3, 19, 'CITA-207', 'REF-207', 'Pediatría General', GETDATE() - 1, GETDATE() - 1, 'Hola Patricia, le recordamos la cita de Emma hoy en KidsHealth.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA');

SET IDENTITY_INSERT HistorialMensajes OFF;
GO