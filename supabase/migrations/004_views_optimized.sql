-- =====================================================
-- VIEWS OPTIMIZADAS - SISTEMA MEDIAS MULTI-TIENDA
-- =====================================================
-- Descripción: Views para consultas POS, reportes y dashboards
-- Versión: 1.0.0
-- Fecha: 2025-09-11

BEGIN;

-- =====================================================
-- 1. VIEW PARA POS - BÚSQUEDA RÁPIDA DE ARTÍCULOS
-- =====================================================

-- View principal para POS con todos los datos necesarios
CREATE OR REPLACE VIEW vw_articulos_pos AS
SELECT 
    -- Identificadores
    a.id as articulo_id,
    a.sku,
    a.codigo_barras,
    a.nombre_completo,
    
    -- Información del producto master
    pm.id as producto_master_id,
    pm.nombre as producto_nombre,
    pm.descripcion as producto_descripcion,
    pm.precio_sugerido,
    pm.imagen_principal_url,
    
    -- Marca
    m.id as marca_id,
    m.nombre as marca_nombre,
    m.logo_url as marca_logo,
    
    -- Categoría
    c.id as categoria_id,
    c.nombre as categoria_nombre,
    
    -- Talla
    t.id as talla_id,
    t.codigo as talla_codigo,
    t.tipo as talla_tipo,
    t.talla_min,
    t.talla_max,
    t.talla_unica,
    
    -- Color
    col.id as color_id,
    col.nombre as color_nombre,
    col.codigo_hex as color_hex,
    
    -- Estado
    a.estado as articulo_estado,
    pm.estado as producto_estado,
    
    -- Metadatos
    a.peso_gramos,
    a.imagen_url as articulo_imagen,
    a.created_at,
    a.updated_at
    
FROM articulos a
JOIN productos_master pm ON a.producto_master_id = pm.id
JOIN marcas m ON pm.marca_id = m.id
JOIN categorias c ON pm.categoria_id = c.id
JOIN tallas t ON pm.talla_id = t.id
JOIN colores col ON a.color_id = col.id
WHERE a.estado = 'ACTIVO' 
AND pm.estado = 'ACTIVO'
AND m.activo = true
AND c.activo = true
AND t.activo = true
AND col.activo = true;

-- Índices para la view POS
CREATE INDEX IF NOT EXISTS idx_vw_pos_sku ON articulos(sku) WHERE estado = 'ACTIVO';
CREATE INDEX IF NOT EXISTS idx_vw_pos_codigo_barras ON articulos(codigo_barras) WHERE codigo_barras IS NOT NULL AND estado = 'ACTIVO';

-- =====================================================
-- 2. VIEW PARA INVENTARIO CONSOLIDADO POR TIENDA
-- =====================================================

CREATE OR REPLACE VIEW vw_inventario_consolidado AS
SELECT 
    -- Identificadores de inventario
    it.id as inventario_id,
    it.tienda_id,
    ti.nombre as tienda_nombre,
    ti.codigo as tienda_codigo,
    
    -- Información del artículo (desde view POS)
    pos.articulo_id,
    pos.sku,
    pos.codigo_barras,
    pos.nombre_completo,
    pos.producto_nombre,
    pos.marca_nombre,
    pos.categoria_nombre,
    pos.talla_codigo,
    pos.color_nombre,
    pos.color_hex,
    
    -- Stock e inventario
    it.stock_actual,
    it.stock_minimo,
    it.stock_maximo,
    it.precio_venta,
    it.precio_costo,
    it.ubicacion_fisica,
    it.activo as inventario_activo,
    it.ultima_venta,
    
    -- Cálculos
    (it.stock_actual * it.precio_venta) as valor_inventario,
    (it.precio_venta - it.precio_costo) as margen_unitario,
    CASE 
        WHEN it.precio_costo > 0 THEN 
            ROUND(((it.precio_venta - it.precio_costo) / it.precio_costo * 100), 2)
        ELSE NULL 
    END as margen_porcentaje,
    
    -- Estado del stock
    CASE 
        WHEN it.stock_actual = 0 THEN 'SIN_STOCK'
        WHEN it.stock_actual <= it.stock_minimo THEN 'STOCK_BAJO'
        WHEN it.stock_maximo IS NOT NULL AND it.stock_actual >= it.stock_maximo THEN 'STOCK_ALTO'
        ELSE 'STOCK_OK'
    END as estado_stock,
    
    -- Días sin venta
    CASE 
        WHEN it.ultima_venta IS NULL THEN NULL
        ELSE EXTRACT(DAY FROM NOW() - it.ultima_venta)::INTEGER
    END as dias_sin_venta,
    
    -- Metadatos
    it.created_at as inventario_created_at,
    it.updated_at as inventario_updated_at
    
