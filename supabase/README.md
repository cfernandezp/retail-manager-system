# Sistema de Medias Multi-Tienda - Supabase Backend

## 📋 Descripción General

Backend completo en Supabase para sistema de inventario multi-tienda especializado en medias con estructura jerárquica de productos, variantes por color, inventario independiente por tienda y control granular de permisos.

## 🏗️ Arquitectura del Sistema

### Estructura de Datos
```
PRODUCTO MASTER: "Media fútbol polyester Arley 9-12"
├── Marca: Arley (prefijo SKU: ARL)
├── Categoría: Polyester (prefijo SKU: POL)  
├── Talla: 9-12 (rango o única)
├── Precio sugerido: S/ 8.50
└── ARTÍCULOS (variantes por color):
    ├── SKU: POL-ARL-912-AZU (auto-generado)
    ├── SKU: POL-ARL-912-ROJ
    └── SKU: POL-ARL-912-NEG
```

### Roles y Permisos
- **SUPER_ADMIN**: Gestión completa del catálogo y todas las tiendas
- **ADMIN_TIENDA**: Gestión de inventario y precios de su tienda
- **VENDEDOR**: Solo lectura de inventario y registro de ventas

## 📂 Estructura de Archivos

```
supabase/
├── migrations/
│   ├── 001_initial_schema.sql      # Tablas principales y constraints
│   ├── 002_rls_policies.sql        # Row Level Security por rol
│   ├── 003_functions_triggers.sql  # Funciones y triggers automáticos
│   ├── 004_views_optimized.sql     # Views para consultas frecuentes
│   ├── 005_seed_data.sql          # Datos de ejemplo para testing
│   └── 006_realtime_storage.sql   # Configuración Realtime y Storage
├── functions/
│   ├── generate-sku/              # Edge Function para generación de SKUs
│   └── inventory-operations/      # Edge Function para operaciones de inventario
└── docs/
    ├── queries_ejemplos.sql       # Queries optimizadas de ejemplo
    └── README.md                  # Esta documentación
```

## 🗄️ Schema de Base de Datos

### Tablas Maestras
- **marcas**: Catálogo de marcas con prefijos SKU
- **categorias**: Materiales/tipos con prefijos SKU  
- **tallas**: Flexibles (rangos 9-12 o únicas 3, 12)
- **colores**: Colores disponibles con prefijos SKU
- **tiendas**: Puntos de venta con configuraciones

### Tablas de Productos
- **productos_master**: Producto base sin variantes de color
- **articulos**: Variantes por color con SKU único auto-generado

### Tablas de Inventario
- **inventario_tienda**: Stock y precios independientes por tienda
- **movimientos_stock**: Auditoría completa de cambios

### Tablas de Usuario
- **perfiles_usuario**: Extensión de auth.users con roles y tiendas

## 🔧 Funcionalidades Principales

### 1. Generación Automática de SKUs
```sql
-- Formato: CATEGORIA-MARCA-TALLA-COLOR
-- Ejemplo: POL-ARL-912-AZU
SELECT generate_sku('ARL', 'POL', '9-12', 'AZU');
```

### 2. Gestión de Stock con Auditoría
```sql
-- Actualizar stock y crear movimiento automático
SELECT update_stock_and_create_movement(
    p_articulo_id := 'uuid-articulo',
    p_tienda_id := 'uuid-tienda',
    p_tipo_movimiento := 'VENTA',
    p_cantidad := -2,  -- Negativo para venta
    p_motivo := 'Venta POS'
);
```

### 3. Traspasos Entre Tiendas
```sql
-- Traspaso automático con auditoría completa
SELECT realizar_traspaso_inventario(
    p_articulo_id := 'uuid-articulo',
    p_tienda_origen_id := 'uuid-tienda-origen',
    p_tienda_destino_id := 'uuid-tienda-destino',
    p_cantidad := 5
);
```

## 📊 Views Optimizadas

### vw_articulos_pos
View principal para POS con todos los datos necesarios para búsquedas rápidas.

### vw_inventario_consolidado  
Inventario completo por tienda con cálculos de negocio.

### vw_dashboard_inventario
Métricas agregadas para dashboards ejecutivos.

### vw_movimientos_detallados
Historial completo de movimientos para reportes.

### vw_catalogo_completo
Catálogo maestro con estadísticas (solo SUPER_ADMIN).

## 🔒 Row Level Security (RLS)

### Políticas por Rol

**SUPER_ADMIN:**
- Acceso completo a todas las tablas
- Gestión del catálogo maestro
- Visibilidad global de inventarios

**ADMIN_TIENDA:**
- Gestión completa de su tienda
- Modificación de precios y stock
- Reportes de su tienda

**VENDEDOR:**
- Solo lectura de inventario activo
- Registro de ventas
- Reportes limitados (30 días)

### Ejemplo de Política RLS
```sql
CREATE POLICY "inventario_admin_own_store" ON inventario_tienda
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM get_user_role_and_store() 
        WHERE user_role = 'ADMIN_TIENDA' 
        AND store_id = inventario_tienda.tienda_id
    )
);
```

## 🚀 Edge Functions

### generate-sku
Generación inteligente de SKUs únicos con validación.

**Endpoint:** `POST /functions/v1/generate-sku`

