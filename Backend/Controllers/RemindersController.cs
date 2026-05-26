using Backend.Models;
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

            // 2. Create PeticionEnvio
            var peticion = new PeticionEnvio
            {
                EstablecimientoID = establecimientoId,
                UsuarioID = usuarioId,
                FechaPeticion = DateTime.UtcNow,
                EstadoProceso = "Pendiente"
            };

            _context.PeticionesEnvio.Add(peticion);
            await _context.SaveChangesAsync();

            // 3. Trigger webhook n8n
            var webhookUrl = _configuration["N8nSettings:WebhookUrl"];
            if (!string.IsNullOrEmpty(webhookUrl))
            {
                var payload = new
                {
                    PeticionID = peticion.PeticionID,
                    EstablecimientoID = peticion.EstablecimientoID
                };

                var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

                // Start fire-and-forget webhook call
                _ = Task.Run(async () =>
                {
                    try
                    {
                        var response = await _httpClient.PostAsync(webhookUrl, content);
                        if (!response.IsSuccessStatusCode)
                        {
                            Console.WriteLine($"Webhook failed: {response.StatusCode}");
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Webhook exception: {ex.Message}");
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
            {
                return Ok(new { estado = "Ninguno", ultimaPeticion = (object?)null });
            }

            return Ok(new { estado = peticion.EstadoProceso, ultimaPeticion = peticion });
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
                    h.EstablecimientoDestino
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
    }
}
