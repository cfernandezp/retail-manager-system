-- Migración: Correcciones al Schema de Productos
-- Fecha: 2025-09-12
-- Descripción: Corregir discrepancias entre BD y modelos, agregar tabla materiales

-- ==============================================================================
-- 1. CREAR TABLA MATERIALES (Faltaba)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    metadatos JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para materiales
CREATE INDEX IF NOT EXISTS idx_materiales_activo ON public.materiales(activo);

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
-- 2. AGREGAR MATERIAL_ID A PRODUCTOS_MASTER
-- ==============================================================================

-- Agregar columna material_id si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='productos_master' AND column_name='material_id') THEN
        ALTER TABLE public.productos_master 
        ADD COLUMN material_id UUID REFERENCES public.materiales(id);
    END IF;
END $$;

-- ==============================================================================
-- 3. CORREGIR CAMPOS INCONSISTENTES
-- ==============================================================================

-- Agregar columna 'valor' a tallas (para compatibilidad con modelo)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='tallas' AND column_name='valor') THEN
        ALTER TABLE public.tallas ADD COLUMN valor VARCHAR(50);
        -- Copiar datos de 'codigo' a 'valor' 
        UPDATE public.tallas SET valor = codigo WHERE valor IS NULL;
        -- Hacer valor NOT NULL después de la migración de datos
        ALTER TABLE public.tallas ALTER COLUMN valor SET NOT NULL;
    END IF;
END $$;

-- Cambiar 'activa' por 'activo' en marcas para consistencia
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='marcas' AND column_name='activa') THEN
        ALTER TABLE public.marcas RENAME COLUMN activa TO activo;
    END IF;
END $$;

-- Cambiar 'activa' por 'activo' en categorias para consistencia
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='categorias' AND column_name='activa') THEN
        ALTER TABLE public.categorias RENAME COLUMN activa TO activo;
    END IF;
END $$;

-- Cambiar 'activa' por 'activo' en tallas para consistencia
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='tallas' AND column_name='activa') THEN
        ALTER TABLE public.tallas RENAME COLUMN activa TO activo;
    END IF;
END $$;

-- Cambiar 'activa' por 'activo' en tiendas para consistencia
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='tiendas' AND column_name='activa') THEN
        ALTER TABLE public.tiendas RENAME COLUMN activa TO activo;
    END IF;
END $$;

-- Agregar columna hex_color a colores (para compatibilidad con modelo)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='colores' AND column_name='hex_color') THEN
        ALTER TABLE public.colores ADD COLUMN hex_color VARCHAR(7);
        -- Copiar datos de 'codigo_hex' a 'hex_color' 
        UPDATE public.colores SET hex_color = codigo_hex WHERE hex_color IS NULL;
    END IF;
END $$;

-- ==============================================================================
-- 4. INSERTAR DATOS INICIALES PARA MATERIALES
-- ==============================================================================

INSERT INTO public.materiales (nombre, descripcion) VALUES 
('Polyester', 'Material sintético, resistente y de secado rápido'),
('Algodón', 'Material natural, suave y transpirable'),
('Mezcla Algodón-Polyester', 'Combinación de comodidad y durabilidad'),
('Lycra', 'Material elástico para mejor ajuste'),
('Nylon', 'Material sintético muy resistente'),
('Bambú', 'Material ecológico con propiedades antimicrobianas')
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- 5. ACTUALIZAR ÍNDICES
-- ==============================================================================

-- Recrear índices con nombres corregidos
DROP INDEX IF EXISTS idx_marcas_activa;
CREATE INDEX IF NOT EXISTS idx_marcas_activo ON public.marcas(activo);

DROP INDEX IF EXISTS idx_categorias_activa;
CREATE INDEX IF NOT EXISTS idx_categorias_activo ON public.categorias(activo);

DROP INDEX IF EXISTS idx_tallas_activa;
CREATE INDEX IF NOT EXISTS idx_tallas_activo ON public.tallas(activo);

-- Índice para productos_master con material_id
CREATE INDEX IF NOT EXISTS idx_productos_master_material ON public.productos_master(material_id);

-- ==============================================================================
-- 6. ACTUALIZAR PRODUCTOS EXISTENTES CON MATERIALES
-- ==============================================================================

-- Asignar materiales a productos existentes basado en categoría
UPDATE public.productos_master 
SET material_id = (
    SELECT m.id FROM public.materiales m WHERE m.nombre = 'Polyester' LIMIT 1
)
WHERE categoria_id IN (
    SELECT id FROM public.categorias WHERE nombre = 'Polyester'
) AND material_id IS NULL;

