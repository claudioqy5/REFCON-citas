-- ============================================================
-- SCRIPT DE MIGRACIÓN A PRODUCCIÓN — REFCON-citas SaaS
-- Ejecutar UNA SOLA VEZ en el SQL Server del VPS
-- ============================================================
USE SistemaRecordatoriosSaaS;
GO

-- 1. Agregar columna Rol a Usuarios (si no existe)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Usuarios' AND COLUMN_NAME = 'Rol'
)
BEGIN
    ALTER TABLE Usuarios ADD Rol NVARCHAR(50) NOT NULL DEFAULT 'User';
    PRINT 'Columna Rol agregada a Usuarios.';
END
ELSE
BEGIN
    PRINT 'Columna Rol ya existe. Saltando.';
END
GO

-- 2. Asignar Rol = 'Admin' al usuario administrador principal
--    (el que corresponde al EstablecimientoID = 1 / Administración Central)
UPDATE Usuarios SET Rol = 'Admin' WHERE EstablecimientoID = 1;
PRINT 'Rol Admin asignado al usuario del EstablecimientoID 1.';
GO

-- ============================================================
-- 3. HASH DE CONTRASEÑAS — IMPORTANTE
--    SQL Server no puede generar hashes BCrypt directamente.
--    Las contraseñas en la BD actual están en TEXTO PLANO.
--
--    DEBES hacer esto desde la aplicación o desde un script
--    externo que use BCrypt. Las opciones son:
--
--    OPCIÓN A (Recomendada): Usa el panel Admin del sistema
--    para editar cada usuario y guardar su nueva contraseña.
--    El backend la hasheará automáticamente con BCrypt.
--
--    OPCIÓN B: Inserta usuarios nuevos directamente desde el
--    panel Admin (POST /api/admin/usuarios) con la contraseña
--    en texto plano — el backend la hashea.
--
--    OPCIÓN C: Si necesitas hacerlo por SQL directamente, 
--    genera los hashes BCrypt fuera y pégalos aquí:
--    (Ejemplo de hash BCrypt de 'admin123':)
--    UPDATE Usuarios 
--    SET ContrasenaHash = '$2a$11$ejemplo_hash_aqui'
--    WHERE Email = 'admin@saas.com';
-- ============================================================

PRINT '';
PRINT '⚠️  ACCIÓN REQUERIDA: Actualizar contraseñas a BCrypt.';
PRINT '   Ver comentarios en el script para instrucciones.';
PRINT '';

-- 4. Verificar estado final
SELECT UsuarioID, Email, Rol, Estado, 
       LEFT(ContrasenaHash, 10) as Hash_Preview
FROM Usuarios
ORDER BY EstablecimientoID;
GO