FROM inventario_tienda it
JOIN tiendas ti ON it.tienda_id = ti.id
JOIN vw_articulos_pos pos ON it.articulo_id = pos.articulo_id
WHERE ti.activo = true
AND it.activo = true;

-- Índices para inventario consolidado
CREATE INDEX IF NOT EXISTS idx_inventario_consolidado_tienda_stock ON inventario_tienda(tienda_id, stock_actual);
CREATE INDEX IF NOT EXISTS idx_inventario_consolidado_estado ON inventario_tienda(tienda_id) 
    WHERE stock_actual <= stock_minimo AND stock_minimo > 0;

-- =====================================================
-- 3. VIEW PARA DASHBOARD - MÉTRICAS DE INVENTARIO
-- =====================================================

CREATE OR REPLACE VIEW vw_dashboard_inventario AS
SELECT 
    ti.id as tienda_id,
    ti.nombre as tienda_nombre,
    ti.codigo as tienda_codigo,
    
    -- Contadores de artículos
    COUNT(*) as total_articulos,
    COUNT(*) FILTER (WHERE it.stock_actual > 0) as articulos_con_stock,
    COUNT(*) FILTER (WHERE it.stock_actual = 0) as articulos_sin_stock,
    COUNT(*) FILTER (WHERE it.stock_actual <= it.stock_minimo AND it.stock_minimo > 0) as articulos_stock_bajo,
    
    -- Valores de inventario
    COALESCE(SUM(it.stock_actual * it.precio_venta), 0) as valor_total_inventario,
    COALESCE(SUM(it.stock_actual * it.precio_costo), 0) as costo_total_inventario,
    COALESCE(AVG(it.precio_venta), 0) as precio_promedio,
    
    -- Stock totales
    COALESCE(SUM(it.stock_actual), 0) as stock_total_unidades,
    COALESCE(AVG(it.stock_actual), 0) as stock_promedio_por_articulo,
    
    -- Última actualización
    MAX(it.updated_at) as ultima_actualizacion
    
FROM tiendas ti
LEFT JOIN inventario_tienda it ON ti.id = it.tienda_id AND it.activo = true
WHERE ti.activo = true
GROUP BY ti.id, ti.nombre, ti.codigo;

-- =====================================================
-- 4. VIEW PARA REPORTES DE MOVIMIENTOS
-- =====================================================

