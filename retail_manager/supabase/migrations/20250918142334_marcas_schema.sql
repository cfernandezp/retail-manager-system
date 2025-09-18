alter table "public"."articulos" drop constraint "uk_articulos_sku_auto";

drop view if exists "public"."estadisticas_por_tienda";

drop view if exists "public"."productos_disponibles_tienda";

drop view if exists "public"."stock_consolidado_productos";

drop view if exists "public"."usuarios_lista_optimizada";

drop index if exists "public"."idx_articulos_sku_auto";

drop index if exists "public"."idx_categorias_activo";

drop index if exists "public"."idx_marcas_activo";

drop index if exists "public"."idx_tallas_activo";

drop index if exists "public"."uk_articulos_sku_auto";

drop index if exists "public"."idx_tiendas_activa";

alter table "public"."articulos" drop column "sku_auto";

alter table "public"."articulos" add column "sku" character varying(100) not null;

alter table "public"."categorias" drop column "activo";

alter table "public"."categorias" add column "activa" boolean default true;

alter table "public"."colores" drop column "hex_color";

alter table "public"."marcas" drop column "activo";

alter table "public"."marcas" add column "activa" boolean default true;

alter table "public"."tallas" drop column "activo";

alter table "public"."tallas" drop column "valor";

alter table "public"."tallas" add column "activa" boolean default true;

alter table "public"."tiendas" drop column "activo";

alter table "public"."tiendas" add column "activa" boolean default true;

CREATE UNIQUE INDEX articulos_sku_key ON public.articulos USING btree (sku);

CREATE INDEX idx_articulos_sku ON public.articulos USING btree (sku);

CREATE INDEX idx_categorias_activa ON public.categorias USING btree (activa);

CREATE INDEX idx_marcas_activa ON public.marcas USING btree (activa);

CREATE INDEX idx_tallas_activa ON public.tallas USING btree (activa);

CREATE INDEX idx_tiendas_activa ON public.tiendas USING btree (activa);

alter table "public"."articulos" add constraint "articulos_sku_key" UNIQUE using index "articulos_sku_key";

set check_function_bodies = off;

create or replace view "public"."estadisticas_por_tienda" as  SELECT t.id AS tienda_id,
    t.nombre AS tienda_nombre,
    t.codigo AS tienda_codigo,
    count(u.id) AS total_usuarios,
    count(u.id) FILTER (WHERE ((u.estado)::text = 'ACTIVA'::text)) AS usuarios_activos,
    count(u.id) FILTER (WHERE ((u.estado)::text = 'PENDIENTE_APROBACION'::text)) AS usuarios_pendientes,
    count(u.id) FILTER (WHERE ((u.estado)::text = 'SUSPENDIDA'::text)) AS usuarios_suspendidos,
    count(u.id) FILTER (WHERE (u.ultimo_acceso >= (now() - '7 days'::interval))) AS activos_ultima_semana,
    count(u.id) FILTER (WHERE ((r.nombre)::text = 'ADMIN'::text)) AS admins,
    count(u.id) FILTER (WHERE ((r.nombre)::text = 'VENDEDOR'::text)) AS vendedores,
    count(u.id) FILTER (WHERE ((r.nombre)::text = 'OPERARIO'::text)) AS operarios,
    t.manager_id,
    m.nombre_completo AS manager_nombre
   FROM (((tiendas t
     LEFT JOIN usuarios u ON ((u.tienda_asignada = t.id)))
     LEFT JOIN roles r ON ((u.rol_id = r.id)))
     LEFT JOIN usuarios m ON ((t.manager_id = m.id)))
  WHERE (t.activa = true)
  GROUP BY t.id, t.nombre, t.codigo, t.manager_id, m.nombre_completo
  ORDER BY t.codigo;


CREATE OR REPLACE FUNCTION public.generar_sku_articulo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    marca_codigo VARCHAR(5);
    categoria_codigo VARCHAR(5);
    talla_codigo VARCHAR(10);
    color_codigo VARCHAR(5);
    nuevo_sku VARCHAR(100);
