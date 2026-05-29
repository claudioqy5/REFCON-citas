using Backend.DTOs;
using Backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Backend.Controllers
{
    [Route("api/admin/usuarios")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminUsuariosController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminUsuariosController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var usuarios = await _context.Usuarios
                .Include(u => u.Establecimiento)
                .Select(u => new
                {
                    u.UsuarioID,
                    u.EstablecimientoID,
                    EstablecimientoNombre = u.Establecimiento!.NombreEstablecimiento,
                    u.NombreCompleto,
                    u.Email,
                    u.Estado,
                    u.Rol
                })
                .ToListAsync();
            return Ok(usuarios);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateUsuarioDto model)
        {
            if (await _context.Usuarios.AnyAsync(u => u.Email == model.Email))
            {
                return BadRequest(new { message = "El email ya está registrado." });
            }

            var usuario = new Usuario
            {
                EstablecimientoID = model.EstablecimientoID,
                NombreCompleto = model.NombreCompleto,
                Email = model.Email,
                Estado = model.Estado ?? "Activo",
                Rol = model.Rol ?? "User",
                // Hash the plain-text password before storing
                ContrasenaHash = BCrypt.Net.BCrypt.HashPassword(model.Contrasena)
            };

            _context.Usuarios.Add(usuario);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Usuario creado exitosamente", id = usuario.UsuarioID });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CreateUsuarioDto model)
        {
            var existing = await _context.Usuarios.FindAsync(id);
            if (existing == null) return NotFound();

            existing.EstablecimientoID = model.EstablecimientoID;
            existing.NombreCompleto = model.NombreCompleto;
            existing.Email = model.Email;
            existing.Estado = model.Estado ?? existing.Estado;
            existing.Rol = model.Rol ?? existing.Rol;

            // Only update password if a new one was provided
            if (!string.IsNullOrEmpty(model.Contrasena))
            {
                existing.ContrasenaHash = BCrypt.Net.BCrypt.HashPassword(model.Contrasena);
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Usuario actualizado exitosamente" });
        }
    }
}
