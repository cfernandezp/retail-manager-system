-- Migración: Limpiar triggers duplicados de materiales
-- Fecha: 2025-09-14
-- Descripción: Eliminar y recrear triggers que están causando conflictos

-- ==============================================================================
-- 1. ELIMINAR TRIGGER DUPLICADO DE MATERIALES
-- ==============================================================================

-- Eliminar trigger si existe (para evitar duplicados)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE t.tgname = 'trigger_materiales_updated_at'
        AND c.relname = 'materiales'
        AND n.nspname = 'public'
    ) THEN
        DROP TRIGGER trigger_materiales_updated_at ON public.materiales;
    END IF;
END $$;

-- ==============================================================================
-- 2. RECREAR TRIGGER CORRECTAMENTE
-- ==============================================================================

-- Crear trigger usando la función disponible
DO $$
BEGIN
    -- Verificar que la tabla materiales existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'materiales' AND table_schema = 'public') THEN
        -- Usar la función actualizar_updated_at que es la estándar actual
        IF EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = 'actualizar_updated_at'
            AND n.nspname = 'public'
        ) THEN
            CREATE TRIGGER trigger_materiales_updated_at
                BEFORE UPDATE ON public.materiales
                FOR EACH ROW
                EXECUTE FUNCTION public.actualizar_updated_at();
        -- Fallback a la función anterior si existe
        ELSIF EXISTS (
            SELECT 1 FROM pg_proc p
            WHERE p.proname = 'update_updated_at'
        ) THEN
            CREATE TRIGGER trigger_materiales_updated_at
                BEFORE UPDATE ON public.materiales
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at();
        END IF;
    END IF;
END $$;

-- ==============================================================================
-- 3. COMENTARIOS
-- ==============================================================================

COMMENT ON TRIGGER trigger_materiales_updated_at ON public.materiales IS 'Actualiza campo updated_at automáticamente';

-- Verificar que el trigger se creó correctamente
SELECT
    'Trigger recreado correctamente' as status,
    COUNT(*) as trigger_count
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE t.tgname = 'trigger_materiales_updated_at'
AND c.relname = 'materiales'
AND n.nspname = 'public';