-- Migración: Políticas RLS para Módulo Productos Multi-Tienda
-- Fecha: 2025-09-11
-- Descripción: Implementar Row Level Security para SUPER_ADMIN, ADMIN_TIENDA, VENDEDOR

-- ==============================================================================
-- 1. HABILITAR RLS EN TODAS LAS TABLAS
-- ==============================================================================

ALTER TABLE public.marcas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tallas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.colores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.productos_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articulos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventario_tienda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimientos_stock ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- 2. FUNCIÓN AUXILIAR PARA OBTENER ROL DEL USUARIO
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT r.nombre INTO user_role
    FROM public.usuarios u
    JOIN public.roles r ON u.rol_id = r.id
    WHERE u.id = auth.uid();
    
    RETURN COALESCE(user_role, 'ANONYMOUS');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener tienda asignada del usuario
CREATE OR REPLACE FUNCTION public.get_user_tienda()
RETURNS UUID AS $$
DECLARE
    user_tienda UUID;
BEGIN
    SELECT u.tienda_asignada INTO user_tienda
    FROM public.usuarios u
    WHERE u.id = auth.uid();
    
    RETURN user_tienda;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 3. POLÍTICAS PARA TABLAS MAESTRAS DEL CATÁLOGO
-- ==============================================================================

-- MARCAS: SUPER_ADMIN full access, otros solo lectura
CREATE POLICY "marcas_select_policy" ON public.marcas
    FOR SELECT
    TO authenticated
    USING (true); -- Todos pueden leer marcas activas

CREATE POLICY "marcas_insert_policy" ON public.marcas
    FOR INSERT
    TO authenticated
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "marcas_update_policy" ON public.marcas
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "marcas_delete_policy" ON public.marcas
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- CATEGORIAS: Mismas reglas que marcas
CREATE POLICY "categorias_select_policy" ON public.categorias
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "categorias_insert_policy" ON public.categorias
    FOR INSERT
    TO authenticated
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "categorias_update_policy" ON public.categorias
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "categorias_delete_policy" ON public.categorias
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- TALLAS: Mismas reglas que marcas
CREATE POLICY "tallas_select_policy" ON public.tallas
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "tallas_insert_policy" ON public.tallas
    FOR INSERT
    TO authenticated
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "tallas_update_policy" ON public.tallas
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "tallas_delete_policy" ON public.tallas
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- COLORES: Mismas reglas que marcas
CREATE POLICY "colores_select_policy" ON public.colores
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "colores_insert_policy" ON public.colores
    FOR INSERT
    TO authenticated
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "colores_update_policy" ON public.colores
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "colores_delete_policy" ON public.colores
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- ==============================================================================
-- 4. POLÍTICAS PARA PRODUCTOS MASTER
-- ==============================================================================

CREATE POLICY "productos_master_select_policy" ON public.productos_master
    FOR SELECT
    TO authenticated
    USING (true); -- Todos pueden ver el catálogo central

CREATE POLICY "productos_master_insert_policy" ON public.productos_master
    FOR INSERT
    TO authenticated
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "productos_master_update_policy" ON public.productos_master
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "productos_master_delete_policy" ON public.productos_master
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- ==============================================================================
-- 5. POLÍTICAS PARA ARTÍCULOS
-- ==============================================================================

CREATE POLICY "articulos_select_policy" ON public.articulos
    FOR SELECT
    TO authenticated
    USING (true); -- Todos pueden ver artículos del catálogo

CREATE POLICY "articulos_insert_policy" ON public.articulos
    FOR INSERT
    TO authenticated
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "articulos_update_policy" ON public.articulos
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

CREATE POLICY "articulos_delete_policy" ON public.articulos
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- ==============================================================================
-- 6. POLÍTICAS PARA INVENTARIO POR TIENDA (Más restrictivas)
-- ==============================================================================

-- SELECT: SUPER_ADMIN ve todo, ADMIN/VENDEDOR solo su tienda
CREATE POLICY "inventario_select_policy" ON public.inventario_tienda
    FOR SELECT
    TO authenticated
    USING (
        public.get_user_role() = 'SUPER_ADMIN' OR
        tienda_id = public.get_user_tienda()
    );

