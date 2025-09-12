-- Migración temporal: Deshabilitar RLS para pruebas de login
-- Fecha: 2025-09-09
-- Descripción: Deshabilitar temporalmente RLS para solucionar recursión infinita

-- Deshabilitar RLS en tablas problemáticas
ALTER TABLE public.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- Crear política simple de bypass para desarrollo
-- Esto es TEMPORAL y solo para desarrollo local

-- Comentario de seguridad
COMMENT ON TABLE public.usuarios IS 'RLS deshabilitado temporalmente para desarrollo. HABILITAR en producción.';
COMMENT ON TABLE public.roles IS 'RLS deshabilitado temporalmente para desarrollo. HABILITAR en producción.';

-- Información
DO $$ 
BEGIN 
    RAISE NOTICE '⚠️  RLS DESHABILITADO TEMPORALMENTE ⚠️';
    RAISE NOTICE 'Esto es solo para desarrollo. NO usar en producción.';
END $$;