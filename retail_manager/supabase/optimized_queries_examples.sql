-- EJEMPLOS DE CONSULTAS OPTIMIZADAS
-- Sistema de Gestión de Usuarios Retail
-- =====================================

-- 1. DASHBOARD DE MÉTRICAS
-- Obtener métricas completas del dashboard con cálculos avanzados
SELECT public.get_dashboard_metrics();

-- Obtener métricas básicas de la vista materializada
SELECT * FROM public.user_metrics;

-- Obtener tendencias semanales
SELECT * FROM public.user_weekly_trends;

-- 2. BÚSQUEDA DE USUARIOS OPTIMIZADA
-- Búsqueda full-text con filtros y paginación
SELECT * FROM public.search_usuarios(
    search_term := 'juan',           -- Buscar por nombre o email
    limite := 10,                    -- Límite de resultados
    offset_val := 0,                 -- Offset para paginación
    filtro_estado := 'ACTIVA',       -- Filtrar por estado
    filtro_rol := 'VENDEDOR',        -- Filtrar por rol
    filtro_tienda := '11111111-1111-1111-1111-111111111111'::UUID -- Filtrar por tienda
);

-- Búsqueda sin filtros (todos los usuarios)
SELECT * FROM public.search_usuarios(
    search_term := NULL,
    limite := 20,
    offset_val := 0
);

-- 3. VISTA OPTIMIZADA DE USUARIOS
-- Lista completa con campos calculados
SELECT 
    id,
    email,
    nombre_completo,
    estado,
    rol_nombre,
    tienda_nombre,
    prioridad,              -- NORMAL, URGENTE, MUY_URGENTE
    actividad_reciente,     -- NUNCA, RECIENTE, MENSUAL, INACTIVO
    priority_score          -- Score para ordenamiento
FROM public.usuarios_lista_optimizada
WHERE estado = 'PENDIENTE_APROBACION'
ORDER BY priority_score DESC, created_at ASC;

-- Usuarios urgentes (más de 3 días pendientes)
SELECT * FROM public.usuarios_lista_optimizada
WHERE prioridad IN ('URGENTE', 'MUY_URGENTE')
ORDER BY created_at ASC;

-- 4. GESTIÓN DE TIENDAS
-- Obtener tiendas accesibles por el usuario actual
SELECT * FROM public.obtener_tiendas_accesibles();

-- Verificar acceso a una tienda específica
SELECT public.tiene_acceso_tienda('11111111-1111-1111-1111-111111111111'::UUID);

-- Estadísticas por tienda
SELECT * FROM public.estadisticas_por_tienda;

-- Performance stats de todas las tiendas
SELECT public.get_tienda_performance_stats();

-- Performance stats de una tienda específica
SELECT public.get_tienda_performance_stats('11111111-1111-1111-1111-111111111111'::UUID);

-- 5. NOTIFICACIONES EN TIEMPO REAL
-- Ver notificaciones del usuario actual
SELECT * FROM public.mis_notificaciones;

-- Marcar todas las notificaciones como leídas
SELECT public.marcar_notificaciones_leidas();

-- Marcar notificaciones específicas como leídas
SELECT public.marcar_notificaciones_leidas(ARRAY[
    'notification-id-1'::UUID,
    'notification-id-2'::UUID
]);

-- Crear notificación manual (solo admins)
SELECT public.crear_notificacion(
    p_usuario_destino := 'user-id'::UUID,
    p_tipo := 'USUARIO_APROBADO',
    p_titulo := 'Cuenta aprobada',
    p_mensaje := 'Tu cuenta ha sido aprobada exitosamente',
    p_prioridad := 'ALTA',
    p_expires_in_hours := 72
);

-- Notificar a todos los admins
SELECT public.notificar_admins(
    p_tipo := 'USUARIO_PENDIENTE',
    p_titulo := 'Nuevo usuario pendiente',
    p_mensaje := 'Hay un nuevo usuario esperando aprobación',
    p_prioridad := 'NORMAL'
);

-- 6. OPERACIONES ADMINISTRATIVAS
-- Verificar si el usuario actual es admin
SELECT public.es_admin_activo();

-- Obtener rol del usuario actual
SELECT public.obtener_rol_usuario();

