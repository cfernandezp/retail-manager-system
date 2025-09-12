-- Migración: Fix temporal para tabla tallas
-- Fecha: 2025-09-12
-- Descripción: Agregar campo valor y aplicar correcciones necesarias

-- Crear función temporal para ejecutar DDL
CREATE OR REPLACE FUNCTION public.temp_fix_tallas()
RETURNS TEXT AS $$
BEGIN
    -- Agregar columna valor si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='tallas' AND column_name='valor'
    ) THEN
        ALTER TABLE public.tallas ADD COLUMN valor VARCHAR(50);
        UPDATE public.tallas SET valor = codigo WHERE valor IS NULL;
        ALTER TABLE public.tallas ALTER COLUMN valor SET NOT NULL;
    END IF;
    
    RETURN 'Columna valor agregada a tallas exitosamente';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ejecutar la función
SELECT public.temp_fix_tallas();

-- Eliminar función temporal
DROP FUNCTION public.temp_fix_tallas();