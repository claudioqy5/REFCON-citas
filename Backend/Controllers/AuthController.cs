using Backend.DTOs;
using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto request)
        {
            var usuario = await _context.Usuarios
                .Include(u => u.Establecimiento)
                .FirstOrDefaultAsync(u => u.Email == request.Email && u.ContrasenaHash == request.Password);

            // Nota: En producción usar BCrypt u otro para comparar hashes. Aquí asumimos texto plano o hash simple en DB.
            if (usuario == null || usuario.Estado != "Activo" || usuario.Establecimiento.Estado != "Activo")
            {
                return Unauthorized(new { message = "Credenciales incorrectas o cuenta inactiva." });
            }

            var rol = (usuario.EstablecimientoID == 1) ? "Admin" : "User";

            var token = GenerateJwtToken(usuario, rol);

            return Ok(new AuthResponseDto
            {
                Token = token,
                UsuarioID = usuario.UsuarioID,
                EstablecimientoID = usuario.EstablecimientoID,
                NombreCompleto = usuario.NombreCompleto,
                Rol = rol
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
    }
}
