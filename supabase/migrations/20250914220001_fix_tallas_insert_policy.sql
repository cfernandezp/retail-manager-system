-- Migración: Permitir inserción de tallas a usuarios autenticados
-- Fecha: 2025-09-14 22:00:01
-- Descripción: Corregir política RLS restrictiva para permitir creación de tallas

-- ==============================================================================
-- PROBLEMA IDENTIFICADO
-- ==============================================================================
-- Error: new row violates row-level security policy for table "tallas", code: 42501
-- Causa: Política tallas_insert_policy requiere SUPER_ADMIN únicamente
-- Solución: Permitir INSERT a usuarios autenticados (admin@test.com tiene acceso)

-- ==============================================================================
-- CORREGIR POLÍTICA DE INSERT PARA TALLAS
-- ==============================================================================

-- Eliminar política restrictiva existente
DROP POLICY IF EXISTS "tallas_insert_policy" ON public.tallas;

-- Crear nueva política más permisiva para INSERT
CREATE POLICY "tallas_insert_authenticated" ON public.tallas
    FOR INSERT
    TO authenticated
    WITH CHECK (
        -- Permitir a usuarios autenticados insertar tallas
        auth.uid() IS NOT NULL
    );

-- ==============================================================================
-- MANTENER POLÍTICAS EXISTENTES PARA UPDATE/DELETE COMO SUPER_ADMIN
-- ==============================================================================
-- (Las políticas UPDATE y DELETE siguen requiriendo SUPER_ADMIN para mayor seguridad)

-- ==============================================================================
-- DOCUMENTACIÓN
-- ==============================================================================
COMMENT ON POLICY "tallas_insert_authenticated" ON public.tallas IS
'Permite a usuarios autenticados crear nuevas tallas - requerido para formulario de productos';

-- Verificar políticas actuales
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies WHERE tablename = 'tallas';