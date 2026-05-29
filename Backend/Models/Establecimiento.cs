using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    [Table("Establecimientos")]
    public class Establecimiento
    {
        [Key]
        public int EstablecimientoID { get; set; }
        public string CodigoUnico { get; set; } = null!;
        public string NombreEstablecimiento { get; set; } = null!;
        public string Estado { get; set; } = "Activo";
        public DateTime? FechaRegistro { get; set; }
        public bool EnvioAutomatico { get; set; } = false;
    }
}
