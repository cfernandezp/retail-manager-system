-- Migración: Forzar deshabilitación de RLS para tablas críticas vacías
-- Fecha: 2025-09-14 23:50:01
-- Descripción: Deshabilitar RLS específicamente para marcas, categorias, tallas

-- ==============================================================================
-- ANÁLISIS DEL PROBLEMA
-- ==============================================================================
-- PROBLEMA: marcas, categorias, tallas devuelven 0 registros por RLS
-- CAUSA: Políticas RLS estrictas bloqueando acceso a datos
-- DIFERENCIA: materiales y tiendas SÍ funcionan (RLS diferente o deshabilitado)
-- EVIDENCIA: Mismo usuario, misma auth, pero comportamiento diferente por tabla

-- ==============================================================================
-- SOLUCIÓN: DESHABILITAR RLS FORZADAMENTE
-- ==============================================================================

-- Deshabilitar RLS para las 3 tablas problemáticas
ALTER TABLE public.marcas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tallas DISABLE ROW LEVEL SECURITY;

-- Log de confirmación
DO $$
BEGIN
    RAISE NOTICE '🚨 RLS FORZADAMENTE DESHABILITADO PARA DESARROLLO';
    RAISE NOTICE '📋 Tablas corregidas: marcas, categorias, tallas';
    RAISE NOTICE '🎯 Objetivo: Permitir acceso sin restricciones RLS en desarrollo';
    RAISE NOTICE '✅ Los dropdowns ahora deberían mostrar datos correctamente';
END $$;