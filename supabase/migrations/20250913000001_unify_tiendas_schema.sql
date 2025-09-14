-- =====================================================
-- MIGRACIÓN: Unificación del Esquema de Tiendas
-- =====================================================
-- Fecha: 2025-09-13
-- Descripción: Unificar campos inconsistentes en tabla tiendas
-- Problema: campos activo/activa mixtos, admin_tienda_id/manager_id duplicados
-- Solución: Estandarizar a 'activa' y 'manager_id', corregir vistas

BEGIN;

-- =====================================================
-- 1. UNIFICACIÓN DE CAMPOS EN TABLA TIENDAS
-- =====================================================

-- Paso 1: Asegurar que existe columna 'activa'
DO $$
BEGIN
    -- Si existe 'activo' y no existe 'activa', renombrar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activo')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activa') THEN
        ALTER TABLE public.tiendas RENAME COLUMN activo TO activa;
        RAISE NOTICE 'Campo activo renombrado a activa';
    END IF;

    -- Si no existe ninguno de los dos, crear 'activa'
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activa')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activo') THEN
        ALTER TABLE public.tiendas ADD COLUMN activa BOOLEAN DEFAULT TRUE;
        RAISE NOTICE 'Campo activa creado';
    END IF;

    -- Si existen ambos, migrar datos de 'activo' a 'activa' y eliminar 'activo'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activo')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activa') THEN
        UPDATE public.tiendas SET activa = activo WHERE activa IS NULL;
        ALTER TABLE public.tiendas DROP COLUMN activo;
        RAISE NOTICE 'Datos migrados de activo a activa, columna activo eliminada';
    END IF;
END $$;

-- Paso 2: Unificar campos de administrador a 'manager_id'
DO $$
BEGIN
    -- Si existe 'admin_tienda_id' y no existe 'manager_id', renombrar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'admin_tienda_id')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'manager_id') THEN
        ALTER TABLE public.tiendas RENAME COLUMN admin_tienda_id TO manager_id;
        RAISE NOTICE 'Campo admin_tienda_id renombrado a manager_id';
    END IF;

    -- Si existen ambos, migrar datos y eliminar admin_tienda_id
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'admin_tienda_id')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'manager_id') THEN
        UPDATE public.tiendas
        SET manager_id = admin_tienda_id
        WHERE manager_id IS NULL AND admin_tienda_id IS NOT NULL;
        ALTER TABLE public.tiendas DROP COLUMN admin_tienda_id;
        RAISE NOTICE 'Datos migrados de admin_tienda_id a manager_id, columna admin_tienda_id eliminada';
    END IF;

    -- Si no existe manager_id, crearlo
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'manager_id') THEN
        ALTER TABLE public.tiendas ADD COLUMN manager_id UUID;
        RAISE NOTICE 'Campo manager_id creado';
    END IF;
END $$;

-- =====================================================
-- 2. CORRECCIÓN DE VISTAS QUE USAN CAMPOS OBSOLETOS
-- =====================================================

-- Recrear vista estadisticas_por_tienda usando campos unificados
DROP VIEW IF EXISTS public.estadisticas_por_tienda;

CREATE VIEW public.estadisticas_por_tienda AS
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
WHERE t.activa = TRUE  -- CORREGIDO: usar 'activa' en lugar de 'activo'
GROUP BY t.id, t.nombre, t.codigo, t.manager_id, m.nombre_completo
ORDER BY t.codigo;

-- =====================================================
-- 3. ACTUALIZACIÓN DE ÍNDICES
-- =====================================================

-- Eliminar índices obsoletos si existen
DROP INDEX IF EXISTS idx_tiendas_activo;
DROP INDEX IF EXISTS idx_tiendas_admin_tienda;

-- Crear índices con campos unificados
CREATE INDEX IF NOT EXISTS idx_tiendas_activa ON public.tiendas(activa) WHERE activa = TRUE;
CREATE INDEX IF NOT EXISTS idx_tiendas_manager ON public.tiendas(manager_id) WHERE manager_id IS NOT NULL;

-- =====================================================
-- 4. ACTUALIZACIÓN DE FOREIGN KEYS
-- =====================================================

-- Verificar y recrear foreign key para manager_id si no existe
DO $$
BEGIN
    -- Eliminar constraint obsoleto si existe
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tiendas_admin_tienda') THEN
        ALTER TABLE public.tiendas DROP CONSTRAINT fk_tiendas_admin_tienda;
        RAISE NOTICE 'Constraint obsoleto fk_tiendas_admin_tienda eliminado';
    END IF;

    -- Crear nuevo constraint para manager_id (si existe tabla usuarios)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'usuarios') THEN
        ALTER TABLE public.tiendas
        ADD CONSTRAINT fk_tiendas_manager
        FOREIGN KEY (manager_id) REFERENCES public.usuarios(id);
        RAISE NOTICE 'Nuevo constraint fk_tiendas_manager creado';
    END IF;
END $$;

-- =====================================================
-- 5. VERIFICACIÓN FINAL
-- =====================================================

-- Verificar estructura final de tabla tiendas
DO $$
DECLARE
    col_activa BOOLEAN;
    col_manager BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tiendas' AND column_name = 'activa'
    ) INTO col_activa;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tiendas' AND column_name = 'manager_id'
    ) INTO col_manager;

    IF col_activa AND col_manager THEN
        RAISE NOTICE '✅ Migración completada exitosamente:';
        RAISE NOTICE '   - Campo activa: %', col_activa;
        RAISE NOTICE '   - Campo manager_id: %', col_manager;
        RAISE NOTICE '   - Vista estadisticas_por_tienda actualizada';
        RAISE NOTICE '   - Índices recreados';
    ELSE
        RAISE EXCEPTION '❌ Error en migración: activa=%, manager_id=%', col_activa, col_manager;
    END IF;
END $$;

-- =====================================================
-- 6. COMENTARIOS ACTUALIZADOS
-- =====================================================

COMMENT ON TABLE public.tiendas IS 'Catálogo unificado de tiendas del sistema retail';
COMMENT ON COLUMN public.tiendas.activa IS 'Estado de la tienda (unificado desde activo/activa)';
COMMENT ON COLUMN public.tiendas.manager_id IS 'Usuario manager de la tienda (unificado desde admin_tienda_id/manager_id)';
COMMENT ON VIEW public.estadisticas_por_tienda IS 'Estadísticas de usuarios por tienda (actualizada con campos unificados)';

COMMIT;

-- =====================================================
-- LOG DE MIGRACIÓN
-- =====================================================
-- Esta migración unifica los campos inconsistentes:
-- ✅ activo/activa → activa (boolean)
-- ✅ admin_tienda_id/manager_id → manager_id (UUID)
-- ✅ Vista estadisticas_por_tienda corregida
-- ✅ Índices actualizados
-- ✅ Foreign keys recreados
-- ✅ Compatible con modelo Flutter existente