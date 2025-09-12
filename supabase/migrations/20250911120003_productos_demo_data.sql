-- Migración: Datos de Demostración para Módulo Productos Multi-Tienda
-- Fecha: 2025-09-11
-- Descripción: Insertar productos de ejemplo para testing y demostración

-- ==============================================================================
-- 1. PRODUCTOS MASTER DE EJEMPLO
-- ==============================================================================

-- Producto Master 1: Media fútbol polyester Arley 9-12
INSERT INTO public.productos_master (
    id, nombre, descripcion, marca_id, categoria_id, talla_id, precio_sugerido,
    codigo_base, imagen_principal_url, especificaciones
) VALUES (
    '10000001-0001-0001-0001-000000000001'::UUID,
    'Media fútbol polyester Arley 9-12',
    'Media deportiva de polyester para fútbol, talla 9-12, diseño clásico con refuerzo en talón y punta',
    (SELECT id FROM public.marcas WHERE nombre = 'Arley' LIMIT 1),
    (SELECT id FROM public.categorias WHERE nombre = 'Polyester' LIMIT 1),
    (SELECT id FROM public.tallas WHERE codigo = '9-12' LIMIT 1),
    8.50,
    'MED-POL-ARL-912',
    'https://example.com/images/media-arley-912.jpg',
    '{
        "material": "100% Polyester",
        "peso": "45g",
        "cuidados": "Lavar en agua fría, no usar suavizante",
        "caracteristicas": ["Refuerzo en talón", "Absorción de humedad", "Antimicrobial"],
        "temporada": "Todo el año"
    }'::JSONB
) ON CONFLICT (id) DO NOTHING;

-- Producto Master 2: Media escolar algodón Arley 6-8
INSERT INTO public.productos_master (
    id, nombre, descripcion, marca_id, categoria_id, talla_id, precio_sugerido,
    codigo_base, imagen_principal_url, especificaciones
) VALUES (
    '10000001-0001-0001-0001-000000000002'::UUID,
    'Media escolar algodón Arley 6-8',
    'Media escolar básica de algodón, talla 6-8, ideal para uso diario',
    (SELECT id FROM public.marcas WHERE nombre = 'Arley' LIMIT 1),
    (SELECT id FROM public.categorias WHERE nombre = 'Algodón' LIMIT 1),
    (SELECT id FROM public.tallas WHERE codigo = '6-8' LIMIT 1),
    5.50,
    'MED-ALG-ARL-68',
    'https://example.com/images/media-escolar-arley-68.jpg',
    '{
        "material": "80% Algodón, 20% Polyester",
        "peso": "38g",
        "cuidados": "Lavar en agua tibia, secar a la sombra",
        "caracteristicas": ["Suave al tacto", "Transpirable", "Duradero"],
        "temporada": "Todo el año"
    }'::JSONB
) ON CONFLICT (id) DO NOTHING;

-- Producto Master 3: Media deportiva Nike running L
INSERT INTO public.productos_master (
    id, nombre, descripcion, marca_id, categoria_id, talla_id, precio_sugerido,
    codigo_base, imagen_principal_url, especificaciones
) VALUES (
    '10000001-0001-0001-0001-000000000003'::UUID,
    'Media deportiva Nike running L',
    'Media técnica Nike para running, talla L, con tecnología Dri-FIT',
    (SELECT id FROM public.marcas WHERE nombre = 'Nike' LIMIT 1),
    (SELECT id FROM public.categorias WHERE nombre = 'Polyester' LIMIT 1),
    (SELECT id FROM public.tallas WHERE codigo = 'L' LIMIT 1),
    25.00,
    'MED-POL-NIK-L',
    'https://example.com/images/media-nike-running-l.jpg',
    '{
        "material": "Dri-FIT Polyester blend",
        "peso": "42g",
        "cuidados": "Lavar en agua fría, no planchar",
        "caracteristicas": ["Dri-FIT", "Acolchado", "Transpirable", "Antimicrobial"],
        "temporada": "Todo el año",
        "tecnologia": "Dri-FIT moisture-wicking"
    }'::JSONB
) ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- 2. ARTÍCULOS (PRODUCTO MASTER + COLOR)
-- ==============================================================================

