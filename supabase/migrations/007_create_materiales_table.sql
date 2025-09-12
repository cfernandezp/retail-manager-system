-- =====================================================
-- MIGRACIÓN: TABLA MATERIALES
-- =====================================================
-- Descripción: Crea tabla materiales separada de categorías
-- Fecha: 2025-09-11
-- Versión: 1.0.0

BEGIN;

-- =====================================================
-- 1. CREAR TABLA MATERIALES
-- =====================================================

CREATE TABLE public.materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    codigo_abrev VARCHAR(10), -- Para SKUs
    densidad DECIMAL(5,2),    -- g/m² textiles
    propiedades JSONB DEFAULT '{}',
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX idx_materiales_nombre ON public.materiales(nombre);
CREATE INDEX idx_materiales_activo ON public.materiales(activo);
CREATE INDEX idx_materiales_codigo_abrev ON public.materiales(codigo_abrev);

-- =====================================================
-- 3. TRIGGER PARA UPDATED_AT
-- =====================================================

CREATE TRIGGER trigger_materiales_updated_at
    BEFORE UPDATE ON public.materiales
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- 4. AGREGAR COLUMNA MATERIAL_ID A PRODUCTOS_MASTER
-- =====================================================

ALTER TABLE public.productos_master 
ADD COLUMN material_id UUID REFERENCES public.materiales(id);

-- =====================================================
-- 5. MIGRAR DATOS DE CATEGORÍAS A MATERIALES
-- =====================================================

-- Insertar materiales desde todas las categorías actuales (que son materiales)
-- Basado en nombres conocidos de materiales textiles
INSERT INTO public.materiales (id, nombre, descripcion, codigo_abrev, activo, created_at, updated_at)
SELECT 
    id,
    nombre,
    descripcion,
    prefijo_sku as codigo_abrev, -- Mapear prefijo_sku a codigo_abrev
    activo,
    created_at,
    updated_at
FROM public.categorias 
WHERE LOWER(nombre) IN ('polyester', 'algodón', 'lycra', 'bambú', 'lana', 'algodón', 'algodón')
   OR nombre ILIKE '%polyester%' 
   OR nombre ILIKE '%algodón%'
   OR nombre ILIKE '%lycra%'
   OR nombre ILIKE '%bambú%'
   OR nombre ILIKE '%lana%';

-- Actualizar productos_master para referenciar materiales migrados
UPDATE public.productos_master 
SET material_id = categoria_id
WHERE categoria_id IN (
    SELECT id FROM public.categorias 
    WHERE LOWER(nombre) IN ('polyester', 'algodón', 'lycra', 'bambú', 'lana')
       OR nombre ILIKE '%polyester%' 
       OR nombre ILIKE '%algodón%'
       OR nombre ILIKE '%lycra%'
       OR nombre ILIKE '%bambú%'
       OR nombre ILIKE '%lana%'
);

-- =====================================================
-- 6. OPCIONAL: MARCAR CATEGORÍAS COMO MATERIALES
-- =====================================================

-- No eliminamos las categorías por compatibilidad, pero las podemos marcar
-- para identificar cuáles se han migrado a materiales
-- 
-- NOTA: Las categorías se mantienen para productos que pueden tener 
-- categorías de estilo/uso además de material

-- =====================================================
-- 7. COMENTARIOS DESCRIPTIVOS
-- =====================================================

COMMENT ON TABLE public.materiales IS 'Tabla de materiales textiles para productos';
COMMENT ON COLUMN public.materiales.codigo_abrev IS 'Código abreviado para generación de SKUs';
COMMENT ON COLUMN public.materiales.densidad IS 'Densidad del material en g/m²';
COMMENT ON COLUMN public.materiales.propiedades IS 'Propiedades técnicas del material en formato JSON';

COMMIT;