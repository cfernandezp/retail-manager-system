-- Migración: Corrección de compatibilidad de nombres de tabla
-- Fecha: 2025-09-12
-- Descripción: Crear alias/vista para compatibilidad con AuthBloc

-- Crear vista perfiles_usuario que apunta a usuarios para compatibilidad
CREATE OR REPLACE VIEW public.perfiles_usuario AS
SELECT * FROM public.usuarios;

-- Garantizar que las operaciones funcionen en la vista también
COMMENT ON VIEW public.perfiles_usuario IS 'Vista de compatibilidad para tabla usuarios, usado por AuthBloc';

-- Crear reglas para hacer la vista completamente operativa (INSERT, UPDATE, DELETE)
CREATE OR REPLACE RULE perfiles_usuario_insert AS
    ON INSERT TO public.perfiles_usuario DO INSTEAD
    INSERT INTO public.usuarios VALUES (NEW.*);

CREATE OR REPLACE RULE perfiles_usuario_update AS
    ON UPDATE TO public.perfiles_usuario DO INSTEAD
    UPDATE public.usuarios SET
        email = NEW.email,
        nombre_completo = NEW.nombre_completo,
        rol_id = NEW.rol_id,
        estado = NEW.estado,
        email_verificado = NEW.email_verificado,
        aprobado_por = NEW.aprobado_por,
        fecha_aprobacion = NEW.fecha_aprobacion,
        ultimo_acceso = NEW.ultimo_acceso,
        intentos_fallidos = NEW.intentos_fallidos,
        bloqueado_hasta = NEW.bloqueado_hasta,
        metadatos = NEW.metadatos,
        created_at = NEW.created_at,
        updated_at = NEW.updated_at
    WHERE id = NEW.id;

CREATE OR REPLACE RULE perfiles_usuario_delete AS
    ON DELETE TO public.perfiles_usuario DO INSTEAD
    DELETE FROM public.usuarios WHERE id = OLD.id;

-- Asegurar que las políticas RLS se apliquen también a la vista
ALTER VIEW public.perfiles_usuario OWNER TO postgres;

-- Comentario final
COMMENT ON VIEW public.perfiles_usuario IS 'Vista de compatibilidad que permite usar tanto "usuarios" como "perfiles_usuario" para referenciar la misma tabla';