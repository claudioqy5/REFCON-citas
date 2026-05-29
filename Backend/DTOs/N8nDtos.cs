namespace Backend.DTOs
{
    /// <summary>
    /// n8n llama a /api/n8n/inicio al arrancar el flujo.
    /// Si viene del cron (sin peticionId), se crea una nueva PeticionEnvio.
    /// Si viene disparado desde el frontend, incluye el peticionId ya creado.
    /// </summary>
    public class N8nInicioDto
    {
        public int EstablecimientoId { get; set; }
        public int? PeticionId { get; set; }
        public int? TotalPacientesNuevos { get; set; }
    }

    /// <summary>
    /// n8n llama a /api/n8n/progreso tras cada mensaje enviado (éxito o error).
    /// Registra el mensaje en HistorialMensajes y actualiza los contadores de PeticionEnvio.
    /// Garantiza aislamiento SaaS: todo se filtra por EstablecimientoId.
    /// </summary>
    public class N8nProgresoDto
    {
        public int PeticionId { get; set; }
        public int EstablecimientoId { get; set; }

        // Datos de la cita (de REFCON)
        public string IdCita { get; set; } = null!;
        public string? IdReferencia { get; set; }
        public string Especialidad { get; set; } = "---";
        public string FechaCita { get; set; } = null!;
        public string? EstablecimientoDestino { get; set; }
        public string? Consultorio { get; set; }
        public string? Medico { get; set; }

        // Datos del paciente
        public string NombrePaciente { get; set; } = null!;
        public string Dni { get; set; } = null!;
        public string Celular { get; set; } = null!;

        // Resultado del envío
        public string? CuerpoMensaje { get; set; }
        public string EstadoEnvio { get; set; } = "Enviado"; // "Enviado" | "Error"
        public string? MensajeError { get; set; }
    }

    /// <summary>
    /// n8n llama a /api/n8n/completado cuando el loop de envíos termina.
    /// Marca la PeticionEnvio como "Completado".
    /// </summary>
    public class N8nCompletadoDto
    {
        public int PeticionId { get; set; }
        public int EstablecimientoId { get; set; }
    }

    /// <summary>
    /// n8n llama a /api/n8n/error cuando falla una etapa crítica del flujo.
    /// Etapas posibles: RefconLogin | ObtenerPacientes | SinPacientes | EnviarWhatsApp
    /// </summary>
    public class N8nErrorDto
    {
        public int PeticionId { get; set; }
        public int EstablecimientoId { get; set; }
        public string Etapa { get; set; } = null!;
        public string Mensaje { get; set; } = null!;
    }
}
