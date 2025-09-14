# Scripts de Mantenimiento de Schema

## 📝 Propósito

Estos scripts ayudan a mantener la documentación de schema actualizada y detectar inconsistencias entre la documentación y la base de datos real.

## 🔧 Scripts Disponibles

### 1. `validate_schema_docs.sql`
**Valida** que la documentación esté sincronizada con la BD real.

```bash
# Ejecutar validación
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f scripts/validate_schema_docs.sql
```

**Output esperado:**
```
✅ marcas.activo - CORRECTO
✅ categorias.activo - CORRECTO
✅ tallas.activo - CORRECTO
✅ tiendas.activa - CORRECTO
✅ tiendas.manager_id - CORRECTO
🎉 DOCUMENTACIÓN ACTUALIZADA - No hay inconsistencias
```

### 2. `generate_schema_docs.sql`
**Genera** automáticamente documentación del estado real de BD.

```bash
# Generar documentación fresca
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f scripts/generate_schema_docs.sql
```

**Uso:**
1. Ejecutar script
2. Copiar output generado
3. Actualizar `docs/CURRENT_SCHEMA_STATE.md`

## 🔄 Flujo de Trabajo Recomendado

### Tras Aplicar Nuevas Migraciones:

1. **Validar** estado actual:
   ```bash
   psql -f scripts/validate_schema_docs.sql
   ```

2. Si hay errores, **regenerar** documentación:
   ```bash
   psql -f scripts/generate_schema_docs.sql
   ```

3. **Actualizar** manualmente `docs/CURRENT_SCHEMA_STATE.md`

4. **Confirmar** que todo está correcto:
   ```bash
   psql -f scripts/validate_schema_docs.sql
   ```

## ⚠️ Limitaciones Actuales

- **No es automático**: Requiere ejecución manual
- **No integrado en CI/CD**: Sin validación automática en pipeline
- **Actualización manual**: Output debe copiarse manualmente

## 🎯 Mejoras Futuras Posibles

1. **Git Hooks**: Pre-commit que valide consistencia
2. **Script Python**: Generador que actualice archivos directamente
3. **CI/CD Integration**: Validación automática en pipeline
4. **Supabase Functions**: Edge functions que mantengan sincronización

## 📋 Ejemplo de Uso Completo

```bash
# 1. Aplicar nueva migración
supabase db push

# 2. Validar documentación
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f scripts/validate_schema_docs.sql

# 3. Si hay errores, regenerar
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f scripts/generate_schema_docs.sql

# 4. Actualizar docs/CURRENT_SCHEMA_STATE.md con output

# 5. Confirmar corrección
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f scripts/validate_schema_docs.sql
```