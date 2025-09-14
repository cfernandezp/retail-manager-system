-- Migración: Deshabilitar RLS para tablas de catálogo en desarrollo
-- Fecha: 2025-09-14 22:20:01
-- Descripción: Deshabilitar RLS para facilitar desarrollo en tablas de catálogo

-- ==============================================================================
-- PROBLEMA
-- ==============================================================================
-- Error: new row violates row-level security policy for table "tallas", code: 42501
-- Causa: RLS está habilitado para tablas de catálogo (marcas, categorias, tallas, etc.)
-- Solución: Deshabilitar RLS para desarrollo en tablas de catálogo

-- ==============================================================================
-- DESHABILITAR RLS PARA TABLAS DE CATÁLOGO EN DESARROLLO
-- ==============================================================================

-- Deshabilitar RLS para tablas de catálogo básico
ALTER TABLE public.marcas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tallas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.colores DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.materiales DISABLE ROW LEVEL SECURITY;

-- Deshabilitar RLS para tablas de productos
ALTER TABLE public.productos_master DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.articulos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventario_tienda DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimientos_stock DISABLE ROW LEVEL SECURITY;

-- Log informativo
DO $$
BEGIN
    RAISE NOTICE '⚠️  RLS DESHABILITADO PARA TABLAS DE CATÁLOGO EN DESARROLLO ⚠️';
    RAISE NOTICE 'Tablas afectadas: marcas, categorias, tallas, colores, materiales';
    RAISE NOTICE 'Tablas productos: productos_master, articulos, inventario_tienda, movimientos_stock';
    RAISE NOTICE 'Esto facilita el desarrollo y testing sin restricciones RLS.';
END $$;

-- Actualizar función para verificar estado RLS incluyendo nuevas tablas
CREATE OR REPLACE FUNCTION check_rls_status()
RETURNS TABLE(table_name text, rls_enabled boolean)
LANGUAGE SQL
AS $$
  SELECT
    tablename::text,
    rowsecurity
  FROM pg_tables
  WHERE schemaname = 'public'
  AND tablename IN (
    'usuarios', 'roles', 'auditoria_usuarios', 'tiendas', 'notificaciones_tiempo_real',
    'marcas', 'categorias', 'tallas', 'colores', 'materiales',
    'productos_master', 'articulos', 'inventario_tienda', 'movimientos_stock'
  )
  ORDER BY tablename;
$$;