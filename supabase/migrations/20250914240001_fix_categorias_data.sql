-- Migración: Corregir datos de categorías - Restaurar categorías específicas de medias
-- Fecha: 2025-09-14 24:00:01
-- Descripción: Limpiar y establecer categorías apropiadas para negocio de medias y ropa

-- ==============================================================================
-- LIMPIAR CATEGORÍAS EXISTENTES Y ESTABLECER DATOS CORRECTOS
-- ==============================================================================

-- Primero, eliminar categorías existentes para evitar conflictos
DELETE FROM public.categorias;

-- Insertar categorías específicas para el negocio de medias y ropa
INSERT INTO public.categorias (nombre, descripcion, prefijo_sku, activo) VALUES
('Medias de Fútbol', 'Medias deportivas para fútbol y deportes de contacto', 'MFU', true),
('Medias Deportivas', 'Medias para actividades deportivas generales', 'MDE', true),
('Medias Casuales', 'Medias para uso diario y casual', 'MCA', true),
('Medias Ejecutivas', 'Medias formales para oficina y eventos', 'MEJ', true),
('Calcetines Deportivos', 'Calcetines para actividades deportivas', 'CDE', true),
('Calcetines Casuales', 'Calcetines para uso diario', 'CCA', true),
('Medias de Compresión', 'Medias terapéuticas y de compresión', 'MCO', true),
('Medias Térmicas', 'Medias para clima frío y actividades de invierno', 'MTE', true),
('Calcetines Tobilleros', 'Calcetines cortos tipo tobillero', 'CTO', true),
('Ropa Interior', 'Ropa interior masculina y femenina', 'RIN', true);

-- ==============================================================================
-- VERIFICACIÓN DE DATOS CORREGIDOS
-- ==============================================================================

-- Mostrar resumen de categorías corregidas
DO $$
BEGIN
    RAISE NOTICE '=== CATEGORÍAS CORREGIDAS ===';
    RAISE NOTICE 'Total categorías: % registros', (SELECT COUNT(*) FROM public.categorias WHERE activo = true);
    RAISE NOTICE '';
    RAISE NOTICE 'Categorías específicas de medias:';
    RAISE NOTICE '• Medias de Fútbol';
    RAISE NOTICE '• Medias Deportivas';
    RAISE NOTICE '• Medias Casuales';
    RAISE NOTICE '• Medias Ejecutivas';
    RAISE NOTICE '• Medias de Compresión';
    RAISE NOTICE '• Medias Térmicas';
    RAISE NOTICE '';
    RAISE NOTICE 'Categorías de calcetines:';
    RAISE NOTICE '• Calcetines Deportivos';
    RAISE NOTICE '• Calcetines Casuales';
    RAISE NOTICE '• Calcetines Tobilleros';
    RAISE NOTICE '';
    RAISE NOTICE 'Otras categorías:';
    RAISE NOTICE '• Ropa Interior';
    RAISE NOTICE '';
    RAISE NOTICE '✅ DATOS DE CATEGORÍAS RESTAURADOS CORRECTAMENTE';
    RAISE NOTICE 'Las categorías ahora reflejan el negocio real de medias y ropa';
END $$;

-- Comentario para documentación
COMMENT ON TABLE public.categorias IS 'Categorías específicas para negocio de medias, calcetines y ropa - Corregidas 2025-09-14';