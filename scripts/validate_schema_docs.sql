-- =====================================================
-- SCRIPT: Validación de Documentación vs BD Real
-- =====================================================
-- Propósito: Verificar que docs/CURRENT_SCHEMA_STATE.md esté actualizado
-- Uso: Ejecutar manualmente tras aplicar migraciones

-- =====================================================
-- VERIFICAR CAMPOS CRÍTICOS DOCUMENTADOS
-- =====================================================

DO $$
DECLARE
    errors_found INTEGER := 0;
    warning_msg TEXT := '';
BEGIN
    RAISE NOTICE '🔍 VALIDANDO CONSISTENCIA DOCUMENTACIÓN vs BD REAL';
    RAISE NOTICE '================================================';

    -- Verificar campo 'activo' en marcas
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'marcas' AND column_name = 'activo'
    ) THEN
        errors_found := errors_found + 1;
        warning_msg := warning_msg || '❌ marcas.activo no existe en BD' || chr(10);
    ELSE
        RAISE NOTICE '✅ marcas.activo - CORRECTO';
    END IF;

    -- Verificar campo 'activo' en categorias
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'categorias' AND column_name = 'activo'
    ) THEN
        errors_found := errors_found + 1;
        warning_msg := warning_msg || '❌ categorias.activo no existe en BD' || chr(10);
    ELSE
        RAISE NOTICE '✅ categorias.activo - CORRECTO';
    END IF;

    -- Verificar campo 'activo' en tallas
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tallas' AND column_name = 'activo'
    ) THEN
        errors_found := errors_found + 1;
        warning_msg := warning_msg || '❌ tallas.activo no existe en BD' || chr(10);
    ELSE
        RAISE NOTICE '✅ tallas.activo - CORRECTO';
    END IF;

    -- Verificar campo 'activa' en tiendas (caso especial)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tiendas' AND column_name = 'activa'
    ) THEN
        errors_found := errors_found + 1;
        warning_msg := warning_msg || '❌ tiendas.activa no existe en BD' || chr(10);
    ELSE
        RAISE NOTICE '✅ tiendas.activa - CORRECTO';
    END IF;

    -- Verificar campo 'manager_id' en tiendas
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tiendas' AND column_name = 'manager_id'
    ) THEN
        errors_found := errors_found + 1;
        warning_msg := warning_msg || '❌ tiendas.manager_id no existe en BD' || chr(10);
    ELSE
        RAISE NOTICE '✅ tiendas.manager_id - CORRECTO';
    END IF;

    -- Resultado final
    RAISE NOTICE '================================================';
    IF errors_found = 0 THEN
        RAISE NOTICE '🎉 DOCUMENTACIÓN ACTUALIZADA - No hay inconsistencias';
    ELSE
        RAISE NOTICE '🚨 DOCUMENTACIÓN DESACTUALIZADA - % errores encontrados', errors_found;
        RAISE NOTICE '%', warning_msg;
        RAISE NOTICE '👉 ACCIÓN REQUERIDA: Actualizar docs/CURRENT_SCHEMA_STATE.md';
    END IF;
END $$;