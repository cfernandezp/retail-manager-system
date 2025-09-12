-- =====================================================
-- MIGRACIÓN: POLÍTICAS RLS PARA MATERIALES
-- =====================================================
-- Descripción: Configurar Row Level Security para tabla materiales
-- Fecha: 2025-09-11
-- Versión: 1.0.0

BEGIN;

-- =====================================================
-- 1. HABILITAR RLS EN TABLA MATERIALES
-- =====================================================

ALTER TABLE public.materiales ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. POLÍTICAS DE LECTURA
-- =====================================================

-- Lectura pública para usuarios autenticados
CREATE POLICY "Materiales: Lectura pública para usuarios autenticados"
ON public.materiales
FOR SELECT
TO authenticated
USING (activo = true);

-- Lectura completa para administradores (incluyendo inactivos)
CREATE POLICY "Materiales: Lectura completa para administradores"
ON public.materiales
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.perfiles_usuario 
        WHERE id = auth.uid() 
        AND rol IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        AND activo = true
    )
);

-- =====================================================
-- 3. POLÍTICAS DE ESCRITURA (INSERT/UPDATE/DELETE)
-- =====================================================

-- Creación solo para administradores
CREATE POLICY "Materiales: Creación solo para administradores"
ON public.materiales
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.perfiles_usuario 
        WHERE id = auth.uid() 
        AND rol IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        AND activo = true
    )
);

-- Actualización solo para administradores
CREATE POLICY "Materiales: Actualización solo para administradores"
ON public.materiales
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.perfiles_usuario 
        WHERE id = auth.uid() 
        AND rol IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        AND activo = true
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.perfiles_usuario 
        WHERE id = auth.uid() 
        AND rol IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        AND activo = true
    )
);

-- Eliminación solo para administradores (soft delete - cambiar activo = false)
CREATE POLICY "Materiales: Eliminación solo para administradores"
ON public.materiales
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.perfiles_usuario 
        WHERE id = auth.uid() 
        AND rol IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        AND activo = true
    )
);

-- =====================================================
-- 4. HABILITAR REALTIME
-- =====================================================

-- Habilitar subscripciones en tiempo real para materiales
ALTER PUBLICATION supabase_realtime ADD TABLE public.materiales;

-- =====================================================
-- 5. GRANTS ESPECÍFICOS
-- =====================================================

-- Permisos para anon (usuarios no autenticados) - solo lectura de materiales activos
GRANT SELECT ON public.materiales TO anon;

-- Permisos para authenticated (usuarios autenticados)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.materiales TO authenticated;

-- Permisos para service_role (funciones del servidor)
GRANT ALL ON public.materiales TO service_role;

-- =====================================================
-- 6. COMENTARIOS DE POLÍTICAS
-- =====================================================

COMMENT ON POLICY "Materiales: Lectura pública para usuarios autenticados" ON public.materiales 
IS 'Permite lectura de materiales activos a usuarios autenticados';

COMMENT ON POLICY "Materiales: Lectura completa para administradores" ON public.materiales 
IS 'Permite lectura completa (incluyendo inactivos) solo a administradores';

COMMENT ON POLICY "Materiales: Creación solo para administradores" ON public.materiales 
IS 'Permite creación de nuevos materiales solo a administradores activos';

COMMENT ON POLICY "Materiales: Actualización solo para administradores" ON public.materiales 
IS 'Permite actualización de materiales solo a administradores activos';

COMMENT ON POLICY "Materiales: Eliminación solo para administradores" ON public.materiales 
IS 'Permite eliminación de materiales solo a administradores activos';

COMMIT;