CREATE OR REPLACE VIEW vw_movimientos_detallados AS
SELECT 
    -- Movimiento
    ms.id as movimiento_id,
    ms.tipo_movimiento,
    ms.cantidad,
    ms.stock_anterior,
    ms.stock_nuevo,
    ms.precio_unitario,
    ms.costo_total,
    ms.motivo,
    ms.referencia_externa,
    ms.created_at as fecha_movimiento,
    
    -- Tienda
    ti.id as tienda_id,
    ti.nombre as tienda_nombre,
    ti.codigo as tienda_codigo,
    
    -- Tienda origen (para traspasos)
    to_tienda.id as tienda_origen_id,
    to_tienda.nombre as tienda_origen_nombre,
    to_tienda.codigo as tienda_origen_codigo,
    
    -- Artículo
    pos.articulo_id,
    pos.sku,
    pos.codigo_barras,
    pos.nombre_completo,
    pos.marca_nombre,
    pos.categoria_nombre,
    pos.talla_codigo,
    pos.color_nombre,
    
    -- Usuario
    pu.id as usuario_id,
    pu.nombre_completo as usuario_nombre,
    pu.rol as usuario_rol,
    
    -- Cálculos adicionales
    ABS(ms.cantidad) as cantidad_absoluta,
    CASE 
        WHEN ms.tipo_movimiento IN ('ENTRADA', 'DEVOLUCION') THEN 'ENTRADA'
        WHEN ms.tipo_movimiento IN ('SALIDA', 'VENTA') THEN 'SALIDA'
        WHEN ms.tipo_movimiento = 'TRASPASO' AND ms.cantidad > 0 THEN 'ENTRADA'
        WHEN ms.tipo_movimiento = 'TRASPASO' AND ms.cantidad < 0 THEN 'SALIDA'
        ELSE 'AJUSTE'
    END as categoria_movimiento
    
FROM movimientos_stock ms
JOIN tiendas ti ON ms.tienda_id = ti.id
JOIN vw_articulos_pos pos ON ms.articulo_id = pos.articulo_id
LEFT JOIN tiendas to_tienda ON ms.tienda_origen_id = to_tienda.id
LEFT JOIN perfiles_usuario pu ON ms.usuario_id = pu.id;

