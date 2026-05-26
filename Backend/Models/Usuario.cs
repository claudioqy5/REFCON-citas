using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    [Table("Usuarios")]
    public class Usuario
    {
        [Key]
        public int UsuarioID { get; set; }
        public int EstablecimientoID { get; set; }
        public string NombreCompleto { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string ContrasenaHash { get; set; } = null!;
        public string Estado { get; set; } = "Activo";

        [ForeignKey("EstablecimientoID")]
        public virtual Establecimiento? Establecimiento { get; set; }
    }
}
