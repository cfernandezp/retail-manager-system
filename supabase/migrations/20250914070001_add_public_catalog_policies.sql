-- Migración: Agregar políticas públicas para catálogo básico
-- Fecha: 2025-09-14
-- Descripción: Permitir lectura pública de marcas, categorías y tallas para formularios

-- ==============================================================================
-- POLÍTICAS PÚBLICAS PARA LECTURA DE CATÁLOGO
-- ==============================================================================

-- Política pública para marcas activas
CREATE POLICY "marcas_public_read"
    ON public.marcas
    FOR SELECT
    USING (activo = true);

-- Política pública para categorías activas
CREATE POLICY "categorias_public_read"
    ON public.categorias
    FOR SELECT
    USING (activo = true);

-- Política pública para tallas activas
CREATE POLICY "tallas_public_read"
    ON public.tallas
    FOR SELECT
    USING (activo = true);

-- Nota: materiales ya tiene política pública, no necesita cambios

-- Comentarios para documentar el propósito
COMMENT ON POLICY "marcas_public_read" ON public.marcas IS 'Permite lectura pública de marcas activas para formularios de catálogo';
COMMENT ON POLICY "categorias_public_read" ON public.categorias IS 'Permite lectura pública de categorías activas para formularios de catálogo';
COMMENT ON POLICY "tallas_public_read" ON public.tallas IS 'Permite lectura pública de tallas activas para formularios de catálogo';