-- Índices para movimientos detallados
CREATE INDEX IF NOT EXISTS idx_movimientos_detallados_fecha ON movimientos_stock(tienda_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_movimientos_detallados_tipo ON movimientos_stock(tienda_id, tipo_movimiento, created_at DESC);

-- =====================================================
-- 5. VIEW PARA CATÁLOGO COMPLETO (SUPER_ADMIN)
-- =====================================================

CREATE OR REPLACE VIEW vw_catalogo_completo AS
SELECT 
    -- Producto master
    pm.id as producto_master_id,
    pm.nombre as producto_nombre,
    pm.descripcion as producto_descripcion,
    pm.precio_sugerido,
    pm.estado as producto_estado,
    pm.imagen_principal_url,
    pm.created_at as producto_created_at,
    
    -- Marca
    m.id as marca_id,
    m.nombre as marca_nombre,
    m.prefijo_sku as marca_prefijo,
    m.logo_url as marca_logo,
    
    -- Categoría
    c.id as categoria_id,
    c.nombre as categoria_nombre,
    c.prefijo_sku as categoria_prefijo,
    
    -- Talla
    t.id as talla_id,
    t.codigo as talla_codigo,
    t.tipo as talla_tipo,
    t.talla_min,
    t.talla_max,
    t.talla_unica,
    t.orden_display as talla_orden,
    
    -- Contadores de variantes
    COUNT(a.id) as total_variantes,
    COUNT(a.id) FILTER (WHERE a.estado = 'ACTIVO') as variantes_activas,
    
    -- Colores disponibles
    array_agg(col.nombre ORDER BY col.nombre) FILTER (WHERE a.id IS NOT NULL) as colores_disponibles,
    array_agg(col.codigo_hex ORDER BY col.nombre) FILTER (WHERE a.id IS NOT NULL) as colores_hex,
    
    -- Rango de precios en tiendas
    (
        SELECT MIN(it.precio_venta) 
        FROM articulos a2 
        JOIN inventario_tienda it ON a2.id = it.articulo_id 
        WHERE a2.producto_master_id = pm.id AND it.activo = true
    ) as precio_minimo_tienda,
    (
        SELECT MAX(it.precio_venta) 
        FROM articulos a2 
        JOIN inventario_tienda it ON a2.id = it.articulo_id 
        WHERE a2.producto_master_id = pm.id AND it.activo = true
    ) as precio_maximo_tienda,
    
    -- Stock total en todas las tiendas
    (
        SELECT COALESCE(SUM(it.stock_actual), 0)
        FROM articulos a2 
        JOIN inventario_tienda it ON a2.id = it.articulo_id 
        WHERE a2.producto_master_id = pm.id AND it.activo = true
    ) as stock_total_sistema
    
FROM productos_master pm
JOIN marcas m ON pm.marca_id = m.id
JOIN categorias c ON pm.categoria_id = c.id
JOIN tallas t ON pm.talla_id = t.id
LEFT JOIN articulos a ON pm.id = a.producto_master_id
LEFT JOIN colores col ON a.color_id = col.id
GROUP BY 
    pm.id, pm.nombre, pm.descripcion, pm.precio_sugerido, pm.estado, pm.imagen_principal_url, pm.created_at,
    m.id, m.nombre, m.prefijo_sku, m.logo_url,
    c.id, c.nombre, c.prefijo_sku,
    t.id, t.codigo, t.tipo, t.talla_min, t.talla_max, t.talla_unica, t.orden_display;

-- =====================================================
-- 6. VIEW PARA ANÁLISIS DE VENTAS (Preparado para futuro)
-- =====================================================

CREATE OR REPLACE VIEW vw_analisis_ventas_stock AS
SELECT 
    ic.tienda_id,
    ic.tienda_nombre,
    ic.articulo_id,
    ic.sku,
    ic.nombre_completo,
    ic.marca_nombre,
    ic.categoria_nombre,
    ic.stock_actual,
    ic.precio_venta,
    ic.valor_inventario,
    ic.ultima_venta,
    ic.dias_sin_venta,
    
    -- Movimientos del último mes
    (
        SELECT COUNT(*)
        FROM movimientos_stock ms
        WHERE ms.articulo_id = ic.articulo_id 
        AND ms.tienda_id = ic.tienda_id
        AND ms.tipo_movimiento = 'VENTA'
        AND ms.created_at >= NOW() - INTERVAL '30 days'
    ) as ventas_ultimo_mes,
    
    -- Unidades vendidas último mes
    (
        SELECT COALESCE(SUM(ABS(ms.cantidad)), 0)
        FROM movimientos_stock ms
        WHERE ms.articulo_id = ic.articulo_id 
        AND ms.tienda_id = ic.tienda_id
        AND ms.tipo_movimiento = 'VENTA'
        AND ms.created_at >= NOW() - INTERVAL '30 days'
    ) as unidades_vendidas_mes,
    
    -- Clasificación ABC (basado en valor de inventario)
    CASE 
        WHEN ic.valor_inventario >= (
            SELECT PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY valor_inventario)
            FROM vw_inventario_consolidado ic2 
            WHERE ic2.tienda_id = ic.tienda_id AND ic2.valor_inventario > 0
        ) THEN 'A'
        WHEN ic.valor_inventario >= (
            SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY valor_inventario)
            FROM vw_inventario_consolidado ic2 
            WHERE ic2.tienda_id = ic.tienda_id AND ic2.valor_inventario > 0
        ) THEN 'B'
        ELSE 'C'
    END as clasificacion_abc
    
FROM vw_inventario_consolidado ic
WHERE ic.stock_actual > 0;

-- =====================================================
-- 7. COMENTARIOS EN VIEWS PARA DOCUMENTACIÓN
-- =====================================================

COMMENT ON VIEW vw_articulos_pos IS 'View optimizada para POS con información completa de artículos activos';
COMMENT ON VIEW vw_inventario_consolidado IS 'View consolidada de inventario por tienda con cálculos de negocio';
COMMENT ON VIEW vw_dashboard_inventario IS 'Métricas agregadas para dashboard de inventario por tienda';
COMMENT ON VIEW vw_movimientos_detallados IS 'Movimientos de stock con información detallada para reportes';
COMMENT ON VIEW vw_catalogo_completo IS 'Catálogo completo de productos con estadísticas para SUPER_ADMIN';
COMMENT ON VIEW vw_analisis_ventas_stock IS 'Análisis de ventas y clasificación ABC para optimización de inventario';

COMMIT;