-- INSERT: Solo SUPER_ADMIN y ADMIN_TIENDA
CREATE POLICY "inventario_insert_policy" ON public.inventario_tienda
    FOR INSERT
    TO authenticated
    WITH CHECK (
        public.get_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'ADMIN_TIENDA') AND
        (public.get_user_role() = 'SUPER_ADMIN' OR tienda_id = public.get_user_tienda())
    );

-- UPDATE: SUPER_ADMIN full, ADMIN solo precios/stock de su tienda, VENDEDOR nada
CREATE POLICY "inventario_update_policy" ON public.inventario_tienda
    FOR UPDATE
    TO authenticated
    USING (
        (public.get_user_role() = 'SUPER_ADMIN') OR
        (public.get_user_role() IN ('ADMIN', 'ADMIN_TIENDA') AND tienda_id = public.get_user_tienda())
    )
    WITH CHECK (
        (public.get_user_role() = 'SUPER_ADMIN') OR
        (public.get_user_role() IN ('ADMIN', 'ADMIN_TIENDA') AND tienda_id = public.get_user_tienda())
    );

-- DELETE: Solo SUPER_ADMIN
CREATE POLICY "inventario_delete_policy" ON public.inventario_tienda
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- ==============================================================================
-- 7. POLÍTICAS PARA MOVIMIENTOS DE STOCK
-- ==============================================================================

-- SELECT: SUPER_ADMIN ve todo, ADMIN/VENDEDOR solo su tienda
CREATE POLICY "movimientos_select_policy" ON public.movimientos_stock
    FOR SELECT
    TO authenticated
    USING (
        public.get_user_role() = 'SUPER_ADMIN' OR
        tienda_id = public.get_user_tienda()
    );

-- INSERT: SUPER_ADMIN y ADMIN pueden crear movimientos, VENDEDOR solo ventas
CREATE POLICY "movimientos_insert_policy" ON public.movimientos_stock
    FOR INSERT
    TO authenticated
    WITH CHECK (
        -- SUPER_ADMIN puede todo
        (public.get_user_role() = 'SUPER_ADMIN') OR
        -- ADMIN solo en su tienda
        (public.get_user_role() IN ('ADMIN', 'ADMIN_TIENDA') AND tienda_id = public.get_user_tienda()) OR
        -- VENDEDOR solo ventas en su tienda
        (public.get_user_role() IN ('VENDEDOR', 'OPERARIO') AND 
         tienda_id = public.get_user_tienda() AND 
         tipo_movimiento IN ('SALIDA_VENTA', 'RESERVA', 'LIBERACION_RESERVA'))
    );

-- UPDATE: Solo SUPER_ADMIN (movimientos son inmutables)
CREATE POLICY "movimientos_update_policy" ON public.movimientos_stock
    FOR UPDATE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN')
    WITH CHECK (public.get_user_role() = 'SUPER_ADMIN');

-- DELETE: Solo SUPER_ADMIN
CREATE POLICY "movimientos_delete_policy" ON public.movimientos_stock
    FOR DELETE
    TO authenticated
    USING (public.get_user_role() = 'SUPER_ADMIN');

-- ==============================================================================
-- 8. VISTAS OPTIMIZADAS PARA CONSULTAS POS
-- ==============================================================================

-- Vista para consulta rápida de productos disponibles por tienda
CREATE OR REPLACE VIEW public.productos_disponibles_tienda AS
SELECT 
    pm.id as producto_master_id,
    pm.nombre as producto_nombre,
    pm.descripcion,
    m.nombre as marca_nombre,
    c.nombre as categoria_nombre,
    t.codigo as talla_codigo,
    t.nombre as talla_nombre,
    a.id as articulo_id,
    a.sku,
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
  AND m.activa = true 
  AND c.activa = true 
  AND t.activa = true 
  AND col.activo = true;

-- NOTA: No se puede aplicar RLS directamente a vistas
-- La seguridad se maneja a través de las políticas RLS de las tablas subyacentes
-- (productos_master, inventario_tienda, etc.)

