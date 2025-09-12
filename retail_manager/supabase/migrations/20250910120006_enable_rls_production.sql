-- Migración: Habilitar RLS para Producción
-- Fecha: 2025-09-10
-- Descripción: Re-habilitar Row Level Security después de las optimizaciones

-- ⚠️  IMPORTANTE: Esta migración RE-HABILITA Row Level Security ⚠️
-- Solo ejecutar cuando todo esté funcionando correctamente

-- Habilitar RLS en todas las tablas principales
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria_usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones_tiempo_real ENABLE ROW LEVEL SECURITY;

-- Verificar que todas las políticas estén activas
DO $$ 
DECLARE
    pol_count INTEGER;
BEGIN
    -- Contar políticas existentes
    SELECT COUNT(*) INTO pol_count 
    FROM pg_policies 
    WHERE schemaname = 'public';
    
    -- Solo proceder si tenemos políticas suficientes
    IF pol_count < 10 THEN
        RAISE EXCEPTION 'No hay suficientes políticas RLS configuradas. Políticas encontradas: %', pol_count;
    END IF;
    
    RAISE NOTICE '✅ RLS habilitado con % políticas activas', pol_count;
END $$;

-- Log de seguridad (solo si existe un usuario admin)
DO $$ 
DECLARE
    admin_user_id UUID;
BEGIN
    -- Buscar un usuario admin existente
    SELECT id INTO admin_user_id 
    FROM public.usuarios 
    WHERE rol_id = (SELECT id FROM public.roles WHERE nombre = 'SUPER_ADMIN')
    LIMIT 1;
    
    -- Solo crear log si existe un admin
    IF admin_user_id IS NOT NULL THEN
        INSERT INTO public.auditoria_usuarios (
            usuario_id, 
            accion, 
            detalles
        ) VALUES (
            admin_user_id,
            'SISTEMA_RLS_HABILITADO',
            json_build_object(
                'timestamp', NOW(),
                'environment', 'production',
                'security_level', 'high'
            )::jsonb
        );
        RAISE NOTICE 'Log de seguridad creado para usuario: %', admin_user_id;
    ELSE
        RAISE NOTICE 'No se encontró usuario SUPER_ADMIN, saltando log de auditoría';
    END IF;
END $$;

-- Comentario final
COMMENT ON SCHEMA public IS 'Schema público con Row Level Security habilitado - Retail Manager System';