```typescript
// Ejemplo de uso
const { data } = await supabase.functions.invoke('generate-sku', {
  body: {
    producto_master_id: 'uuid-producto',
    color_id: 'uuid-color'
  }
});
// Respuesta: { sku: 'POL-ARL-912-AZU', nombre_completo: '...', is_unique: true }
```

### inventory-operations
Operaciones complejas de inventario en tiempo real.

**Operaciones disponibles:**
- `stock_update`: Actualización de stock
- `transfer`: Traspaso entre tiendas  
- `bulk_update`: Actualización masiva
- `price_update`: Cambio de precios
- `low_stock_alert`: Alertas de stock bajo

## 📡 Realtime y Notificaciones

### Canales Configurados
- `inventory_changes`: Cambios de inventario por tienda
- `stock_movements`: Movimientos de stock en tiempo real
- `low_stock_alerts`: Alertas automáticas de stock bajo

### Configuración Cliente
```typescript
const channel = supabase
  .channel(`inventory_store_${tiendaId}`)
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'inventario_tienda',
    filter: `tienda_id=eq.${tiendaId}`
  }, (payload) => {
    console.log('Stock update:', payload);
  })
  .subscribe();
```

## 💾 Storage y Archivos

### Buckets Configurados
- **producto-images**: Imágenes de productos (público)
- **marca-logos**: Logos de marcas (público)  
- **documents**: Documentos privados (facturas, reportes)

### Políticas de Storage
- Lectura pública para imágenes y logos
- Subida restringida por rol
- Documentos filtrados por tienda

## 📈 Queries de Ejemplo

### Búsqueda POS por SKU
```sql
SELECT * FROM vw_articulos_pos WHERE sku = 'POL-ARL-912-AZU';
```

### Stock por Tienda
```sql
SELECT * FROM vw_inventario_consolidado 
WHERE tienda_id = 'uuid-tienda' 
AND estado_stock != 'SIN_STOCK';
```

### Artículos Más Vendidos
```sql
SELECT 
    articulo_sku,
    SUM(ABS(cantidad)) as total_vendido
FROM vw_movimientos_detallados
WHERE tipo_movimiento = 'VENTA'
AND fecha_movimiento >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY articulo_sku
ORDER BY total_vendido DESC;
```

## 🔧 Setup e Instalación

### 1. Configuración Inicial
```bash
# Instalar Supabase CLI
npm install -g supabase

# Inicializar proyecto
supabase init

# Ejecutar migraciones
supabase db push
```

### 2. Variables de Entorno
```env
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 3. Despliegue Edge Functions
```bash
supabase functions deploy generate-sku
supabase functions deploy inventory-operations
```

## 📊 Datos de Prueba

El archivo `005_seed_data.sql` incluye:
- 5 marcas con prefijos SKU
- 5 categorías de materiales
- 7 tallas (rangos y únicas)
- 10 colores con códigos hex
- 4 tiendas ejemplo
- 5 productos master
- 20+ artículos con variantes
- Inventario inicial realista
- Movimientos de ejemplo

## 🎯 Casos de Uso Principales

### 1. POS - Búsqueda Rápida
- Búsqueda por SKU, código de barras o nombre
- Verificación de stock en tiempo real
- Precios dinámicos por tienda

### 2. Gestión de Inventario
- Actualización de stock con auditoría
- Alertas automáticas de stock bajo
- Traspasos entre tiendas

### 3. Reportes y Analytics  
- Dashboard ejecutivo con KPIs
- Análisis de rotación ABC
- Reportes de ventas por período

### 4. Administración Multi-Tienda
- Control granular por roles
- Precios independientes por tienda
- Visibilidad segmentada de datos

## 🔍 Optimizaciones de Performance

### Índices Implementados
- Búsquedas POS (SKU, código de barras)
- Filtros por tienda y estado
- Ordenamiento por fecha/valor
- Texto completo en nombres

### Views Materializadas
- Dashboard metrics para consulta rápida
- Inventario consolidado pre-calculado
- Estadísticas de catálogo

### Particionado de Datos
- Movimientos antiguos archivados automáticamente
- Limpieza programada de logs

## 🚨 Consideraciones de Seguridad

- RLS habilitado en todas las tablas
- Validación de entrada en Edge Functions
- Auditoría completa de cambios críticos
- Tokens JWT con expiración
- Filtrado por tienda en todas las consultas

## 📝 Mantenimiento

### Tareas Automáticas
- Limpieza de movimientos antiguos (6+ meses)
- Alertas de stock bajo via pg_notify
- Actualización automática de timestamps

### Monitoreo Recomendado
- Performance de queries principales
- Uso de storage y bandwidth
- Alertas de RLS failures
- Métricas de Edge Functions

---

## 🎉 Sistema Listo para Producción

Este backend de Supabase está completamente funcional y listo para soportar un sistema de medias multi-tienda con:

✅ **Schema robusto** con constraints y validaciones  
✅ **RLS granular** por roles y tiendas  
✅ **Automatización completa** de SKUs y auditoría  
✅ **Views optimizadas** para consultas frecuentes  
✅ **Edge Functions** para lógica compleja  
✅ **Realtime** para actualizaciones instantáneas  
✅ **Storage seguro** para archivos multimedia  
✅ **Datos de prueba** para desarrollo inmediato

**Próximos pasos:** Integrar con frontend Flutter utilizando el cliente de Supabase y las views/functions proporcionadas.