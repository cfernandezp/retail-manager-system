-- =====================================================
-- QUERIES DE EJEMPLO - SISTEMA MEDIAS MULTI-TIENDA
-- =====================================================
-- Descripción: Ejemplos de queries optimizadas para casos de uso comunes
-- Versión: 1.0.0
-- Fecha: 2025-09-11

-- =====================================================
-- 1. BÚSQUEDAS POS - TIEMPO REAL
-- =====================================================

-- Búsqueda por SKU (más común en POS)
SELECT * FROM vw_articulos_pos 
WHERE sku = 'POL-ARL-912-AZU';

-- Búsqueda por código de barras
SELECT * FROM vw_articulos_pos 
WHERE codigo_barras = '7801234567890';

-- Búsqueda por nombre (con índice de texto completo)
SELECT * FROM vw_articulos_pos 
WHERE to_tsvector('spanish', nombre_completo) @@ plainto_tsquery('spanish', 'media arley azul');

-- Búsqueda avanzada con filtros
SELECT * FROM vw_articulos_pos 
WHERE marca_nombre ILIKE '%arley%'
AND categoria_nombre = 'Polyester'
AND talla_codigo = '9-12'
ORDER BY nombre_completo;

-- =====================================================
-- 2. INVENTARIO POR TIENDA - DASHBOARD
-- =====================================================

-- Stock actual de una tienda específica
SELECT 
    sku,
    nombre_completo,
    stock_actual,
    precio_venta,
    valor_inventario,
    estado_stock
FROM vw_inventario_consolidado 
WHERE tienda_id = 'uuid-tienda-gamarra'
ORDER BY valor_inventario DESC;

-- Artículos con stock bajo en tienda
SELECT 
    sku,
    nombre_completo,
    stock_actual,
    stock_minimo,
    (stock_minimo - stock_actual) as cantidad_faltante
FROM vw_inventario_consolidado 
WHERE tienda_id = 'uuid-tienda-gamarra'
AND estado_stock = 'STOCK_BAJO'
ORDER BY cantidad_faltante DESC;

-- Artículos sin movimiento reciente (más de 30 días)
SELECT 
    sku,
    nombre_completo,
    stock_actual,
    valor_inventario,
    dias_sin_venta
FROM vw_inventario_consolidado 
WHERE tienda_id = 'uuid-tienda-gamarra'
AND (dias_sin_venta > 30 OR dias_sin_venta IS NULL)
AND stock_actual > 0
ORDER BY dias_sin_venta DESC NULLS FIRST;

-- =====================================================
-- 3. REPORTES DE MOVIMIENTOS
-- =====================================================

-- Movimientos del día actual
SELECT 
    articulo_sku,
    articulo_nombre,
    tipo_movimiento,
    cantidad,
    precio_unitario,
    costo_total,
    usuario_nombre,
    fecha_movimiento
FROM vw_movimientos_detallados
WHERE tienda_id = 'uuid-tienda-gamarra'
AND DATE(fecha_movimiento) = CURRENT_DATE
ORDER BY fecha_movimiento DESC;

-- Resumen de ventas por día (últimos 7 días)
SELECT 
    DATE(fecha_movimiento) as fecha,
    COUNT(*) as total_transacciones,
    SUM(ABS(cantidad)) as unidades_vendidas,
    SUM(costo_total) as total_ventas
FROM vw_movimientos_detallados
WHERE tienda_id = 'uuid-tienda-gamarra'
AND tipo_movimiento = 'VENTA'
AND fecha_movimiento >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(fecha_movimiento)
ORDER BY fecha DESC;

-- Artículos más vendidos (último mes)
SELECT 
    articulo_sku,
    articulo_nombre,
    marca_nombre,
    SUM(ABS(cantidad)) as total_vendido,
    SUM(costo_total) as total_ingresos,
    COUNT(*) as transacciones
FROM vw_movimientos_detallados
WHERE tienda_id = 'uuid-tienda-gamarra'
AND tipo_movimiento = 'VENTA'
AND fecha_movimiento >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY articulo_sku, articulo_nombre, marca_nombre
ORDER BY total_vendido DESC
LIMIT 10;

-- =====================================================
-- 4. ANÁLISIS DE INVENTARIO
-- =====================================================

-- Análisis ABC por valor de inventario
SELECT 
    clasificacion_abc,
    COUNT(*) as total_articulos,
    SUM(stock_actual) as total_unidades,
    SUM(valor_inventario) as valor_total,
    ROUND(AVG(valor_inventario), 2) as valor_promedio
FROM vw_analisis_ventas_stock
WHERE tienda_id = 'uuid-tienda-gamarra'
GROUP BY clasificacion_abc
ORDER BY 
    CASE clasificacion_abc 
        WHEN 'A' THEN 1 
        WHEN 'B' THEN 2 
        WHEN 'C' THEN 3 
    END;

