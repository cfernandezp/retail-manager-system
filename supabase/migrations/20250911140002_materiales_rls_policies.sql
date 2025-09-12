-- Migración: Políticas RLS para tabla materiales
-- Fecha: 2025-09-11
-- Descripción: Implementar Row Level Security para tabla materiales

-- ==============================================================================
-- 1. HABILITAR RLS EN TABLA MATERIALES
-- ==============================================================================

ALTER TABLE public.materiales ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- 2. POLÍTICAS DE LECTURA (SELECT)
-- ==============================================================================

-- Permitir lectura a todos los usuarios autenticados (materiales son catálogo público)
CREATE POLICY "materiales_select_authenticated" ON public.materiales
    FOR SELECT
    TO authenticated
    USING (true);

-- Permitir lectura a usuarios anónimos solo para materiales activos
CREATE POLICY "materiales_select_anonymous" ON public.materiales
    FOR SELECT
    TO anon
    USING (activo = true);

-- ==============================================================================
-- 3. POLÍTICAS DE ESCRITURA (INSERT, UPDATE, DELETE)
-- ==============================================================================

-- Solo administradores pueden crear materiales
CREATE POLICY "materiales_insert_admin" ON public.materiales
    FOR INSERT
    TO authenticated
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

-- Solo administradores pueden actualizar materiales
CREATE POLICY "materiales_update_admin" ON public.materiales
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

-- Solo administradores pueden eliminar materiales (soft delete recomendado)
CREATE POLICY "materiales_delete_admin" ON public.materiales
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- ==============================================================================
-- 4. HABILITAR REALTIME PARA MATERIALES
-- ==============================================================================

-- Agregar tabla a realtime para notificaciones en vivo
ALTER PUBLICATION supabase_realtime ADD TABLE public.materiales;

-- ==============================================================================
-- 5. COMENTARIOS PARA DOCUMENTACIÓN
-- ==============================================================================

COMMENT ON POLICY "materiales_select_authenticated" ON public.materiales IS 
'Permite lectura de materiales a usuarios autenticados';

COMMENT ON POLICY "materiales_select_anonymous" ON public.materiales IS 
'Permite lectura de materiales activos a usuarios anónimos';

COMMENT ON POLICY "materiales_insert_admin" ON public.materiales IS 
'Solo administradores pueden crear nuevos materiales';

COMMENT ON POLICY "materiales_update_admin" ON public.materiales IS 
'Solo administradores pueden actualizar materiales existentes';

COMMENT ON POLICY "materiales_delete_admin" ON public.materiales IS 
'Solo administradores pueden eliminar materiales';

-- ==============================================================================
-- VERIFICACIÓN DE POLÍTICAS
-- ==============================================================================

DO $$
BEGIN
    -- Verificar que RLS esté habilitado
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'materiales' 
        AND rowsecurity = true
    ) THEN
        RAISE EXCEPTION 'RLS no está habilitado en tabla materiales';
    END IF;
    
    -- Mostrar conteo de políticas creadas
    RAISE NOTICE 'Políticas RLS creadas para materiales: %', 
        (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'materiales');
        
    RAISE NOTICE 'Tabla materiales agregada a realtime: %',
        (SELECT COUNT(*) FROM pg_publication_tables WHERE tablename = 'materiales');
END$$;