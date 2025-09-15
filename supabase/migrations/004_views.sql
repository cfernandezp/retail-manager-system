-- =====================================================
-- VISTAS LIMPIAS - BASADAS EN ESTADO REAL BD
-- =====================================================
-- Archivo: 004_views_clean.sql
-- Propósito: Reemplazo limpio de 004_views_optimized.sql
-- Basado en: docs/CURRENT_SCHEMA_STATE.md (validado 2025-09-14)
-- Fecha: 2025-09-15
--
-- VISTAS INCLUIDAS:
-- - vista_productos_completos: Productos con toda la info joined
-- - vista_inventario_completo: Inventario con detalles de productos
-- - vista_movimientos_detallados: Movimientos con info contextual
-- - vista_stock_bajo: Productos con stock bajo por tienda
-- =====================================================

-- =====================================================
-- VISTA: PRODUCTOS COMPLETOS
-- =====================================================

-- Vista completa de productos con todas las relaciones
CREATE OR REPLACE VIEW vista_productos_completos AS
SELECT
    pm.id as producto_id,
    pm.nombre as producto_nombre,
    pm.descripcion as producto_descripcion,
    pm.precio_sugerido,
    pm.estado as producto_estado,
    pm.imagen_principal_url,
    pm.especificaciones as producto_especificaciones,
    pm.created_at as producto_created_at,
    pm.updated_at as producto_updated_at,

    -- Información de marca
    m.id as marca_id,
    m.nombre as marca_nombre,
    m.prefijo_sku as marca_prefijo,
    m.activo as marca_activa,

    -- Información de categoría
    c.id as categoria_id,
    c.nombre as categoria_nombre,
    c.prefijo_sku as categoria_prefijo,
    c.activo as categoria_activa,

    -- Información de talla
    t.id as talla_id,
    t.codigo as talla_codigo,
    t.tipo as talla_tipo,
    t.valor as talla_valor,
    t.orden_display as talla_orden,
    t.activo as talla_activa,

    -- Información de material (puede ser NULL)
    mat.id as material_id,
    mat.nombre as material_nombre,
    mat.codigo_abrev as material_codigo,
    mat.activo as material_activo,

    -- Información del artículo (con color)
    a.id as articulo_id,
    a.sku_auto as sku,
    a.codigo_barras,
    a.imagen_color_url as articulo_imagen,
    a.activo as articulo_activo,
    a.fecha_activacion,
    a.fecha_descontinuacion,

    -- Información de color
    col.id as color_id,
    col.nombre as color_nombre,
    col.codigo_hex as color_hex,
    col.codigo_abrev as color_prefijo,
    col.activo as color_activo

FROM productos_master pm
LEFT JOIN marcas m ON pm.marca_id = m.id
LEFT JOIN categorias c ON pm.categoria_id = c.id
LEFT JOIN tallas t ON pm.talla_id = t.id
LEFT JOIN materiales mat ON pm.material_id = mat.id
LEFT JOIN articulos a ON pm.id = a.producto_master_id
LEFT JOIN colores col ON a.color_id = col.id

ORDER BY pm.nombre, col.nombre;

-- =====================================================
-- VISTA: INVENTARIO COMPLETO
-- =====================================================

-- Vista completa de inventario con detalles de productos y tiendas
CREATE OR REPLACE VIEW vista_inventario_completo AS
SELECT
    inv.id as inventario_id,
    inv.stock_actual,
    inv.stock_minimo,
    inv.stock_maximo,
    inv.precio_venta,
    inv.precio_costo,
    inv.ubicacion_fisica,
    inv.activo as inventario_activo,
    inv.ultima_venta,
    inv.created_at as inventario_created_at,
    inv.updated_at as inventario_updated_at,

    -- Información de tienda
    tienda.id as tienda_id,
    tienda.nombre as tienda_nombre,
    tienda.codigo as tienda_codigo,
    tienda.activa as tienda_activa,

    -- Información completa del producto (desde vista anterior)
    vpc.producto_id,
    vpc.producto_nombre,
    vpc.sku,
    vpc.codigo_barras,
    vpc.marca_nombre,
    vpc.categoria_nombre,
    vpc.color_nombre,
    vpc.color_hex,
    vpc.talla_codigo,
    vpc.talla_tipo,
    vpc.material_nombre,
    vpc.precio_sugerido,

    -- Cálculos útiles
    CASE
        WHEN inv.stock_actual <= inv.stock_minimo THEN 'BAJO'
        WHEN inv.stock_actual >= COALESCE(inv.stock_maximo, 999999) THEN 'ALTO'
        ELSE 'NORMAL'
    END as estado_stock,

    (inv.precio_venta - inv.precio_costo) as margen_ganancia,

    CASE
        WHEN inv.precio_costo > 0 THEN
            ROUND(((inv.precio_venta - inv.precio_costo) / inv.precio_costo * 100)::numeric, 2)
        ELSE 0
    END as margen_porcentaje

FROM inventario_tienda inv
LEFT JOIN tiendas tienda ON inv.tienda_id = tienda.id
LEFT JOIN vista_productos_completos vpc ON inv.articulo_id = vpc.articulo_id

WHERE inv.activo = true
AND tienda.activa = true

ORDER BY tienda.nombre, vpc.marca_nombre, vpc.producto_nombre, vpc.color_nombre;

-- =====================================================
-- VISTA: MOVIMIENTOS DETALLADOS
-- =====================================================