-- Rotación de inventario por marca
SELECT 
    marca_nombre,
    COUNT(*) as total_articulos,
    SUM(stock_actual) as stock_total,
    SUM(unidades_vendidas_mes) as ventas_mes,
    ROUND(
        CASE 
            WHEN SUM(stock_actual) > 0 THEN SUM(unidades_vendidas_mes)::DECIMAL / SUM(stock_actual) * 30
            ELSE 0 
        END, 
        2
    ) as rotacion_dias
FROM vw_analisis_ventas_stock
WHERE tienda_id = 'uuid-tienda-gamarra'
GROUP BY marca_nombre
ORDER BY rotacion_dias DESC;

-- =====================================================
-- 5. COMPARATIVA ENTRE TIENDAS
-- =====================================================

-- Comparativa de stock por artículo entre tiendas
SELECT 
    a.sku,
    a.nombre_completo,
    json_object_agg(
        t.codigo, 
        json_build_object(
            'stock', COALESCE(it.stock_actual, 0),
            'precio', COALESCE(it.precio_venta, pm.precio_sugerido)
        )
    ) as inventario_por_tienda,
    SUM(COALESCE(it.stock_actual, 0)) as stock_total_sistema
FROM articulos a
JOIN productos_master pm ON a.producto_master_id = pm.id
CROSS JOIN tiendas t
LEFT JOIN inventario_tienda it ON a.id = it.articulo_id AND t.id = it.tienda_id
WHERE a.estado = 'ACTIVO'
AND t.activo = true
AND a.sku = 'POL-ARL-912-AZU' -- Ejemplo específico
GROUP BY a.id, a.sku, a.nombre_completo;

-- Resumen de inventario por tienda
SELECT 
    tienda_nombre,
    total_articulos,
    articulos_con_stock,
    articulos_sin_stock,
    articulos_stock_bajo,
    ROUND(valor_total_inventario, 2) as valor_inventario,
    ROUND(stock_total_unidades, 0) as total_unidades,
    ultima_actualizacion
FROM vw_dashboard_inventario
ORDER BY valor_total_inventario DESC;

-- =====================================================
-- 6. QUERIES PARA TRASPASOS
-- =====================================================

-- Ver artículos disponibles para traspaso desde una tienda
SELECT 
    articulo_id,
    sku,
    nombre_completo,
    stock_actual,
    precio_venta,
    (stock_actual - stock_minimo) as disponible_para_traspaso
FROM vw_inventario_consolidado
WHERE tienda_id = 'uuid-tienda-origen'
AND stock_actual > stock_minimo
AND stock_actual > 0
ORDER BY disponible_para_traspaso DESC;

-- Historial de traspasos entre tiendas
SELECT 
    md.fecha_movimiento,
    md.articulo_sku,
    md.articulo_nombre,
    md.cantidad_absoluta,
    md.tienda_nombre as tienda_destino,
    md.tienda_origen_nombre as tienda_origen,
    md.usuario_nombre,
    md.motivo
FROM vw_movimientos_detallados md
WHERE md.tipo_movimiento = 'TRASPASO'
AND md.categoria_movimiento = 'ENTRADA'
ORDER BY md.fecha_movimiento DESC
LIMIT 50;

-- =====================================================
-- 7. QUERIES DE AUDITORÍA
-- =====================================================

-- Cambios de precio en las últimas 24 horas
SELECT 
    ms.created_at,
    a.sku,
    a.nombre_completo,
    t.codigo as tienda,
    ms.motivo,
    pu.nombre_completo as usuario
FROM movimientos_stock ms
JOIN articulos a ON ms.articulo_id = a.id
JOIN tiendas t ON ms.tienda_id = t.id
LEFT JOIN perfiles_usuario pu ON ms.usuario_id = pu.id
WHERE ms.tipo_movimiento = 'AJUSTE'
AND ms.motivo LIKE '%precio%'
AND ms.created_at >= NOW() - INTERVAL '24 hours'
ORDER BY ms.created_at DESC;

-- Discrepancias de stock (comparar último movimiento vs stock actual)
SELECT 
    a.sku,
    a.nombre_completo,
    t.codigo as tienda,
    it.stock_actual,
    (
        SELECT stock_nuevo 
        FROM movimientos_stock ms 
        WHERE ms.articulo_id = a.id 
        AND ms.tienda_id = t.id 
        ORDER BY created_at DESC 
        LIMIT 1
    ) as ultimo_stock_calculado,
    (
        it.stock_actual - (
            SELECT stock_nuevo 
            FROM movimientos_stock ms 
            WHERE ms.articulo_id = a.id 
            AND ms.tienda_id = t.id 
            ORDER BY created_at DESC 
            LIMIT 1
        )
    ) as discrepancia
FROM inventario_tienda it
JOIN articulos a ON it.articulo_id = a.id
JOIN tiendas t ON it.tienda_id = t.id
WHERE it.activo = true
HAVING (
    it.stock_actual - (
        SELECT COALESCE(stock_nuevo, 0)
        FROM movimientos_stock ms 
        WHERE ms.articulo_id = a.id 
        AND ms.tienda_id = t.id 
        ORDER BY created_at DESC 
        LIMIT 1
    )
) != 0;

