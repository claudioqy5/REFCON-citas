using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    [Table("HistorialMensajes")]
    public class HistorialMensaje
    {
        [Key]
        public int MensajeID { get; set; }
        public int PeticionID { get; set; }
        public int EstablecimientoID { get; set; }
        public int PacienteID { get; set; }
        public string IdCita { get; set; } = null!;
        public string? IdReferencia { get; set; }
        public string Especialidad { get; set; } = null!;
        public DateTime FechaCita { get; set; }
        public DateTime? FechaHoraEnvio { get; set; }
        public string CuerpoMensaje { get; set; } = null!;
        public string EstadoEnvio { get; set; } = "Enviado";
        public string? EstablecimientoDestino { get; set; }

        [ForeignKey("PeticionID")]
        public virtual PeticionEnvio PeticionEnvio { get; set; } = null!;
        [ForeignKey("EstablecimientoID")]
        public virtual Establecimiento Establecimiento { get; set; } = null!;
        [ForeignKey("PacienteID")]
        public virtual Paciente Paciente { get; set; } = null!;
    }
}