UPDATE public.productos_master 
SET material_id = (
    SELECT m.id FROM public.materiales m WHERE m.nombre = 'Algodón' LIMIT 1
)
WHERE categoria_id IN (
    SELECT id FROM public.categorias WHERE nombre = 'Algodón'
) AND material_id IS NULL;

-- ==============================================================================
-- 7. CORRECCIÓN DEL MODELO ARTICULOS - CAMPO SKU_AUTO
-- ==============================================================================

-- Cambiar 'sku' por 'sku_auto' en artículos para consistencia con modelo
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='articulos' AND column_name='sku') THEN
        ALTER TABLE public.articulos RENAME COLUMN sku TO sku_auto;
    END IF;
END $$;

-- Recrear índice con nombre correcto
DROP INDEX IF EXISTS idx_articulos_sku;
CREATE INDEX IF NOT EXISTS idx_articulos_sku_auto ON public.articulos(sku_auto);

-- Actualizar constraint único
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.constraint_column_usage 
               WHERE constraint_name LIKE '%sku%' AND table_name = 'articulos') THEN
        -- Buscar y eliminar constraint viejo
        EXECUTE 'ALTER TABLE public.articulos DROP CONSTRAINT ' || 
                (SELECT constraint_name FROM information_schema.table_constraints 
                 WHERE table_name = 'articulos' AND constraint_type = 'UNIQUE' 
                 AND constraint_name LIKE '%sku%' LIMIT 1);
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Ignorar si no existe
    NULL;
END $$;

-- Agregar nuevo constraint único
ALTER TABLE public.articulos ADD CONSTRAINT uk_articulos_sku_auto UNIQUE (sku_auto);

-- ==============================================================================
-- 8. ACTUALIZAR FUNCIÓN DE GENERACIÓN DE SKU
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.generar_sku_articulo()
RETURNS TRIGGER AS $$
DECLARE
    marca_codigo VARCHAR(5);
    categoria_codigo VARCHAR(5);
    talla_codigo VARCHAR(10);
    color_codigo VARCHAR(5);
    nuevo_sku VARCHAR(100);
BEGIN
    -- Si ya tiene SKU, no modificar
    IF NEW.sku_auto IS NOT NULL AND NEW.sku_auto != '' THEN
        RETURN NEW;
    END IF;
    
    -- Obtener códigos para construir SKU
    SELECT 
        UPPER(LEFT(REGEXP_REPLACE(m.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
        UPPER(LEFT(REGEXP_REPLACE(c.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
        UPPER(REGEXP_REPLACE(t.codigo, '[^A-Za-z0-9]', '', 'g')),
        col.codigo_abrev
    INTO marca_codigo, categoria_codigo, talla_codigo, color_codigo
    FROM public.productos_master pm
    JOIN public.marcas m ON pm.marca_id = m.id
    JOIN public.categorias c ON pm.categoria_id = c.id
    JOIN public.tallas t ON pm.talla_id = t.id
    JOIN public.colores col ON NEW.color_id = col.id
    WHERE pm.id = NEW.producto_master_id;
    
    -- Construir SKU: MED-POL-ARL-912-AZU
    nuevo_sku := 'MED-' || categoria_codigo || '-' || marca_codigo || '-' || talla_codigo || '-' || color_codigo;
    
    -- Verificar unicidad y agregar sufijo si es necesario
    WHILE EXISTS (SELECT 1 FROM public.articulos WHERE sku_auto = nuevo_sku) LOOP
        nuevo_sku := nuevo_sku || '-' || TO_CHAR(FLOOR(RANDOM() * 100), 'FM00');
    END LOOP;
    
    NEW.sku_auto := nuevo_sku;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 9. COMENTARIOS
-- ==============================================================================

COMMENT ON TABLE public.materiales IS 'Catálogo de materiales para productos (Polyester, Algodón, etc.)';
COMMENT ON COLUMN public.productos_master.material_id IS 'Material principal del producto';
COMMENT ON COLUMN public.tallas.valor IS 'Valor de la talla (compatibilidad con modelo)';
COMMENT ON COLUMN public.colores.hex_color IS 'Código hexadecimal del color (compatibilidad con modelo)';

-- Mostrar resumen de cambios
SELECT 
    'Tablas corregidas' as tipo,
    'marcas, categorias, tallas, tiendas, colores, articulos' as detalle
UNION ALL
SELECT 
    'Nueva tabla' as tipo,
    'materiales' as detalle
UNION ALL
SELECT 
    'Nuevas columnas' as tipo,
    'productos_master.material_id, tallas.valor, colores.hex_color' as detalle;