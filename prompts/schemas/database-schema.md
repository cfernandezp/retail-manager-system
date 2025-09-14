# Database Schema - Sistema Retail Manager

## Esquemas Confirmados y Validados

> **IMPORTANTE**: Estos esquemas han sido validados en desarrollo. Los agentes DEBEN usar exactamente estos nombres de campos y tipos para evitar errores 400/23505.

## Convenciones Establecidas

### Nomenclatura
- **Campos boolean**: Usar `activa` (NO `activo`) para consistencia
- **IDs**: Siempre UUID con `gen_random_uuid()`
- **Timestamps**: `created_at`, `updated_at` con `TIMESTAMPTZ`
- **Códigos**: TEXT UNIQUE para identificadores legibles
- **Precios**: `DECIMAL(10,2)` para montos en soles

### Triggers Estándar
```sql
-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a todas las tablas principales
CREATE TRIGGER trigger_{tabla}_updated_at
    BEFORE UPDATE ON public.{tabla}
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();
```

## Tablas Principales

### 1. usuarios (Extensión de auth.users)
```sql
CREATE TYPE rol_usuario AS ENUM (
    'ADMIN',
    'GERENTE',
    'SUPERVISOR',
    'VENDEDOR',
    'CLIENTE'
);

CREATE TYPE estado_usuario AS ENUM (
    'PENDIENTE_APROBACION',
    'ACTIVO',
    'SUSPENDIDO',
    'RECHAZADO'
);

CREATE TABLE public.usuarios (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    nombre_completo TEXT NOT NULL,
    telefono TEXT,
    direccion TEXT,
    rol rol_usuario NOT NULL DEFAULT 'VENDEDOR',
    estado estado_usuario NOT NULL DEFAULT 'PENDIENTE_APROBACION',
    tienda_asignada UUID REFERENCES public.tiendas(id),
    fecha_creacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_suspension TIMESTAMPTZ,
    fecha_reactivacion TIMESTAMPTZ,
    motivo_rechazo TEXT,
    motivo_suspension TEXT,
    activo BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices críticos
CREATE INDEX idx_usuarios_email ON public.usuarios(email);
CREATE INDEX idx_usuarios_rol ON public.usuarios(rol);
CREATE INDEX idx_usuarios_estado ON public.usuarios(estado);
CREATE INDEX idx_usuarios_tienda ON public.usuarios(tienda_asignada);
```

### 2. tiendas
```sql
CREATE TABLE public.tiendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    direccion TEXT,
    telefono TEXT,
    email TEXT,
    manager_id UUID REFERENCES public.usuarios(id),
    horario_apertura TIME,
    horario_cierre TIME,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_tiendas_codigo ON public.tiendas(codigo);
CREATE INDEX idx_tiendas_activa ON public.tiendas(activa);
CREATE INDEX idx_tiendas_manager ON public.tiendas(manager_id);
```

### 3. marcas
```sql
CREATE TABLE public.marcas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    descripcion TEXT,
    logo_url TEXT,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_marcas_codigo ON public.marcas(codigo);
CREATE INDEX idx_marcas_activa ON public.marcas(activa);
CREATE UNIQUE INDEX idx_marcas_nombre_lower ON public.marcas(LOWER(nombre));
```

### 4. categorias
```sql
CREATE TABLE public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    descripcion TEXT,
    categoria_padre_id UUID REFERENCES public.categorias(id),
    orden INTEGER DEFAULT 0,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_categorias_codigo ON public.categorias(codigo);
CREATE INDEX idx_categorias_activa ON public.categorias(activa);
CREATE INDEX idx_categorias_padre ON public.categorias(categoria_padre_id);
CREATE UNIQUE INDEX idx_categorias_nombre_lower ON public.categorias(LOWER(nombre));
```

