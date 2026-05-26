using Backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Backend.Controllers
{
    [Route("api/admin/establecimientos")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminEstablecimientosController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminEstablecimientosController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var establecimientos = await _context.Establecimientos.ToListAsync();
            return Ok(establecimientos);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Establecimiento model)
        {
            model.FechaRegistro = DateTime.UtcNow;
            _context.Establecimientos.Add(model);
            await _context.SaveChangesAsync();
            return Ok(model);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Establecimiento model)
        {
            var existing = await _context.Establecimientos.FindAsync(id);
            if (existing == null) return NotFound();

            existing.CodigoUnico = model.CodigoUnico;
            existing.NombreEstablecimiento = model.NombreEstablecimiento;
            existing.Estado = model.Estado;

            await _context.SaveChangesAsync();
            return Ok(existing);
        }
    }
}
