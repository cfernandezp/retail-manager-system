-- =====================================================
-- SEED DATA - SISTEMA MEDIAS MULTI-TIENDA
-- =====================================================
-- Descripción: Datos de ejemplo para testing del sistema
-- Versión: 1.0.0
-- Fecha: 2025-09-11

BEGIN;

-- =====================================================
-- 1. MARCAS
-- =====================================================

INSERT INTO marcas (id, nombre, descripcion, prefijo_sku, logo_url) VALUES
(uuid_generate_v4(), 'Arley', 'Marca premium de medias y calcetines deportivos', 'ARL', 'https://example.com/logos/arley.png'),
(uuid_generate_v4(), 'Nike', 'Marca deportiva internacional líder', 'NIK', 'https://example.com/logos/nike.png'),
(uuid_generate_v4(), 'Adidas', 'Marca deportiva alemana de renombre mundial', 'ADI', 'https://example.com/logos/adidas.png'),
(uuid_generate_v4(), 'Puma', 'Marca deportiva alemana con estilo urbano', 'PUM', 'https://example.com/logos/puma.png'),
(uuid_generate_v4(), 'Genérica', 'Marca económica para mercado masivo', 'GEN', NULL);

-- =====================================================
-- 2. CATEGORIAS/MATERIALES
-- =====================================================

INSERT INTO categorias (id, nombre, descripcion, prefijo_sku) VALUES
(uuid_generate_v4(), 'Polyester', 'Fibra sintética resistente y de secado rápido', 'POL'),
(uuid_generate_v4(), 'Algodón', 'Fibra natural cómoda y transpirable', 'ALG'),
(uuid_generate_v4(), 'Lycra', 'Fibra elástica para mayor flexibilidad', 'LYC'),
(uuid_generate_v4(), 'Bambú', 'Fibra natural antibacteriana y ecológica', 'BAM'),
(uuid_generate_v4(), 'Lana', 'Fibra natural cálida para clima frío', 'LAN');

-- =====================================================
-- 3. TALLAS
-- =====================================================

INSERT INTO tallas (id, codigo, tipo, talla_min, talla_max, talla_unica, orden_display) VALUES
(uuid_generate_v4(), '3', 'UNICA', NULL, NULL, 3, 10),
(uuid_generate_v4(), '6-8', 'RANGO', 6, 8, NULL, 20),
(uuid_generate_v4(), '9-12', 'RANGO', 9, 12, NULL, 30),
(uuid_generate_v4(), '13-15', 'RANGO', 13, 15, NULL, 40),
(uuid_generate_v4(), '16-18', 'RANGO', 16, 18, NULL, 50),
(uuid_generate_v4(), '12', 'UNICA', NULL, NULL, 12, 35),
(uuid_generate_v4(), '15', 'UNICA', NULL, NULL, 15, 45);

-- =====================================================
-- 4. COLORES
-- =====================================================

INSERT INTO colores (id, nombre, codigo_hex, prefijo_sku) VALUES
(uuid_generate_v4(), 'Azul', '#0066CC', 'AZU'),
(uuid_generate_v4(), 'Rojo', '#CC0000', 'ROJ'),
(uuid_generate_v4(), 'Negro', '#000000', 'NEG'),
(uuid_generate_v4(), 'Blanco', '#FFFFFF', 'BLA'),
(uuid_generate_v4(), 'Verde', '#00CC66', 'VER'),
(uuid_generate_v4(), 'Amarillo', '#CCCC00', 'AMA'),
(uuid_generate_v4(), 'Rosa', '#CC6699', 'ROS'),
(uuid_generate_v4(), 'Gris', '#666666', 'GRI'),
(uuid_generate_v4(), 'Morado', '#6600CC', 'MOR'),
(uuid_generate_v4(), 'Naranja', '#FF6600', 'NAR');

-- =====================================================
-- 5. TIENDAS
-- =====================================================

INSERT INTO tiendas (id, nombre, codigo, direccion, telefono, email) VALUES
(uuid_generate_v4(), 'Tienda Gamarra', 'GAM', 'Av. Gamarra 1234, La Victoria, Lima', '01-4567890', 'gamarra@mediasstore.pe'),
(uuid_generate_v4(), 'Tienda Mesa Redonda', 'MES', 'Jr. Cusco 567, Cercado de Lima', '01-9876543', 'mesaredonda@mediasstore.pe'),
(uuid_generate_v4(), 'Tienda San Juan de Lurigancho', 'SJL', 'Av. Próceres 890, SJL, Lima', '01-1357924', 'sjl@mediasstore.pe'),
(uuid_generate_v4(), 'Tienda Villa El Salvador', 'VES', 'Av. El Sol 456, Villa El Salvador', '01-2468135', 'ves@mediasstore.pe');

