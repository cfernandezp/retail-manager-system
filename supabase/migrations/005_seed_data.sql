-- =====================================================
-- DATOS SEMILLA LIMPIOS - BASADOS EN ESTADO REAL BD
-- =====================================================
-- Archivo: 005_seed_data_clean.sql
-- Propósito: Reemplazo limpio de 005_seed_data.sql
-- Basado en: docs/CURRENT_SCHEMA_STATE.md (validado 2025-09-14)
-- Fecha: 2025-09-15
--
-- DATOS INCLUIDOS:
-- - Marcas base (5 marcas confirmadas)
-- - Categorías base (5 categorías confirmadas)
-- - Tallas base (16 tallas confirmadas)
-- - Colores base
-- - Materiales base
-- - Usuario admin de prueba
-- =====================================================

-- =====================================================
-- LIMPIAR DATOS EXISTENTES (ORDEN INVERSO POR FK)
-- =====================================================

-- Nota: Usar TRUNCATE con CASCADE solo si es necesario recrear todo
-- DELETE FROM movimientos_stock;
-- DELETE FROM inventario_tienda;
-- DELETE FROM articulos;
-- DELETE FROM productos_master;
-- DELETE FROM materiales;
-- DELETE FROM colores;
-- DELETE FROM tallas;
-- DELETE FROM categorias;
-- DELETE FROM marcas;
-- DELETE FROM tiendas;

-- =====================================================
-- MARCAS BASE (5 marcas confirmadas)
-- =====================================================

INSERT INTO marcas (nombre, descripcion, prefijo_sku, activo) VALUES
('Nike', 'Marca deportiva internacional', 'NIK', true),
('Adidas', 'Marca deportiva alemana', 'ADI', true),
('Puma', 'Marca deportiva internacional', 'PUM', true),
('Local Sport', 'Marca deportiva local', 'LOC', true),
('Fashion Plus', 'Marca de moda casual', 'FAS', true)
ON CONFLICT (nombre) DO NOTHING;

-- =====================================================
-- CATEGORÍAS BASE (5 categorías confirmadas)
-- =====================================================

INSERT INTO categorias (nombre, descripcion, prefijo_sku, activo) VALUES
('Zapatillas', 'Calzado deportivo y casual', 'ZAP', true),
('Polos', 'Camisetas y polos deportivos', 'POL', true),
('Shorts', 'Pantalones cortos deportivos', 'SHO', true),
('Medias', 'Calcetines y medias deportivas', 'MED', true),
('Accesorios', 'Complementos deportivos', 'ACC', true)
ON CONFLICT (nombre) DO NOTHING;

-- =====================================================
-- TALLAS BASE (16 tallas confirmadas)
-- =====================================================

-- Tallas de calzado (tipo INDIVIDUAL)
INSERT INTO tallas (codigo, nombre, tipo, orden_display, activo, valor) VALUES
('35', 'Talla 35', 'INDIVIDUAL', 1, true, '35'),
('36', 'Talla 36', 'INDIVIDUAL', 2, true, '36'),
('37', 'Talla 37', 'INDIVIDUAL', 3, true, '37'),
('38', 'Talla 38', 'INDIVIDUAL', 4, true, '38'),
('39', 'Talla 39', 'INDIVIDUAL', 5, true, '39'),
('40', 'Talla 40', 'INDIVIDUAL', 6, true, '40'),
('41', 'Talla 41', 'INDIVIDUAL', 7, true, '41'),
('42', 'Talla 42', 'INDIVIDUAL', 8, true, '42'),
('43', 'Talla 43', 'INDIVIDUAL', 9, true, '43'),
('44', 'Talla 44', 'INDIVIDUAL', 10, true, '44')
ON CONFLICT (codigo) DO NOTHING;

-- Tallas de ropa (tipo LETRA)
INSERT INTO tallas (codigo, nombre, tipo, orden_display, activo, valor) VALUES
('XS', 'Extra Small', 'LETRA', 11, true, 'XS'),
('S', 'Small', 'LETRA', 12, true, 'S'),
('M', 'Medium', 'LETRA', 13, true, 'M'),
('L', 'Large', 'LETRA', 14, true, 'L'),
('XL', 'Extra Large', 'LETRA', 15, true, 'XL'),
('XXL', 'Double Extra Large', 'LETRA', 16, true, 'XXL')
ON CONFLICT (codigo) DO NOTHING;

-- =====================================================
-- COLORES BASE
-- =====================================================

INSERT INTO colores (nombre, codigo_hex, codigo_abrev, activo, hex_color) VALUES
('Negro', '#000000', 'NEG', true, '#000000'),
('Blanco', '#FFFFFF', 'BLA', true, '#FFFFFF'),
('Rojo', '#FF0000', 'ROJ', true, '#FF0000'),
('Azul', '#0000FF', 'AZU', true, '#0000FF'),
('Verde', '#008000', 'VER', true, '#008000'),
('Amarillo', '#FFFF00', 'AMA', true, '#FFFF00'),
('Gris', '#808080', 'GRI', true, '#808080'),
('Rosa', '#FFC0CB', 'ROS', true, '#FFC0CB'),
('Naranja', '#FFA500', 'NAR', true, '#FFA500'),
('Morado', '#800080', 'MOR', true, '#800080')
ON CONFLICT (nombre) DO NOTHING;

-- =====================================================
-- MATERIALES BASE
-- =====================================================

