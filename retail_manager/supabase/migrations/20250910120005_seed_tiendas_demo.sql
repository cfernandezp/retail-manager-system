-- Migración: Datos de Ejemplo para Tiendas
-- Fecha: 2025-09-10
-- Descripción: Insertar tiendas de ejemplo para testing y demostración

-- Insertar tiendas de ejemplo solo si no existen
INSERT INTO public.tiendas (id, nombre, codigo, direccion, telefono, email, configuracion) 
VALUES 
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    'Tienda Central Lima',
    'T001',
    'Av. Javier Prado 1234, San Isidro, Lima',
    '+51 1 234-5678',
    'central@retailmanager.pe',
    '{
        "horario_atencion": {
            "lunes_viernes": "09:00-20:00",
            "sabados": "09:00-21:00", 
            "domingos": "10:00-18:00"
        },
        "pos_config": {
            "impresora": "EPSON_TM_T20III",
            "cajones": 2,
            "scanner": true
        },
        "inventario_config": {
            "stock_minimo_global": 5,
            "alertas_activadas": true
        }
    }'::JSONB
),
(
    '22222222-2222-2222-2222-222222222222'::UUID,
    'Tienda Norte Comas',
    'T002', 
    'Av. Túpac Amaru 567, Comas, Lima',
    '+51 1 345-6789',
    'comas@retailmanager.pe',
    '{
        "horario_atencion": {
            "lunes_viernes": "08:30-19:30",
            "sabados": "08:30-20:00",
            "domingos": "09:00-17:00"
        },
        "pos_config": {
            "impresora": "STAR_TSP143III",
            "cajones": 1,
            "scanner": true
        },
        "inventario_config": {
            "stock_minimo_global": 3,
            "alertas_activadas": true
        }
    }'::JSONB
),
(
    '33333333-3333-3333-3333-333333333333'::UUID,
    'Tienda Este Villa El Salvador',
    'T003',
    'Av. El Sol 890, Villa El Salvador, Lima',
    '+51 1 456-7890', 
    'ves@retailmanager.pe',
    '{
        "horario_atencion": {
            "lunes_viernes": "09:00-19:00",
            "sabados": "09:00-19:30",
            "domingos": "10:00-17:00"
        },
        "pos_config": {
            "impresora": "BIXOLON_SRP350III",
            "cajones": 1,
            "scanner": false
        },
        "inventario_config": {
            "stock_minimo_global": 2,
            "alertas_activadas": false
        }
    }'::JSONB
),
(
    '44444444-4444-4444-4444-444444444444'::UUID,
    'Tienda Sur Chorrillos',  
    'T004',
    'Av. Huaylas 321, Chorrillos, Lima',
    '+51 1 567-8901',
    'chorrillos@retailmanager.pe',
    '{
        "horario_atencion": {
            "lunes_viernes": "09:30-20:00",
            "sabados": "09:00-21:00",
            "domingos": "10:30-18:00"
        },
        "pos_config": {
            "impresora": "EPSON_TM_T88VI",
            "cajones": 2,
            "scanner": true
        },
        "inventario_config": {
            "stock_minimo_global": 4,
            "alertas_activadas": true
        }
    }'::JSONB
)
ON CONFLICT (codigo) DO NOTHING;

-- Actualizar la vista materializada de métricas para incluir los nuevos datos
REFRESH MATERIALIZED VIEW public.user_metrics;

-- Función para asignar usuarios existentes a tiendas aleatoriamente (solo para testing)
CREATE OR REPLACE FUNCTION public.asignar_usuarios_tiendas_demo()
RETURNS INTEGER AS $$
DECLARE
    tiendas_ids UUID[] := ARRAY[
        '11111111-1111-1111-1111-111111111111'::UUID,
        '22222222-2222-2222-2222-222222222222'::UUID,
        '33333333-3333-3333-3333-333333333333'::UUID,
        '44444444-4444-4444-4444-444444444444'::UUID
    ];
    usuario_record RECORD;
    random_tienda UUID;
    updated_count INTEGER := 0;
BEGIN
    -- Solo asignar usuarios que no tengan tienda asignada y no sean SUPER_ADMIN
    FOR usuario_record IN 
        SELECT u.id 
        FROM public.usuarios u
        JOIN public.roles r ON u.rol_id = r.id
        WHERE u.tienda_asignada IS NULL 
        AND r.nombre != 'SUPER_ADMIN'
        AND u.estado = 'ACTIVA'
    LOOP
        -- Seleccionar una tienda aleatoria
        random_tienda := tiendas_ids[1 + floor(random() * array_length(tiendas_ids, 1))::int];
        
        -- Asignar la tienda
        UPDATE public.usuarios 
        SET tienda_asignada = random_tienda 
        WHERE id = usuario_record.id;
        
        updated_count := updated_count + 1;
    END LOOP;
    
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar la asignación automática (solo en desarrollo/testing)
-- SELECT public.asignar_usuarios_tiendas_demo();

-- Función para generar datos de testing adicionales
CREATE OR REPLACE FUNCTION public.generar_usuarios_testing(cantidad INTEGER DEFAULT 20)
RETURNS INTEGER AS $$
DECLARE
    i INTEGER;
    tiendas_ids UUID[] := ARRAY[
        '11111111-1111-1111-1111-111111111111'::UUID,
        '22222222-2222-2222-2222-222222222222'::UUID,
        '33333333-3333-3333-3333-333333333333'::UUID,
        '44444444-4444-4444-4444-444444444444'::UUID
    ];
    estados VARCHAR[] := ARRAY['PENDIENTE_APROBACION', 'ACTIVA', 'SUSPENDIDA'];
    roles_ids UUID[];
    random_user_id UUID;
    random_estado VARCHAR;
    random_tienda UUID;
    random_role UUID;
    created_count INTEGER := 0;
