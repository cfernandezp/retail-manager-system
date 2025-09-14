-- =====================================================
-- SCRIPT: Generador Automático de Documentación de Schema
-- =====================================================
-- Propósito: Generar automáticamente el estado real de todas las tablas
-- Uso: Ejecutar tras aplicar migraciones para regenerar documentación

-- =====================================================
-- GENERAR ESTRUCTURA COMPLETA DE TABLAS PRINCIPALES
-- =====================================================

-- Función para generar documentación de una tabla
CREATE OR REPLACE FUNCTION generate_table_docs(table_name_param TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    result_text TEXT := '';
    col_record RECORD;
    constraint_record RECORD;
BEGIN
    result_text := result_text || '#### `' || table_name_param || '`' || chr(10);
    result_text := result_text || '```sql' || chr(10);

    -- Obtener columnas de la tabla
    FOR col_record IN
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_name = table_name_param
        AND table_schema = 'public'
        ORDER BY ordinal_position
    LOOP
        result_text := result_text || col_record.column_name;

        -- Agregar tipo de dato
        CASE
            WHEN col_record.data_type = 'character varying' THEN
                result_text := result_text || ' VARCHAR(' || col_record.character_maximum_length || ')';
            WHEN col_record.data_type = 'uuid' THEN
                result_text := result_text || ' UUID';
            WHEN col_record.data_type = 'boolean' THEN
                result_text := result_text || ' BOOLEAN';
            WHEN col_record.data_type = 'text' THEN
                result_text := result_text || ' TEXT';
            WHEN col_record.data_type = 'integer' THEN
                result_text := result_text || ' INTEGER';
            WHEN col_record.data_type = 'numeric' THEN
                result_text := result_text || ' DECIMAL';
            WHEN col_record.data_type = 'timestamp with time zone' THEN
                result_text := result_text || ' TIMESTAMP WITH TIME ZONE';
            WHEN col_record.data_type = 'jsonb' THEN
                result_text := result_text || ' JSONB';
            ELSE
                result_text := result_text || ' ' || upper(col_record.data_type);
        END CASE;

        -- Agregar constraints y defaults
        IF col_record.column_default IS NOT NULL THEN
            IF col_record.column_default LIKE 'uuid_generate_v4()%' THEN
                result_text := result_text || ' PRIMARY KEY DEFAULT uuid_generate_v4()';
            ELSIF col_record.column_default = 'true' THEN
                result_text := result_text || ' DEFAULT true';
            ELSIF col_record.column_default = 'false' THEN
                result_text := result_text || ' DEFAULT false';
            ELSIF col_record.column_default = 'now()' THEN
                result_text := result_text || ' DEFAULT NOW()';
            ELSIF col_record.column_default = '''{}''::jsonb' THEN
                result_text := result_text || ' DEFAULT ''{}''';
            END IF;
        END IF;

        IF col_record.is_nullable = 'NO' AND col_record.column_default IS NULL THEN
            result_text := result_text || ' NOT NULL';
        END IF;

        result_text := result_text || chr(10);
    END LOOP;

    result_text := result_text || '```' || chr(10) || chr(10);

    RETURN result_text;
END $$;

-- =====================================================
-- EJECUTAR GENERACIÓN DE DOCUMENTACIÓN
-- =====================================================

DO $$
DECLARE
    doc_content TEXT := '';
    table_list TEXT[] := ARRAY[
        'marcas', 'categorias', 'tallas', 'colores', 'materiales',
        'tiendas', 'productos_master', 'articulos',
        'inventario_tienda', 'movimientos_stock'
    ];
    table_name TEXT;
BEGIN
    RAISE NOTICE '📝 GENERANDO DOCUMENTACIÓN AUTOMÁTICA DE SCHEMA';
    RAISE NOTICE '=================================================';

    doc_content := '# ESTADO ACTUAL DEL ESQUEMA - GENERADO AUTOMÁTICAMENTE' || chr(10) || chr(10);
    doc_content := doc_content || '> **GENERADO**: ' || to_char(NOW(), 'YYYY-MM-DD HH24:MI:SS UTC') || chr(10);
    doc_content := doc_content || '> **FUENTE**: Consulta directa a information_schema' || chr(10) || chr(10);

    FOREACH table_name IN ARRAY table_list
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = table_name AND table_schema = 'public') THEN
            doc_content := doc_content || generate_table_docs(table_name);
            RAISE NOTICE '✅ Tabla % documentada', table_name;
        ELSE
            RAISE NOTICE '⚠️  Tabla % no existe', table_name;
        END IF;
    END LOOP;

    RAISE NOTICE '=================================================';
    RAISE NOTICE '📋 DOCUMENTACIÓN GENERADA EXITOSAMENTE';
    RAISE NOTICE '💾 Copiar contenido y actualizar docs/CURRENT_SCHEMA_STATE.md';
    RAISE NOTICE '=================================================';

    -- Output del contenido generado
    RAISE NOTICE '%', doc_content;
END $$;

-- Limpiar función temporal
DROP FUNCTION generate_table_docs(TEXT);