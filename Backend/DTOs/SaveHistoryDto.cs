using System;

namespace Backend.DTOs
{
    public class SaveHistoryDto
    {
        public int PeticionID { get; set; }
        public int EstablecimientoID { get; set; }
        public string PacienteDni { get; set; } = null!;
        public string PacienteNombre { get; set; } = null!;
        public string PacienteCelular { get; set; } = null!;
        public string IdCita { get; set; } = null!;
        public string? IdReferencia { get; set; }
        public string Especialidad { get; set; } = null!;
        public DateTime FechaCita { get; set; }
        public string CuerpoMensaje { get; set; } = null!;
        public string EstadoEnvio { get; set; } = "Enviado";
        public string? EstablecimientoDestino { get; set; }
        public string? Consultorio { get; set; }
        public string? Medico { get; set; }
    }

    public class CompleteProcessDto
    {
        public string EstadoProceso { get; set; } = "Completado"; // "Completado" or "Fallido"
    }

    public class SaveCredentialsDto
    {
        public string? UsuarioReferencial { get; set; }
        public string? ClaveReferencial { get; set; }
    }

    /// <summary>
    /// DTO para crear/actualizar usuarios desde el panel Admin.
    /// Usa 'Contrasena' (texto plano) en vez de 'ContrasenaHash'; el backend hashea con BCrypt.
    /// </summary>
    public class CreateUsuarioDto
    {
        public int EstablecimientoID { get; set; }
        public string NombreCompleto { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? Contrasena { get; set; } // Plain text — backend will BCrypt hash it
        public string? Estado { get; set; }     // null = keep existing
        public string? Rol { get; set; }        // "Admin" or "User", null = keep existing
    }
}
