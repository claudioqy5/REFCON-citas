const fs = require('fs');
const { parse } = require('csv-parse/sync');

try {
    const fileContent = fs.readFileSync('historial.csv', 'utf8');
    const records = parse(fileContent, {
      columns: true,
      skip_empty_lines: true,
      relax_quotes: true
    });

    let sql = `
-- Script de migracion de historial
USE SistemaRecordatoriosSaaS;
GO

-- Asegurar que existe la Peticion 1 y Establecimiento 5
IF NOT EXISTS (SELECT 1 FROM PeticionesEnvio WHERE PeticionID = 1)
BEGIN
    SET IDENTITY_INSERT PeticionesEnvio ON;
    INSERT INTO PeticionesEnvio (PeticionID, EstablecimientoID, UsuarioID, ArchivoOriginal, TotalRegistros, EstadoProceso, FechaSubida) 
    VALUES (1, 5, 5, 'historial_3_meses.csv', ${records.length}, 'Completado', GETDATE());
    SET IDENTITY_INSERT PeticionesEnvio OFF;
END
GO
`;

    let pacientes = {};

    for(const row of records) {
       let dni = row['DNI'] ? row['DNI'].trim() : '';
       let nombre = row['Paciente'] ? row['Paciente'].replace(/'/g, "''").trim() : '';
       let celular = row['Celular'] ? row['Celular'].trim() : '';
       
       if (dni !== '' && !pacientes[dni]) {
           pacientes[dni] = true;
           sql += `
IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE Dni = '${dni}')
BEGIN
    INSERT INTO Pacientes (EstablecimientoID, Dni, NombreCompleto, Celular) VALUES (5, '${dni}', '${nombre}', '${celular}');
END
`;
       }
    }

    sql += `\nGO\n`;

    for(const row of records) {
       let idcita = row['idcita'] ? row['idcita'].replace(/'/g, "''").trim() : '';
       let idRef = row['IdReferencia'] ? row['IdReferencia'].replace(/'/g, "''").trim() : '';
       let dni = row['DNI'] ? row['DNI'].trim() : '';
       let dest = row['Establecimiento de destino'] ? row['Establecimiento de destino'].replace(/'/g, "''").trim() : '';
       let esp = row['especialidad'] ? row['especialidad'].replace(/'/g, "''").trim() : '';
       let fCita = row['fechacita'] ? row['fechacita'].trim() : '';
       let fEnvio = row['fecha_hora_envio'] ? row['fecha_hora_envio'].trim() : '';
       let msg = row['mensaje_enviado'] ? row['mensaje_enviado'].replace(/'/g, "''").trim() : '';
       let estado = row['estado_envio'] ? row['estado_envio'].replace(/'/g, "''").trim() : 'Enviado';

       if(dni !== '') {
           sql += `
INSERT INTO HistorialMensajes (PeticionID, EstablecimientoID, PacienteID, IdCita, IdReferencia, Especialidad, FechaCita, FechaHoraEnvio, CuerpoMensaje, EstadoEnvio, EstablecimientoDestino)
SELECT 1, 5, PacienteID, '${idcita}', '${idRef}', '${esp}', CONVERT(datetime, '${fCita}', 103), CONVERT(datetime, '${fEnvio}', 120), '${msg}', '${estado}', '${dest}'
FROM Pacientes WHERE Dni = '${dni}';
`;
       }
    }

    fs.writeFileSync('migracion_historial.sql', sql);
    console.log("¡Archivo migracion_historial.sql generado con éxito!");

} catch (e) {
    console.error("Error procesando CSV:", e);
}