### 5. tallas
```sql
CREATE TYPE tipo_talla_enum AS ENUM (
    'INDIVIDUAL',    -- Talla única (S, M, L, XL)
    'NUMERICA',      -- Talla numérica (36, 38, 40, 42)
    'ESPECIAL'       -- Tallas especiales (custom)
);

CREATE TABLE public.tallas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,           -- S, M, L, XL, 36, 38, etc.
    valor TEXT NOT NULL,                   -- Valor mostrado al usuario
    descripcion TEXT,
    tipo_talla tipo_talla_enum DEFAULT 'INDIVIDUAL',
    orden INTEGER DEFAULT 0,               -- Para ordenamiento (S=1, M=2, L=3, etc.)
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraint para evitar duplicados por tipo
    UNIQUE(codigo, tipo_talla)
);

-- Índices
CREATE INDEX idx_tallas_codigo ON public.tallas(codigo);
CREATE INDEX idx_tallas_activa ON public.tallas(activa);
CREATE INDEX idx_tallas_tipo ON public.tallas(tipo_talla);
CREATE INDEX idx_tallas_orden ON public.tallas(orden);
```

### 6. colores
```sql
CREATE TABLE public.colores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,           -- ROJO, AZUL, NEGRO, etc.
    nombre TEXT UNIQUE NOT NULL,           -- Rojo, Azul, Negro, etc.
    hex_color TEXT,                        -- #FF0000, #0000FF, etc.
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_colores_codigo ON public.colores(codigo);
CREATE INDEX idx_colores_activa ON public.colores(activa);
CREATE UNIQUE INDEX idx_colores_nombre_lower ON public.colores(LOWER(nombre));
```

### 7. materiales
```sql
CREATE TABLE public.materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,           -- ALG, POL, LYC, etc.
    nombre TEXT UNIQUE NOT NULL,           -- Algodón, Poliéster, Lycra, etc.
    descripcion TEXT,
    porcentaje_composicion DECIMAL(5,2),   -- Para mezclas de materiales
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_materiales_codigo ON public.materiales(codigo);
CREATE INDEX idx_materiales_activa ON public.materiales(activa);
CREATE UNIQUE INDEX idx_materiales_nombre_lower ON public.materiales(LOWER(nombre));
```

### 8. producto_master
```sql
CREATE TABLE public.producto_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,           -- SKU base del producto
    nombre TEXT NOT NULL,
    descripcion TEXT,
    marca_id UUID NOT NULL REFERENCES public.marcas(id),
    categoria_id UUID NOT NULL REFERENCES public.categorias(id),
    material_id UUID REFERENCES public.materiales(id),
    precio_base DECIMAL(10,2) NOT NULL,    -- Precio base en soles
    costo_base DECIMAL(10,2),              -- Costo base del producto
    margen_minimo DECIMAL(5,2) DEFAULT 20.00, -- Margen mínimo permitido (%)
    imagen_url TEXT,
    tags TEXT[],                           -- Array de etiquetas para búsqueda
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT check_precio_positivo CHECK (precio_base > 0),
    CONSTRAINT check_costo_positivo CHECK (costo_base >= 0),
    CONSTRAINT check_margen_valido CHECK (margen_minimo >= 0 AND margen_minimo <= 100)
);

-- Índices
CREATE INDEX idx_producto_master_codigo ON public.producto_master(codigo);
CREATE INDEX idx_producto_master_activo ON public.producto_master(activo);
CREATE INDEX idx_producto_master_marca ON public.producto_master(marca_id);
CREATE INDEX idx_producto_master_categoria ON public.producto_master(categoria_id);
CREATE INDEX idx_producto_master_material ON public.producto_master(material_id);
CREATE INDEX idx_producto_master_nombre_gin ON public.producto_master USING gin(to_tsvector('spanish', nombre));
CREATE INDEX idx_producto_master_tags_gin ON public.producto_master USING gin(tags);
```

