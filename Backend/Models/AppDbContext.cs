using Microsoft.EntityFrameworkCore;

namespace Backend.Models
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Establecimiento> Establecimientos { get; set; } = null!;
        public DbSet<Usuario> Usuarios { get; set; } = null!;
        public DbSet<Paciente> Pacientes { get; set; } = null!;
        public DbSet<PeticionEnvio> PeticionesEnvio { get; set; } = null!;
        public DbSet<HistorialMensaje> HistorialMensajes { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Unique constraint for Pacientes
            modelBuilder.Entity<Paciente>()
                .HasIndex(p => new { p.EstablecimientoID, p.Dni })
                .IsUnique();
        }
    }
}
