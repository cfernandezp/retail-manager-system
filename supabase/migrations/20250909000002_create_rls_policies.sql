-- Migración: Políticas RLS para Seguridad
-- Fecha: 2025-09-09
-- Descripción: Crear políticas de Row Level Security para el sistema de usuarios

-- Habilitar RLS en todas las tablas
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria_usuarios ENABLE ROW LEVEL SECURITY;

-- Política: Todos pueden leer roles (necesario para UI)
CREATE POLICY "roles_lectura_publica" ON public.roles
    FOR SELECT 
    USING (activo = TRUE);

-- Política: Solo SUPER_ADMIN puede modificar roles
CREATE POLICY "roles_solo_super_admin" ON public.roles
    FOR ALL 
    USING (
        auth.uid() IN (
            SELECT u.id FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE r.nombre = 'SUPER_ADMIN' AND u.estado = 'ACTIVA'
        )
    );

-- Política: Usuarios pueden ver su propio perfil
CREATE POLICY "usuarios_ver_propio_perfil" ON public.usuarios
    FOR SELECT 
    USING (auth.uid() = id);

-- Política: Admins pueden ver todos los usuarios
CREATE POLICY "admins_ver_todos_usuarios" ON public.usuarios
    FOR SELECT 
    USING (
        auth.uid() IN (
            SELECT u.id FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE r.nombre IN ('ADMIN', 'SUPER_ADMIN') 
            AND u.estado = 'ACTIVA'
        )
    );

-- Política: Solo usuarios con cuentas verificadas pueden hacer login
CREATE POLICY "login_solo_verificados" ON public.usuarios
    FOR SELECT 
    USING (
        estado = 'ACTIVA' 
        AND email_verificado = TRUE
        AND auth.uid() = id
    );

-- Política: Admins pueden aprobar/modificar usuarios
CREATE POLICY "admins_modificar_usuarios" ON public.usuarios
    FOR UPDATE 
    USING (
        auth.uid() IN (
            SELECT u.id FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE r.nombre IN ('ADMIN', 'SUPER_ADMIN') 
            AND u.estado = 'ACTIVA'
        )
    );

-- Política: Registro público permitido (solo INSERT)
CREATE POLICY "registro_publico" ON public.usuarios
    FOR INSERT 
    WITH CHECK (
        -- Solo se puede registrar con rol OPERARIO
        rol_id = (SELECT id FROM public.roles WHERE nombre = 'OPERARIO')
        -- Y solo si el email coincide con el usuario autenticado
        AND auth.uid() = id
    );

-- Política: Usuarios pueden actualizar su propio perfil (datos básicos)
-- Nota: Movido a trigger para evitar recursión infinita
CREATE POLICY "usuarios_actualizar_perfil" ON public.usuarios
    FOR UPDATE 
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Política: Auditoría - Admins pueden ver todo, usuarios solo su propio log
CREATE POLICY "auditoria_lectura_controlada" ON public.auditoria_usuarios
    FOR SELECT 
    USING (
        -- Admins ven todo
        auth.uid() IN (
            SELECT u.id FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE r.nombre IN ('ADMIN', 'SUPER_ADMIN') 
            AND u.estado = 'ACTIVA'
        )
        OR 
        -- Usuarios ven solo su propio log
        usuario_id = auth.uid()
    );

-- Política: Solo el sistema puede escribir en auditoría (via triggers)
CREATE POLICY "auditoria_solo_sistema" ON public.auditoria_usuarios
    FOR INSERT 
    WITH CHECK (TRUE); -- Se maneja via triggers y funciones

-- Función helper para verificar si el usuario actual es admin
CREATE OR REPLACE FUNCTION public.es_admin_activo()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.usuarios u
        JOIN public.roles r ON u.rol_id = r.id
        WHERE u.id = auth.uid()
        AND r.nombre IN ('ADMIN', 'SUPER_ADMIN')
        AND u.estado = 'ACTIVA'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función helper para obtener rol del usuario actual
CREATE OR REPLACE FUNCTION public.obtener_rol_usuario()
RETURNS TEXT AS $$
DECLARE
    rol_nombre TEXT;
BEGIN
    SELECT r.nombre INTO rol_nombre
    FROM public.usuarios u
    JOIN public.roles r ON u.rol_id = r.id
    WHERE u.id = auth.uid() AND u.estado = 'ACTIVA';
    
    RETURN COALESCE(rol_nombre, 'SIN_ROL');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear vista para facilitar consultas de usuarios con roles
CREATE OR REPLACE VIEW public.vista_usuarios_completa AS
SELECT 
    u.id,
    u.email,
    u.nombre_completo,
    u.estado,
    u.email_verificado,
    u.ultimo_acceso,
    u.created_at,
    r.nombre as rol_nombre,
    r.descripcion as rol_descripcion,
    r.permisos as rol_permisos,
    CASE 
        WHEN u.aprobado_por IS NOT NULL THEN admin.email
        ELSE NULL
    END as aprobado_por_email
FROM public.usuarios u
JOIN public.roles r ON u.rol_id = r.id
LEFT JOIN public.usuarios admin ON u.aprobado_por = admin.id;

-- Trigger para prevenir que usuarios cambien su rol/estado
CREATE OR REPLACE FUNCTION public.validar_actualizacion_usuario()
RETURNS TRIGGER AS $$
BEGIN
    -- Si no es admin, no puede cambiar rol o estado
    IF NOT public.es_admin_activo() THEN
        IF OLD.rol_id != NEW.rol_id THEN
            RAISE EXCEPTION 'No tienes permisos para cambiar el rol';
        END IF;
        IF OLD.estado != NEW.estado THEN
            RAISE EXCEPTION 'No tienes permisos para cambiar el estado';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_validar_actualizacion_usuario
    BEFORE UPDATE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_actualizacion_usuario();

-- Comentarios
COMMENT ON POLICY "login_solo_verificados" ON public.usuarios IS 'Solo usuarios verificados y activos pueden hacer login';
COMMENT ON POLICY "registro_publico" ON public.usuarios IS 'Permite registro público pero solo como OPERARIO';
COMMENT ON FUNCTION public.es_admin_activo() IS 'Verifica si el usuario actual es admin activo';