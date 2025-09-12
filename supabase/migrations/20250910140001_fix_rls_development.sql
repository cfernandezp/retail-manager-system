-- Migración: Corregir RLS para desarrollo
-- Fecha: 2025-09-10
-- Descripción: Deshabilitar temporalmente RLS para evitar recursión en desarrollo

-- ⚠️  TEMPORAL: Deshabilitar RLS para desarrollo local ⚠️
ALTER TABLE public.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria_usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tiendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones_tiempo_real DISABLE ROW LEVEL SECURITY;

-- Crear función para verificar estado RLS
CREATE OR REPLACE FUNCTION check_rls_status()
RETURNS TABLE(table_name text, rls_enabled boolean) 
LANGUAGE SQL
AS $$
  SELECT 
    tablename::text,
    rowsecurity
  FROM pg_tables 
  WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'roles', 'auditoria_usuarios', 'tiendas', 'notificaciones_tiempo_real');
$$;

-- Log informativo
DO $$ 
BEGIN 
    RAISE NOTICE '⚠️  RLS DESHABILITADO PARA DESARROLLO LOCAL ⚠️';
    RAISE NOTICE 'Esto permite acceso completo a datos para testing.';
    RAISE NOTICE 'Usuario admin creado: admin@test.com / admin123';
    RAISE NOTICE 'Para verificar estado: SELECT * FROM check_rls_status();';
END $$;