using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    [Table("Pacientes")]
    public class Paciente
    {
        [Key]
        public int PacienteID { get; set; }
        public int EstablecimientoID { get; set; }
        public string Dni { get; set; } = null!;
        public string NombreCompleto { get; set; } = null!;
        public string Celular { get; set; } = null!;

        [ForeignKey("EstablecimientoID")]
        public virtual Establecimiento Establecimiento { get; set; } = null!;
    }
}
