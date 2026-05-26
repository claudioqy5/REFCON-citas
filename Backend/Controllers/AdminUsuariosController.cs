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
                    EstablecimientoNombre = u.Establecimiento.NombreEstablecimiento,
                    u.NombreCompleto,
                    u.Email,
                    u.Estado
                })
                .ToListAsync();
            return Ok(usuarios);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Usuario model)
        {
            if (await _context.Usuarios.AnyAsync(u => u.Email == model.Email))
            {
                return BadRequest(new { message = "El email ya está registrado." });
            }

            _context.Usuarios.Add(model);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Usuario creado exitosamente", id = model.UsuarioID });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Usuario model)
        {
            var existing = await _context.Usuarios.FindAsync(id);
            if (existing == null) return NotFound();

            existing.EstablecimientoID = model.EstablecimientoID;
            existing.NombreCompleto = model.NombreCompleto;
            existing.Email = model.Email;
            existing.Estado = model.Estado;
            
            if (!string.IsNullOrEmpty(model.ContrasenaHash))
            {
                existing.ContrasenaHash = model.ContrasenaHash;
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Usuario actualizado exitosamente" });
        }
    }
}
