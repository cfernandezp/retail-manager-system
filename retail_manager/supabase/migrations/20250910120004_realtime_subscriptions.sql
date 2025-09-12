-- Migración: Configuración de Realtime Subscriptions
-- Fecha: 2025-09-10
-- Descripción: Setup de subscripciones en tiempo real para el sistema de usuarios

-- Habilitar realtime en las tablas críticas
ALTER PUBLICATION supabase_realtime ADD TABLE public.usuarios;
-- Nota: user_metrics es vista materializada, no se puede agregar a realtime
-- Se usarán notificaciones para indicar cuando actualizar métricas
ALTER PUBLICATION supabase_realtime ADD TABLE public.auditoria_usuarios;

-- Crear tabla para notificaciones en tiempo real
CREATE TABLE IF NOT EXISTS public.notificaciones_tiempo_real (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_destino UUID REFERENCES public.usuarios(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN (
        'USUARIO_PENDIENTE', 
        'USUARIO_APROBADO', 
        'USUARIO_RECHAZADO',
        'USUARIO_SUSPENDIDO',
        'METRICAS_ACTUALIZADAS',
        'OPERACION_MASIVA_COMPLETADA'
    )),
    titulo VARCHAR(255) NOT NULL,
    mensaje TEXT NOT NULL,
    datos_adicionales JSONB DEFAULT '{}',
    leida BOOLEAN DEFAULT FALSE,
    prioridad VARCHAR(20) DEFAULT 'NORMAL' CHECK (prioridad IN ('BAJA', 'NORMAL', 'ALTA', 'URGENTE')),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS para notificaciones
ALTER TABLE public.notificaciones_tiempo_real ENABLE ROW LEVEL SECURITY;

-- Política: usuarios solo ven sus propias notificaciones
CREATE POLICY "notificaciones_usuario_propio" ON public.notificaciones_tiempo_real
    FOR SELECT 
    USING (usuario_destino = auth.uid());

-- Política: marcar como leídas
CREATE POLICY "marcar_notificaciones_leidas" ON public.notificaciones_tiempo_real
    FOR UPDATE 
    USING (usuario_destino = auth.uid())
    WITH CHECK (usuario_destino = auth.uid());

-- Política: solo admins pueden crear notificaciones
CREATE POLICY "admins_crear_notificaciones" ON public.notificaciones_tiempo_real
    FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.usuarios u
            JOIN public.roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre IN ('ADMIN', 'SUPER_ADMIN')
            AND u.estado = 'ACTIVA'
        )
    );