-- Artículos para Media fútbol polyester Arley 9-12
INSERT INTO public.articulos (
    id, producto_master_id, color_id, precio_sugerido, imagen_color_url
) VALUES 
-- Azul
(
    '20000001-0001-0001-0001-000000000001'::UUID,
    '10000001-0001-0001-0001-000000000001'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'AZU' LIMIT 1),
    8.50,
    'https://example.com/images/media-arley-912-azul.jpg'
),
-- Rojo
(
    '20000001-0001-0001-0001-000000000002'::UUID,
    '10000001-0001-0001-0001-000000000001'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'ROJ' LIMIT 1),
    8.50,
    'https://example.com/images/media-arley-912-rojo.jpg'
),
-- Negro
(
    '20000001-0001-0001-0001-000000000003'::UUID,
    '10000001-0001-0001-0001-000000000001'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'NEG' LIMIT 1),
    8.50,
    'https://example.com/images/media-arley-912-negro.jpg'
),
-- Blanco
(
    '20000001-0001-0001-0001-000000000004'::UUID,
    '10000001-0001-0001-0001-000000000001'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'BLA' LIMIT 1),
    8.50,
    'https://example.com/images/media-arley-912-blanco.jpg'
)
ON CONFLICT (id) DO NOTHING;

-- Artículos para Media escolar algodón Arley 6-8
INSERT INTO public.articulos (
    id, producto_master_id, color_id, precio_sugerido, imagen_color_url
) VALUES 
-- Blanco (escolar)
(
    '20000001-0001-0001-0002-000000000001'::UUID,
    '10000001-0001-0001-0001-000000000002'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'BLA' LIMIT 1),
    5.50,
    'https://example.com/images/media-escolar-arley-68-blanco.jpg'
),
-- Azul (escolar)
(
    '20000001-0001-0001-0002-000000000002'::UUID,
    '10000001-0001-0001-0001-000000000002'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'AZU' LIMIT 1),
    5.50,
    'https://example.com/images/media-escolar-arley-68-azul.jpg'
)
ON CONFLICT (id) DO NOTHING;

-- Artículos para Media Nike running L
INSERT INTO public.articulos (
    id, producto_master_id, color_id, precio_sugerido, imagen_color_url
) VALUES 
-- Negro Nike
(
    '20000001-0001-0001-0003-000000000001'::UUID,
    '10000001-0001-0001-0001-000000000003'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'NEG' LIMIT 1),
    25.00,
    'https://example.com/images/media-nike-running-l-negro.jpg'
),
-- Blanco Nike
(
    '20000001-0001-0001-0003-000000000002'::UUID,
    '10000001-0001-0001-0001-000000000003'::UUID,
    (SELECT id FROM public.colores WHERE codigo_abrev = 'BLA' LIMIT 1),
    25.00,
    'https://example.com/images/media-nike-running-l-blanco.jpg'
)
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- 3. INVENTARIO INICIAL POR TIENDA
-- ==============================================================================

-- Obtener IDs de tiendas existentes
-- Tienda Central Lima: 11111111-1111-1111-1111-111111111111
-- Tienda Norte Comas: 22222222-2222-2222-2222-222222222222  
-- Tienda Este VES: 33333333-3333-3333-3333-333333333333
-- Tienda Sur Chorrillos: 44444444-4444-4444-4444-444444444444

