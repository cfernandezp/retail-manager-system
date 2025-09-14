-- Test SQL directo para verificar corrección de tiendas
-- Ejecutar con: psql -h localhost -p 54322 -U postgres -d postgres -f test_tiendas_sql.sql

\echo '=========================================='
\echo 'TEST: Verificación corrección tabla tiendas'
\echo '=========================================='

\echo 'Test 1: Verificar estructura de tabla tiendas'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'tiendas' AND table_schema = 'public'
ORDER BY ordinal_position;

\echo ''
\echo 'Test 2: Verificar datos en tabla tiendas'
SELECT id, nombre, codigo, activa, manager_id, created_at
FROM public.tiendas
LIMIT 5;

\echo ''
\echo 'Test 3: Contar tiendas activas'
SELECT COUNT(*) as tiendas_activas
FROM public.tiendas
WHERE activa = TRUE;

\echo ''
\echo 'Test 4: Verificar vista estadisticas_por_tienda'
SELECT tienda_codigo, tienda_nombre, total_usuarios, usuarios_activos
FROM public.estadisticas_por_tienda
LIMIT 3;

\echo ''
\echo 'Test 5: Verificar que NO existe columna activo (obsoleta)'
SELECT COUNT(*) as columna_activo_existe
FROM information_schema.columns
WHERE table_name = 'tiendas' AND column_name = 'activo' AND table_schema = 'public';

\echo ''
\echo '=========================================='
\echo 'FIN TEST - Si todos los resultados son OK,'
\echo 'la corrección de tiendas fue exitosa.'
\echo '=========================================='