-- =====================================================
-- 6. PRODUCTOS MASTER (usando IDs de referencias)
-- =====================================================

-- Necesitamos obtener los IDs para crear productos
WITH marca_arley AS (SELECT id FROM marcas WHERE prefijo_sku = 'ARL'),
     marca_nike AS (SELECT id FROM marcas WHERE prefijo_sku = 'NIK'),
     marca_generica AS (SELECT id FROM marcas WHERE prefijo_sku = 'GEN'),
     cat_polyester AS (SELECT id FROM categorias WHERE prefijo_sku = 'POL'),
     cat_algodon AS (SELECT id FROM categorias WHERE prefijo_sku = 'ALG'),
     cat_lycra AS (SELECT id FROM categorias WHERE prefijo_sku = 'LYC'),
     talla_912 AS (SELECT id FROM tallas WHERE codigo = '9-12'),
     talla_68 AS (SELECT id FROM tallas WHERE codigo = '6-8'),
     talla_1315 AS (SELECT id FROM tallas WHERE codigo = '13-15'),
     talla_3 AS (SELECT id FROM tallas WHERE codigo = '3')

INSERT INTO productos_master (id, nombre, descripcion, marca_id, categoria_id, talla_id, precio_sugerido) 
SELECT 
    uuid_generate_v4(),
    'Media fútbol polyester Arley 9-12',
    'Media deportiva de alta calidad para fútbol, ideal para práctica y competencia',
    marca_arley.id,
    cat_polyester.id,
    talla_912.id,
    8.50
FROM marca_arley, cat_polyester, talla_912
UNION ALL
SELECT 
    uuid_generate_v4(),
    'Media fútbol polyester Arley 6-8',
    'Media deportiva infantil de alta calidad para fútbol',
    marca_arley.id,
    cat_polyester.id,
    talla_68.id,
    7.00
FROM marca_arley, cat_polyester, talla_68
UNION ALL
SELECT 
    uuid_generate_v4(),
    'Media casual algodón Nike 13-15',
    'Media cómoda de uso diario con logo Nike',
    marca_nike.id,
    cat_algodon.id,
    talla_1315.id,
    12.00
FROM marca_nike, cat_algodon, talla_1315
UNION ALL
SELECT 
    uuid_generate_v4(),
    'Media bebé algodón talla 3',
    'Media suave para bebés de algodón 100%',
    marca_generica.id,
    cat_algodon.id,
    talla_3.id,
    4.50
FROM marca_generica, cat_algodon, talla_3
UNION ALL
SELECT 
    uuid_generate_v4(),
    'Media deportiva lycra Nike 9-12',
    'Media elástica de alto rendimiento para deportistas',
    marca_nike.id,
    cat_lycra.id,
    talla_912.id,
    15.00
FROM marca_nike, cat_lycra, talla_912;

-- =====================================================
-- 7. ARTÍCULOS (VARIANTES POR COLOR)
-- =====================================================

-- Crear artículos para "Media fútbol polyester Arley 9-12" en varios colores
WITH 
producto_arley_912 AS (
    SELECT pm.id 
    FROM productos_master pm 
    JOIN marcas m ON pm.marca_id = m.id 
    JOIN tallas t ON pm.talla_id = t.id
    WHERE m.prefijo_sku = 'ARL' AND t.codigo = '9-12' AND pm.nombre LIKE '%polyester%'
),
colores_basicos AS (
    SELECT id FROM colores WHERE prefijo_sku IN ('AZU', 'ROJ', 'NEG', 'BLA', 'VER')
)
INSERT INTO articulos (producto_master_id, color_id)
SELECT p.id, c.id
FROM producto_arley_912 p
CROSS JOIN colores_basicos c;

