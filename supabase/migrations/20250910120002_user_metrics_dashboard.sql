-- Migración: Dashboard de Métricas de Usuarios
-- Fecha: 2025-09-10
-- Descripción: Vista materializada y funciones para métricas en tiempo real

-- Vista materializada para métricas del dashboard
CREATE MATERIALIZED VIEW public.user_metrics AS
SELECT 
    COUNT(*) as total_users,
    COUNT(*) FILTER (WHERE estado = 'PENDIENTE_EMAIL') as pending_email,
    COUNT(*) FILTER (WHERE estado = 'PENDIENTE_APROBACION') as pending_approval,
    COUNT(*) FILTER (WHERE estado = 'ACTIVA') as active_users,
    COUNT(*) FILTER (WHERE estado = 'SUSPENDIDA') as suspended_users,
    COUNT(*) FILTER (WHERE estado = 'RECHAZADA') as rejected_users,
    COUNT(*) FILTER (WHERE estado = 'PENDIENTE_APROBACION' AND created_at < NOW() - INTERVAL '3 days') as urgent_pending,
    COUNT(*) FILTER (WHERE estado = 'PENDIENTE_APROBACION' AND created_at < NOW() - INTERVAL '7 days') as very_urgent_pending,
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') as new_this_week,
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days') as new_this_month,
    COUNT(*) FILTER (WHERE ultimo_acceso >= NOW() - INTERVAL '7 days') as active_this_week,
    COUNT(*) FILTER (WHERE ultimo_acceso >= NOW() - INTERVAL '30 days') as active_this_month,
    -- Por rol
    COUNT(*) FILTER (WHERE rol_id = (SELECT id FROM roles WHERE nombre = 'SUPER_ADMIN')) as super_admins,
    COUNT(*) FILTER (WHERE rol_id = (SELECT id FROM roles WHERE nombre = 'ADMIN')) as admins,
    COUNT(*) FILTER (WHERE rol_id = (SELECT id FROM roles WHERE nombre = 'VENDEDOR')) as vendedores,
    COUNT(*) FILTER (WHERE rol_id = (SELECT id FROM roles WHERE nombre = 'OPERARIO')) as operarios,
    -- Fecha de actualización
    NOW() as last_updated
FROM public.usuarios;

-- Crear índices únicos para la vista materializada
CREATE UNIQUE INDEX user_metrics_unique_idx ON public.user_metrics(last_updated);

-- Vista para tendencias semanales
CREATE OR REPLACE VIEW public.user_weekly_trends AS
WITH weekly_data AS (
    SELECT 
        DATE_TRUNC('week', created_at) as semana,
        COUNT(*) as registros_semana,
        COUNT(*) FILTER (WHERE estado = 'ACTIVA') as aprobados_semana,
        COUNT(*) FILTER (WHERE estado = 'RECHAZADA') as rechazados_semana
    FROM public.usuarios 
    WHERE created_at >= NOW() - INTERVAL '8 weeks'
    GROUP BY DATE_TRUNC('week', created_at)
    ORDER BY semana
)
SELECT 
    semana,
    registros_semana,
    aprobados_semana,
    rechazados_semana,
    COALESCE(
        LAG(registros_semana) OVER (ORDER BY semana),
        0
    ) as registros_semana_anterior,
    ROUND(
        CASE 
            WHEN LAG(registros_semana) OVER (ORDER BY semana) > 0 THEN
                ((registros_semana::DECIMAL - LAG(registros_semana) OVER (ORDER BY semana)) / LAG(registros_semana) OVER (ORDER BY semana)) * 100
            ELSE 0
        END, 2
    ) as porcentaje_cambio
FROM weekly_data;

-- Función para actualizar métricas automáticamente
CREATE OR REPLACE FUNCTION public.refresh_user_metrics()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.user_metrics;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener métricas con cálculos adicionales
CREATE OR REPLACE FUNCTION public.get_dashboard_metrics()
RETURNS JSON AS $$
DECLARE
    metrics_data JSON;
    conversion_rate DECIMAL;
    approval_rate DECIMAL;
    avg_approval_time INTERVAL;