### 9. articulos (Variantes de Producto)
```sql
CREATE TABLE public.articulos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_master_id UUID NOT NULL REFERENCES public.producto_master(id) ON DELETE CASCADE,
    sku TEXT UNIQUE NOT NULL,              -- SKU único por variante
    talla_id UUID NOT NULL REFERENCES public.tallas(id),
    color_id UUID NOT NULL REFERENCES public.colores(id),
    precio_venta DECIMAL(10,2) NOT NULL,   -- Precio específico de esta variante
    costo DECIMAL(10,2),                   -- Costo específico de esta variante
    peso DECIMAL(5,2),                     -- Peso en gramos
    dimensiones JSONB,                     -- {largo: 30, ancho: 20, alto: 5}
    codigo_barras TEXT UNIQUE,             -- Código de barras EAN13/UPC
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints críticos para evitar duplicados
    UNIQUE(producto_master_id, talla_id, color_id),
    CONSTRAINT check_precio_venta_positivo CHECK (precio_venta > 0),
    CONSTRAINT check_costo_positivo CHECK (costo >= 0),
    CONSTRAINT check_peso_positivo CHECK (peso >= 0)
);

-- Índices críticos
CREATE UNIQUE INDEX idx_articulos_sku ON public.articulos(sku);
CREATE INDEX idx_articulos_producto_master ON public.articulos(producto_master_id);
CREATE INDEX idx_articulos_talla ON public.articulos(talla_id);
CREATE INDEX idx_articulos_color ON public.articulos(color_id);
CREATE INDEX idx_articulos_activo ON public.articulos(activo);
CREATE UNIQUE INDEX idx_articulos_codigo_barras ON public.articulos(codigo_barras) WHERE codigo_barras IS NOT NULL;
```

### 10. inventario
```sql
CREATE TABLE public.inventario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    articulo_id UUID NOT NULL REFERENCES public.articulos(id),
    tienda_id UUID NOT NULL REFERENCES public.tiendas(id),
    stock_actual INTEGER NOT NULL DEFAULT 0,
    stock_minimo INTEGER DEFAULT 5,
    stock_maximo INTEGER DEFAULT 100,
    stock_reservado INTEGER DEFAULT 0,      -- Stock reservado para ventas
    ubicacion_fisica TEXT,                  -- Pasillo, estante, etc.
    ultima_actualizacion TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints para integridad de stock
    UNIQUE(articulo_id, tienda_id),
    CONSTRAINT check_stock_actual_positivo CHECK (stock_actual >= 0),
    CONSTRAINT check_stock_minimo_positivo CHECK (stock_minimo >= 0),
    CONSTRAINT check_stock_maximo_positivo CHECK (stock_maximo >= stock_minimo),
    CONSTRAINT check_stock_reservado_valido CHECK (stock_reservado >= 0 AND stock_reservado <= stock_actual)
);

-- Índices para consultas frecuentes
CREATE UNIQUE INDEX idx_inventario_articulo_tienda ON public.inventario(articulo_id, tienda_id);
CREATE INDEX idx_inventario_tienda ON public.inventario(tienda_id);
CREATE INDEX idx_inventario_stock_bajo ON public.inventario(stock_actual) WHERE stock_actual <= stock_minimo;
CREATE INDEX idx_inventario_sin_stock ON public.inventario(stock_actual) WHERE stock_actual = 0;
```

