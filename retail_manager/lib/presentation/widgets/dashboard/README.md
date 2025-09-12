# Dashboard Widgets

Esta carpeta contiene los widgets específicos del dashboard principal del sistema, optimizados para web desktop (≥1200px).

## Estructura de Componentes

### KpiCard (`kpi_card.dart`)
Widget para métricas clave del negocio con las siguientes características:
- **Diseño**: Material Design 3 con elevación sutil y animaciones hover
- **Contenido**: Título, valor principal, subtítulo, icono y tendencia opcional  
- **Interactividad**: Efectos hover, animaciones de escala y navegación por tap
- **Estados**: Loading skeleton con shimmer effects
- **Uso**: Mostrar KPIs como ventas, stock, clientes, órdenes

### ChartCard (`chart_card.dart`)
Componente para visualización de gráficos dummy con:
- **Tipos**: Gráficos de líneas y barras
- **Header**: Título, subtítulo, filtros de tiempo y botón de actualización
- **Visualización**: Custom painters para renderizado de gráficos
- **Estados**: Loading, error con retry, datos vacíos
- **Datos**: Modelo ChartDataPoint para representación de información

### QuickActions (`quick_actions.dart`)
Panel de acciones rápidas para navegación a módulos principales:
- **Layout**: Grid 3x2 con tiles interactivos
- **Contenido**: 6 acciones principales (POS, Productos, Inventario, etc.)
- **Diseño**: Gradientes de colores, iconos Material y efectos hover
- **Navegación**: Integración directa con GoRouter

### RecentTransactions (`recent_transactions.dart`)
Lista de transacciones recientes del sistema:
- **Datos**: Últimas 5 transacciones con información completa
- **Visualización**: Tiles con avatar, detalles, estado y monto
- **Estados**: Loading skeletons, empty state con ilustración
- **Formatos**: Timestamps relativos, moneda peruana (S/)
- **Interactividad**: Hover effects y navegación a detalle

## Diseño y Estilo

### Colores Corporativos
- **Primario**: Turquesa #4ECDC4 (AppTheme.primaryTurquoise)
- **Éxito**: Verde #4CAF50 para ventas positivas
- **Advertencia**: Naranja #FF9800 para alertas
- **Error**: Rojo #F44336 para problemas
- **Información**: Azul #2196F3 para datos informativos

### Tipografía
- **Headers**: Bold, 18-32px para títulos principales
- **Valores**: Bold, 24-32px para métricas importantes
- **Texto**: Regular, 14-16px para contenido general
- **Subtítulos**: 12-14px para información secundaria

### Espaciado
- **Padding exterior**: 24px para márgenes de página
- **Padding interno**: 16-20px para contenido de cards
- **Separación entre elementos**: 8-24px según jerarquía
- **Border radius**: 12-16px para cards y containers

## Integración con Sistema

### Navegación
Utiliza GoRouter para navegación entre módulos:
```dart
context.go('/sales')  // Navegar a ventas
context.go('/pos')    // Abrir punto de venta
```

### Estado de Loading
Todos los widgets implementan estados de carga consistentes:
```dart
isLoading: true,      // Muestra skeletons o spinners
onRefresh: callback,  // Función de actualización
```

### Datos Dummy
Los widgets incluyen datos de demostración para pruebas:
- Transacciones con diferentes estados
- Gráficos con datos mensuales simulados  
- KPIs con valores realistas para retail

### Responsive Design
Optimizado específicamente para escritorio:
- Ancho mínimo: 1200px (desktop breakpoint)
- Layout en grid y flex para aprovechamiento de espacio
- Hover effects y cursors apropiados para mouse
- Tamaños de touch targets adecuados para escritorio

## Uso en DashboardPage

Los widgets se integran en el layout principal de la siguiente manera:

```dart
// KPI Cards en fila horizontal
Row(
  children: [
    Expanded(child: KpiCard(...)),
    // ... más KPIs
  ],
)

// Layout principal con columnas
Row(
  children: [
    // Columna izquierda (2/3) - Gráficos y transacciones
    Expanded(
      flex: 2,
      child: Column([
        ChartCard(...), // Gráficos
        RecentTransactions(...), // Lista de transacciones
      ]),
    ),
    
    // Columna derecha (1/3) - Acciones rápidas
    Expanded(
      flex: 1,
      child: QuickActions(...),
    ),
  ],
)
```

Este diseño garantiza un aprovechamiento óptimo del espacio en pantallas de escritorio y una experiencia de usuario fluida para el sistema POS.