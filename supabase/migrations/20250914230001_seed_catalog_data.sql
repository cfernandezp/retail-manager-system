-- Migración: Poblar datos de catálogo básico
-- Fecha: 2025-09-14 23:00:01
-- Descripción: Insertar datos de prueba para marcas, categorías y tallas

-- ==============================================================================
-- MARCAS DE PRUEBA
-- ==============================================================================

INSERT INTO public.marcas (nombre, descripcion, activo) VALUES
('Nike', 'Marca deportiva internacional', true),
('Adidas', 'Calzado y ropa deportiva', true),
('Puma', 'Marca alemana de artículos deportivos', true),
('Under Armour', 'Ropa deportiva de alta performance', true),
('Reebok', 'Marca de calzado deportivo', true),
('New Balance', 'Calzado deportivo especializado', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- CATEGORÍAS DE PRUEBA
-- ==============================================================================

INSERT INTO public.categorias (nombre, descripcion, activo) VALUES
('Medias Deportivas', 'Medias para actividades deportivas', true),
('Medias Casuales', 'Medias para uso diario', true),
('Medias de Compresión', 'Medias terapéuticas y de compresión', true),
('Medias Térmicas', 'Medias para clima frío', true),
('Calcetines Cortos', 'Calcetines tobilleros', true),
('Medias Ejecutivas', 'Medias formales para oficina', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- TALLAS DE PRUEBA
-- ==============================================================================

INSERT INTO public.tallas (codigo, tipo, talla_unica, activo) VALUES
('S', 'UNICA', 35, true),
('M', 'UNICA', 38, true),
('L', 'UNICA', 41, true),
('XL', 'UNICA', 44, true),
('XS', 'UNICA', 32, true)
ON CONFLICT (codigo) DO NOTHING;

-- Tallas con rango
INSERT INTO public.tallas (codigo, tipo, talla_min, talla_max, activo) VALUES
('35-37', 'RANGO', 35, 37, true),
('38-40', 'RANGO', 38, 40, true),
('41-43', 'RANGO', 41, 43, true),
('44-46', 'RANGO', 44, 46, true)
ON CONFLICT (codigo) DO NOTHING;

-- Log informativo
DO $$
BEGIN
    RAISE NOTICE '✅ DATOS DE CATÁLOGO INSERTADOS EXITOSAMENTE';
    RAISE NOTICE '📦 Marcas: 6 registros';
    RAISE NOTICE '📂 Categorías: 6 registros';
    RAISE NOTICE '📏 Tallas: 9 registros (5 únicas + 4 rangos)';
    RAISE NOTICE 'Los dropdowns ahora tendrán datos disponibles';
END $$;