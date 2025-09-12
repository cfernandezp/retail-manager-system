-- Migración: Políticas RLS Granulares por Rol
-- Fecha: 2025-09-10
-- Descripción: Políticas de seguridad avanzadas para multi-tienda

-- Habilitar RLS para nuevas tablas
ALTER TABLE public.tiendas ENABLE ROW LEVEL SECURITY;
-- Nota: Las vistas materializadas no soportan RLS directamente
-- Se manejará el acceso a user_metrics a través de políticas en las funciones

-- =============================
-- POLÍTICAS PARA TIENDAS
-- =============================

-- SUPER_ADMIN: acceso completo a todas las tiendas
CREATE POLICY "super_admin_tiendas_completo" ON public.tiendas
    FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre = 'SUPER_ADMIN' 
            AND u.estado = 'ACTIVA'
        )
    );

-- ADMIN: puede ver tiendas donde es manager o todas si no tiene asignación específica
CREATE POLICY "admin_tiendas_gestion" ON public.tiendas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre = 'ADMIN'
            AND u.estado = 'ACTIVA'
            AND (u.tienda_asignada IS NULL OR u.tienda_asignada = tiendas.id OR manager_id = u.id)
        )
    );

-- VENDEDOR/OPERARIO: solo pueden ver su tienda asignada
CREATE POLICY "usuarios_tienda_asignada" ON public.tiendas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre IN ('VENDEDOR', 'OPERARIO')
            AND u.estado = 'ACTIVA'
            AND u.tienda_asignada = tiendas.id
        )
    );

-- =============================
-- POLÍTICAS MEJORADAS PARA USUARIOS
-- =============================

-- Reemplazar política existente de admins con filtro por tienda
DROP POLICY IF EXISTS "admins_ver_todos_usuarios" ON public.usuarios;

CREATE POLICY "super_admin_usuarios_completo" ON public.usuarios
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre = 'SUPER_ADMIN' 
            AND u.estado = 'ACTIVA'
        )
    );

CREATE POLICY "admin_usuarios_por_tienda" ON public.usuarios
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios admin
            JOIN public.roles r ON admin.rol_id = r.id
            WHERE admin.id = auth.uid()
            AND r.nombre = 'ADMIN'
            AND admin.estado = 'ACTIVA'
            AND (
                admin.tienda_asignada IS NULL OR  -- Admin sin restricción de tienda
                usuarios.tienda_asignada = admin.tienda_asignada OR  -- Misma tienda
                usuarios.tienda_asignada IS NULL  -- Usuarios sin asignar
            )
        )
    );

-- Política mejorada para modificación de usuarios por admins
DROP POLICY IF EXISTS "admins_modificar_usuarios" ON public.usuarios;

CREATE POLICY "super_admin_modificar_usuarios" ON public.usuarios
    FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre = 'SUPER_ADMIN' 
            AND u.estado = 'ACTIVA'
        )
    );

CREATE POLICY "admin_modificar_usuarios_tienda" ON public.usuarios
    FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios admin
            JOIN public.roles r ON admin.rol_id = r.id
            WHERE admin.id = auth.uid()
            AND r.nombre = 'ADMIN'
            AND admin.estado = 'ACTIVA'
            AND (
                admin.tienda_asignada IS NULL OR  -- Admin sin restricción
                usuarios.tienda_asignada = admin.tienda_asignada OR  -- Misma tienda
                usuarios.tienda_asignada IS NULL  -- Usuarios sin asignar
            )
        )
    );

-- =============================
-- POLÍTICAS PARA MÉTRICAS
-- =============================

-- Nota: Las vistas materializadas no pueden tener RLS
-- El control de acceso a métricas se maneja en las funciones que las consultan

-- =============================
-- FUNCIONES DE UTILIDAD MEJORADAS
-- =============================

