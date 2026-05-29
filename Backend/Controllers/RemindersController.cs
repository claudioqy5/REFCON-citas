using Backend.Models;
using Backend.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text;
using System.Text.Json;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class RemindersController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public RemindersController(AppDbContext context, HttpClient httpClient, IConfiguration configuration)
        {
            _context = context;
            _httpClient = httpClient;
            _configuration = configuration;
        }

        private int GetEstablecimientoID()
        {
            var claim = User.Claims.FirstOrDefault(c => c.Type == "EstablecimientoID");
            return claim != null ? int.Parse(claim.Value) : 0;
        }

        private int GetUsuarioID()
        {
            var claim = User.Claims.FirstOrDefault(c => c.Type == "UsuarioID");
            return claim != null ? int.Parse(claim.Value) : 0;
        }

        [HttpPost("trigger")]
        public async Task<IActionResult> TriggerReminders()
        {
            int establecimientoId = GetEstablecimientoID();
            int usuarioId = GetUsuarioID();

            if (establecimientoId == 0 || usuarioId == 0)
                return Unauthorized();

            // 1. Check if there's already one in progress
            var existingPeticion = await _context.PeticionesEnvio
                .Where(p => p.EstablecimientoID == establecimientoId && (p.EstadoProceso == "Pendiente" || p.EstadoProceso == "Procesando"))
                .FirstOrDefaultAsync();

            if (existingPeticion != null)
            {
                return BadRequest(new { message = "Ya existe un proceso de envío en curso." });
            }

            // 2. Fetch the user credentials
            var activeUser = await _context.Usuarios.FindAsync(usuarioId);
            string? usuarioReferencial = activeUser?.UsuarioReferencial;
            string? claveReferencial = activeUser?.ClaveReferencial;

            var peticion = new PeticionEnvio
            {
                EstablecimientoID = establecimientoId,
                UsuarioID = usuarioId,
                FechaPeticion = DateTime.UtcNow,
                EstadoProceso = "Pendiente"
            };

            _context.PeticionesEnvio.Add(peticion);
            await _context.SaveChangesAsync();

            // 3. Trigger webhook n8n (fire-and-forget con timeout de 15 s)
            var webhookUrl = _configuration["N8nSettings:WebhookUrl"];
            if (!string.IsNullOrEmpty(webhookUrl))
            {
                var payload = new
                {
                    PeticionID = peticion.PeticionID,
                    EstablecimientoID = peticion.EstablecimientoID,
                    UsuarioReferencial = usuarioReferencial,
                    ClaveReferencial = claveReferencial
                };

                var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");
                var peticionId = peticion.PeticionID;
                var establId   = peticion.EstablecimientoID;

                _ = Task.Run(async () =>
                {
                    using var cts = new System.Threading.CancellationTokenSource(TimeSpan.FromSeconds(15));
                    try
                    {
                        var response = await _httpClient.PostAsync(webhookUrl, content, cts.Token);
                        if (!response.IsSuccessStatusCode)
                        {
                            Console.WriteLine($"[n8n] Webhook failed (HTTP {response.StatusCode}) para PeticionID={peticionId}");
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[n8n] Webhook exception para PeticionID={peticionId}: {ex.Message}");
                        // Marcar la petición como Error para que no quede pegada en "Pendiente"
                        try
                        {
                            var pet = await _context.PeticionesEnvio.FindAsync(peticionId);
                            if (pet != null && (pet.EstadoProceso == "Pendiente" || pet.EstadoProceso == "Procesando"))
                            {
                                pet.EstadoProceso     = "Error";
                                pet.MensajeError      = $"No se pudo conectar con n8n: {ex.Message}";
                                pet.EtapaError        = "Conexion_N8n";
                                pet.FechaFinalizacion = DateTime.UtcNow;
                                await _context.SaveChangesAsync();
                            }
                        }
                        catch (Exception dbEx)
                        {
                            Console.WriteLine($"[n8n] Error al actualizar peticion en BD: {dbEx.Message}");
                        }
                    }
                });
            }

            return Ok(new { message = "Envío de recordatorios iniciado.", PeticionID = peticion.PeticionID });

        }

        [HttpGet("status")]
        public async Task<IActionResult> GetStatus()
        {
            int establecimientoId = GetEstablecimientoID();

            var peticion = await _context.PeticionesEnvio
                .Where(p => p.EstablecimientoID == establecimientoId)
                .OrderByDescending(p => p.FechaPeticion)
                .FirstOrDefaultAsync();

            if (peticion == null)
                return Ok(new { estado = "Ninguno", ultimaPeticion = (object?)null });

            return Ok(new
            {
                estado = peticion.EstadoProceso,
                ultimaPeticion = new
                {
                    peticion.PeticionID,
                    peticion.EstadoProceso,
                    peticion.FechaPeticion,
                    peticion.FechaFinalizacion,
                    peticion.TotalPacientesNuevos,
                    peticion.TotalEnviados,
                    peticion.TotalErrores,
                    peticion.MensajeError,
                    peticion.EtapaError
                }
            });
        }

        [HttpGet("history")]
        public async Task<IActionResult> GetHistory()
        {
            int establecimientoId = GetEstablecimientoID();

            var historial = await _context.HistorialMensajes
                .Include(h => h.Paciente)
                .Where(h => h.EstablecimientoID == establecimientoId)
                .OrderByDescending(h => h.FechaHoraEnvio)
                .Select(h => new
                {
                    h.MensajeID,
                    h.PeticionID,
                    PacienteNombre = h.Paciente.NombreCompleto,
                    PacienteDni = h.Paciente.Dni,
                    PacienteCelular = h.Paciente.Celular,
                    h.IdCita,
                    h.Especialidad,
                    h.FechaCita,
                    h.FechaHoraEnvio,
                    h.EstadoEnvio,
                    h.CuerpoMensaje,
                    h.EstablecimientoDestino,
                    h.Consultorio,
                    h.Medico,
                    EstablecimientoNombre = h.Establecimiento.NombreEstablecimiento
                })
                .ToListAsync();

            return Ok(historial);
        }

        [HttpGet("patients")]
        public async Task<IActionResult> GetPatients()
        {
            int establecimientoId = GetEstablecimientoID();
            var patients = await _context.Pacientes
                .Where(p => p.EstablecimientoID == establecimientoId)
                .Select(p => new
                {
                    p.PacienteID,
                    p.Dni,
                    p.NombreCompleto,
                    p.Celular
                })
                .ToListAsync();

            return Ok(patients);
        }

        [HttpGet("settings")]
        public async Task<IActionResult> GetSettings()
        {
            int establecimientoId = GetEstablecimientoID();
            if (establecimientoId == 0) return Unauthorized();

            var establecimiento = await _context.Establecimientos
                .FirstOrDefaultAsync(e => e.EstablecimientoID == establecimientoId);

            if (establecimiento == null) return NotFound();

            return Ok(new { envioAutomatico = establecimiento.EnvioAutomatico });
        }

        [HttpPost("settings")]
        public async Task<IActionResult> UpdateSettings([FromBody] SettingsDto dto)
        {
            int establecimientoId = GetEstablecimientoID();
            if (establecimientoId == 0) return Unauthorized();

            var establecimiento = await _context.Establecimientos
                .FirstOrDefaultAsync(e => e.EstablecimientoID == establecimientoId);

            if (establecimiento == null) return NotFound();

            establecimiento.EnvioAutomatico = dto.EnvioAutomatico;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Configuración actualizada con éxito.", envioAutomatico = establecimiento.EnvioAutomatico });
        }

        [HttpGet("establishment")]
        public async Task<IActionResult> GetEstablishmentName()
        {
            int establecimientoId = GetEstablecimientoID();
            var est = await _context.Establecimientos.FindAsync(establecimientoId);
            if (est == null) return NotFound();
            return Ok(new { name = est.NombreEstablecimiento });
        }

        [HttpPost("log")]
        public async Task<IActionResult> LogMessage([FromBody] SaveHistoryDto dto)
        {
            if (dto == null) return BadRequest("Datos nulos");

            // 1. Resolve or create patient
            var paciente = await _context.Pacientes
                .FirstOrDefaultAsync(p => p.Dni == dto.PacienteDni && p.EstablecimientoID == dto.EstablecimientoID);

            if (paciente == null)
            {
                paciente = new Paciente
                {
                    EstablecimientoID = dto.EstablecimientoID,
                    Dni = dto.PacienteDni,
                    NombreCompleto = dto.PacienteNombre,
                    Celular = dto.PacienteCelular
                };
                _context.Pacientes.Add(paciente);
                await _context.SaveChangesAsync(); // save to get PacienteID
            }
            else
            {
                // Optionally update name/phone if they changed
                bool modified = false;
                if (paciente.NombreCompleto != dto.PacienteNombre) { paciente.NombreCompleto = dto.PacienteNombre; modified = true; }
                if (paciente.Celular != dto.PacienteCelular) { paciente.Celular = dto.PacienteCelular; modified = true; }
                if (modified)
                {
                    _context.Entry(paciente).State = EntityState.Modified;
                }
            }

            // 2. Insert into HistorialMensajes
            var historial = new HistorialMensaje
            {
                PeticionID = dto.PeticionID,
                EstablecimientoID = dto.EstablecimientoID,
                PacienteID = paciente.PacienteID,
                IdCita = dto.IdCita,
                IdReferencia = dto.IdReferencia,
                Especialidad = dto.Especialidad,
                FechaCita = dto.FechaCita,
                FechaHoraEnvio = DateTime.UtcNow,
                CuerpoMensaje = dto.CuerpoMensaje,
                EstadoEnvio = dto.EstadoEnvio,
                EstablecimientoDestino = dto.EstablecimientoDestino,
                Consultorio = dto.Consultorio,
                Medico = dto.Medico
            };

            _context.HistorialMensajes.Add(historial);
            await _context.SaveChangesAsync();

            // Also check if process state is "Pendiente" and update it to "Procesando"
            var peticion = await _context.PeticionesEnvio.FindAsync(dto.PeticionID);
            if (peticion != null && peticion.EstadoProceso == "Pendiente")
            {
                peticion.EstadoProceso = "Procesando";
                _context.Entry(peticion).State = EntityState.Modified;
                await _context.SaveChangesAsync();
            }

            return Ok(new { success = true, mensajeID = historial.MensajeID });
        }

        [HttpPost("complete-process/{id}")]
        public async Task<IActionResult> CompleteProcess(int id, [FromBody] CompleteProcessDto dto)
        {
            var peticion = await _context.PeticionesEnvio.FindAsync(id);
            if (peticion == null) return NotFound("Petición no encontrada");

            peticion.EstadoProceso = dto.EstadoProceso;
            peticion.FechaFinalizacion = DateTime.UtcNow;

            _context.Entry(peticion).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(new { success = true, peticionID = id, estado = peticion.EstadoProceso });
        }

        [HttpGet("credentials")]
        public async Task<IActionResult> GetCredentials()
        {
            int usuarioId = GetUsuarioID();
            if (usuarioId == 0) return Unauthorized();

            var user = await _context.Usuarios.FindAsync(usuarioId);
            if (user == null) return NotFound("Usuario no encontrado");

            return Ok(new
            {
                usuarioReferencial = user.UsuarioReferencial,
                hasPassword = !string.IsNullOrEmpty(user.ClaveReferencial)
            });
        }

        [HttpPost("credentials")]
        public async Task<IActionResult> SaveCredentials([FromBody] SaveCredentialsDto dto)
        {
            int usuarioId = GetUsuarioID();
            if (usuarioId == 0) return Unauthorized();

            if (dto == null) return BadRequest("Datos nulos");

            var user = await _context.Usuarios.FindAsync(usuarioId);
            if (user == null) return NotFound("Usuario no encontrado");

            user.UsuarioReferencial = dto.UsuarioReferencial;
            if (!string.IsNullOrEmpty(dto.ClaveReferencial))
            {
                user.ClaveReferencial = dto.ClaveReferencial;
            }

            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Credenciales de scraping guardadas correctamente." });
        }
    }

    public class SettingsDto
    {
        public bool EnvioAutomatico { get; set; }
    }
}
