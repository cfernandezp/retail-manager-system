-- Seed inicial para Retail Manager
-- Crear usuario SUPER_ADMIN por defecto

-- Crear usuario de prueba (método compatible con Supabase local)
DO $$ 
DECLARE
    user_id UUID := gen_random_uuid();
    encrypted_password TEXT;
BEGIN 
    -- Crear hash de la contraseña (sin caracteres especiales para compatibilidad)
    encrypted_password := crypt('admin123', gen_salt('bf'));
    
    -- Insertar en auth.users directamente
    INSERT INTO auth.users (
        id,
        instance_id,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        aud,
        role
    ) VALUES (
        user_id,
        '00000000-0000-0000-0000-000000000000',
        'admin@test.com',
        encrypted_password,
        NOW(),
        NOW(),
        NOW(),
        'authenticated',
        'authenticated'
    );
    
    -- Insertar en tabla usuarios
    INSERT INTO public.usuarios (
        id, 
        email, 
        nombre_completo,
        rol_id, 
        estado, 
        email_verificado,
        created_at
    ) VALUES (
        user_id,
        'admin@test.com',
        'Administrador de Prueba',
        (SELECT id FROM public.roles WHERE nombre = 'SUPER_ADMIN'),
        'ACTIVA',
        TRUE,
        NOW()
    );
    
    RAISE NOTICE 'Usuario admin creado exitosamente: admin@test.com / admin123';
    RAISE NOTICE 'ID del usuario: %', user_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creando usuario admin: %', SQLERRM;
END $$;

-- Datos de ejemplo para testing (opcional)
-- Crear algunos productos de ejemplo
INSERT INTO public.roles (nombre, descripcion, permisos) VALUES 
('SUPERVISOR', 'Supervisor de operaciones', '{"pos": ["read", "write"], "reports": ["read"], "inventory": ["read"], "users": ["read"]}')
ON CONFLICT (nombre) DO NOTHING;

-- Mensaje de información
DO $$ 
BEGIN 
    RAISE NOTICE 'Seed completado. Recuerde crear manualmente el usuario SUPER_ADMIN inicial.';
    RAISE NOTICE 'Email: admin@test.com';
    RAISE NOTICE 'Password: admin123';
END $$;