-- Inventario para Tienda Central Lima
INSERT INTO public.inventario_tienda (
    tienda_id, articulo_id, stock_actual, stock_minimo, stock_maximo,
    precio_venta, precio_costo, ubicacion_fisica
) VALUES 
-- Media Arley 9-12 en diferentes colores
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0001-000000000001'::UUID, -- Azul
    50, 10, 100, 9.50, 6.50, 'Estante A-1'
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0001-000000000002'::UUID, -- Rojo
    30, 10, 100, 9.50, 6.50, 'Estante A-1'
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0001-000000000003'::UUID, -- Negro
    45, 10, 100, 9.50, 6.50, 'Estante A-1'
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0001-000000000004'::UUID, -- Blanco
    40, 10, 100, 9.50, 6.50, 'Estante A-1'
),
-- Media escolar Arley 6-8
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0002-000000000001'::UUID, -- Blanco escolar
    80, 20, 150, 6.50, 4.50, 'Estante B-1'
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0002-000000000002'::UUID, -- Azul escolar
    60, 15, 120, 6.50, 4.50, 'Estante B-1'
),
-- Nike running L
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0003-000000000001'::UUID, -- Negro Nike
    15, 3, 30, 28.00, 20.00, 'Vitrina Premium'
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0003-000000000002'::UUID, -- Blanco Nike
    12, 3, 30, 28.00, 20.00, 'Vitrina Premium'
)
ON CONFLICT (tienda_id, articulo_id) DO NOTHING;

-- Inventario para Tienda Norte Comas (precios más bajos)
INSERT INTO public.inventario_tienda (
    tienda_id, articulo_id, stock_actual, stock_minimo, stock_maximo,
    precio_venta, precio_costo, ubicacion_fisica
) VALUES 
-- Media Arley 9-12
(
    '22222222-2222-2222-2222-222222222222'::UUID,
    '20000001-0001-0001-0001-000000000001'::UUID, -- Azul
    35, 8, 80, 8.90, 6.50, 'Estante 1A'
),
(
    '22222222-2222-2222-2222-222222222222'::UUID,
    '20000001-0001-0001-0001-000000000003'::UUID, -- Negro
    40, 8, 80, 8.90, 6.50, 'Estante 1A'
),
-- Media escolar
(
    '22222222-2222-2222-2222-222222222222'::UUID,
    '20000001-0001-0001-0002-000000000001'::UUID, -- Blanco escolar
    100, 25, 200, 6.00, 4.50, 'Estante 2A'
),
-- Sin Nike (tienda más popular)
(
    '22222222-2222-2222-2222-222222222222'::UUID,
    '20000001-0001-0001-0003-000000000001'::UUID, -- Negro Nike
    5, 2, 15, 26.00, 20.00, 'Vitrina'
)
ON CONFLICT (tienda_id, articulo_id) DO NOTHING;

-- Inventario para Tienda Este VES (stock menor)
INSERT INTO public.inventario_tienda (
    tienda_id, articulo_id, stock_actual, stock_minimo, stock_maximo,
    precio_venta, precio_costo, ubicacion_fisica
) VALUES 
-- Productos básicos
(
    '33333333-3333-3333-3333-333333333333'::UUID,
    '20000001-0001-0001-0001-000000000001'::UUID, -- Azul Arley
    20, 5, 50, 9.20, 6.50, 'Almacén'
),
(
    '33333333-3333-3333-3333-333333333333'::UUID,
    '20000001-0001-0001-0002-000000000001'::UUID, -- Blanco escolar
    40, 10, 80, 6.20, 4.50, 'Estante Principal'
)
ON CONFLICT (tienda_id, articulo_id) DO NOTHING;

-- Inventario para Tienda Sur Chorrillos (variedad media)
INSERT INTO public.inventario_tienda (
    tienda_id, articulo_id, stock_actual, stock_minimo, stock_maximo,
    precio_venta, precio_costo, ubicacion_fisica
) VALUES 
-- Variedad media de productos
(
    '44444444-4444-4444-4444-444444444444'::UUID,
    '20000001-0001-0001-0001-000000000001'::UUID, -- Azul Arley
    25, 5, 60, 9.30, 6.50, 'Estante A'
),
(
    '44444444-4444-4444-4444-444444444444'::UUID,
    '20000001-0001-0001-0001-000000000004'::UUID, -- Blanco Arley
    30, 5, 60, 9.30, 6.50, 'Estante A'
),
(
    '44444444-4444-4444-4444-444444444444'::UUID,
    '20000001-0001-0001-0002-000000000001'::UUID, -- Blanco escolar
    50, 10, 100, 6.30, 4.50, 'Estante B'
),
(
    '44444444-4444-4444-4444-444444444444'::UUID,
    '20000001-0001-0001-0003-000000000002'::UUID, -- Blanco Nike
    8, 2, 20, 27.50, 20.00, 'Vitrina'
)
ON CONFLICT (tienda_id, articulo_id) DO NOTHING;