-- Crear artículos para "Media fútbol polyester Arley 6-8" en colores básicos
WITH 
producto_arley_68 AS (
    SELECT pm.id 
    FROM productos_master pm 
    JOIN marcas m ON pm.marca_id = m.id 
    JOIN tallas t ON pm.talla_id = t.id
    WHERE m.prefijo_sku = 'ARL' AND t.codigo = '6-8' AND pm.nombre LIKE '%polyester%'
),
colores_infantil AS (
    SELECT id FROM colores WHERE prefijo_sku IN ('AZU', 'ROS', 'VER', 'AMA')
)
INSERT INTO articulos (producto_master_id, color_id)
SELECT p.id, c.id
FROM producto_arley_68 p
CROSS JOIN colores_infantil c;

-- Crear artículos para "Media casual algodón Nike 13-15"
WITH 
producto_nike_1315 AS (
    SELECT pm.id 
    FROM productos_master pm 
    JOIN marcas m ON pm.marca_id = m.id 
    JOIN tallas t ON pm.talla_id = t.id
    WHERE m.prefijo_sku = 'NIK' AND t.codigo = '13-15' AND pm.nombre LIKE '%algodón%'
),
colores_casual AS (
    SELECT id FROM colores WHERE prefijo_sku IN ('NEG', 'BLA', 'GRI')
)
INSERT INTO articulos (producto_master_id, color_id)
SELECT p.id, c.id
FROM producto_nike_1315 p
CROSS JOIN colores_casual c;

-- Crear artículos para "Media bebé algodón talla 3"
WITH 
producto_bebe AS (
    SELECT pm.id 
    FROM productos_master pm 
    JOIN marcas m ON pm.marca_id = m.id 
    JOIN tallas t ON pm.talla_id = t.id
    WHERE m.prefijo_sku = 'GEN' AND t.codigo = '3' AND pm.nombre LIKE '%bebé%'
),
colores_bebe AS (
    SELECT id FROM colores WHERE prefijo_sku IN ('ROS', 'AZU', 'BLA', 'AMA')
)
INSERT INTO articulos (producto_master_id, color_id)
SELECT p.id, c.id
FROM producto_bebe p
CROSS JOIN colores_bebe c;

-- Crear artículos para "Media deportiva lycra Nike 9-12"
WITH 
producto_nike_lycra AS (
    SELECT pm.id 
    FROM productos_master pm 
    JOIN marcas m ON pm.marca_id = m.id 
    JOIN tallas t ON pm.talla_id = t.id
    WHERE m.prefijo_sku = 'NIK' AND t.codigo = '9-12' AND pm.nombre LIKE '%lycra%'
),
colores_deportivo AS (
    SELECT id FROM colores WHERE prefijo_sku IN ('NEG', 'AZU', 'ROJ', 'VER')
)
INSERT INTO articulos (producto_master_id, color_id)
SELECT p.id, c.id
FROM producto_nike_lycra p
CROSS JOIN colores_deportivo c;

-- =====================================================
-- 8. INVENTARIO INICIAL POR TIENDA
-- =====================================================

-- Función para crear inventario aleatorio pero realista
WITH tiendas_activas AS (
    SELECT id, codigo FROM tiendas WHERE activo = true
),
articulos_activos AS (
    SELECT a.id, pm.precio_sugerido
    FROM articulos a 
    JOIN productos_master pm ON a.producto_master_id = pm.id
    WHERE a.estado = 'ACTIVO'
)
INSERT INTO inventario_tienda (articulo_id, tienda_id, stock_actual, stock_minimo, stock_maximo, precio_venta, precio_costo)
SELECT 
    aa.id,
    ta.id,
    -- Stock inicial aleatorio entre 5 y 50
    (FLOOR(RANDOM() * 46) + 5)::INTEGER,
    -- Stock mínimo entre 3 y 10
    (FLOOR(RANDOM() * 8) + 3)::INTEGER,
    -- Stock máximo entre 50 y 100
    (FLOOR(RANDOM() * 51) + 50)::INTEGER,
    -- Precio venta: precio sugerido +/- 15%
    ROUND((aa.precio_sugerido * (0.85 + (RANDOM() * 0.3)))::numeric, 2),
    -- Precio costo: 60-70% del precio venta
    ROUND((aa.precio_sugerido * (0.6 + (RANDOM() * 0.1)))::numeric, 2)
FROM articulos_activos aa
CROSS JOIN tiendas_activas ta;

-- =====================================================
-- 9. ALGUNOS MOVIMIENTOS DE STOCK INICIAL
-- =====================================================

