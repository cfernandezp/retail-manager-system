-- Migración: Corrección completa del esquema de tallas
-- Fecha: 2025-09-12
-- Descripción: Corregir discrepancias en tabla tallas para que funcione con el repository

-- ==============================================================================
-- 1. VERIFICAR Y AGREGAR CAMPO 'valor' A TALLAS
-- ==============================================================================

-- Agregar columna 'valor' si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='tallas' AND column_name='valor') THEN
        ALTER TABLE public.tallas ADD COLUMN valor VARCHAR(50);
        -- Copiar datos de 'codigo' a 'valor' 
        UPDATE public.tallas SET valor = codigo WHERE valor IS NULL;
        -- Hacer valor NOT NULL después de la migración de datos
        ALTER TABLE public.tallas ALTER COLUMN valor SET NOT NULL;
    END IF;
END $$;

-- ==============================================================================
-- 2. RENOMBRAR 'activa' A 'activo' PARA CONSISTENCIA
-- ==============================================================================

-- Cambiar 'activa' por 'activo' en tallas para consistencia
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='tallas' AND column_name='activa') THEN
        ALTER TABLE public.tallas RENAME COLUMN activa TO activo;
    END IF;
END $$;

-- ==============================================================================
-- 3. ACTUALIZAR ÍNDICES CON NOMBRES CORRECTOS
-- ==============================================================================

-- Recrear índices con nombres corregidos
DROP INDEX IF EXISTS idx_tallas_activa;
CREATE INDEX IF NOT EXISTS idx_tallas_activo ON public.tallas(activo);

-- ==============================================================================
-- 4. ACTUALIZAR VISTAS QUE REFERENCIAN TALLAS
-- ==============================================================================

-- Recrear vista con campos corregidos
DROP VIEW IF EXISTS public.productos_disponibles_tienda;
CREATE OR REPLACE VIEW public.productos_disponibles_tienda AS
SELECT 
    pm.id as producto_master_id,
    pm.nombre as producto_nombre,
    pm.descripcion,
    m.nombre as marca_nombre,
    c.nombre as categoria_nombre,
    t.codigo as talla_codigo,
    t.nombre as talla_nombre,
    t.valor as talla_valor,
    a.id as articulo_id,
    a.sku_auto as sku,
    a.codigo_barras,
    col.nombre as color_nombre,
    col.codigo_hex,
    it.tienda_id,
    it.stock_actual,
    it.stock_reservado,
    (it.stock_actual - it.stock_reservado) as stock_disponible,
    it.precio_venta,
    it.precio_costo,
    it.ubicacion_fisica,
    pm.imagen_principal_url,
    a.imagen_color_url,
    pm.especificaciones
FROM public.productos_master pm
JOIN public.marcas m ON pm.marca_id = m.id
JOIN public.categorias c ON pm.categoria_id = c.id
JOIN public.tallas t ON pm.talla_id = t.id
JOIN public.articulos a ON pm.id = a.producto_master_id
JOIN public.colores col ON a.color_id = col.id
LEFT JOIN public.inventario_tienda it ON a.id = it.articulo_id
WHERE pm.activo = true 
  AND a.activo = true 
  AND m.activo = true 
  AND c.activo = true 
  AND t.activo = true 
  AND col.activo = true;

-- ==============================================================================
-- 5. CORREGIR FUNCIÓN get_stock_disponible
-- ==============================================================================

-- Función para obtener stock disponible de un artículo en una tienda
CREATE OR REPLACE FUNCTION public.get_stock_disponible(
    p_articulo_id UUID,
    p_tienda_id UUID
)
RETURNS INTEGER AS $$
DECLARE
    stock_disp INTEGER := 0;
BEGIN
    SELECT COALESCE(stock_actual - stock_reservado, 0)
    INTO stock_disp
    FROM public.inventario_tienda
    WHERE articulo_id = p_articulo_id 
      AND tienda_id = p_tienda_id
      AND activo = true;
    
    RETURN COALESCE(stock_disp, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 6. VERIFICAR DATOS EXISTENTES
-- ==============================================================================

-- Mostrar estadísticas de la corrección
SELECT 
    'tallas' as tabla,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE valor IS NOT NULL) as con_valor,
    COUNT(*) FILTER (WHERE activo = true) as activos
FROM public.tallas;

-- ==============================================================================
-- 7. COMENTARIOS
-- ==============================================================================

COMMENT ON COLUMN public.tallas.valor IS 'Valor de la talla (requerido por modelo Flutter)';
COMMENT ON COLUMN public.tallas.activo IS 'Estado activo (consistencia con otros modelos)';