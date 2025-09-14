-- Migración: Asegurar datos básicos siempre disponibles
-- Fecha: 2025-09-14 20:00:01
-- Descripción: Script definitivo para evitar listas vacías - datos mínimos requeridos

-- ==============================================================================
-- DATOS BÁSICOS DE MARCAS
-- ==============================================================================

-- Insertar marcas básicas si no existen
INSERT INTO public.marcas (nombre, descripcion, prefijo_sku, activo) VALUES
('Arley', 'Marca principal de medias y ropa interior', 'ARL', true),
('Nike', 'Marca deportiva premium', 'NIK', true),
('Adidas', 'Marca deportiva internacional', 'ADD', true),
('Puma', 'Marca deportiva de alto rendimiento', 'PUM', true),
('Genérica', 'Marca genérica para productos sin marca específica', 'GEN', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- DATOS BÁSICOS DE CATEGORÍAS
-- ==============================================================================

-- Insertar categorías básicas si no existen
INSERT INTO public.categorias (nombre, descripcion, prefijo_sku, activo) VALUES
('Medias', 'Medias para hombre y mujer', 'MED', true),
('Calcetines', 'Calcetines deportivos y casuales', 'CAL', true),
('Ropa Interior', 'Ropa interior masculina y femenina', 'ROI', true),
('Deportivo', 'Ropa deportiva y activewear', 'DEP', true),
('Casual', 'Ropa casual de uso diario', 'CAS', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- DATOS BÁSICOS DE TALLAS
-- ==============================================================================

-- Insertar tallas básicas si no existen
INSERT INTO public.tallas (codigo, nombre, valor, tipo, activo) VALUES
('UNICA', 'Talla Única', 'UNICA', 'INDIVIDUAL', true),
('XS', 'Extra Small', 'XS', 'INDIVIDUAL', true),
('S', 'Small', 'S', 'INDIVIDUAL', true),
('M', 'Medium', 'M', 'INDIVIDUAL', true),
('L', 'Large', 'L', 'INDIVIDUAL', true),
('XL', 'Extra Large', 'XL', 'INDIVIDUAL', true),
('XXL', 'Double Extra Large', 'XXL', 'INDIVIDUAL', true),
('36-38', 'Rango 36-38', '36-38', 'RANGO', true),
('39-42', 'Rango 39-42', '39-42', 'RANGO', true),
('43-46', 'Rango 43-46', '43-46', 'RANGO', true)
ON CONFLICT (codigo) DO NOTHING;

-- ==============================================================================
-- DATOS BÁSICOS DE COLORES
-- ==============================================================================

-- Insertar colores básicos si no existen
INSERT INTO public.colores (nombre, codigo_abrev, codigo_hex, hex_color, activo) VALUES
('Blanco', 'BLA', '#FFFFFF', '#FFFFFF', true),
('Negro', 'NEG', '#000000', '#000000', true),
('Azul', 'AZU', '#0000FF', '#0000FF', true),
('Rojo', 'ROJ', '#FF0000', '#FF0000', true),
('Verde', 'VER', '#00FF00', '#00FF00', true),
('Amarillo', 'AMA', '#FFFF00', '#FFFF00', true),
('Gris', 'GRI', '#808080', '#808080', true),
('Rosa', 'ROS', '#FFC0CB', '#FFC0CB', true),
('Morado', 'MOR', '#800080', '#800080', true),
('Naranja', 'NAR', '#FFA500', '#FFA500', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- DATOS BÁSICOS DE MATERIALES
-- ==============================================================================

-- Insertar materiales básicos si no existen
INSERT INTO public.materiales (nombre, descripcion, activo) VALUES
('Polyester', 'Material sintético, resistente y de secado rápido', true),
('Algodón', 'Material natural, suave y transpirable', true),
('Mezcla Algodón-Polyester', 'Combinación de comodidad y durabilidad', true),
('Lycra', 'Material elástico para mejor ajuste', true),
('Nylon', 'Material sintético muy resistente', true),
('Bambú', 'Material ecológico con propiedades antimicrobianas', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- DATOS BÁSICOS DE TIENDAS
-- ==============================================================================

-- Insertar tienda principal si no existe
INSERT INTO public.tiendas (nombre, direccion, telefono, email, activo) VALUES
('Tienda Principal', 'Av. Principal 123, Lima', '+51 999 888 777', 'tienda@retail.com', true),
('Sucursal Centro', 'Jr. Lima 456, Lima Centro', '+51 999 888 778', 'centro@retail.com', true)
ON CONFLICT (nombre) DO NOTHING;

-- ==============================================================================
-- USUARIO ADMIN POR DEFECTO
-- ==============================================================================

-- Insertar usuario admin si no existe (para desarrollo)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'authenticated',
    'authenticated',
    'admin@test.com',
    '$2a$10$MqCOv8OJ6.4DmI4z0YgKCOqiOl9jS0Pb5UO5pGOhv5Q8WGb9yJmE2', -- admin123
    NOW(),
    NOW(),
    '',
    NOW(),
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Admin User", "role": "admin"}',
    false,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL,
    false,
    NULL
) ON CONFLICT (email) DO NOTHING;

-- Insertar perfil de usuario admin si no existe
INSERT INTO public.perfiles_usuario (
    id,
    email,
    nombre_completo,
    rol,
    tienda_id,
    activo,
    created_at,
    updated_at
) VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'admin@test.com',
    'Administrador de Prueba',
    'SUPER_ADMIN',
    (SELECT id FROM public.tiendas WHERE nombre = 'Tienda Principal' LIMIT 1),
    true,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- VERIFICACIÓN DE DATOS
-- ==============================================================================

-- Mostrar resumen de datos insertados
DO $$
BEGIN
    RAISE NOTICE '=== DATOS BÁSICOS INSERTADOS ===';
    RAISE NOTICE 'Marcas: % registros', (SELECT COUNT(*) FROM public.marcas WHERE activo = true);
    RAISE NOTICE 'Categorías: % registros', (SELECT COUNT(*) FROM public.categorias WHERE activo = true);
    RAISE NOTICE 'Tallas: % registros', (SELECT COUNT(*) FROM public.tallas WHERE activo = true);
    RAISE NOTICE 'Colores: % registros', (SELECT COUNT(*) FROM public.colores WHERE activo = true);
    RAISE NOTICE 'Materiales: % registros', (SELECT COUNT(*) FROM public.materiales WHERE activo = true);
    RAISE NOTICE 'Tiendas: % registros', (SELECT COUNT(*) FROM public.tiendas WHERE activo = true);
    RAISE NOTICE 'Usuarios: % registros', (SELECT COUNT(*) FROM auth.users WHERE email = 'admin@test.com');
    RAISE NOTICE '=== FIN VERIFICACIÓN ===';
END $$;

-- Comentarios para documentación
COMMENT ON TABLE public.marcas IS 'Datos básicos de marcas siempre disponibles';
COMMENT ON TABLE public.categorias IS 'Datos básicos de categorías siempre disponibles';
COMMENT ON TABLE public.tallas IS 'Datos básicos de tallas siempre disponibles';
COMMENT ON TABLE public.colores IS 'Datos básicos de colores siempre disponibles';
COMMENT ON TABLE public.materiales IS 'Datos básicos de materiales siempre disponibles';
COMMENT ON TABLE public.tiendas IS 'Datos básicos de tiendas siempre disponibles';