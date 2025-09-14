-- Migración: Solución definitiva para triggers duplicados
-- Fecha: 2025-09-14
-- Descripción: Elimina y recrea triggers de manera definitiva para evitar conflictos

-- ==============================================================================
-- SOLUCIÓN DEFINITIVA: DROP + CREATE
-- ==============================================================================

-- 1. Eliminar cualquier trigger existente (sin error si no existe)
DROP TRIGGER IF EXISTS trigger_materiales_updated_at ON public.materiales;

-- 2. Recrear trigger solo si la tabla existe
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'materiales' AND table_schema = 'public') THEN
        -- Usar la función estándar actual
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
        END IF;
    END IF;
END $$;

-- Verificar que se creó correctamente
SELECT 'Trigger definitivamente creado' as status, COUNT(*) as count
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE t.tgname = 'trigger_materiales_updated_at'
AND c.relname = 'materiales'
AND n.nspname = 'public';