-- Validar operación masiva
SELECT public.validar_operacion_masiva(
    usuario_ids := ARRAY['user1'::UUID, 'user2'::UUID],
    operacion := 'APROBAR'
);

-- 7. CONSULTAS DE AUDITORÍA
-- Ver auditoría de un usuario específico
SELECT 
    a.accion,
    a.detalles,
    a.created_at,
    u.nombre_completo as realizada_por
FROM public.auditoria_usuarios a
LEFT JOIN public.usuarios u ON a.realizada_por = u.id
WHERE a.usuario_id = 'target-user-id'::UUID
ORDER BY a.created_at DESC;

-- Actividad reciente en el sistema
SELECT 
    u.nombre_completo,
    u.email,
    a.accion,
    a.created_at
FROM public.auditoria_usuarios a
JOIN public.usuarios u ON a.usuario_id = u.id
WHERE a.created_at >= NOW() - INTERVAL '24 hours'
ORDER BY a.created_at DESC;

-- 8. LIMPIEZA Y MANTENIMIENTO
-- Limpiar notificaciones expiradas
SELECT public.limpiar_notificaciones_expiradas();

-- Actualizar métricas manualmente
SELECT public.refresh_user_metrics();

-- 9. GENERACIÓN DE DATOS DE TESTING
-- Generar usuarios de prueba (solo desarrollo)
-- SELECT public.generar_usuarios_testing(50);

-- Asignar usuarios existentes a tiendas aleatoriamente (solo desarrollo)
-- SELECT public.asignar_usuarios_tiendas_demo();

-- 10. CONSULTAS DE PERFORMANCE
-- Usuarios por estado y fecha
SELECT 
    estado,
    DATE_TRUNC('day', created_at) as fecha,
    COUNT(*) as cantidad
FROM public.usuarios
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY estado, DATE_TRUNC('day', created_at)
ORDER BY fecha DESC, estado;

-- Actividad de usuarios por tienda
SELECT 
    t.nombre as tienda,
    COUNT(u.id) as total_usuarios,
    COUNT(u.id) FILTER (WHERE u.ultimo_acceso >= NOW() - INTERVAL '7 days') as activos_semana,
    ROUND(
        (COUNT(u.id) FILTER (WHERE u.ultimo_acceso >= NOW() - INTERVAL '7 days')::DECIMAL / 
         NULLIF(COUNT(u.id), 0)) * 100, 2
    ) as porcentaje_actividad
FROM public.tiendas t
LEFT JOIN public.usuarios u ON u.tienda_asignada = t.id AND u.estado = 'ACTIVA'
WHERE t.activa = TRUE
GROUP BY t.id, t.nombre
ORDER BY porcentaje_actividad DESC;

-- Tiempo promedio de aprobación por semana
SELECT 
    DATE_TRUNC('week', created_at) as semana,
    COUNT(*) as usuarios_creados,
    COUNT(*) FILTER (WHERE estado = 'ACTIVA') as usuarios_aprobados,
    AVG(
        CASE 
            WHEN fecha_aprobacion IS NOT NULL THEN 
                EXTRACT(EPOCH FROM (fecha_aprobacion - created_at)) / 3600
            ELSE NULL
        END
    )::INTEGER as horas_promedio_aprobacion
FROM public.usuarios
WHERE created_at >= NOW() - INTERVAL '8 weeks'
GROUP BY DATE_TRUNC('week', created_at)
ORDER BY semana DESC;

-- 11. SUBSCRIPCIONES REALTIME (para usar en Flutter)
-- Escuchar cambios en usuarios:
-- supabase.from('usuarios').stream(primaryKey: ['id'])

-- Escuchar cambios en notificaciones:
-- supabase.from('notificaciones_tiempo_real').stream(primaryKey: ['id'])
-- .eq('usuario_destino', userId)

-- Escuchar cambios en auditoría:
-- supabase.from('auditoria_usuarios').stream(primaryKey: ['id'])

-- 12. EDGE FUNCTIONS (llamadas desde Flutter)
-- Aprobación masiva:
-- POST /functions/v1/user-operations/bulk-approve
-- Body: {"user_ids": ["uuid1", "uuid2"], "approval_reason": "Bulk approval"}

-- Obtener métricas:
-- GET /functions/v1/user-operations/metrics

-- Notificaciones urgentes:
-- GET /functions/v1/user-operations/urgent-notifications