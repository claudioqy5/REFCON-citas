using Backend.DTOs;
using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Backend.Controllers
{
    /// <summary>
    /// Endpoints que n8n llama durante su ejecución automática.
    /// NO requieren JWT — están protegidos por X-Api-Key (ApiKey compartida con n8n).
    /// Cada operación filtra siempre por EstablecimientoID → garantía SaaS total.
    /// </summary>
    [Route("api/n8n")]
    [ApiController]
    public class N8nCallbackController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public N8nCallbackController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        // ── Validación de API Key ────────────────────────────────────────────
        private bool ValidateApiKey()
        {
            var expectedKey = _configuration["N8nSettings:ApiKey"];
            if (string.IsNullOrEmpty(expectedKey)) return false;
            Request.Headers.TryGetValue("X-Api-Key", out var providedKey);
            return string.Equals(providedKey, expectedKey, StringComparison.Ordinal);
        }

        // ─────────────────────────────────────────────────────────────────────
        // POST /api/n8n/inicio
        // n8n llama esto como primer paso del flujo.
        // • Si viene del cron (sin peticionId) → crea una PeticionEnvio nueva.
        // • Si viene del frontend (con peticionId) → actualiza la existente.
        // Devuelve el peticionId para que n8n lo use en todos los callbacks siguientes.
        // ─────────────────────────────────────────────────────────────────────
        [HttpPost("inicio")]
        public async Task<IActionResult> Inicio([FromBody] N8nInicioDto dto)
        {
            if (!ValidateApiKey())
                return Unauthorized(new { error = "API Key inválida." });

            PeticionEnvio peticion;

            if (dto.PeticionId.HasValue)
            {
                // Fue disparado desde el frontend, actualizamos la petición existente
                peticion = await _context.PeticionesEnvio
                    .FirstOrDefaultAsync(p => p.PeticionID == dto.PeticionId
                                           && p.EstablecimientoID == dto.EstablecimientoId);

                if (peticion == null)
                    return NotFound(new { error = $"PeticionEnvio ID={dto.PeticionId} no encontrada para EstablecimientoID={dto.EstablecimientoId}." });
            }
            else
            {
                // Fue disparado por el cron (ejecución automática)
                // Validar si el establecimiento tiene habilitado el envío automático
                var establecimiento = await _context.Establecimientos
                    .FirstOrDefaultAsync(e => e.EstablecimientoID == dto.EstablecimientoId);

                if (establecimiento == null || !establecimiento.EnvioAutomatico)
                {
                    // Retornamos procesar = false para que n8n finalice inmediatamente sin hacer nada
                    return Ok(new { peticionId = 0, procesar = false });
                }

                // Crear petición nueva automática
                peticion = new PeticionEnvio
                {
                    EstablecimientoID = dto.EstablecimientoId,
                    UsuarioID = null, // ejecución automática
                    FechaPeticion = DateTime.UtcNow,
                };
                _context.PeticionesEnvio.Add(peticion);
            }

            peticion.EstadoProceso = "Procesando";
            // Solo actualizamos TotalPacientesNuevos cuando el valor viene explícitamente.
            // n8n llama a este endpoint dos veces:
            //   1) Desde "Crear Peticion BD" (sin total) → solo valida/crea la petición.
            //   2) Desde "Actualizar Total Pacientes" (con total real) → guarda el conteo correcto.
            if (dto.TotalPacientesNuevos.HasValue)
                peticion.TotalPacientesNuevos = dto.TotalPacientesNuevos;

            await _context.SaveChangesAsync();

            return Ok(new { peticionId = peticion.PeticionID, procesar = true });
        }

        // ─────────────────────────────────────────────────────────────────────
        // GET /api/n8n/enviados?establecimientoId=X
        // Devuelve todos los IdCita ya registrados para ese establecimiento.
        // n8n usa esta lista para filtrar los pacientes nuevos (anti-duplicados).
        // REEMPLAZA la consulta a Google Sheets del flujo original.
        // Aislamiento SaaS: cada establecimiento solo ve sus propios IdCita.
        // ─────────────────────────────────────────────────────────────────────
        [HttpGet("enviados")]
        public async Task<IActionResult> GetEnviados([FromQuery] int establecimientoId)
        {
            if (!ValidateApiKey())
                return Unauthorized(new { error = "API Key inválida." });

            if (establecimientoId == 0)
                return BadRequest(new { error = "establecimientoId es requerido." });

            var idsEnviados = await _context.HistorialMensajes
                .Where(h => h.EstablecimientoID == establecimientoId)
                .Select(h => h.IdCita)
                .Distinct()
                .ToListAsync();

            // Devuelto en objeto { ids: [...] } para acceso seguro en n8n
            return Ok(new { ids = idsEnviados });
        }

        // ─────────────────────────────────────────────────────────────────────
        // POST /api/n8n/progreso
        // n8n llama esto después de cada mensaje enviado (éxito O error).
        // • Busca o crea el Paciente por DNI + EstablecimientoID (tenant isolation).
        // • Registra el resultado en HistorialMensajes.
        // • Incrementa los contadores (TotalEnviados / TotalErrores) en PeticionEnvio.
        // ─────────────────────────────────────────────────────────────────────
        [HttpPost("progreso")]
        public async Task<IActionResult> Progreso([FromBody] N8nProgresoDto dto)
        {
            if (!ValidateApiKey())
                return Unauthorized(new { error = "API Key inválida." });

            // 1. Verificar que la petición pertenece a este establecimiento (tenant check)
            var peticion = await _context.PeticionesEnvio
                .FirstOrDefaultAsync(p => p.PeticionID == dto.PeticionId
                                       && p.EstablecimientoID == dto.EstablecimientoId);

            if (peticion == null)
                return NotFound(new { error = $"PeticionEnvio ID={dto.PeticionId} no pertenece al EstablecimientoID={dto.EstablecimientoId}." });

            // 2. Buscar o crear el paciente (siempre filtrado por EstablecimientoID)
            var paciente = await _context.Pacientes
                .FirstOrDefaultAsync(p => p.EstablecimientoID == dto.EstablecimientoId
                                       && p.Dni == dto.Dni);

            if (paciente == null)
            {
                paciente = new Paciente
                {
                    EstablecimientoID = dto.EstablecimientoId,
                    Dni = dto.Dni,
                    NombreCompleto = dto.NombrePaciente?.Trim() ?? "---",
                    Celular = dto.Celular ?? "---"
                };
                _context.Pacientes.Add(paciente);
                await _context.SaveChangesAsync(); // necesario para obtener PacienteID
            }
            else
            {
                // Actualizar nombre/celular si cambió en REFCON
                paciente.NombreCompleto = dto.NombrePaciente?.Trim() ?? paciente.NombreCompleto;
                paciente.Celular = dto.Celular ?? paciente.Celular;
            }

            // 3. Parsear la fecha de cita (REFCON la envía como "dd/MM/yyyy HH:mm" o similar)
            DateTime fechaCita = DateTime.MinValue;
            if (!string.IsNullOrWhiteSpace(dto.FechaCita))
            {
                var formatos = new[] { "dd/MM/yyyy HH:mm", "dd/MM/yyyy", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd" };
                DateTime.TryParseExact(dto.FechaCita, formatos,
                    System.Globalization.CultureInfo.InvariantCulture,
                    System.Globalization.DateTimeStyles.None, out fechaCita);
            }

            // 4. Registrar en HistorialMensajes
            var historial = new HistorialMensaje
            {
                PeticionID        = dto.PeticionId,
                EstablecimientoID = dto.EstablecimientoId,
                PacienteID        = paciente.PacienteID,
                IdCita            = dto.IdCita,
                IdReferencia      = dto.IdReferencia,
                Especialidad      = dto.Especialidad ?? "---",
                FechaCita         = fechaCita,
                FechaHoraEnvio    = DateTime.UtcNow,
                CuerpoMensaje     = dto.CuerpoMensaje ?? "",
                EstadoEnvio       = dto.EstadoEnvio,
                EstablecimientoDestino = dto.EstablecimientoDestino,
                Consultorio       = dto.Consultorio,
                Medico            = dto.Medico
            };
            _context.HistorialMensajes.Add(historial);

            // 5. Actualizar contadores en la petición
            if (dto.EstadoEnvio == "Enviado")
                peticion.TotalEnviados = (peticion.TotalEnviados ?? 0) + 1;
            else
                peticion.TotalErrores = (peticion.TotalErrores ?? 0) + 1;

            await _context.SaveChangesAsync();

            return Ok(new { registrado = true, mensajeId = historial.MensajeID });
        }

        // ─────────────────────────────────────────────────────────────────────
        // POST /api/n8n/completado
        // n8n llama esto cuando el loop de Split In Batches termina (todos procesados).
        // Marca la PeticionEnvio como "Completado".
        // ─────────────────────────────────────────────────────────────────────
        [HttpPost("completado")]
        public async Task<IActionResult> Completado([FromBody] N8nCompletadoDto dto)
        {
            if (!ValidateApiKey())
                return Unauthorized(new { error = "API Key inválida." });

            var peticion = await _context.PeticionesEnvio
                .FirstOrDefaultAsync(p => p.PeticionID == dto.PeticionId
                                       && p.EstablecimientoID == dto.EstablecimientoId);

            if (peticion == null) return NotFound();

            peticion.EstadoProceso    = "Completado";
            peticion.FechaFinalizacion = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new { estado = "Completado" });
        }

        // ─────────────────────────────────────────────────────────────────────
        // POST /api/n8n/error
        // n8n llama esto cuando ocurre un error en una etapa crítica del flujo.
        // Etapa "SinPacientes" no es error real — se guarda con ese estado especial.
        // ─────────────────────────────────────────────────────────────────────
        [HttpPost("error")]
        public async Task<IActionResult> Error([FromBody] N8nErrorDto dto)
        {
            if (!ValidateApiKey())
                return Unauthorized(new { error = "API Key inválida." });

            var peticion = await _context.PeticionesEnvio
                .FirstOrDefaultAsync(p => p.PeticionID == dto.PeticionId
                                       && p.EstablecimientoID == dto.EstablecimientoId);

            if (peticion == null) return NotFound();

            // "SinPacientes" es informativo, no un error del sistema
            peticion.EstadoProceso    = dto.Etapa == "SinPacientes" ? "SinPacientes" : "Error";
            peticion.MensajeError     = dto.Mensaje;
            peticion.EtapaError       = dto.Etapa;
            peticion.FechaFinalizacion = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new { registrado = true });
        }
    }
}