BEGIN
    -- Obtener métricas básicas
    SELECT row_to_json(m.*) INTO metrics_data
    FROM public.user_metrics m;
    
    -- Calcular tasa de conversión (email verificado -> aprobado)
    SELECT 
        CASE 
            WHEN COUNT(*) FILTER (WHERE email_verificado = TRUE) > 0 THEN
                ROUND(
                    (COUNT(*) FILTER (WHERE estado = 'ACTIVA')::DECIMAL / 
                     COUNT(*) FILTER (WHERE email_verificado = TRUE)) * 100, 2
                )
            ELSE 0
        END
    INTO conversion_rate
    FROM public.usuarios;
    
    -- Calcular tasa de aprobación general
    SELECT 
        CASE 
            WHEN COUNT(*) FILTER (WHERE estado IN ('ACTIVA', 'RECHAZADA')) > 0 THEN
                ROUND(
                    (COUNT(*) FILTER (WHERE estado = 'ACTIVA')::DECIMAL / 
                     COUNT(*) FILTER (WHERE estado IN ('ACTIVA', 'RECHAZADA'))) * 100, 2
                )
            ELSE 0
        END
    INTO approval_rate
    FROM public.usuarios;
    
    -- Calcular tiempo promedio de aprobación
    SELECT 
        AVG(fecha_aprobacion - created_at)
    INTO avg_approval_time
    FROM public.usuarios 
    WHERE fecha_aprobacion IS NOT NULL 
    AND created_at >= NOW() - INTERVAL '30 days';
    
    -- Combinar toda la información
    RETURN json_build_object(
        'metrics', metrics_data,
        'conversion_rate', COALESCE(conversion_rate, 0),
        'approval_rate', COALESCE(approval_rate, 0),
        'avg_approval_time_hours', COALESCE(EXTRACT(EPOCH FROM avg_approval_time) / 3600, 0),
        'generated_at', NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para actualizar métricas automáticamente cuando cambian usuarios
CREATE OR REPLACE FUNCTION public.trigger_refresh_metrics()
RETURNS TRIGGER AS $$
BEGIN
    -- Programar actualización de métricas (no bloquear la transacción)
    PERFORM pg_notify('refresh_metrics', 'user_change');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Crear trigger que se ejecuta después de cambios en usuarios
CREATE TRIGGER trigger_user_metrics_refresh
    AFTER INSERT OR UPDATE OR DELETE ON public.usuarios
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.trigger_refresh_metrics();

-- Vista optimizada para lista paginada de usuarios
CREATE OR REPLACE VIEW public.usuarios_lista_optimizada AS
SELECT 
    u.id,
    u.email,
    u.nombre_completo,
    u.estado,
    u.email_verificado,
    u.ultimo_acceso,
    u.created_at,
    u.fecha_aprobacion,
    u.fecha_suspension,
    u.tienda_asignada,
    r.nombre as rol_nombre,
    r.descripcion as rol_descripcion,
    t.nombre as tienda_nombre,
    t.codigo as tienda_codigo,
    CASE 
        WHEN u.aprobado_por IS NOT NULL THEN admin.nombre_completo
        ELSE NULL
    END as aprobado_por_nombre,
    -- Campos calculados
    CASE 
        WHEN u.estado = 'PENDIENTE_APROBACION' AND u.created_at < NOW() - INTERVAL '7 days' THEN 'MUY_URGENTE'
        WHEN u.estado = 'PENDIENTE_APROBACION' AND u.created_at < NOW() - INTERVAL '3 days' THEN 'URGENTE'
        ELSE 'NORMAL'
    END as prioridad,
    
    CASE 
        WHEN u.ultimo_acceso IS NULL THEN 'NUNCA'
        WHEN u.ultimo_acceso >= NOW() - INTERVAL '7 days' THEN 'RECIENTE'
        WHEN u.ultimo_acceso >= NOW() - INTERVAL '30 days' THEN 'MENSUAL'
        ELSE 'INACTIVO'
    END as actividad_reciente,
    
    -- Score para ordenamiento inteligente
    (
        CASE WHEN u.estado = 'PENDIENTE_APROBACION' THEN 100 ELSE 0 END +
        CASE WHEN u.created_at < NOW() - INTERVAL '3 days' AND u.estado = 'PENDIENTE_APROBACION' THEN 50 ELSE 0 END +
        CASE WHEN u.ultimo_acceso >= NOW() - INTERVAL '7 days' THEN 10 ELSE 0 END
    ) as priority_score
    
FROM public.usuarios u
JOIN public.roles r ON u.rol_id = r.id
LEFT JOIN public.tiendas t ON u.tienda_asignada = t.id
LEFT JOIN public.usuarios admin ON u.aprobado_por = admin.id;

-- Función para búsqueda full-text optimizada
CREATE OR REPLACE FUNCTION public.search_usuarios(
    search_term TEXT,
    limite INTEGER DEFAULT 20,
    offset_val INTEGER DEFAULT 0,
    filtro_estado TEXT DEFAULT NULL,
    filtro_rol TEXT DEFAULT NULL,
    filtro_tienda UUID DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    email VARCHAR,
    nombre_completo VARCHAR,
    estado VARCHAR,
    rol_nombre VARCHAR,
    tienda_nombre VARCHAR,
    priority_score INTEGER,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        u.id,
        u.email,
        u.nombre_completo,
        u.estado,
        u.rol_nombre,
        u.tienda_nombre,
        u.priority_score,
        ts_rank(
            to_tsvector('spanish', COALESCE(u.nombre_completo, '') || ' ' || COALESCE(u.email, '')),
            plainto_tsquery('spanish', search_term)
        ) as rank
    FROM public.usuarios_lista_optimizada u
    WHERE (
        search_term IS NULL OR search_term = '' OR
        to_tsvector('spanish', COALESCE(u.nombre_completo, '') || ' ' || COALESCE(u.email, '')) @@ plainto_tsquery('spanish', search_term)
    )
    AND (filtro_estado IS NULL OR filtro_estado = 'TODOS' OR u.estado = filtro_estado)
    AND (filtro_rol IS NULL OR filtro_rol = 'TODOS' OR u.rol_nombre = filtro_rol)
    AND (filtro_tienda IS NULL OR u.tienda_asignada = filtro_tienda)
    ORDER BY 
        CASE WHEN search_term IS NOT NULL AND search_term != '' THEN rank ELSE u.priority_score END DESC,
        u.created_at DESC
    LIMIT limite
    OFFSET offset_val;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentarios
COMMENT ON MATERIALIZED VIEW public.user_metrics IS 'Métricas agregadas de usuarios actualizadas automáticamente';
COMMENT ON VIEW public.user_weekly_trends IS 'Tendencias semanales de registro y aprobación de usuarios';
COMMENT ON FUNCTION public.get_dashboard_metrics() IS 'Función que retorna métricas completas del dashboard incluyendo cálculos avanzados';
COMMENT ON FUNCTION public.search_usuarios(TEXT, INTEGER, INTEGER, TEXT, TEXT, UUID) IS 'Búsqueda full-text optimizada de usuarios con filtros';