BEGIN
    -- Obtener IDs de roles disponibles
    SELECT ARRAY(SELECT id FROM public.roles WHERE nombre IN ('OPERARIO', 'VENDEDOR', 'ADMIN')) 
    INTO roles_ids;
    
    FOR i IN 1..cantidad LOOP
        random_user_id := gen_random_uuid();
        random_estado := estados[1 + floor(random() * array_length(estados, 1))::int];
        random_tienda := tiendas_ids[1 + floor(random() * array_length(tiendas_ids, 1))::int];
        random_role := roles_ids[1 + floor(random() * array_length(roles_ids, 1))::int];
        
        -- Insertar usuario de testing
        INSERT INTO public.usuarios (
            id,
            email,
            nombre_completo,
            rol_id,
            estado,
            email_verificado,
            tienda_asignada,
            created_at,
            ultimo_acceso
        ) VALUES (
            random_user_id,
            'test' || i || '@retailmanager.pe',
            'Usuario Test ' || i,
            random_role,
            random_estado,
            random() > 0.3, -- 70% tienen email verificado
            random_tienda,
            NOW() - INTERVAL '1 day' * floor(random() * 30), -- Creados en los últimos 30 días
            CASE 
                WHEN random_estado = 'ACTIVA' AND random() > 0.4 THEN
                    NOW() - INTERVAL '1 day' * floor(random() * 7) -- Último acceso en los últimos 7 días
                ELSE NULL
            END
        );
        
        created_count := created_count + 1;
    END LOOP;
    
    -- Actualizar métricas
    REFRESH MATERIALIZED VIEW public.user_metrics;
    
    RETURN created_count;
END;
$$ LANGUAGE plpgsql;

-- Vista para estadísticas por tienda
CREATE OR REPLACE VIEW public.estadisticas_por_tienda AS
SELECT 
    t.id as tienda_id,
    t.nombre as tienda_nombre,
    t.codigo as tienda_codigo,
    COUNT(u.id) as total_usuarios,
    COUNT(u.id) FILTER (WHERE u.estado = 'ACTIVA') as usuarios_activos,
    COUNT(u.id) FILTER (WHERE u.estado = 'PENDIENTE_APROBACION') as usuarios_pendientes,
    COUNT(u.id) FILTER (WHERE u.estado = 'SUSPENDIDA') as usuarios_suspendidos,
    COUNT(u.id) FILTER (WHERE u.ultimo_acceso >= NOW() - INTERVAL '7 days') as activos_ultima_semana,
    COUNT(u.id) FILTER (WHERE r.nombre = 'ADMIN') as admins,
    COUNT(u.id) FILTER (WHERE r.nombre = 'VENDEDOR') as vendedores,
    COUNT(u.id) FILTER (WHERE r.nombre = 'OPERARIO') as operarios,
    t.manager_id,
    m.nombre_completo as manager_nombre
FROM public.tiendas t
LEFT JOIN public.usuarios u ON u.tienda_asignada = t.id
LEFT JOIN public.roles r ON u.rol_id = r.id
LEFT JOIN public.usuarios m ON t.manager_id = m.id
WHERE t.activa = TRUE
GROUP BY t.id, t.nombre, t.codigo, t.manager_id, m.nombre_completo
ORDER BY t.codigo;

-- Función para estadísticas de performance por tienda
CREATE OR REPLACE FUNCTION public.get_tienda_performance_stats(tienda_id UUID DEFAULT NULL)
RETURNS JSON AS $$
DECLARE
    stats_data JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'tienda_id', tienda_id,
            'tienda_nombre', tienda_nombre,
            'tienda_codigo', tienda_codigo,
            'total_usuarios', total_usuarios,
            'usuarios_activos', usuarios_activos,
            'usuarios_pendientes', usuarios_pendientes,
            'tasa_actividad_semanal', 
                CASE 
                    WHEN total_usuarios > 0 THEN 
                        ROUND((activos_ultima_semana::DECIMAL / total_usuarios) * 100, 2)
                    ELSE 0 
                END,
            'distribucion_roles', json_build_object(
                'admins', admins,
                'vendedores', vendedores, 
                'operarios', operarios
            ),
            'manager', json_build_object(
                'id', manager_id,
                'nombre', manager_nombre
            )
        )
    ) INTO stats_data
    FROM public.estadisticas_por_tienda
    WHERE (tienda_id IS NULL OR estadisticas_por_tienda.tienda_id = tienda_id);
    
    RETURN COALESCE(stats_data, '[]'::JSON);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentarios
COMMENT ON FUNCTION public.asignar_usuarios_tiendas_demo() IS 'Función para asignar usuarios existentes a tiendas (solo testing)';
COMMENT ON FUNCTION public.generar_usuarios_testing(INTEGER) IS 'Genera usuarios de prueba para testing del sistema';
COMMENT ON VIEW public.estadisticas_por_tienda IS 'Estadísticas agregadas de usuarios por tienda';
COMMENT ON FUNCTION public.get_tienda_performance_stats(UUID) IS 'Estadísticas de performance y actividad por tienda';