-- Migración: Corregir esquema tabla tiendas
-- Fecha: 2025-09-13
-- Descripción: Unificar esquema tiendas con estructura requerida

-- Asegurar que la tabla tiendas tenga exactamente los campos requeridos:
-- id, nombre, direccion, admin_tienda_id, activa, created_at
DO $$
BEGIN
    -- Verificar que la tabla tiendas existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tiendas' AND table_schema = 'public') THEN

        -- Agregar campos faltantes si no existen

        -- Campo activa (boolean) - estándar del sistema
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activa') THEN
            -- Si existe 'activo', renombrarlo a 'activa'
            IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activo') THEN
                ALTER TABLE public.tiendas RENAME COLUMN activo TO activa;
            ELSE
                -- Si no existe, crearlo
                ALTER TABLE public.tiendas ADD COLUMN activa BOOLEAN DEFAULT TRUE NOT NULL;
            END IF;
        END IF;

        -- Campo manager_id (UUID) - manager asignado a la tienda
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'manager_id') THEN
            ALTER TABLE public.tiendas ADD COLUMN manager_id UUID;
        END IF;

        -- Campo created_at si no existe
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'created_at') THEN
            ALTER TABLE public.tiendas ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL;
        END IF;

        -- Campo updated_at si no existe
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'updated_at') THEN
            ALTER TABLE public.tiendas ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL;
        END IF;

        -- Asegurar que admin_tienda_id existe (podría llamarse diferente)
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'admin_tienda_id') THEN
            -- Verificar si existe con otro nombre y renombrar si es necesario
            -- Por el momento solo agregamos si no existe
            ALTER TABLE public.tiendas ADD COLUMN admin_tienda_id UUID;
        END IF;

    ELSE
        -- Si la tabla no existe, crearla con el esquema correcto
        CREATE TABLE public.tiendas (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            nombre VARCHAR(200) NOT NULL,
            direccion TEXT,
            admin_tienda_id UUID,
            manager_id UUID,
            activa BOOLEAN DEFAULT TRUE NOT NULL,
            created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
            updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
            -- Campos adicionales del sistema original
            codigo VARCHAR(10) UNIQUE,
            telefono VARCHAR(20),
            email VARCHAR(100),
            configuracion JSONB DEFAULT '{}'
        );
    END IF;

END $$;

-- Crear índices optimizados
CREATE INDEX IF NOT EXISTS idx_tiendas_activa ON public.tiendas(activa);
CREATE INDEX IF NOT EXISTS idx_tiendas_manager ON public.tiendas(manager_id) WHERE manager_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tiendas_admin ON public.tiendas(admin_tienda_id) WHERE admin_tienda_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tiendas_codigo ON public.tiendas(codigo) WHERE codigo IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tiendas_created_at ON public.tiendas(created_at);

-- Trigger para updated_at (verificación robusta)
DO $$
BEGIN
    -- Verificar que no existe el trigger antes de crearlo
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE t.tgname = 'trigger_tiendas_updated_at'
        AND c.relname = 'tiendas'
        AND n.nspname = 'public'
    ) THEN
        -- Verificar que la función existe
        IF EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = 'actualizar_updated_at'
            AND n.nspname = 'public'
        ) THEN
            CREATE TRIGGER trigger_tiendas_updated_at
                BEFORE UPDATE ON public.tiendas
                FOR EACH ROW
                EXECUTE FUNCTION public.actualizar_updated_at();
        END IF;
    END IF;
END $$;

-- Comentarios para documentación
COMMENT ON TABLE public.tiendas IS 'Catálogo de tiendas del sistema retail';
COMMENT ON COLUMN public.tiendas.id IS 'Identificador único de la tienda';
COMMENT ON COLUMN public.tiendas.nombre IS 'Nombre comercial de la tienda';
COMMENT ON COLUMN public.tiendas.direccion IS 'Dirección física de la tienda';
COMMENT ON COLUMN public.tiendas.admin_tienda_id IS 'Usuario administrador de la tienda';
COMMENT ON COLUMN public.tiendas.manager_id IS 'Usuario manager asignado a la tienda';
COMMENT ON COLUMN public.tiendas.activa IS 'Estado activo/inactivo de la tienda';
COMMENT ON COLUMN public.tiendas.codigo IS 'Código único de la tienda (ej: T001, GAM, MES)';
COMMENT ON COLUMN public.tiendas.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN public.tiendas.updated_at IS 'Fecha de última actualización del registro';