-- Vista para stock consolidado por producto master
CREATE OR REPLACE VIEW public.stock_consolidado_productos AS
SELECT 
    pm.id as producto_master_id,
    pm.nombre as producto_nombre,
    m.nombre as marca_nombre,
    c.nombre as categoria_nombre,
    t.codigo as talla_codigo,
    COUNT(DISTINCT a.id) as total_articulos,
    COUNT(DISTINCT it.tienda_id) as tiendas_con_stock,
    SUM(COALESCE(it.stock_actual, 0)) as stock_total,
    SUM(COALESCE(it.stock_reservado, 0)) as reservado_total,
    MIN(it.precio_venta) as precio_minimo,
    MAX(it.precio_venta) as precio_maximo,
    AVG(it.precio_venta) as precio_promedio,
    pm.precio_sugerido
FROM public.productos_master pm
JOIN public.marcas m ON pm.marca_id = m.id
JOIN public.categorias c ON pm.categoria_id = c.id
JOIN public.tallas t ON pm.talla_id = t.id
LEFT JOIN public.articulos a ON pm.id = a.producto_master_id AND a.activo = true
LEFT JOIN public.inventario_tienda it ON a.id = it.articulo_id AND it.activo = true
WHERE pm.activo = true
GROUP BY pm.id, pm.nombre, m.nombre, c.nombre, t.codigo, pm.precio_sugerido;

-- ==============================================================================
-- 9. FUNCIONES PARA OPERACIONES COMUNES
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

-- Función para registrar venta (movimiento de stock)
CREATE OR REPLACE FUNCTION public.registrar_venta_stock(
    p_tienda_id UUID,
    p_articulo_id UUID,
    p_cantidad INTEGER,
    p_precio_unitario DECIMAL,
    p_usuario_id UUID DEFAULT auth.uid()
)
RETURNS UUID AS $$
DECLARE
    stock_anterior INTEGER;
    movimiento_id UUID;
    stock_disponible INTEGER;
BEGIN
    -- Verificar permisos
    IF NOT (public.get_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'ADMIN_TIENDA', 'VENDEDOR', 'OPERARIO') AND
            (public.get_user_role() = 'SUPER_ADMIN' OR public.get_user_tienda() = p_tienda_id)) THEN
        RAISE EXCEPTION 'Sin permisos para registrar venta en esta tienda';
    END IF;
    
    -- Obtener stock actual
    SELECT stock_actual INTO stock_anterior
    FROM public.inventario_tienda
    WHERE tienda_id = p_tienda_id AND articulo_id = p_articulo_id;
    
    IF stock_anterior IS NULL THEN
        RAISE EXCEPTION 'Artículo no existe en inventario de la tienda';
    END IF;
    
    -- Verificar stock disponible
    stock_disponible := public.get_stock_disponible(p_articulo_id, p_tienda_id);
    IF stock_disponible < p_cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %, Solicitado: %', stock_disponible, p_cantidad;
    END IF;
    
    -- Registrar movimiento de salida
    INSERT INTO public.movimientos_stock (
        tienda_id, articulo_id, tipo_movimiento, cantidad,
        stock_anterior, stock_resultante, precio_unitario, usuario_id
    ) VALUES (
        p_tienda_id, p_articulo_id, 'SALIDA_VENTA', -p_cantidad,
        stock_anterior, stock_anterior - p_cantidad, p_precio_unitario, p_usuario_id
    ) RETURNING id INTO movimiento_id;
    
    RETURN movimiento_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 10. COMENTARIOS
-- ==============================================================================

COMMENT ON FUNCTION public.get_user_role() IS 'Obtiene el rol del usuario autenticado actual';
COMMENT ON FUNCTION public.get_user_tienda() IS 'Obtiene la tienda asignada del usuario actual';
COMMENT ON VIEW public.productos_disponibles_tienda IS 'Vista optimizada para consultas POS con stock por tienda';
COMMENT ON VIEW public.stock_consolidado_productos IS 'Vista consolidada de stock total por producto master';
COMMENT ON FUNCTION public.get_stock_disponible(UUID, UUID) IS 'Calcula stock disponible (actual - reservado)';
COMMENT ON FUNCTION public.registrar_venta_stock IS 'Registra movimiento de venta con validaciones de stock y permisos';