-- =====================================================
-- 8. QUERIES DE PERFORMANCE - CATÁLOGO
-- =====================================================

-- Catálogo completo con estadísticas (para SUPER_ADMIN)
SELECT 
    producto_nombre,
    marca_nombre,
    categoria_nombre,
    talla_codigo,
    total_variantes,
    variantes_activas,
    array_to_string(colores_disponibles, ', ') as colores,
    COALESCE(precio_minimo_tienda, precio_sugerido) as precio_desde,
    COALESCE(precio_maximo_tienda, precio_sugerido) as precio_hasta,
    stock_total_sistema
FROM vw_catalogo_completo
WHERE producto_estado = 'ACTIVO'
ORDER BY marca_nombre, producto_nombre;

-- Artículos sin stock en ninguna tienda
SELECT 
    vc.producto_nombre,
    vc.marca_nombre,
    array_to_string(vc.colores_disponibles, ', ') as variantes_sin_stock
FROM vw_catalogo_completo vc
WHERE vc.stock_total_sistema = 0
AND vc.producto_estado = 'ACTIVO'
ORDER BY vc.marca_nombre, vc.producto_nombre;

-- =====================================================
-- 9. QUERIES PARA REPORTES EJECUTIVOS
-- =====================================================

-- KPIs principales por tienda (último mes)
WITH kpis_tienda AS (
    SELECT 
        t.id as tienda_id,
        t.nombre as tienda_nombre,
        -- Ventas
        COUNT(*) FILTER (WHERE ms.tipo_movimiento = 'VENTA') as total_ventas,
        SUM(ms.costo_total) FILTER (WHERE ms.tipo_movimiento = 'VENTA') as ingresos_ventas,
        SUM(ABS(ms.cantidad)) FILTER (WHERE ms.tipo_movimiento = 'VENTA') as unidades_vendidas,
        -- Inventario
        (SELECT COUNT(*) FROM inventario_tienda it WHERE it.tienda_id = t.id AND it.activo = true) as articulos_activos,
        (SELECT COUNT(*) FROM inventario_tienda it WHERE it.tienda_id = t.id AND it.stock_actual <= it.stock_minimo) as articulos_stock_bajo,
        (SELECT SUM(it.stock_actual * it.precio_venta) FROM inventario_tienda it WHERE it.tienda_id = t.id AND it.activo = true) as valor_inventario
    FROM tiendas t
    LEFT JOIN movimientos_stock ms ON t.id = ms.tienda_id 
        AND ms.created_at >= CURRENT_DATE - INTERVAL '30 days'
    WHERE t.activo = true
    GROUP BY t.id, t.nombre
)
SELECT 
    tienda_nombre,
    total_ventas,
    ROUND(ingresos_ventas, 2) as ingresos_total,
    unidades_vendidas,
    ROUND(ingresos_ventas / NULLIF(total_ventas, 0), 2) as venta_promedio,
    articulos_activos,
    articulos_stock_bajo,
    ROUND(articulos_stock_bajo::DECIMAL / NULLIF(articulos_activos, 0) * 100, 1) as porcentaje_stock_bajo,
    ROUND(valor_inventario, 2) as valor_inventario
FROM kpis_tienda
ORDER BY ingresos_ventas DESC NULLS LAST;

-- Productos más rentables (margen y volumen)
SELECT 
    pm.nombre as producto,
    m.nombre as marca,
    c.nombre as categoria,
    COUNT(DISTINCT a.id) as variantes_color,
    SUM(it.stock_actual) as stock_total,
    ROUND(AVG(it.precio_venta - it.precio_costo), 2) as margen_promedio,
    ROUND(AVG((it.precio_venta - it.precio_costo) / NULLIF(it.precio_costo, 0) * 100), 1) as margen_porcentaje,
    (
        SELECT SUM(ABS(ms.cantidad)) 
        FROM movimientos_stock ms 
        JOIN articulos a2 ON ms.articulo_id = a2.id
        WHERE a2.producto_master_id = pm.id 
        AND ms.tipo_movimiento = 'VENTA'
        AND ms.created_at >= CURRENT_DATE - INTERVAL '30 days'
    ) as unidades_vendidas_mes
FROM productos_master pm
JOIN marcas m ON pm.marca_id = m.id
JOIN categorias c ON pm.categoria_id = c.id
JOIN articulos a ON pm.id = a.producto_master_id
JOIN inventario_tienda it ON a.id = it.articulo_id
WHERE pm.estado = 'ACTIVO'
AND a.estado = 'ACTIVO'
AND it.activo = true
GROUP BY pm.id, pm.nombre, m.nombre, c.nombre
HAVING COUNT(DISTINCT a.id) > 0
ORDER BY margen_promedio DESC, unidades_vendidas_mes DESC NULLS LAST;