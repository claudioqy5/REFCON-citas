namespace Backend.DTOs
{
    public class AuthResponseDto
    {
        public string Token { get; set; } = null!;
        public int UsuarioID { get; set; }
        public int EstablecimientoID { get; set; }
        public string NombreCompleto { get; set; } = null!;
        public string Rol { get; set; } = "User";
        public string EstablecimientoNombre { get; set; } = null!;
    }
}