BEGIN
    -- Si ya tiene SKU, no modificar
    IF NEW.sku IS NOT NULL AND NEW.sku != '' THEN
        RETURN NEW;
    END IF;
    
    -- Obtener códigos para construir SKU
    SELECT 
        UPPER(LEFT(REGEXP_REPLACE(m.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
        UPPER(LEFT(REGEXP_REPLACE(c.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
        UPPER(REGEXP_REPLACE(t.codigo, '[^A-Za-z0-9]', '', 'g')),
        col.codigo_abrev
    INTO marca_codigo, categoria_codigo, talla_codigo, color_codigo
    FROM public.productos_master pm
    JOIN public.marcas m ON pm.marca_id = m.id
    JOIN public.categorias c ON pm.categoria_id = c.id
    JOIN public.tallas t ON pm.talla_id = t.id
    JOIN public.colores col ON NEW.color_id = col.id
    WHERE pm.id = NEW.producto_master_id;
    
    -- Construir SKU: MED-POL-ARL-912-AZU
    nuevo_sku := 'MED-' || categoria_codigo || '-' || marca_codigo || '-' || talla_codigo || '-' || color_codigo;
    
    -- Verificar unicidad y agregar sufijo si es necesario
    WHILE EXISTS (SELECT 1 FROM public.articulos WHERE sku = nuevo_sku) LOOP
        nuevo_sku := nuevo_sku || '-' || TO_CHAR(FLOOR(RANDOM() * 100), 'FM00');
    END LOOP;
    
    NEW.sku := nuevo_sku;
    RETURN NEW;
END;
$function$
;

create or replace view "public"."productos_disponibles_tienda" as  SELECT pm.id AS producto_master_id,
    pm.nombre AS producto_nombre,
    pm.descripcion,
    m.nombre AS marca_nombre,
    c.nombre AS categoria_nombre,
    t.codigo AS talla_codigo,
    t.nombre AS talla_nombre,
    a.id AS articulo_id,
    a.sku,
    a.codigo_barras,
    col.nombre AS color_nombre,
    col.codigo_hex,
    it.tienda_id,
    it.stock_actual,
    it.stock_reservado,
    (it.stock_actual - it.stock_reservado) AS stock_disponible,
    it.precio_venta,
    it.precio_costo,
    it.ubicacion_fisica,
    pm.imagen_principal_url,
    a.imagen_color_url,
    pm.especificaciones
   FROM ((((((productos_master pm
     JOIN marcas m ON ((pm.marca_id = m.id)))
     JOIN categorias c ON ((pm.categoria_id = c.id)))
     JOIN tallas t ON ((pm.talla_id = t.id)))
     JOIN articulos a ON ((pm.id = a.producto_master_id)))
     JOIN colores col ON ((a.color_id = col.id)))
     LEFT JOIN inventario_tienda it ON ((a.id = it.articulo_id)))
  WHERE ((pm.activo = true) AND (a.activo = true) AND (m.activa = true) AND (c.activa = true) AND (t.activa = true) AND (col.activo = true));


create or replace view "public"."stock_consolidado_productos" as  SELECT pm.id AS producto_master_id,
    pm.nombre AS producto_nombre,
    m.nombre AS marca_nombre,
    c.nombre AS categoria_nombre,
    t.codigo AS talla_codigo,
    count(DISTINCT a.id) AS total_articulos,
    count(DISTINCT it.tienda_id) AS tiendas_con_stock,
    sum(COALESCE(it.stock_actual, 0)) AS stock_total,
    sum(COALESCE(it.stock_reservado, 0)) AS reservado_total,
    min(it.precio_venta) AS precio_minimo,
    max(it.precio_venta) AS precio_maximo,
    avg(it.precio_venta) AS precio_promedio,
    pm.precio_sugerido
   FROM (((((productos_master pm
     JOIN marcas m ON ((pm.marca_id = m.id)))
     JOIN categorias c ON ((pm.categoria_id = c.id)))
     JOIN tallas t ON ((pm.talla_id = t.id)))
     LEFT JOIN articulos a ON (((pm.id = a.producto_master_id) AND (a.activo = true))))
     LEFT JOIN inventario_tienda it ON (((a.id = it.articulo_id) AND (it.activo = true))))
  WHERE (pm.activo = true)
  GROUP BY pm.id, pm.nombre, m.nombre, c.nombre, t.codigo, pm.precio_sugerido;


CREATE OR REPLACE FUNCTION public.sync_email_verified()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

create or replace view "public"."usuarios_lista_optimizada" as  SELECT u.id,
    u.email,
    u.nombre_completo,
    u.estado,
    u.email_verificado,
    u.ultimo_acceso,
    u.created_at,
    u.fecha_aprobacion,
    u.fecha_suspension,
    u.tienda_asignada,
    r.nombre AS rol_nombre,
    r.descripcion AS rol_descripcion,
    t.nombre AS tienda_nombre,
    t.codigo AS tienda_codigo,
        CASE
            WHEN (u.aprobado_por IS NOT NULL) THEN admin.nombre_completo
            ELSE NULL::character varying
        END AS aprobado_por_nombre,
        CASE
            WHEN (((u.estado)::text = 'PENDIENTE_APROBACION'::text) AND (u.created_at < (now() - '7 days'::interval))) THEN 'MUY_URGENTE'::text
            WHEN (((u.estado)::text = 'PENDIENTE_APROBACION'::text) AND (u.created_at < (now() - '3 days'::interval))) THEN 'URGENTE'::text
            ELSE 'NORMAL'::text
        END AS prioridad,
        CASE
            WHEN (u.ultimo_acceso IS NULL) THEN 'NUNCA'::text
            WHEN (u.ultimo_acceso >= (now() - '7 days'::interval)) THEN 'RECIENTE'::text
            WHEN (u.ultimo_acceso >= (now() - '30 days'::interval)) THEN 'MENSUAL'::text
            ELSE 'INACTIVO'::text
        END AS actividad_reciente,
    ((
        CASE
            WHEN ((u.estado)::text = 'PENDIENTE_APROBACION'::text) THEN 100
            ELSE 0
        END +
        CASE
            WHEN ((u.created_at < (now() - '3 days'::interval)) AND ((u.estado)::text = 'PENDIENTE_APROBACION'::text)) THEN 50
            ELSE 0
        END) +
        CASE
            WHEN (u.ultimo_acceso >= (now() - '7 days'::interval)) THEN 10
            ELSE 0
        END) AS priority_score
   FROM (((usuarios u
     JOIN roles r ON ((u.rol_id = r.id)))
     LEFT JOIN tiendas t ON ((u.tienda_asignada = t.id)))
     LEFT JOIN usuarios admin ON ((u.aprobado_por = admin.id)));



