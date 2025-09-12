-- Crear función trigger para sincronizar email_verificado
CREATE OR REPLACE FUNCTION sync_email_verified()
RETURNS TRIGGER AS $$
BEGIN
  -- Si el email_confirmed_at cambió de NULL a NOT NULL, actualizar email_verificado
  IF OLD.email_confirmed_at IS NULL AND NEW.email_confirmed_at IS NOT NULL THEN
    UPDATE public.usuarios 
    SET email_verificado = true,
        estado = CASE 
          WHEN estado = 'PENDIENTE_EMAIL' THEN 'PENDIENTE_APROBACION'
          ELSE estado
        END
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear el trigger
DROP TRIGGER IF EXISTS sync_email_verified_trigger ON auth.users;
CREATE TRIGGER sync_email_verified_trigger
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION sync_email_verified();