-- Crear movimientos de entrada inicial para algunas tiendas
WITH movimientos_entrada AS (
    SELECT 
        it.articulo_id,
        it.tienda_id,
        it.stock_actual,
        it.precio_costo
    FROM inventario_tienda it
    LIMIT 20 -- Solo algunos ejemplos
)
INSERT INTO movimientos_stock (
    articulo_id, 
    tienda_id, 
    tipo_movimiento, 
    cantidad, 
    stock_anterior, 
    stock_nuevo, 
    precio_unitario, 
    costo_total,
    motivo,
    referencia_externa
)
SELECT 
    me.articulo_id,
    me.tienda_id,
    'ENTRADA'::tipo_movimiento,
    me.stock_actual, -- Cantidad de entrada
    0, -- Stock anterior (inicial)
    me.stock_actual, -- Stock nuevo
    me.precio_costo,
    (me.stock_actual * me.precio_costo),
    'Stock inicial del sistema',
    'INIT-' || gen_random_uuid()::text
FROM movimientos_entrada me;

-- =====================================================
-- 10. ACTUALIZACIÓN DE CÓDIGOS DE BARRAS SIMULADOS
-- =====================================================

-- Actualizar algunos artículos con códigos de barras simulados (EAN13)
WITH numerados AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) as rn
    FROM articulos
    ORDER BY RANDOM()
    LIMIT 15
)
UPDATE articulos 
SET codigo_barras = '780' || LPAD(numerados.rn::text, 9, '0') || 
                   LPAD(FLOOR(RANDOM() * 100)::text, 2, '0')
FROM numerados
WHERE articulos.id = numerados.id;

-- =====================================================
-- 11. CONFIGURACIONES ESPECÍFICAS POR TIENDA
-- =====================================================

-- Actualizar configuraciones de ejemplo para las tiendas
UPDATE tiendas SET configuracion = jsonb_build_object(
    'horario_apertura', '08:00',
    'horario_cierre', '20:00',
    'moneda_local', 'PEN',
    'impresora_recibos', true,
    'lector_codigo_barras', true,
    'permite_venta_credito', false
) WHERE codigo = 'GAM';

UPDATE tiendas SET configuracion = jsonb_build_object(
    'horario_apertura', '09:00',
    'horario_cierre', '19:00',
    'moneda_local', 'PEN',
    'impresora_recibos', true,
    'lector_codigo_barras', false,
    'permite_venta_credito', true
) WHERE codigo = 'MES';

-- =====================================================
-- 12. VERIFICACIÓN FINAL
-- =====================================================

-- Mostrar resumen de datos creados
DO $$
DECLARE
    marca_count INTEGER;
    categoria_count INTEGER;
    talla_count INTEGER;
    color_count INTEGER;
    tienda_count INTEGER;
    producto_count INTEGER;
    articulo_count INTEGER;
    inventario_count INTEGER;
    movimiento_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO marca_count FROM marcas;
    SELECT COUNT(*) INTO categoria_count FROM categorias;
    SELECT COUNT(*) INTO talla_count FROM tallas;
    SELECT COUNT(*) INTO color_count FROM colores;
    SELECT COUNT(*) INTO tienda_count FROM tiendas;
    SELECT COUNT(*) INTO producto_count FROM productos_master;
    SELECT COUNT(*) INTO articulo_count FROM articulos;
    SELECT COUNT(*) INTO inventario_count FROM inventario_tienda;
    SELECT COUNT(*) INTO movimiento_count FROM movimientos_stock;
    
    RAISE NOTICE '=== RESUMEN SEED DATA ===';
    RAISE NOTICE 'Marcas creadas: %', marca_count;
    RAISE NOTICE 'Categorías creadas: %', categoria_count;
    RAISE NOTICE 'Tallas creadas: %', talla_count;
    RAISE NOTICE 'Colores creados: %', color_count;
    RAISE NOTICE 'Tiendas creadas: %', tienda_count;
    RAISE NOTICE 'Productos master creados: %', producto_count;
    RAISE NOTICE 'Artículos (variantes) creados: %', articulo_count;
    RAISE NOTICE 'Registros inventario creados: %', inventario_count;
    RAISE NOTICE 'Movimientos stock creados: %', movimiento_count;
    RAISE NOTICE '========================';
END $$;

COMMIT;