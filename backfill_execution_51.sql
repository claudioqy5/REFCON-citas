
-- Script de insercion manual para PeticionID = 51 y EstablecimientoID = 5
USE SistemaRecordatoriosSaaS;
GO

-- Asegurar que la peticion exista y este en estado correcto
IF EXISTS (SELECT 1 FROM PeticionesEnvio WHERE PeticionID = 51)
BEGIN
    UPDATE PeticionesEnvio 
    SET EstadoProceso = 'Completado', 
        TotalPacientesNuevos = 33, 
        TotalEnviados = 33, 
        TotalErrores = 0,
        FechaFinalizacion = GETUTCDATE()
    WHERE PeticionID = 51;
END
ELSE
BEGIN
    SET IDENTITY_INSERT PeticionesEnvio ON;
    INSERT INTO PeticionesEnvio (PeticionID, EstablecimientoID, UsuarioID, EstadoProceso, TotalPacientesNuevos, TotalEnviados, TotalErrores, FechaPeticion, FechaFinalizacion)
    VALUES (51, 5, 5, 'Completado', 33, 33, 0, GETUTCDATE(), GETUTCDATE());
    SET IDENTITY_INSERT PeticionesEnvio OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07427062')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '07427062', 'CELEDONIA ORTIZ CONDOR', '987816435');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'CELEDONIA ORTIZ CONDOR', Celular = '987816435'
    WHERE EstablecimientoID = 5 AND Dni = '07427062';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08955670')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08955670', 'MACEDONIO MARTINEZ LOPEZ', '915929766');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'MACEDONIO MARTINEZ LOPEZ', Celular = '915929766'
    WHERE EstablecimientoID = 5 AND Dni = '08955670';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09104674')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09104674', 'HUGO JUAN LIZARBE DELZO', '956285748');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'HUGO JUAN LIZARBE DELZO', Celular = '956285748'
    WHERE EstablecimientoID = 5 AND Dni = '09104674';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07836121')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '07836121', 'ROSALINA MARIA FAJARDO TRILLO', '922913012');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'ROSALINA MARIA FAJARDO TRILLO', Celular = '922913012'
    WHERE EstablecimientoID = 5 AND Dni = '07836121';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09947370')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09947370', 'ZENON PONCE YACAVILCA', '916775676');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'ZENON PONCE YACAVILCA', Celular = '916775676'
    WHERE EstablecimientoID = 5 AND Dni = '09947370';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09264002')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09264002', 'ORTIZ VICTOR REYES ZANABRIA', '991152853');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'ORTIZ VICTOR REYES ZANABRIA', Celular = '991152853'
    WHERE EstablecimientoID = 5 AND Dni = '09264002';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '80348124')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '80348124', 'OTILIA HERRERA DELGADO', '927399141');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'OTILIA HERRERA DELGADO', Celular = '927399141'
    WHERE EstablecimientoID = 5 AND Dni = '80348124';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08967521')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08967521', 'BERNARDINA CUTIPA SUCASAIRE', '979327151');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'BERNARDINA CUTIPA SUCASAIRE', Celular = '979327151'
    WHERE EstablecimientoID = 5 AND Dni = '08967521';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '02023314')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '02023314', 'PABLO OTAZU QUISPE', '930416738');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'PABLO OTAZU QUISPE', Celular = '930416738'
    WHERE EstablecimientoID = 5 AND Dni = '02023314';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09002422')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09002422', 'TOMASA HUAYHUAS TACURI', '981229460');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'TOMASA HUAYHUAS TACURI', Celular = '981229460'
    WHERE EstablecimientoID = 5 AND Dni = '09002422';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08971371')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08971371', 'REGINA CHAHUILLCO MANCO DE CCENTE', '934426713');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'REGINA CHAHUILLCO MANCO DE CCENTE', Celular = '934426713'
    WHERE EstablecimientoID = 5 AND Dni = '08971371';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09105171')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09105171', 'PAULINA MONDALGO REYMUNDO', '937401249');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'PAULINA MONDALGO REYMUNDO', Celular = '937401249'
    WHERE EstablecimientoID = 5 AND Dni = '09105171';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '19982242')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '19982242', 'VICTORIA FLORES DELSO', '951320654');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'VICTORIA FLORES DELSO', Celular = '951320654'
    WHERE EstablecimientoID = 5 AND Dni = '19982242';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09268237')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09268237', 'INES ALEJANDRINA AVILA RETAMOZO', '922939388');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'INES ALEJANDRINA AVILA RETAMOZO', Celular = '922939388'
    WHERE EstablecimientoID = 5 AND Dni = '09268237';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09108356')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09108356', 'VICTOR PEREZ ROJAS', '944940640');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'VICTOR PEREZ ROJAS', Celular = '944940640'
    WHERE EstablecimientoID = 5 AND Dni = '09108356';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09068245')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09068245', 'AUREA MEDRANO VASQUEZ', '932716077');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'AUREA MEDRANO VASQUEZ', Celular = '932716077'
    WHERE EstablecimientoID = 5 AND Dni = '09068245';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08991123')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08991123', 'JUANA RUPERTA ALVAREZ ALVARO', '923728917');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'JUANA RUPERTA ALVAREZ ALVARO', Celular = '923728917'
    WHERE EstablecimientoID = 5 AND Dni = '08991123';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09264761')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09264761', 'EUSEBIA MAGDALENA GUZMAN BUENDIA', '983775185');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'EUSEBIA MAGDALENA GUZMAN BUENDIA', Celular = '983775185'
    WHERE EstablecimientoID = 5 AND Dni = '09264761';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '10102672')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '10102672', 'JUAN VILLEGAS FERNANDEZ', '941501241');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'JUAN VILLEGAS FERNANDEZ', Celular = '941501241'
    WHERE EstablecimientoID = 5 AND Dni = '10102672';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09009765')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09009765', 'MARIA ANGELICA JARA DUEÑAS', '981511725');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'MARIA ANGELICA JARA DUEÑAS', Celular = '981511725'
    WHERE EstablecimientoID = 5 AND Dni = '09009765';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08782977')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08782977', 'SIMONA LAGO GONZALES', '902078450');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'SIMONA LAGO GONZALES', Celular = '902078450'
    WHERE EstablecimientoID = 5 AND Dni = '08782977';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07798691')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '07798691', 'TEMOTEA RAMIREZ GONZALES', '914926958');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'TEMOTEA RAMIREZ GONZALES', Celular = '914926958'
    WHERE EstablecimientoID = 5 AND Dni = '07798691';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08954122')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08954122', 'JAIME AQUILINO ANYOSA SIN DATOS', '947825506');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'JAIME AQUILINO ANYOSA SIN DATOS', Celular = '947825506'
    WHERE EstablecimientoID = 5 AND Dni = '08954122';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07806876')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '07806876', 'FELICITAS ZARATE CASTILLA', '935559749');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'FELICITAS ZARATE CASTILLA', Celular = '935559749'
    WHERE EstablecimientoID = 5 AND Dni = '07806876';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09264531')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09264531', 'ANGELICA UCEDA GAUNA', '934937390');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'ANGELICA UCEDA GAUNA', Celular = '934937390'
    WHERE EstablecimientoID = 5 AND Dni = '09264531';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09113746')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09113746', 'FLORENTINO GONZALO PEREZ CACERES', '936515696');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'FLORENTINO GONZALO PEREZ CACERES', Celular = '936515696'
    WHERE EstablecimientoID = 5 AND Dni = '09113746';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09114947')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09114947', 'SABINO CRISPIN CAPCHA CHIPANA', '923370386');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'SABINO CRISPIN CAPCHA CHIPANA', Celular = '923370386'
    WHERE EstablecimientoID = 5 AND Dni = '09114947';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09005060')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09005060', 'SUSANA BALDERRAMA ANTICONA', '924567370');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'SUSANA BALDERRAMA ANTICONA', Celular = '924567370'
    WHERE EstablecimientoID = 5 AND Dni = '09005060';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09265448')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '09265448', 'DOMINGA HUILLCA CHOQUE VDA DE QUISPE', '960119441');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'DOMINGA HUILLCA CHOQUE VDA DE QUISPE', Celular = '960119441'
    WHERE EstablecimientoID = 5 AND Dni = '09265448';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '20592360')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '20592360', 'TARCILA ERMINIA ZACARIAS TORRES', '991487864');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'TARCILA ERMINIA ZACARIAS TORRES', Celular = '991487864'
    WHERE EstablecimientoID = 5 AND Dni = '20592360';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '31160748')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '31160748', 'FABIANA CHIPANA DE AYQUIPA', '947239389');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'FABIANA CHIPANA DE AYQUIPA', Celular = '947239389'
    WHERE EstablecimientoID = 5 AND Dni = '31160748';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08933527')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08933527', 'JUSTA MENDOZA CAYO', '995840666');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'JUSTA MENDOZA CAYO', Celular = '995840666'
    WHERE EstablecimientoID = 5 AND Dni = '08933527';