### 11. movimientos_stock
```sql
CREATE TYPE tipo_movimiento AS ENUM (
    'ENTRADA',      -- Compra, devolución cliente
    'SALIDA',       -- Venta, pérdida, merma
    'TRANSFERENCIA',-- Entre tiendas
    'AJUSTE'        -- Corrección de inventario
);

CREATE TYPE motivo_movimiento AS ENUM (
    'VENTA',
    'COMPRA',
    'DEVOLUCION_CLIENTE',
    'DEVOLUCION_PROVEEDOR',
    'TRANSFERENCIA_ENTRADA',
    'TRANSFERENCIA_SALIDA',
    'AJUSTE_INVENTARIO',
    'PERDIDA',
    'MERMA',
    'ROBO',
    'PROMOCION'
);

CREATE TABLE public.movimientos_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    articulo_id UUID NOT NULL REFERENCES public.articulos(id),
    tienda_id UUID NOT NULL REFERENCES public.tiendas(id),
    tipo_movimiento tipo_movimiento NOT NULL,
    motivo motivo_movimiento NOT NULL,
    cantidad INTEGER NOT NULL,              -- Puede ser negativo para salidas
    stock_anterior INTEGER NOT NULL,
    stock_nuevo INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2),          -- Precio al momento del movimiento
    usuario_id UUID REFERENCES public.usuarios(id),
    referencia_id UUID,                     -- ID de venta, compra, transferencia, etc.
    notas TEXT,
    fecha_movimiento TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints para validar coherencia
    CONSTRAINT check_cantidad_no_cero CHECK (cantidad != 0),
    CONSTRAINT check_precio_unitario_positivo CHECK (precio_unitario >= 0)
);

-- Índices para auditoría y reportes
CREATE INDEX idx_movimientos_stock_articulo ON public.movimientos_stock(articulo_id);
CREATE INDEX idx_movimientos_stock_tienda ON public.movimientos_stock(tienda_id);
CREATE INDEX idx_movimientos_stock_tipo ON public.movimientos_stock(tipo_movimiento);
CREATE INDEX idx_movimientos_stock_fecha ON public.movimientos_stock(fecha_movimiento);
CREATE INDEX idx_movimientos_stock_usuario ON public.movimientos_stock(usuario_id);
CREATE INDEX idx_movimientos_stock_referencia ON public.movimientos_stock(referencia_id);
```

### 12. ventas
```sql
CREATE TYPE estado_venta AS ENUM (
    'BORRADOR',     -- Venta en proceso
    'CONFIRMADA',   -- Venta confirmada
    'ENTREGADA',    -- Mercancía entregada
    'CANCELADA',    -- Venta cancelada
    'DEVUELTA'      -- Venta devuelta (total o parcial)
);

CREATE TYPE tipo_comprobante AS ENUM (
    'BOLETA',
    'FACTURA',
    'NOTA_VENTA',
    'TICKET'
);

CREATE TABLE public.ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_venta TEXT UNIQUE NOT NULL,     -- Número correlativo de venta
    tienda_id UUID NOT NULL REFERENCES public.tiendas(id),
    vendedor_id UUID NOT NULL REFERENCES public.usuarios(id),
    cliente_id UUID REFERENCES public.clientes(id), -- Opcional para ventas anónimas
    estado estado_venta DEFAULT 'BORRADOR',
    tipo_comprobante tipo_comprobante DEFAULT 'TICKET',

    -- Totales
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    descuento DECIMAL(10,2) DEFAULT 0,
    impuestos DECIMAL(10,2) DEFAULT 0,      -- IGV 18%
    total DECIMAL(10,2) NOT NULL DEFAULT 0,

    -- Información fiscal
    serie_comprobante TEXT,
    numero_comprobante TEXT,

    -- Fechas y estados
    fecha_venta TIMESTAMPTZ DEFAULT NOW(),
    fecha_entrega TIMESTAMPTZ,
    fecha_cancelacion TIMESTAMPTZ,

    -- Observaciones
    notas TEXT,
    motivo_cancelacion TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT check_subtotal_positivo CHECK (subtotal >= 0),
    CONSTRAINT check_descuento_positivo CHECK (descuento >= 0),
    CONSTRAINT check_impuestos_positivo CHECK (impuestos >= 0),
    CONSTRAINT check_total_positivo CHECK (total >= 0),
    CONSTRAINT check_descuento_no_mayor_subtotal CHECK (descuento <= subtotal)
);

-- Índices críticos
CREATE UNIQUE INDEX idx_ventas_numero ON public.ventas(numero_venta);
CREATE INDEX idx_ventas_tienda ON public.ventas(tienda_id);
CREATE INDEX idx_ventas_vendedor ON public.ventas(vendedor_id);
CREATE INDEX idx_ventas_cliente ON public.ventas(cliente_id);
CREATE INDEX idx_ventas_estado ON public.ventas(estado);
CREATE INDEX idx_ventas_fecha ON public.ventas(fecha_venta);
CREATE INDEX idx_ventas_comprobante ON public.ventas(serie_comprobante, numero_comprobante);
```

