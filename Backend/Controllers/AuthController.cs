using Backend.DTOs;
using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text.Json;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly HttpClient _httpClient;

        public AuthController(AppDbContext context, IConfiguration configuration, HttpClient httpClient)
        {
            _context = context;
            _configuration = configuration;
            _httpClient = httpClient;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto request)
        {
            var usuario = await _context.Usuarios
                .Include(u => u.Establecimiento)
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            // Verify BCrypt hash. If no hash exists yet (migration scenario), reject.
            if (usuario == null || !BCrypt.Net.BCrypt.Verify(request.Password, usuario.ContrasenaHash))
            {
                return Unauthorized(new { message = "Credenciales incorrectas o cuenta inactiva." });
            }

            if (usuario.Estado != "Activo" || usuario.Establecimiento?.Estado != "Activo")
            {
                return Unauthorized(new { message = "Credenciales incorrectas o cuenta inactiva." });
            }

            // Role comes from the database, not a hardcoded condition.
            var rol = usuario.Rol;

            var token = GenerateJwtToken(usuario, rol);

            return Ok(new AuthResponseDto
            {
                Token = token,
                UsuarioID = usuario.UsuarioID,
                EstablecimientoID = usuario.EstablecimientoID,
                NombreCompleto = usuario.NombreCompleto,
                Rol = rol,
                EstablecimientoNombre = usuario.Establecimiento!.NombreEstablecimiento
            });
        }

        private string GenerateJwtToken(Usuario usuario, string rol)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["Secret"]!;

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, usuario.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim("UsuarioID", usuario.UsuarioID.ToString()),
                new Claim("EstablecimientoID", usuario.EstablecimientoID.ToString()),
                new Claim(ClaimTypes.Role, rol)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddHours(8),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto request)
        {
            var usuario = await _context.Usuarios
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (usuario == null)
            {
                return BadRequest(new { message = "El correo electrónico no se encuentra registrado en el sistema." });
            }

            // 1. Envío por Webhook de Make/N8n (si está configurado)
            var webhookUrl = _configuration["N8nSettings:WebhookUrl"];
            if (!string.IsNullOrEmpty(webhookUrl))
            {
                try
                {
                    var payload = new
                    {
                        @event = "forgot_password",
                        email = request.Email,
                        message = request.Message,
                        target_email = "claudioquello5@gmail.com",
                        timestamp = DateTime.UtcNow
                    };
                    var jsonContent = new StringContent(
                        System.Text.Json.JsonSerializer.Serialize(payload),
                        Encoding.UTF8,
                        "application/json"
                    );
                    await _httpClient.PostAsync(webhookUrl, jsonContent);
                }
                catch (Exception)
                {
                    // Fallback / Log
                }
            }

            // 2. Envío por SMTP tradicional (si está configurado)
            var smtpHost = _configuration["SmtpSettings:Host"];
            if (!string.IsNullOrEmpty(smtpHost))
            {
                try
                {
                    using (var mail = new System.Net.Mail.MailMessage())
                    {
                        mail.From = new System.Net.Mail.MailAddress(_configuration["SmtpSettings:From"] ?? "noreply@refconcitas.com");
                        mail.To.Add("claudioquello5@gmail.com");
                        mail.Subject = "Solicitud de Restablecimiento de Contraseña - REFCON Citas";
                        mail.Body = $"El usuario con correo {request.Email} ha solicitado un restablecimiento de contraseña.\n\nMensaje:\n{request.Message}";
                        mail.IsBodyHtml = false;

                        using (var smtp = new System.Net.Mail.SmtpClient(smtpHost))
                        {
                            smtp.Port = int.Parse(_configuration["SmtpSettings:Port"] ?? "587");
                            smtp.Credentials = new System.Net.NetworkCredential(
                                _configuration["SmtpSettings:Username"],
                                _configuration["SmtpSettings:Password"]
                            );
                            smtp.EnableSsl = bool.Parse(_configuration["SmtpSettings:EnableSsl"] ?? "true");
                            await smtp.SendMailAsync(mail);
                        }
                    }
                }
                catch (Exception)
                {
                    // Fallback / Log
                }
            }

            return Ok(new { message = "Tu solicitud ha sido enviada al administrador del sistema para restablecer tu contraseña." });
        }
    }
}
