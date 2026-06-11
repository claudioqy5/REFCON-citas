using Backend.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using System.Text;

namespace Backend.Services
{
    public class AutoSendService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AutoSendService> _logger;

        public AutoSendService(IServiceScopeFactory scopeFactory, IConfiguration configuration, ILogger<AutoSendService> logger)
        {
            _scopeFactory = scopeFactory;
            _configuration = configuration;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("AutoSendService is starting.");

            while (!stoppingToken.IsCancellationRequested)
            {
                var now = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, TimeZoneInfo.FindSystemTimeZoneById("SA Pacific Standard Time")); // Lima time

                if (now.Hour == 8 && now.Minute >= 0 && now.Minute <= 5)
                {
                    try
                    {
                        await ProcessAutomaticReminders(now.Date);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error processing automatic reminders.");
                    }
                    
                    // Delay to prevent running multiple times in the same minute/hour range
                    await Task.Delay(TimeSpan.FromMinutes(10), stoppingToken);
                }
                else
                {
                    // Check every minute
                    await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
                }
            }
        }

        private async Task ProcessAutomaticReminders(DateTime today)
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            var establecimientos = await context.Establecimientos
                .Where(e => e.EnvioAutomatico && e.Estado == "Activo")
                .ToListAsync();

            foreach (var est in establecimientos)
            {
                // Check if already processed today
                var tomorrow = today.AddDays(1);
                var existingPeticionToday = await context.PeticionesEnvio
                    .Where(p => p.EstablecimientoID == est.EstablecimientoID && p.FechaPeticion >= today && p.FechaPeticion < tomorrow && p.EstadoProceso != "Error")
                    .FirstOrDefaultAsync();

                if (existingPeticionToday != null)
                {
                    continue; // Already processed today
                }

                // Get a valid user with credentials for this establishment
                var user = await context.Usuarios
                    .Where(u => u.EstablecimientoID == est.EstablecimientoID && u.Estado == "Activo" && !string.IsNullOrEmpty(u.UsuarioReferencial))
                    .FirstOrDefaultAsync();

                if (user == null)
                {
                    _logger.LogWarning($"No active user with credentials found for establishment {est.EstablecimientoID}");
                    continue;
                }

                var peticion = new PeticionEnvio
                {
                    EstablecimientoID = est.EstablecimientoID,
                    UsuarioID = user.UsuarioID,
                    FechaPeticion = DateTime.UtcNow,
                    EstadoProceso = "Pendiente"
                };

                context.PeticionesEnvio.Add(peticion);
                await context.SaveChangesAsync();

                var webhookUrl = _configuration["N8nSettings:WebhookUrl"];
                if (!string.IsNullOrEmpty(webhookUrl))
                {
                    var payload = new
                    {
                        PeticionID = peticion.PeticionID,
                        EstablecimientoID = peticion.EstablecimientoID,
                        UsuarioReferencial = user.UsuarioReferencial,
                        ClaveReferencial = user.ClaveReferencial
                    };

                    var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");
                    var peticionId = peticion.PeticionID;

                    _ = Task.Run(async () =>
                    {
                        try
                        {
                            using var cts = new System.Threading.CancellationTokenSource(TimeSpan.FromSeconds(15));
                            using var client = new HttpClient();
                            var response = await client.PostAsync(webhookUrl, content, cts.Token);
                            if (!response.IsSuccessStatusCode)
                            {
                                _logger.LogError($"[n8n] Webhook failed (HTTP {response.StatusCode}) para PeticionID={peticionId}");
                            }
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError($"[n8n] Webhook exception para PeticionID={peticionId}: {ex.Message}");
                            try
                            {
                                using var errScope = _scopeFactory.CreateScope();
                                var errContext = errScope.ServiceProvider.GetRequiredService<AppDbContext>();
                                var pet = await errContext.PeticionesEnvio.FindAsync(peticionId);
                                if (pet != null && (pet.EstadoProceso == "Pendiente" || pet.EstadoProceso == "Procesando"))
                                {
                                    pet.EstadoProceso = "Error";
                                    pet.MensajeError = $"No se pudo conectar con n8n: {ex.Message}";
                                    pet.EtapaError = "Conexion_N8n";
                                    pet.FechaFinalizacion = DateTime.UtcNow;
                                    await errContext.SaveChangesAsync();
                                }
                            }
                            catch (Exception dbEx)
                            {
                                _logger.LogError($"[n8n] Error al actualizar peticion en BD: {dbEx.Message}");
                            }
                        }
                    });
                }
            }
        }
    }
}