-- ==============================================================================
-- 4. MOVIMIENTOS INICIALES DE STOCK (Para trazabilidad)
-- ==============================================================================

-- Movimientos de ingreso inicial para Tienda Central Lima
INSERT INTO public.movimientos_stock (
    tienda_id, articulo_id, tipo_movimiento, cantidad,
    stock_anterior, stock_resultante, precio_unitario, motivo, usuario_id
) VALUES 
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0001-000000000001'::UUID, -- Azul Arley
    'INGRESO_COMPRA', 50, 0, 50, 6.50,
    'Stock inicial - Compra a proveedor', 
    (SELECT id FROM public.usuarios WHERE email LIKE '%admin%' LIMIT 1)
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0002-000000000001'::UUID, -- Blanco escolar
    'INGRESO_COMPRA', 80, 0, 80, 4.50,
    'Stock inicial - Compra a proveedor',
    (SELECT id FROM public.usuarios WHERE email LIKE '%admin%' LIMIT 1)
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0003-000000000001'::UUID, -- Negro Nike
    'INGRESO_COMPRA', 15, 0, 15, 20.00,
    'Stock inicial - Compra productos premium',
    (SELECT id FROM public.usuarios WHERE email LIKE '%admin%' LIMIT 1)
)
ON CONFLICT DO NOTHING;

-- Algunos movimientos de venta simulados (últimos días)
INSERT INTO public.movimientos_stock (
    tienda_id, articulo_id, tipo_movimiento, cantidad,
    stock_anterior, stock_resultante, precio_unitario, motivo, usuario_id, fecha_movimiento
) VALUES 
-- Ventas en Tienda Central
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0001-000000000001'::UUID, -- Azul Arley
    'SALIDA_VENTA', -3, 50, 47, 9.50,
    'Venta mostrador - Cliente walk-in',
    (SELECT id FROM public.usuarios WHERE email LIKE '%admin%' LIMIT 1),
    NOW() - INTERVAL '2 days'
),
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0002-000000000001'::UUID, -- Blanco escolar
    'SALIDA_VENTA', -5, 80, 75, 6.50,
    'Venta pack escolar',
    (SELECT id FROM public.usuarios WHERE email LIKE '%admin%' LIMIT 1),
    NOW() - INTERVAL '1 day'
),
-- Venta premium Nike
(
    '11111111-1111-1111-1111-111111111111'::UUID,
    '20000001-0001-0001-0003-000000000001'::UUID, -- Negro Nike
    'SALIDA_VENTA', -1, 15, 14, 28.00,
    'Venta producto premium',
    (SELECT id FROM public.usuarios WHERE email LIKE '%admin%' LIMIT 1),
    NOW() - INTERVAL '3 hours'
)
ON CONFLICT DO NOTHING;

-- ==============================================================================
-- 5. FUNCIÓN PARA GENERAR MÁS DATOS DE TESTING
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.generar_datos_productos_testing(
    productos_adicionales INTEGER DEFAULT 10,
    variantes_por_producto INTEGER DEFAULT 3
)
RETURNS JSON AS $$
DECLARE
    contador INTEGER := 0;
    marca_id UUID;
    categoria_id UUID;
    talla_id UUID;
    color_ids UUID[];
    producto_master_id UUID;
    articulo_id UUID;
    tienda_ids UUID[];
    resultado JSON;
