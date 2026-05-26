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
        public int UsuarioID { get; set; }
        public DateTime? FechaPeticion { get; set; }
        public string EstadoProceso { get; set; } = "Pendiente";
        public DateTime? FechaFinalizacion { get; set; }

        [ForeignKey("EstablecimientoID")]
        public virtual Establecimiento Establecimiento { get; set; } = null!;
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; } = null!;
    }
}
