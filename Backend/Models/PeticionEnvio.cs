using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    [Table("PeticionesEnvio")]
    public class PeticionEnvio
    {
        [Key]
        public int PeticionID { get; set; }
        public int EstablecimientoID { get; set; }
        public int? UsuarioID { get; set; }  // nullable: permite ejecuciones automáticas por cron sin usuario

        public DateTime? FechaPeticion { get; set; }
        public string EstadoProceso { get; set; } = "Pendiente";
        // Estados posibles: Pendiente | Procesando | Completado | SinPacientes | Error
        public DateTime? FechaFinalizacion { get; set; }

        // ── Contadores de resultado ──────────────────────────────────────────
        public int? TotalPacientesNuevos { get; set; }  // cuántos había para enviar
        public int? TotalEnviados { get; set; }          // cuántos se enviaron OK
        public int? TotalErrores { get; set; }           // cuántos fallaron

        // ── Detalle de error (si el flujo falló en una etapa crítica) ────────
        public string? MensajeError { get; set; }
        // Etapas posibles: RefconLogin | ObtenerPacientes | SinPacientes | EnviarWhatsApp
        public string? EtapaError { get; set; }

        [ForeignKey("EstablecimientoID")]
        public virtual Establecimiento Establecimiento { get; set; } = null!;
        [ForeignKey("UsuarioID")]
        public virtual Usuario? Usuario { get; set; }
    }
}