-- Función para verificar si usuario tiene acceso a otra tienda
CREATE OR REPLACE FUNCTION public.tiene_acceso_tienda(tienda_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
    user_tienda UUID;
BEGIN
    SELECT r.nombre, u.tienda_asignada 
    INTO user_role, user_tienda
    FROM public.usuarios u
    JOIN public.roles r ON u.rol_id = r.id
    WHERE u.id = auth.uid() AND u.estado = 'ACTIVA';
    
    -- SUPER_ADMIN tiene acceso a todo
    IF user_role = 'SUPER_ADMIN' THEN
        RETURN TRUE;
    END IF;
    
    -- ADMIN sin tienda asignada tiene acceso a todo
    IF user_role = 'ADMIN' AND user_tienda IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar si es la misma tienda asignada
    IF user_tienda = tienda_id THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar si es manager de la tienda
    IF EXISTS (
        SELECT 1 FROM public.tiendas t 
        WHERE t.id = tienda_id AND t.manager_id = auth.uid()
    ) THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener tiendas accesibles por usuario
CREATE OR REPLACE FUNCTION public.obtener_tiendas_accesibles()
RETURNS TABLE (
    id UUID,
    nombre VARCHAR,
    codigo VARCHAR
) AS $$
DECLARE
    user_role TEXT;
    user_tienda UUID;
BEGIN
    SELECT r.nombre, u.tienda_asignada 
    INTO user_role, user_tienda
    FROM public.usuarios u
    JOIN public.roles r ON u.rol_id = r.id
    WHERE u.id = auth.uid() AND u.estado = 'ACTIVA';
    
    -- SUPER_ADMIN ve todas las tiendas
    IF user_role = 'SUPER_ADMIN' THEN
        RETURN QUERY
        SELECT t.id, t.nombre, t.codigo 
        FROM public.tiendas t 
        WHERE t.activa = TRUE
        ORDER BY t.nombre;
        RETURN;
    END IF;
    
    -- ADMIN sin tienda asignada ve todas
    IF user_role = 'ADMIN' AND user_tienda IS NULL THEN
        RETURN QUERY
        SELECT t.id, t.nombre, t.codigo 
        FROM public.tiendas t 
        WHERE t.activa = TRUE
        ORDER BY t.nombre;
        RETURN;
    END IF;
    
    -- Otros usuarios solo ven su tienda asignada o donde son managers
    RETURN QUERY
    SELECT t.id, t.nombre, t.codigo 
    FROM public.tiendas t 
    WHERE t.activa = TRUE 
    AND (t.id = user_tienda OR t.manager_id = auth.uid())
    ORDER BY t.nombre;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para validar operaciones masivas
CREATE OR REPLACE FUNCTION public.validar_operacion_masiva(
    usuario_ids UUID[],
    operacion TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
    user_tienda UUID;
    target_user RECORD;
BEGIN
    -- Obtener rol del usuario que ejecuta
    SELECT r.nombre, u.tienda_asignada 
    INTO user_role, user_tienda
    FROM public.usuarios u
    JOIN public.roles r ON u.rol_id = r.id
    WHERE u.id = auth.uid() AND u.estado = 'ACTIVA';
    
    -- SUPER_ADMIN puede todo
    IF user_role = 'SUPER_ADMIN' THEN
        RETURN TRUE;
    END IF;
    
    -- Para ADMIN, verificar que todos los usuarios objetivo estén en su alcance
    IF user_role = 'ADMIN' THEN
        FOR target_user IN 
            SELECT u.tienda_asignada 
            FROM public.usuarios u 
            WHERE u.id = ANY(usuario_ids)
        LOOP
            -- Si admin tiene tienda específica, verificar coincidencia
            IF user_tienda IS NOT NULL AND 
               target_user.tienda_asignada != user_tienda AND 
               target_user.tienda_asignada IS NOT NULL THEN
                RETURN FALSE;
            END IF;
        END LOOP;
        RETURN TRUE;
    END IF;
    
    -- Otros roles no pueden hacer operaciones masivas
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================
-- TRIGGER MEJORADO PARA VALIDACIONES
-- =============================

-- Mejorar función de validación existente
DROP FUNCTION IF EXISTS public.validar_actualizacion_usuario() CASCADE;

CREATE OR REPLACE FUNCTION public.validar_actualizacion_usuario()
RETURNS TRIGGER AS $$
DECLARE
    user_role TEXT;
    user_tienda UUID;
    can_modify BOOLEAN := FALSE;
BEGIN
    -- Obtener información del usuario que modifica
    SELECT r.nombre, u.tienda_asignada 
    INTO user_role, user_tienda
    FROM public.usuarios u
    JOIN public.roles r ON u.rol_id = r.id
    WHERE u.id = auth.uid() AND u.estado = 'ACTIVA';
    
    -- Si es el propio usuario, solo puede cambiar datos básicos
    IF auth.uid() = NEW.id THEN
        IF OLD.rol_id != NEW.rol_id OR OLD.estado != NEW.estado OR 
           OLD.tienda_asignada != NEW.tienda_asignada THEN
            RAISE EXCEPTION 'No puedes modificar tu rol, estado o tienda asignada';
        END IF;
        RETURN NEW;
    END IF;
    
    -- SUPER_ADMIN puede modificar todo
    IF user_role = 'SUPER_ADMIN' THEN
        can_modify := TRUE;
    -- ADMIN puede modificar según su alcance de tienda
    ELSIF user_role = 'ADMIN' THEN
        can_modify := (
            user_tienda IS NULL OR  -- Admin sin restricción
            OLD.tienda_asignada = user_tienda OR  -- Mismo ámbito
            OLD.tienda_asignada IS NULL  -- Usuario sin asignar
        );
    END IF;
    
    IF NOT can_modify THEN
        RAISE EXCEPTION 'No tienes permisos para modificar este usuario';
    END IF;
    
    -- Si se está aprobando un usuario, registrar quién lo aprobó
    IF OLD.estado != 'ACTIVA' AND NEW.estado = 'ACTIVA' AND NEW.aprobado_por IS NULL THEN
        NEW.aprobado_por = auth.uid();
        NEW.fecha_aprobacion = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recrear el trigger
CREATE TRIGGER trigger_validar_actualizacion_usuario
    BEFORE UPDATE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION public.validar_actualizacion_usuario();

-- Comentarios
COMMENT ON FUNCTION public.tiene_acceso_tienda(UUID) IS 'Verifica si el usuario actual tiene acceso a una tienda específica';
COMMENT ON FUNCTION public.obtener_tiendas_accesibles() IS 'Retorna las tiendas accesibles según el rol y asignación del usuario';
COMMENT ON FUNCTION public.validar_operacion_masiva(UUID[], TEXT) IS 'Valida si el usuario puede realizar operaciones masivas sobre un grupo de usuarios';