### 13. detalle_ventas
```sql
CREATE TABLE public.detalle_ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id UUID NOT NULL REFERENCES public.ventas(id) ON DELETE CASCADE,
    articulo_id UUID NOT NULL REFERENCES public.articulos(id),
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento_unitario DECIMAL(10,2) DEFAULT 0,
    precio_final DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,       -- cantidad * precio_final
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT check_cantidad_positiva CHECK (cantidad > 0),
    CONSTRAINT check_precio_unitario_positivo CHECK (precio_unitario >= 0),
    CONSTRAINT check_descuento_unitario_positivo CHECK (descuento_unitario >= 0),
    CONSTRAINT check_precio_final_positivo CHECK (precio_final >= 0),
    CONSTRAINT check_subtotal_positivo CHECK (subtotal >= 0),
    CONSTRAINT check_descuento_no_mayor_precio CHECK (descuento_unitario <= precio_unitario)
);

-- Índices para consultas frecuentes
CREATE INDEX idx_detalle_ventas_venta ON public.detalle_ventas(venta_id);
CREATE INDEX idx_detalle_ventas_articulo ON public.detalle_ventas(articulo_id);
```

### 14. clientes (Opcional)
```sql
CREATE TYPE tipo_documento AS ENUM (
    'DNI',          -- 8 dígitos
    'RUC',          -- 11 dígitos
    'CARNET_EXTRANJERIA',
    'PASAPORTE'
);

CREATE TABLE public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo_documento tipo_documento DEFAULT 'DNI',
    numero_documento TEXT UNIQUE,
    nombre_completo TEXT NOT NULL,
    email TEXT,
    telefono TEXT,
    direccion TEXT,
    fecha_nacimiento DATE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints para documentos peruanos
    CONSTRAINT check_dni_valido CHECK (
        tipo_documento != 'DNI' OR
        (numero_documento IS NOT NULL AND LENGTH(numero_documento) = 8 AND numero_documento ~ '^[0-9]+$')
    ),
    CONSTRAINT check_ruc_valido CHECK (
        tipo_documento != 'RUC' OR
        (numero_documento IS NOT NULL AND LENGTH(numero_documento) = 11 AND numero_documento ~ '^[0-9]+$')
    )
);

-- Índices
CREATE UNIQUE INDEX idx_clientes_documento ON public.clientes(numero_documento) WHERE numero_documento IS NOT NULL;
CREATE INDEX idx_clientes_activo ON public.clientes(activo);
CREATE INDEX idx_clientes_email ON public.clientes(email);
CREATE INDEX idx_clientes_nombre_gin ON public.clientes USING gin(to_tsvector('spanish', nombre_completo));
```

## Views Optimizadas

### vista_productos_completos
```sql
CREATE VIEW vista_productos_completos AS
SELECT
    pm.id,
    pm.codigo,
    pm.nombre,
    pm.descripcion,
    pm.precio_base,
    pm.activo,
    m.nombre as marca_nombre,
    c.nombre as categoria_nombre,
    mat.nombre as material_nombre,
    COUNT(a.id) as total_variantes,
    COALESCE(SUM(i.stock_actual), 0) as stock_total,
    MIN(a.precio_venta) as precio_minimo,
    MAX(a.precio_venta) as precio_maximo
FROM producto_master pm
LEFT JOIN marcas m ON pm.marca_id = m.id
LEFT JOIN categorias c ON pm.categoria_id = c.id
LEFT JOIN materiales mat ON pm.material_id = mat.id
LEFT JOIN articulos a ON pm.id = a.producto_master_id AND a.activo = true
LEFT JOIN inventario i ON a.id = i.articulo_id
WHERE pm.activo = true
GROUP BY pm.id, pm.codigo, pm.nombre, pm.descripcion, pm.precio_base,
         pm.activo, m.nombre, c.nombre, mat.nombre;
```

