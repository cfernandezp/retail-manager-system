-- Migración: Crear tabla materiales separada
-- Fecha: 2025-09-11
-- Descripción: Crear tabla materiales independiente y migrar datos de categorias con tipo=MATERIAL

-- ==============================================================================
-- 1. CREAR TABLA MATERIALES
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    codigo_abrev VARCHAR(10), -- Para códigos cortos en SKUs
    densidad DECIMAL(5,2), -- g/m² para materiales textiles
    propiedades JSONB DEFAULT '{}', -- Transpirable, antibacterial, etc.
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 2. MIGRAR DATOS DE CATEGORIAS CON TIPO=MATERIAL
-- ==============================================================================

INSERT INTO public.materiales (nombre, descripcion, codigo_abrev, activo, created_at)
SELECT 
    nombre,
    descripcion,
    UPPER(LEFT(REGEXP_REPLACE(nombre, '[^A-Za-z0-9]', '', 'g'), 3)) as codigo_abrev,
    activa,
    created_at
FROM public.categorias
WHERE tipo = 'MATERIAL'
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- 3. AGREGAR COLUMNA MATERIAL_ID A PRODUCTOS_MASTER
-- ==============================================================================

-- Agregar columna material_id si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'productos_master' AND column_name = 'material_id'
    ) THEN
        ALTER TABLE public.productos_master 
        ADD COLUMN material_id UUID REFERENCES public.materiales(id);
    END IF;
END$$;

-- ==============================================================================
-- 4. MIGRAR RELACIONES EXISTENTES
-- ==============================================================================

-- Actualizar productos_master para referenciar materiales en lugar de categorias
UPDATE public.productos_master 
SET material_id = m.id
FROM public.materiales m
JOIN public.categorias c ON c.nombre = m.nombre
WHERE productos_master.categoria_id = c.id 
AND c.tipo = 'MATERIAL'
AND productos_master.material_id IS NULL;

-- ==============================================================================
-- 5. CREAR ÍNDICES Y TRIGGERS
-- ==============================================================================

-- Índices para materiales
CREATE INDEX IF NOT EXISTS idx_materiales_activo ON public.materiales(activo);
CREATE INDEX IF NOT EXISTS idx_materiales_nombre ON public.materiales USING gin(to_tsvector('spanish', nombre));
CREATE INDEX IF NOT EXISTS idx_materiales_codigo ON public.materiales(codigo_abrev);

-- Índice para nueva relación
CREATE INDEX IF NOT EXISTS idx_productos_master_material ON public.productos_master(material_id);

-- Trigger para updated_at - COMENTADO PARA EVITAR DUPLICADOS
-- La migración 20250914020001_fix_trigger_duplicates.sql se encarga de esto
/*
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE t.tgname = 'trigger_materiales_updated_at'
        AND c.relname = 'materiales'
        AND n.nspname = 'public'
    ) THEN
        CREATE TRIGGER trigger_materiales_updated_at
            BEFORE UPDATE ON public.materiales
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;
END $$;
*/

-- ==============================================================================
-- 6. DATOS INICIALES ADICIONALES
-- ==============================================================================

-- Insertar materiales básicos adicionales si no existen
INSERT INTO public.materiales (nombre, descripcion, codigo_abrev, densidad, propiedades) VALUES 
('Algodón Peinado', 'Algodón de alta calidad con fibras peinadas', 'ALG', 180.0, '{"suavidad": "alta", "transpirable": true}'),
('Bambú Orgánico', 'Fibra de bambú natural y antibacterial', 'BAM', 160.0, '{"antibacterial": true, "hipoalergenico": true}'),
('Merino Wool', 'Lana merino premium para uso deportivo', 'MER', 200.0, '{"termorregulador": true, "antibacterial": true}'),
('Coolmax', 'Fibra sintética de secado rápido', 'COL', 120.0, '{"secado_rapido": true, "absorcion_humedad": true}')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- 7. COMENTARIOS PARA DOCUMENTACIÓN
-- ==============================================================================

COMMENT ON TABLE public.materiales IS 'Catálogo de materiales textiles independiente de categorías';
COMMENT ON COLUMN public.materiales.codigo_abrev IS 'Código abreviado para usar en SKUs automáticos';
COMMENT ON COLUMN public.materiales.densidad IS 'Densidad del material en g/m² para especificaciones técnicas';
COMMENT ON COLUMN public.materiales.propiedades IS 'Propiedades específicas del material (JSON flexible)';
COMMENT ON COLUMN public.productos_master.material_id IS 'Referencia al material del producto (separado de categoría)';

-- ==============================================================================
-- VERIFICACIÓN
-- ==============================================================================

-- Verificar migración exitosa
DO $$
BEGIN
    -- Mostrar conteo de registros migrados
    RAISE NOTICE 'Materiales creados: %', (SELECT COUNT(*) FROM public.materiales);
    RAISE NOTICE 'Productos con material asignado: %', (SELECT COUNT(*) FROM public.productos_master WHERE material_id IS NOT NULL);
    RAISE NOTICE 'Categorías tipo MATERIAL: %', (SELECT COUNT(*) FROM public.categorias WHERE tipo = 'MATERIAL');
END$$;