INSERT INTO materiales (nombre, descripcion, codigo_abrev, densidad, activo) VALUES
('Algodón', 'Material natural transpirable', 'ALG', 1.54, true),
('Poliéster', 'Fibra sintética resistente', 'POL', 1.38, true),
('Nylon', 'Fibra sintética elástica', 'NYL', 1.14, true),
('Cuero', 'Material natural para calzado', 'CUE', 0.86, true),
('Lycra', 'Fibra elástica', 'LYC', 1.30, true),
('Mesh', 'Tejido transpirable', 'MES', 0.95, true),
('Denim', 'Tela de algodón resistente', 'DEN', 1.65, true),
('Lana', 'Fibra natural cálida', 'LAN', 1.31, true)
ON CONFLICT (nombre) DO NOTHING;

-- =====================================================
-- TIENDA BASE PARA DESARROLLO
-- =====================================================

INSERT INTO tiendas (nombre, codigo, direccion, telefono, email, activa) VALUES
('Tienda Principal', 'MAIN', 'Av. Javier Prado 123, San Isidro, Lima', '+51 1 234-5678', 'principal@retailsystem.pe', true),
('Sucursal Centro', 'CENT', 'Jr. de la Unión 456, Cercado de Lima', '+51 1 234-5679', 'centro@retailsystem.pe', true)
ON CONFLICT (codigo) DO NOTHING;

-- =====================================================
-- ROLES BASE
-- =====================================================

INSERT INTO roles (nombre, descripcion, permisos) VALUES
('SUPER_ADMIN', 'Administrador del sistema completo', '{"all": true, "users": ["create", "read", "update", "delete"], "settings": ["read", "write"]}'),
('ADMIN', 'Administrador de tienda y usuarios', '{"users": ["read", "approve", "suspend"], "reports": ["read", "export"], "pos": ["read", "write"], "inventory": ["read", "write"]}'),
('MANAGER', 'Manager de tienda', '{"users": ["read"], "reports": ["read"], "pos": ["read", "write"], "inventory": ["read", "write"]}'),
('VENDEDOR', 'Vendedor con permisos básicos', '{"pos": ["read", "write"], "products": ["read"], "sales": ["create", "read"], "customers": ["read", "create"]}'),
('OPERARIO', 'Operario con permisos básicos', '{"pos": ["read", "write"], "products": ["read"], "sales": ["create", "read"]}'),
('CLIENTE', 'Cliente del sistema', '{"profile": ["read", "update"]}')
ON CONFLICT (nombre) DO NOTHING;

-- =====================================================
-- USUARIOS BASE PARA DESARROLLO
-- =====================================================

-- Nota: El usuario admin se crea en 007_admin_user_seed.sql
-- después de que las tablas estén disponibles

-- =====================================================
-- PRODUCTOS DEMO (OPCIONAL)
-- =====================================================

-- Ejemplo de producto demo si se requiere para testing
-- Se mantiene comentado para evitar conflictos

/*
-- Producto demo: Nike Air Max en diferentes colores
DO $$
DECLARE
    nike_id UUID;
    zapatillas_id UUID;
    talla_40_id UUID;
    color_negro_id UUID;
    color_blanco_id UUID;
    producto_master_id UUID;
BEGIN
    -- Obtener IDs de marca, categoría y talla
    SELECT id INTO nike_id FROM marcas WHERE nombre = 'Nike';
    SELECT id INTO zapatillas_id FROM categorias WHERE nombre = 'Zapatillas';
    SELECT id INTO talla_40_id FROM tallas WHERE codigo = '40';
    SELECT id INTO color_negro_id FROM colores WHERE nombre = 'Negro';
    SELECT id INTO color_blanco_id FROM colores WHERE nombre = 'Blanco';

    -- Crear producto master
    INSERT INTO productos_master (
        nombre, descripcion, marca_id, categoria_id, talla_id,
        precio_sugerido, estado
    ) VALUES (
        'Air Max 90', 'Zapatilla deportiva clásica', nike_id, zapatillas_id, talla_40_id,
        299.90, 'ACTIVO'
    ) RETURNING id INTO producto_master_id;

    -- Crear artículos en diferentes colores
    INSERT INTO articulos (producto_master_id, color_id, sku_auto, activo) VALUES
    (producto_master_id, color_negro_id, 'AIR-MAX-90-NEG-40', true),
    (producto_master_id, color_blanco_id, 'AIR-MAX-90-BLA-40', true);

EXCEPTION
    WHEN OTHERS THEN
        -- Ignorar errores si los datos ya existen
        NULL;
END $$;
*/

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE marcas IS 'Datos semilla: 5 marcas base confirmadas en estado real BD';
COMMENT ON TABLE categorias IS 'Datos semilla: 5 categorías base confirmadas en estado real BD';
COMMENT ON TABLE tallas IS 'Datos semilla: 16 tallas base confirmadas en estado real BD';
COMMENT ON TABLE colores IS 'Datos semilla: Colores base para desarrollo';
COMMENT ON TABLE materiales IS 'Datos semilla: Materiales base para productos textiles';
COMMENT ON TABLE tiendas IS 'Datos semilla: Tiendas base para desarrollo';

-- =====================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- =====================================================

-- Consultas para verificar que los datos se insertaron correctamente
-- (Solo para información, no se ejecutan automáticamente)

/*
SELECT 'marcas' as tabla, COUNT(*) as registros FROM marcas WHERE activo = true
UNION ALL
SELECT 'categorias' as tabla, COUNT(*) as registros FROM categorias WHERE activo = true
UNION ALL
SELECT 'tallas' as tabla, COUNT(*) as registros FROM tallas WHERE activo = true
UNION ALL
SELECT 'colores' as tabla, COUNT(*) as registros FROM colores WHERE activo = true
UNION ALL
SELECT 'materiales' as tabla, COUNT(*) as registros FROM materiales WHERE activo = true
UNION ALL
SELECT 'tiendas' as tabla, COUNT(*) as registros FROM tiendas WHERE activa = true;
*/

-- Fin de datos semilla limpios