-- =====================================================
-- TABLA DE PERFILES DE USUARIO
-- =====================================================
-- Archivo: 006_users_profiles.sql
-- Propósito: Tabla de perfiles complementaria a auth.users
-- Fecha: 2025-09-15
--
-- NOTA: Supabase maneja autenticación en auth.users
-- Esta tabla extiende con información de perfil de negocio
-- =====================================================

-- =====================================================
-- TIPO ENUM PARA ROLES
-- =====================================================

-- Roles de usuario en el sistema
CREATE TYPE rol_usuario AS ENUM ('ADMIN', 'MANAGER', 'VENDEDOR', 'CLIENTE');

-- =====================================================
-- TABLA DE PERFILES DE USUARIO
-- =====================================================

-- Tabla que extiende auth.users con información del negocio
CREATE TABLE perfiles_usuario (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email           VARCHAR(255) NOT NULL UNIQUE,
    nombre_completo VARCHAR(200) NOT NULL,
    telefono        VARCHAR(20),
    dni             VARCHAR(8),  -- Para Perú
    direccion       TEXT,
    rol             rol_usuario DEFAULT 'CLIENTE',
    tienda_id       UUID REFERENCES tiendas(id),  -- Para vendedores/managers
    activo          BOOLEAN DEFAULT true,
    configuracion   JSONB DEFAULT '{}',
    ultimo_acceso   TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- RLS PARA PERFILES
-- =====================================================

-- Habilitar RLS en perfiles
ALTER TABLE perfiles_usuario ENABLE ROW LEVEL SECURITY;

-- Política: Usuarios pueden ver y editar su propio perfil
CREATE POLICY "usuarios_propio_perfil" ON perfiles_usuario
    FOR ALL
    USING (auth.uid() = id);

-- Política: Admins pueden ver todos los perfiles
CREATE POLICY "admin_ve_todos_perfiles" ON perfiles_usuario
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM perfiles_usuario
            WHERE perfiles_usuario.id = auth.uid()
            AND perfiles_usuario.rol = 'ADMIN'
        )
    );

-- Política: Admins pueden insertar perfiles
CREATE POLICY "admin_inserta_perfiles" ON perfiles_usuario
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM perfiles_usuario
            WHERE perfiles_usuario.id = auth.uid()
            AND perfiles_usuario.rol = 'ADMIN'
        )
    );

-- Política: Admins pueden actualizar perfiles
CREATE POLICY "admin_actualiza_perfiles" ON perfiles_usuario
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM perfiles_usuario
            WHERE perfiles_usuario.id = auth.uid()
            AND perfiles_usuario.rol = 'ADMIN'
        )
    );

-- Política: Admins pueden eliminar perfiles
CREATE POLICY "admin_elimina_perfiles" ON perfiles_usuario
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM perfiles_usuario
            WHERE perfiles_usuario.id = auth.uid()
            AND perfiles_usuario.rol = 'ADMIN'
        )
    );

-- =====================================================
-- FUNCIÓN PARA CREAR PERFIL AUTOMÁTICAMENTE
-- =====================================================

-- Función que crea perfil automáticamente cuando se registra usuario
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO perfiles_usuario (id, email, nombre_completo, rol)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'nombre_completo', NEW.email),
        CASE
            WHEN NEW.email LIKE '%admin%' THEN 'ADMIN'::rol_usuario
            ELSE 'CLIENTE'::rol_usuario
        END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que ejecuta la función al crear usuario
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =====================================================
-- TRIGGER PARA updated_at
-- =====================================================

-- Trigger para actualizar updated_at automáticamente
CREATE TRIGGER trigger_update_perfiles_usuario_updated_at
    BEFORE UPDATE ON perfiles_usuario
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- =====================================================
-- ÍNDICES PARA PERFILES
-- =====================================================

CREATE INDEX idx_perfiles_usuario_email ON perfiles_usuario(email);
CREATE INDEX idx_perfiles_usuario_rol ON perfiles_usuario(rol);
CREATE INDEX idx_perfiles_usuario_tienda ON perfiles_usuario(tienda_id) WHERE tienda_id IS NOT NULL;
CREATE INDEX idx_perfiles_usuario_activo ON perfiles_usuario(activo) WHERE activo = true;
CREATE INDEX idx_perfiles_usuario_dni ON perfiles_usuario(dni) WHERE dni IS NOT NULL;

-- =====================================================
-- VISTAS ÚTILES PARA USUARIOS
-- =====================================================

-- Vista que combina auth.users con perfiles_usuario
CREATE VIEW vista_usuarios_completa AS
SELECT
    pu.id,
    pu.email,
    pu.nombre_completo,
    pu.telefono,
    pu.dni,
    pu.direccion,
    pu.rol,
    pu.activo,
    pu.ultimo_acceso,
    pu.created_at,
    pu.updated_at,

    -- Información de tienda (si aplica)
    t.nombre as tienda_nombre,
    t.codigo as tienda_codigo,

    -- Información de auth.users
    au.email_confirmed_at,
    au.last_sign_in_at,
    au.created_at as auth_created_at

FROM perfiles_usuario pu
LEFT JOIN tiendas t ON pu.tienda_id = t.id
LEFT JOIN auth.users au ON pu.id = au.id

WHERE pu.activo = true
ORDER BY pu.nombre_completo;

-- =====================================================
-- FUNCIONES AUXILIARES
-- =====================================================

-- Función para obtener rol del usuario actual
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS rol_usuario AS $$
DECLARE
    user_role rol_usuario;
BEGIN
    SELECT rol INTO user_role
    FROM perfiles_usuario
    WHERE id = auth.uid();

    RETURN COALESCE(user_role, 'CLIENTE'::rol_usuario);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si usuario es admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN get_user_role() = 'ADMIN'::rol_usuario;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si usuario puede acceder a tienda
CREATE OR REPLACE FUNCTION can_access_tienda(tienda_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Admin puede acceder a cualquier tienda
    IF is_admin() THEN
        RETURN TRUE;
    END IF;

    -- Usuario debe estar asignado a la tienda
    RETURN EXISTS (
        SELECT 1 FROM perfiles_usuario
        WHERE id = auth.uid()
        AND tienda_id = tienda_uuid
        AND activo = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE perfiles_usuario IS 'Perfiles de usuario complementarios a auth.users - Sistema retail';
COMMENT ON COLUMN perfiles_usuario.rol IS 'Rol en el sistema: ADMIN, MANAGER, VENDEDOR, CLIENTE';
COMMENT ON COLUMN perfiles_usuario.tienda_id IS 'Tienda asignada para vendedores/managers';
COMMENT ON COLUMN perfiles_usuario.dni IS 'DNI para usuarios peruanos (8 dígitos)';

COMMENT ON VIEW vista_usuarios_completa IS 'Vista completa de usuarios con auth y perfil';

COMMENT ON FUNCTION get_user_role() IS 'Obtiene rol del usuario autenticado actual';
COMMENT ON FUNCTION is_admin() IS 'Verifica si usuario actual es admin';
COMMENT ON FUNCTION can_access_tienda(UUID) IS 'Verifica si usuario puede acceder a tienda específica';

-- Fin de tabla perfiles de usuario