END

IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08954319')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular)
    VALUES (5, '08954319', 'ANTERO ARCIDIO HERNANDEZ MALCA', '912737326');
END
ELSE
BEGIN
    UPDATE Pacientes
    SET NombreCompleto = 'ANTERO ARCIDIO HERNANDEZ MALCA', Celular = '912737326'
    WHERE EstablecimientoID = 5 AND Dni = '08954319';
END

GO

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30824631')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30824631', '30470852', 'OTORRINOLARINGOLOGÍA', CONVERT(datetime, '10/08/2026 09:00:00', 103), GETUTCDATE(), 'Hola C. ORTIZ, le recordamos su cita de OTORRINOLARINGOLOGÍA en HOSPITAL MARIA AUXILIADORA el 10/08/2026 09:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'DELGADO PONCE CARLOS FERNANDO'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07427062';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30793032')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30793032', '30439766', 'PSIQUIATRÍA', CONVERT(datetime, '11/06/2026 08:20:00', 103), GETUTCDATE(), 'Hola M. MARTINEZ, le recordamos su cita de PSIQUIATRÍA en CENTRO DE SALUD MENTAL COMUNITARIO SAN GABRIEL ALTO el 11/06/2026 08:20:00.', 'Enviado', 'CENTRO DE SALUD MENTAL COMUNITARIO SAN GABRIEL ALTO', 'INTEGRAL ADULTO Y ADULTO MAYOR', 'GOMEZ VASQUEZ JUDITH'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08955670';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30791417')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30791417', '30438176', 'NEFROLOGÍA', CONVERT(datetime, '30/06/2026 07:00:00', 103), GETUTCDATE(), 'Hola H. LIZARBE, le recordamos su cita de NEFROLOGÍA en HOSPITAL MARIA AUXILIADORA el 30/06/2026 07:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'DIAZ ARMAS JOSE WILDER'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09104674';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30772868')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30772868', '30419875', 'OTORRINOLARINGOLOGÍA', CONVERT(datetime, '13/08/2026 09:00:00', 103), GETUTCDATE(), 'Hola R. FAJARDO, le recordamos su cita de OTORRINOLARINGOLOGÍA en HOSPITAL MARIA AUXILIADORA el 13/08/2026 09:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'VASQUEZ DIAZ DENNIS'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07836121';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30737519')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30737519', '30385019', 'OFTALMOLOGÍA', CONVERT(datetime, '10/06/2026 09:00:00', 103), GETUTCDATE(), 'Hola Z. PONCE, le recordamos su cita de OFTALMOLOGÍA en CENTRO MATERNO INFANTIL DANIEL ALCIDES CARRION el 10/06/2026 09:00:00.', 'Enviado', 'CENTRO MATERNO INFANTIL DANIEL ALCIDES CARRION', 'OFTALMOLOGIA 1', 'RODRIGUEZ DOMINGUEZ LUIS ALBERTO'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09947370';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30729120')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30729120', '30376737', 'RADIODIAGNÓSTICO', CONVERT(datetime, '11/06/2026 15:30:00', 103), GETUTCDATE(), 'Hola O. REYES, le recordamos su cita de RADIODIAGNÓSTICO en CENTRO DE SALUD JESUS PODEROSO el 11/06/2026 15:30:00.', 'Enviado', 'CENTRO DE SALUD JESUS PODEROSO', 'ECOGRAFIA', 'AVILA CRUZ MONICA CAROLINA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09264002';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30728363')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30728363', '30375991', 'OTORRINOLARINGOLOGÍA', CONVERT(datetime, '12/08/2026 09:00:00', 103), GETUTCDATE(), 'Hola O. HERRERA, le recordamos su cita de OTORRINOLARINGOLOGÍA en HOSPITAL MARIA AUXILIADORA el 12/08/2026 09:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'FELIPE YOPLAC KATIA LUCERO'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '80348124';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30705456')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30705456', '30353480', 'OTORRINOLARINGOLOGÍA', CONVERT(datetime, '19/08/2026 08:00:00', 103), GETUTCDATE(), 'Hola B. CUTIPA, le recordamos su cita de OTORRINOLARINGOLOGÍA en HOSPITAL MARIA AUXILIADORA el 19/08/2026 08:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'REYES APARCANA KARIN MARLENE'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08967521';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30705201')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30705201', '30353233', 'NEUROLOGÍA', CONVERT(datetime, '30/07/2026 08:40:00', 103), GETUTCDATE(), 'Hola P. OTAZU, le recordamos su cita de NEUROLOGÍA en HOSPITAL MARIA AUXILIADORA el 30/07/2026 08:40:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'TAPIA CASTAÑEDA ROGER'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '02023314';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30700113')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30700113', '30348245', 'NEUROLOGÍA', CONVERT(datetime, '22/07/2026 14:00:00', 103), GETUTCDATE(), 'Hola T. HUAYHUAS, le recordamos su cita de NEUROLOGÍA en HOSPITAL MARIA AUXILIADORA el 22/07/2026 14:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'WONG ARMAS JORGE LUIS'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09002422';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30697810')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30697810', '30345978', 'REUMATOLOGÍA', CONVERT(datetime, '23/06/2026 15:45:00', 103), GETUTCDATE(), 'Hola R. CHAHUILLCO, le recordamos su cita de REUMATOLOGÍA en HOSPITAL MARIA AUXILIADORA el 23/06/2026 15:45:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'ZUTA SANTILLAN ADOLFINA ELIZABETH'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08971371';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30697269')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30697269', '30345444', 'REUMATOLOGÍA', CONVERT(datetime, '04/07/2026 08:00:00', 103), GETUTCDATE(), 'Hola P. MONDALGO, le recordamos su cita de REUMATOLOGÍA en HOSPITAL MARIA AUXILIADORA el 04/07/2026 08:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'HUAMAN ROSALES MIRIAM ROSABEL'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09105171';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30695574')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30695574', '30343793', 'RADIODIAGNÓSTICO', CONVERT(datetime, '11/06/2026 13:15:00', 103), GETUTCDATE(), 'Hola V. FLORES, le recordamos su cita de RADIODIAGNÓSTICO en CENTRO DE SALUD JESUS PODEROSO el 11/06/2026 13:15:00.', 'Enviado', 'CENTRO DE SALUD JESUS PODEROSO', 'ECOGRAFIA', 'AVILA CRUZ MONICA CAROLINA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '19982242';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30695040')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30695040', '30343262', 'NEUROLOGÍA', CONVERT(datetime, '31/07/2026 09:00:00', 103), GETUTCDATE(), 'Hola I. AVILA, le recordamos su cita de NEUROLOGÍA en HOSPITAL MARIA AUXILIADORA el 31/07/2026 09:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'VALDERRAMA TORRES RENE EDUARDO'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09268237';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30611576')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30611576', '30261096', 'NEUROCIRUGÍA', CONVERT(datetime, '17/07/2026 14:00:00', 103), GETUTCDATE(), 'Hola V. PEREZ, le recordamos su cita de NEUROCIRUGÍA en HOSPITAL MARIA AUXILIADORA el 17/07/2026 14:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'ALEJO CHARAJA SAUL ALEX'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09108356';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30606964')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30606964', '30256537', 'ENDOCRINOLOGÍA', CONVERT(datetime, '11/08/2026 09:00:00', 103), GETUTCDATE(), 'Hola A. MEDRANO, le recordamos su cita de ENDOCRINOLOGÍA en HOSPITAL MARIA AUXILIADORA el 11/08/2026 09:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'CRUZ ESTACIO DELIA VIRGINIA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09068245';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30588311')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30588311', '30238144', 'RADIODIAGNÓSTICO', CONVERT(datetime, '25/06/2026 11:50:00', 103), GETUTCDATE(), 'Hola J. ALVAREZ, le recordamos su cita de RADIODIAGNÓSTICO en CENTRO DE SALUD VILLA SAN LUIS el 25/06/2026 11:50:00.', 'Enviado', 'CENTRO DE SALUD VILLA SAN LUIS', 'ECOGRAFIA 01', 'CONILLA ARISPE JOSE MAYCOL'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08991123';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30588039')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30588039', '30237884', 'DERMATOLOGÍA', CONVERT(datetime, '22/07/2026 08:15:00', 103), GETUTCDATE(), 'Hola E. GUZMAN, le recordamos su cita de DERMATOLOGÍA en HOSPITAL MARIA AUXILIADORA el 22/07/2026 08:15:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'VERA CORNEJO CECILIA MERCEDES'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09264761';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30584319')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30584319', '30234223', 'RADIODIAGNÓSTICO', CONVERT(datetime, '20/06/2026 05:50:00', 103), GETUTCDATE(), 'Hola J. VILLEGAS, le recordamos su cita de RADIODIAGNÓSTICO en CENTRO DE SALUD VILLA SAN LUIS el 20/06/2026 05:50:00.', 'Enviado', 'CENTRO DE SALUD VILLA SAN LUIS', 'ECOGRAFIA 01', 'CONILLA ARISPE JOSE MAYCOL'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '10102672';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30576080')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30576080', '30226097', 'ENDOCRINOLOGÍA', CONVERT(datetime, '05/08/2026 09:15:00', 103), GETUTCDATE(), 'Hola M. JARA, le recordamos su cita de ENDOCRINOLOGÍA en HOSPITAL MARIA AUXILIADORA el 05/08/2026 09:15:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'CRUZ ESTACIO DELIA VIRGINIA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09009765';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30565556')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30565556', '30215699', 'RADIODIAGNÓSTICO', CONVERT(datetime, '11/06/2026 15:00:00', 103), GETUTCDATE(), 'Hola S. LAGO, le recordamos su cita de RADIODIAGNÓSTICO en CENTRO DE SALUD JESUS PODEROSO el 11/06/2026 15:00:00.', 'Enviado', 'CENTRO DE SALUD JESUS PODEROSO', 'ECOGRAFIA', 'AVILA CRUZ MONICA CAROLINA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08782977';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30564050')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30564050', '30214206', 'CIRUGÍA GENERAL', CONVERT(datetime, '10/07/2026 08:15:00', 103), GETUTCDATE(), 'Hola T. RAMIREZ, le recordamos su cita de CIRUGÍA GENERAL en HOSPITAL MARIA AUXILIADORA el 10/07/2026 08:15:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'RUIZ MEZA OSCAR'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07798691';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30563816')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30563816', '30213976', 'RADIODIAGNÓSTICO', CONVERT(datetime, '13/06/2026 15:15:00', 103), GETUTCDATE(), 'Hola J. ANYOSA, le recordamos su cita de RADIODIAGNÓSTICO en CENTRO DE SALUD JESUS PODEROSO el 13/06/2026 15:15:00.', 'Enviado', 'CENTRO DE SALUD JESUS PODEROSO', 'ECOGRAFIA', 'AVILA CRUZ MONICA CAROLINA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08954122';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30424720')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30424720', '30076985', 'NEUMOLOGÍA', CONVERT(datetime, '10/06/2026 08:00:00', 103), GETUTCDATE(), 'Hola F. ZARATE, le recordamos su cita de NEUMOLOGÍA en HOSPITAL MARIA AUXILIADORA el 10/06/2026 08:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'LOAYZA SALAZAR VANESSA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '07806876';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30423797')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30423797', '30076082', 'ENDOCRINOLOGÍA', CONVERT(datetime, '05/08/2026 14:00:00', 103), GETUTCDATE(), 'Hola A. UCEDA, le recordamos su cita de ENDOCRINOLOGÍA en HOSPITAL MARIA AUXILIADORA el 05/08/2026 14:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'CISNEROS PACHECO DORA SUSANA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09264531';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30405482')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30405482', '30058053', 'CARDIOLOGÍA', CONVERT(datetime, '10/07/2026 08:15:00', 103), GETUTCDATE(), 'Hola F. PEREZ, le recordamos su cita de CARDIOLOGÍA en HOSPITAL MARIA AUXILIADORA el 10/07/2026 08:15:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'PENA PERRET DE FONSECA CECILIA CLEMENCIA LIBE'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09113746';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30392037')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30392037', '30044894', 'TRAUMATOLOGÍA Y ORTOPEDIA', CONVERT(datetime, '25/07/2026 07:30:00', 103), GETUTCDATE(), 'Hola S. CAPCHA, le recordamos su cita de TRAUMATOLOGÍA Y ORTOPEDIA en HOSPITAL MARIA AUXILIADORA el 25/07/2026 07:30:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'CHAMBILLA OSCO GANDI FRAN'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09114947';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30381685')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30381685', '30034666', 'ENDOCRINOLOGÍA', CONVERT(datetime, '07/08/2026 14:00:00', 103), GETUTCDATE(), 'Hola S. BALDERRAMA, le recordamos su cita de ENDOCRINOLOGÍA en HOSPITAL MARIA AUXILIADORA el 07/08/2026 14:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'CRUZ ESTACIO DELIA VIRGINIA'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09005060';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30381569')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30381569', '30034554', 'TRAUMATOLOGÍA Y ORTOPEDIA', CONVERT(datetime, '13/07/2026 14:15:00', 103), GETUTCDATE(), 'Hola D. HUILLCA, le recordamos su cita de TRAUMATOLOGÍA Y ORTOPEDIA en HOSPITAL MARIA AUXILIADORA el 13/07/2026 14:15:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'ELIAS CANTAFIO LUIS FELIPE'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '09265448';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30380726')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30380726', '30033738', 'TRAUMATOLOGÍA Y ORTOPEDIA', CONVERT(datetime, '06/07/2026 15:00:00', 103), GETUTCDATE(), 'Hola T. ZACARIAS, le recordamos su cita de TRAUMATOLOGÍA Y ORTOPEDIA en HOSPITAL MARIA AUXILIADORA el 06/07/2026 15:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'CABEZAS DAVALOS ENGILVERO EVERARDO'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '20592360';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30366825')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30366825', '30020067', 'TRAUMATOLOGÍA Y ORTOPEDIA', CONVERT(datetime, '16/07/2026 08:45:00', 103), GETUTCDATE(), 'Hola F. CHIPANA, le recordamos su cita de TRAUMATOLOGÍA Y ORTOPEDIA en HOSPITAL MARIA AUXILIADORA el 16/07/2026 08:45:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'REYES MAYAUTE HENRY NELSON'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '31160748';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30231665')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30231665', '29886744', 'CARDIOLOGÍA', CONVERT(datetime, '03/07/2026 08:00:00', 103), GETUTCDATE(), 'Hola J. MENDOZA, le recordamos su cita de CARDIOLOGÍA en HOSPITAL MARIA AUXILIADORA el 03/07/2026 08:00:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'VALDEZ RAMOS MIRIAM MILAGROS'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08933527';
END

IF NOT EXISTS (SELECT 1 FROM HistorialMensajes WHERE EstablecimientoID = 5 AND IdCita = '30172012')
BEGIN
    INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino, Consultorio, Medico)
    SELECT 51, 5, PacienteID, '30172012', '29827873', 'CARDIOLOGÍA', CONVERT(datetime, '01/07/2026 14:30:00', 103), GETUTCDATE(), 'Hola A. HERNANDEZ, le recordamos su cita de CARDIOLOGÍA en HOSPITAL MARIA AUXILIADORA el 01/07/2026 14:30:00.', 'Enviado', 'HOSPITAL MARIA AUXILIADORA', 'CONSULTORIO1', 'PARRA GALVAN JOSE ALEJANDRO'
    FROM Pacientes WHERE EstablecimientoID = 5 AND Dni = '08954319';
END

GO