-- Índices para optimización de notificaciones
CREATE INDEX IF NOT EXISTS idx_notificaciones_usuario_fecha ON public.notificaciones_tiempo_real(usuario_destino, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notificaciones_no_leidas ON public.notificaciones_tiempo_real(usuario_destino, leida) WHERE leida = FALSE;
CREATE INDEX IF NOT EXISTS idx_notificaciones_prioridad ON public.notificaciones_tiempo_real(prioridad, created_at) WHERE leida = FALSE;
CREATE INDEX IF NOT EXISTS idx_notificaciones_expired ON public.notificaciones_tiempo_real(expires_at) WHERE expires_at IS NOT NULL;

-- Habilitar realtime para notificaciones
ALTER PUBLICATION supabase_realtime ADD TABLE public.notificaciones_tiempo_real;

-- Función para crear notificaciones automáticamente
CREATE OR REPLACE FUNCTION public.crear_notificacion(
    p_usuario_destino UUID,
    p_tipo VARCHAR,
    p_titulo VARCHAR,
    p_mensaje TEXT,
    p_datos_adicionales JSONB DEFAULT '{}',
    p_prioridad VARCHAR DEFAULT 'NORMAL',
    p_expires_in_hours INTEGER DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
    expires_time TIMESTAMPTZ;
BEGIN
    -- Calcular fecha de expiración si se especifica
    IF p_expires_in_hours IS NOT NULL THEN
        expires_time := NOW() + INTERVAL '1 hour' * p_expires_in_hours;
    END IF;
    
    -- Insertar notificación
    INSERT INTO public.notificaciones_tiempo_real (
        usuario_destino,
        tipo,
        titulo,
        mensaje,
        datos_adicionales,
        prioridad,
        expires_at
    ) VALUES (
        p_usuario_destino,
        p_tipo,
        p_titulo,
        p_mensaje,
        p_datos_adicionales,
        p_prioridad,
        expires_time
    ) RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para notificar a todos los admins
CREATE OR REPLACE FUNCTION public.notificar_admins(
    p_tipo VARCHAR,
    p_titulo VARCHAR,
    p_mensaje TEXT,
    p_datos_adicionales JSONB DEFAULT '{}',
    p_prioridad VARCHAR DEFAULT 'NORMAL'
)
RETURNS INTEGER AS $$
DECLARE
    admin_record RECORD;
    notifications_created INTEGER := 0;
BEGIN
    -- Obtener todos los admins activos
    FOR admin_record IN 
        SELECT u.id 
        FROM public.usuarios u
        JOIN public.roles r ON u.rol_id = r.id
        WHERE r.nombre IN ('ADMIN', 'SUPER_ADMIN')
        AND u.estado = 'ACTIVA'
    LOOP
        PERFORM public.crear_notificacion(
            admin_record.id,
            p_tipo,
            p_titulo,
            p_mensaje,
            p_datos_adicionales,
            p_prioridad,
            24  -- Expira en 24 horas
        );
        notifications_created := notifications_created + 1;
    END LOOP;
    
    RETURN notifications_created;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para generar notificaciones automáticas cuando cambia el estado de usuarios
CREATE OR REPLACE FUNCTION public.trigger_notificaciones_usuario()
RETURNS TRIGGER AS $$
DECLARE
    admin_count INTEGER;
BEGIN
    -- Notificaciones por cambio de estado
    IF TG_OP = 'UPDATE' AND OLD.estado != NEW.estado THEN
        
        -- Nuevo usuario pendiente -> notificar admins
        IF NEW.estado = 'PENDIENTE_APROBACION' THEN
            admin_count := public.notificar_admins(
                'USUARIO_PENDIENTE',
                'Nuevo usuario pendiente de aprobación',
                format('El usuario %s (%s) está esperando aprobación', 
                       COALESCE(NEW.nombre_completo, 'Sin nombre'), NEW.email),
                json_build_object(
                    'usuario_id', NEW.id,
                    'email', NEW.email,
                    'created_at', NEW.created_at
                )::jsonb,
                'ALTA'
            );
            
        -- Usuario aprobado -> notificar al usuario
        ELSIF NEW.estado = 'ACTIVA' AND OLD.estado = 'PENDIENTE_APROBACION' THEN
            PERFORM public.crear_notificacion(
                NEW.id,
                'USUARIO_APROBADO',
                '¡Cuenta aprobada!',
                'Tu cuenta ha sido aprobada y ya puedes acceder al sistema',
                json_build_object('approved_at', NEW.fecha_aprobacion)::jsonb,
                'ALTA',
                72  -- Expira en 3 días
            );
            
        -- Usuario rechazado -> notificar al usuario
        ELSIF NEW.estado = 'RECHAZADA' THEN
            PERFORM public.crear_notificacion(
                NEW.id,
                'USUARIO_RECHAZADO',
                'Solicitud de cuenta rechazada',
                format('Tu solicitud de cuenta ha sido rechazada. Motivo: %s', 
                       COALESCE(NEW.motivo_rechazo, 'No especificado')),
                json_build_object(
                    'reason', NEW.motivo_rechazo,
                    'rejected_at', NEW.fecha_rechazo
                )::jsonb,
                'NORMAL',
                168  -- Expira en 1 semana
            );
            
        -- Usuario suspendido -> notificar al usuario
        ELSIF NEW.estado = 'SUSPENDIDA' THEN
            PERFORM public.crear_notificacion(
                NEW.id,
                'USUARIO_SUSPENDIDO',
                'Cuenta suspendida',
                format('Tu cuenta ha sido suspendida. Motivo: %s', 
                       COALESCE(NEW.motivo_suspension, 'No especificado')),
                json_build_object(
                    'reason', NEW.motivo_suspension,
                    'suspended_at', NEW.fecha_suspension,
                    'blocked_until', NEW.bloqueado_hasta
                )::jsonb,
                'URGENTE',
                NULL  -- No expira
            );
        END IF;
        
        -- Notificar cambio de métricas (debounced via pg_notify)
        PERFORM pg_notify('metrics_changed', json_build_object(
            'type', 'user_state_change',
            'old_state', OLD.estado,
            'new_state', NEW.estado,
            'timestamp', NOW()
        )::text);
        
    END IF;
    
    -- Notificar usuarios urgentes (más de 3 días pendientes)
    IF TG_OP = 'UPDATE' AND NEW.estado = 'PENDIENTE_APROBACION' 
       AND NEW.created_at < NOW() - INTERVAL '3 days' 
       AND (OLD.created_at >= NOW() - INTERVAL '3 days' OR OLD.estado != 'PENDIENTE_APROBACION') THEN
        
        admin_count := public.notificar_admins(
            'USUARIO_PENDIENTE',
            'Usuario urgente pendiente de aprobación',
            format('El usuario %s (%s) lleva más de 3 días esperando aprobación', 
                   COALESCE(NEW.nombre_completo, 'Sin nombre'), NEW.email),
            json_build_object(
                'usuario_id', NEW.id,
                'email', NEW.email,
                'days_pending', EXTRACT(days FROM (NOW() - NEW.created_at)),
                'is_urgent', true
            )::jsonb,
            'URGENTE'
        );
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para notificaciones automáticas
DROP TRIGGER IF EXISTS trigger_notificaciones_usuario ON public.usuarios;
CREATE TRIGGER trigger_notificaciones_usuario
    AFTER UPDATE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_notificaciones_usuario();

-- Función para limpiar notificaciones expiradas (programar en cron)
CREATE OR REPLACE FUNCTION public.limpiar_notificaciones_expiradas()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.notificaciones_tiempo_real 
    WHERE expires_at IS NOT NULL 
    AND expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- También limpiar notificaciones muy antiguas ya leídas (más de 30 días)
    DELETE FROM public.notificaciones_tiempo_real 
    WHERE leida = TRUE 
    AND created_at < NOW() - INTERVAL '30 days';
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Vista para notificaciones activas del usuario
CREATE OR REPLACE VIEW public.mis_notificaciones AS
SELECT 
    id,
    tipo,
    titulo,
    mensaje,
    datos_adicionales,
    leida,
    prioridad,
    created_at,
    CASE 
        WHEN expires_at IS NOT NULL THEN expires_at
        ELSE NULL
    END as expires_at,
    CASE 
        WHEN prioridad = 'URGENTE' THEN 1
        WHEN prioridad = 'ALTA' THEN 2
        WHEN prioridad = 'NORMAL' THEN 3
        WHEN prioridad = 'BAJA' THEN 4
        ELSE 5
    END as sort_order
FROM public.notificaciones_tiempo_real
WHERE usuario_destino = auth.uid()
AND (expires_at IS NULL OR expires_at > NOW())
ORDER BY 
    leida ASC,  -- No leídas primero
    sort_order ASC,  -- Por prioridad
    created_at DESC;  -- Más recientes primero

-- Función para marcar notificaciones como leídas
CREATE OR REPLACE FUNCTION public.marcar_notificaciones_leidas(
    notification_ids UUID[] DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    IF notification_ids IS NULL THEN
        -- Marcar todas como leídas
        UPDATE public.notificaciones_tiempo_real 
        SET leida = TRUE, updated_at = NOW()
        WHERE usuario_destino = auth.uid() AND leida = FALSE;
    ELSE
        -- Marcar específicas como leídas
        UPDATE public.notificaciones_tiempo_real 
        SET leida = TRUE, updated_at = NOW()
        WHERE id = ANY(notification_ids) 
        AND usuario_destino = auth.uid() 
        AND leida = FALSE;
    END IF;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentarios
COMMENT ON TABLE public.notificaciones_tiempo_real IS 'Sistema de notificaciones en tiempo real para usuarios';
COMMENT ON FUNCTION public.crear_notificacion(UUID, VARCHAR, VARCHAR, TEXT, JSONB, VARCHAR, INTEGER) IS 'Crear notificación para un usuario específico';
COMMENT ON FUNCTION public.notificar_admins(VARCHAR, VARCHAR, TEXT, JSONB, VARCHAR) IS 'Enviar notificación a todos los administradores activos';
COMMENT ON FUNCTION public.limpiar_notificaciones_expiradas() IS 'Función para limpiar notificaciones expiradas (usar en cron job)';
COMMENT ON VIEW public.mis_notificaciones IS 'Vista optimizada de notificaciones activas del usuario actual';