### vista_inventario_critico
```sql
CREATE VIEW vista_inventario_critico AS
SELECT
    i.id,
    i.articulo_id,
    i.tienda_id,
    i.stock_actual,
    i.stock_minimo,
    pm.nombre as producto_nombre,
    a.sku,
    t.valor as talla,
    col.nombre as color,
    ti.nombre as tienda_nombre,
    CASE
        WHEN i.stock_actual = 0 THEN 'SIN_STOCK'
        WHEN i.stock_actual <= i.stock_minimo THEN 'STOCK_BAJO'
        ELSE 'STOCK_OK'
    END as estado_stock
FROM inventario i
JOIN articulos a ON i.articulo_id = a.id
JOIN producto_master pm ON a.producto_master_id = pm.id
JOIN tallas t ON a.talla_id = t.id
JOIN colores col ON a.color_id = col.id
JOIN tiendas ti ON i.tienda_id = ti.id
WHERE a.activo = true AND pm.activo = true AND ti.activa = true
ORDER BY
    CASE
        WHEN i.stock_actual = 0 THEN 1
        WHEN i.stock_actual <= i.stock_minimo THEN 2
        ELSE 3
    END,
    pm.nombre, a.sku;
```

## Funciones Útiles

### generar_sku_automatico
```sql
CREATE OR REPLACE FUNCTION generar_sku_automatico(
    p_producto_master_id UUID,
    p_talla_id UUID,
    p_color_id UUID
) RETURNS TEXT AS $$
DECLARE
    codigo_producto TEXT;
    codigo_talla TEXT;
    codigo_color TEXT;
    nuevo_sku TEXT;
BEGIN
    -- Obtener códigos base
    SELECT codigo INTO codigo_producto
    FROM producto_master
    WHERE id = p_producto_master_id;

    SELECT codigo INTO codigo_talla
    FROM tallas
    WHERE id = p_talla_id;

    SELECT codigo INTO codigo_color
    FROM colores
    WHERE id = p_color_id;

    -- Generar SKU: PRODUCTO-TALLA-COLOR
    nuevo_sku := codigo_producto || '-' || codigo_talla || '-' || codigo_color;

    RETURN nuevo_sku;
END;
$$ LANGUAGE plpgsql;
```

### actualizar_stock_por_venta
```sql
CREATE OR REPLACE FUNCTION actualizar_stock_por_venta(
    p_venta_id UUID
) RETURNS VOID AS $$
DECLARE
    detalle RECORD;
BEGIN
    -- Iterar sobre cada item de la venta
    FOR detalle IN
        SELECT dv.articulo_id, dv.cantidad, v.tienda_id
        FROM detalle_ventas dv
        JOIN ventas v ON dv.venta_id = v.id
        WHERE v.id = p_venta_id
    LOOP
        -- Actualizar stock
        UPDATE inventario
        SET
            stock_actual = stock_actual - detalle.cantidad,
            ultima_actualizacion = NOW()
        WHERE articulo_id = detalle.articulo_id
        AND tienda_id = detalle.tienda_id;

        -- Registrar movimiento
        INSERT INTO movimientos_stock (
            articulo_id,
            tienda_id,
            tipo_movimiento,
            motivo,
            cantidad,
            stock_anterior,
            stock_nuevo,
            referencia_id
        ) VALUES (
            detalle.articulo_id,
            detalle.tienda_id,
            'SALIDA',
            'VENTA',
            -detalle.cantidad,
            (SELECT stock_actual + detalle.cantidad FROM inventario
             WHERE articulo_id = detalle.articulo_id AND tienda_id = detalle.tienda_id),
            (SELECT stock_actual FROM inventario
             WHERE articulo_id = detalle.articulo_id AND tienda_id = detalle.tienda_id),
            p_venta_id
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

## Políticas RLS (Row Level Security)

### Usuarios
```sql
-- Solo admins pueden ver todos los usuarios
CREATE POLICY "Admins can view all users" ON usuarios
FOR SELECT USING (
    EXISTS(SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'ADMIN')
);