BEGIN
    -- Obtener arrays de IDs disponibles
    SELECT ARRAY(SELECT id FROM public.marcas WHERE activa = true LIMIT 5) INTO marca_id;
    SELECT ARRAY(SELECT id FROM public.categorias WHERE activa = true LIMIT 3) INTO categoria_id;
    SELECT ARRAY(SELECT id FROM public.tallas WHERE activa = true LIMIT 8) INTO talla_id;
    SELECT ARRAY(SELECT id FROM public.colores WHERE activo = true LIMIT 6) INTO color_ids;
    SELECT ARRAY(SELECT id FROM public.tiendas WHERE activa = true) INTO tienda_ids;
    
    -- Generar productos master adicionales
    FOR i IN 1..productos_adicionales LOOP
        producto_master_id := gen_random_uuid();
        
        -- Insertar producto master
        INSERT INTO public.productos_master (
            id, nombre, descripcion, marca_id, categoria_id, talla_id, precio_sugerido
        ) VALUES (
            producto_master_id,
            'Producto Testing ' || i,
            'Producto generado automáticamente para testing',
            (SELECT unnest FROM unnest(marca_id) ORDER BY random() LIMIT 1),
            (SELECT unnest FROM unnest(categoria_id) ORDER BY random() LIMIT 1),
            (SELECT unnest FROM unnest(talla_id) ORDER BY random() LIMIT 1),
            5.00 + (random() * 20)::DECIMAL(10,2)
        );
        
        -- Generar artículos por color
        FOR j IN 1..LEAST(variantes_por_producto, array_length(color_ids, 1)) LOOP
            articulo_id := gen_random_uuid();
            
            INSERT INTO public.articulos (
                id, producto_master_id, color_id
            ) VALUES (
                articulo_id,
                producto_master_id,
                color_ids[j]
            );
            
            -- Agregar inventario aleatorio en algunas tiendas
            FOR k IN 1..array_length(tienda_ids, 1) LOOP
                IF random() > 0.4 THEN -- 60% probabilidad de estar en cada tienda
                    INSERT INTO public.inventario_tienda (
                        tienda_id, articulo_id, stock_actual, precio_venta, precio_costo
                    ) VALUES (
                        tienda_ids[k],
                        articulo_id,
                        (5 + (random() * 50)::INTEGER),
                        5.00 + (random() * 25)::DECIMAL(10,2),
                        3.00 + (random() * 15)::DECIMAL(10,2)
                    ) ON CONFLICT DO NOTHING;
                END IF;
            END LOOP;
        END LOOP;
        
        contador := contador + 1;
    END LOOP;
    
    resultado := json_build_object(
        'productos_creados', contador,
        'articulos_estimados', contador * variantes_por_producto,
        'inventarios_estimados', contador * variantes_por_producto * array_length(tienda_ids, 1) * 0.6
    );
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 6. COMENTARIOS
-- ==============================================================================

COMMENT ON FUNCTION public.generar_datos_productos_testing IS 'Genera productos, artículos e inventarios adicionales para testing';

-- Mostrar resumen de datos insertados
SELECT 
    'Productos Master' as tabla, COUNT(*) as registros
FROM public.productos_master
WHERE nombre LIKE '%Media %' OR nombre LIKE '%Producto Testing%'

UNION ALL

SELECT 
    'Artículos' as tabla, COUNT(*) as registros  
FROM public.articulos a
JOIN public.productos_master pm ON a.producto_master_id = pm.id
WHERE pm.nombre LIKE '%Media %' OR pm.nombre LIKE '%Producto Testing%'

UNION ALL

SELECT 
    'Inventarios' as tabla, COUNT(*) as registros
FROM public.inventario_tienda it
JOIN public.articulos a ON it.articulo_id = a.id  
JOIN public.productos_master pm ON a.producto_master_id = pm.id
WHERE pm.nombre LIKE '%Media %' OR pm.nombre LIKE '%Producto Testing%'

UNION ALL

SELECT 
    'Movimientos Stock' as tabla, COUNT(*) as registros
FROM public.movimientos_stock ms
JOIN public.articulos a ON ms.articulo_id = a.id
JOIN public.productos_master pm ON a.producto_master_id = pm.id
WHERE pm.nombre LIKE '%Media %' OR pm.nombre LIKE '%Producto Testing%';