-- Vista de movimientos de stock con contexto completo
CREATE OR REPLACE VIEW vista_movimientos_detallados AS
SELECT
    mov.id as movimiento_id,
    mov.tipo_movimiento,
    mov.cantidad,
    mov.stock_anterior,
    mov.stock_nuevo,
    mov.precio_unitario,
    mov.costo_total,
    mov.motivo,
    mov.referencia_externa,
    mov.created_at as movimiento_fecha,

    -- Información de tienda
    tienda.nombre as tienda_nombre,
    tienda.codigo as tienda_codigo,

    -- Información de producto
    vpc.producto_nombre,
    vpc.sku,
    vpc.marca_nombre,
    vpc.categoria_nombre,
    vpc.color_nombre,
    vpc.talla_codigo,

    -- Información de tienda origen (para traspasos)
    tienda_origen.nombre as tienda_origen_nombre,
    tienda_origen.codigo as tienda_origen_codigo,

    -- Información de usuario (si disponible)
    mov.usuario_id,

    -- Cálculos útiles
    CASE mov.tipo_movimiento
        WHEN 'ENTRADA' THEN '+'
        WHEN 'SALIDA' THEN '-'
        WHEN 'VENTA' THEN '-'
        WHEN 'DEVOLUCION' THEN '+'
        WHEN 'AJUSTE' THEN '='
        WHEN 'TRASPASO' THEN CASE
            WHEN mov.tienda_origen_id IS NOT NULL THEN '+'  -- Entrada por traspaso
            ELSE '-'  -- Salida por traspaso
        END
        ELSE ''
    END as signo_movimiento

FROM movimientos_stock mov
LEFT JOIN tiendas tienda ON mov.tienda_id = tienda.id
LEFT JOIN vista_productos_completos vpc ON mov.articulo_id = vpc.articulo_id
LEFT JOIN tiendas tienda_origen ON mov.tienda_origen_id = tienda_origen.id

ORDER BY mov.created_at DESC;

-- =====================================================
-- VISTA: STOCK BAJO
-- =====================================================

-- Vista de productos con stock bajo o crítico
CREATE OR REPLACE VIEW vista_stock_bajo AS
SELECT
    vic.inventario_id,
    vic.tienda_nombre,
    vic.tienda_codigo,
    vic.producto_nombre,
    vic.sku,
    vic.marca_nombre,
    vic.categoria_nombre,
    vic.color_nombre,
    vic.talla_codigo,
    vic.stock_actual,
    vic.stock_minimo,
    vic.precio_venta,
    vic.ubicacion_fisica,

    -- Cálculo de criticidad
    CASE
        WHEN vic.stock_actual = 0 THEN 'AGOTADO'
        WHEN vic.stock_actual <= (vic.stock_minimo * 0.5) THEN 'CRÍTICO'
        WHEN vic.stock_actual <= vic.stock_minimo THEN 'BAJO'
        ELSE 'NORMAL'
    END as nivel_criticidad,

    -- Diferencia con stock mínimo
    (vic.stock_minimo - vic.stock_actual) as unidades_faltantes,

    -- Días desde última venta (si disponible)
    CASE
        WHEN vic.ultima_venta IS NOT NULL THEN
            EXTRACT(DAYS FROM NOW() - vic.ultima_venta)::INTEGER
        ELSE NULL
    END as dias_sin_venta

FROM vista_inventario_completo vic

WHERE vic.stock_actual <= vic.stock_minimo
AND vic.inventario_activo = true
AND vic.tienda_activa = true

ORDER BY
    CASE
        WHEN vic.stock_actual = 0 THEN 1  -- Agotados primero
        WHEN vic.stock_actual <= (vic.stock_minimo * 0.5) THEN 2  -- Críticos segundo
        ELSE 3  -- Bajos al final
    END,
    vic.tienda_nombre,
    vic.marca_nombre,
    vic.producto_nombre;

-- =====================================================
-- VISTA: RESUMEN STOCK POR TIENDA
-- =====================================================

-- Vista resumen de stock por tienda
CREATE OR REPLACE VIEW vista_resumen_stock_tienda AS
SELECT
    t.id as tienda_id,
    t.nombre as tienda_nombre,
    t.codigo as tienda_codigo,

    -- Contadores generales
    COUNT(inv.id) as total_articulos,
    COUNT(CASE WHEN inv.stock_actual > 0 THEN 1 END) as articulos_con_stock,
    COUNT(CASE WHEN inv.stock_actual = 0 THEN 1 END) as articulos_agotados,
    COUNT(CASE WHEN inv.stock_actual <= inv.stock_minimo THEN 1 END) as articulos_stock_bajo,

    -- Valores de inventario
    SUM(inv.stock_actual) as stock_total_unidades,
    SUM(inv.stock_actual * inv.precio_costo) as valor_inventario_costo,
    SUM(inv.stock_actual * inv.precio_venta) as valor_inventario_venta,

    -- Promedios
    ROUND(AVG(inv.stock_actual)::numeric, 2) as promedio_stock_articulo,
    ROUND(AVG(inv.precio_venta)::numeric, 2) as precio_venta_promedio,

    -- Última actualización
    MAX(inv.updated_at) as ultima_actualizacion

FROM tiendas t
LEFT JOIN inventario_tienda inv ON t.id = inv.tienda_id AND inv.activo = true

WHERE t.activa = true

GROUP BY t.id, t.nombre, t.codigo
ORDER BY t.nombre;

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON VIEW vista_productos_completos IS 'Vista completa de productos con todas las relaciones - Basada en estado real BD';
COMMENT ON VIEW vista_inventario_completo IS 'Vista completa de inventario con detalles y cálculos - Basada en estado real BD';
COMMENT ON VIEW vista_movimientos_detallados IS 'Vista de movimientos con contexto completo - Basada en estado real BD';
COMMENT ON VIEW vista_stock_bajo IS 'Vista de productos con stock bajo o crítico - Basada en estado real BD';
COMMENT ON VIEW vista_resumen_stock_tienda IS 'Vista resumen de stock por tienda - Basada en estado real BD';

-- Fin de vistas limpias