-- Usuarios pueden ver su propio perfil
CREATE POLICY "Users can view own profile" ON usuarios
FOR SELECT USING (id = auth.uid());
```

### Inventario
```sql
-- Solo pueden ver inventario de tiendas asignadas
CREATE POLICY "Users can view assigned store inventory" ON inventario
FOR SELECT USING (
    tienda_id IN (
        SELECT tienda_asignada FROM usuarios WHERE id = auth.uid()
        UNION
        SELECT id FROM tiendas WHERE manager_id = auth.uid()
    )
);
```

### Ventas
```sql
-- Solo pueden ver ventas de tiendas asignadas
CREATE POLICY "Users can view assigned store sales" ON ventas
FOR SELECT USING (
    tienda_id IN (
        SELECT tienda_asignada FROM usuarios WHERE id = auth.uid()
        UNION
        SELECT id FROM tiendas WHERE manager_id = auth.uid()
    )
    OR vendedor_id = auth.uid()
);
```

## Validaciones Críticas

### Errores Conocidos a Evitar

1. **Campo boolean**: Usar `activa` no `activo`
2. **Constraint violations**: Validar unique antes de INSERT
3. **Stock negativo**: Validar stock suficiente antes de ventas
4. **SKU duplicados**: Usar función de generación automática
5. **Precios negativos**: Validar precios > 0

### Queries de Validación
```sql
-- Verificar consistencia de stock
SELECT
    a.sku,
    i.stock_actual,
    COALESCE(SUM(CASE WHEN ms.tipo_movimiento = 'ENTRADA' THEN ms.cantidad ELSE -ms.cantidad END), 0) as stock_calculado
FROM articulos a
LEFT JOIN inventario i ON a.id = i.articulo_id
LEFT JOIN movimientos_stock ms ON a.id = ms.articulo_id
GROUP BY a.id, a.sku, i.stock_actual
HAVING i.stock_actual != COALESCE(SUM(CASE WHEN ms.tipo_movimiento = 'ENTRADA' THEN ms.cantidad ELSE -ms.cantidad END), 0);

-- Verificar SKUs duplicados
SELECT sku, COUNT(*)
FROM articulos
GROUP BY sku
HAVING COUNT(*) > 1;

-- Verificar precios inconsistentes
SELECT pm.codigo, pm.precio_base, a.sku, a.precio_venta
FROM producto_master pm
JOIN articulos a ON pm.id = a.producto_master_id
WHERE a.precio_venta < pm.precio_base * 0.8  -- Variación mayor a 20%
OR a.precio_venta > pm.precio_base * 2.0;
```

## Comandos de Mantenimiento

### Backup Selectivo
```sql
-- Backup solo tablas principales
pg_dump --data-only --table=usuarios --table=producto_master --table=articulos --table=inventario db_retail > backup_core.sql

-- Restore
psql db_retail < backup_core.sql
```

### Optimización de Índices
```sql
-- Reindexar tablas críticas
REINDEX TABLE articulos;
REINDEX TABLE inventario;
REINDEX TABLE ventas;

-- Analizar estadísticas
ANALYZE;
```

### Limpieza de Datos
```sql
-- Eliminar movimientos de stock antiguos (>1 año)
DELETE FROM movimientos_stock
WHERE fecha_movimiento < NOW() - INTERVAL '1 year';

-- Limpiar ventas borrador antiguas (>7 días)
DELETE FROM ventas
WHERE estado = 'BORRADOR'
AND created_at < NOW() - INTERVAL '7 days';
```