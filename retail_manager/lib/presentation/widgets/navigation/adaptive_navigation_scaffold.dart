import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'desktop_sidebar.dart';
import 'tablet_navigation_rail.dart';
import 'mobile_drawer.dart';
import 'mobile_bottom_navigation.dart';

/// Scaffold adaptativo que maneja navegación multiplataforma según requerimientos específicos:
/// - Desktop (≥1200px): Sidebar fijo expandido por defecto con toggle
/// - Tablet (768-1199px): NavigationRail colapsible estilo Material 3
/// - Mobile (<768px): Drawer oculto + BottomNavigation ÚNICAMENTE
class AdaptiveNavigationScaffold extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final String pageTitle;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final Widget? bottomSheet;
  
  const AdaptiveNavigationScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.pageTitle,
    this.actions,
    this.floatingActionButton,
    this.bottomSheet,
  });

  @override
  State<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends State<AdaptiveNavigationScaffold> {
  // Estados de navegación específicos por plataforma
  bool _desktopSidebarExpanded = true;  // Desktop: sidebar expandido por defecto
  bool _tabletRailExpanded = false;     // Tablet: rail colapsado por defecto
  bool _mobileDrawerOpen = false;       // Mobile: drawer oculto por defecto

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final platformType = AppTheme.getPlatformType(width);
        final navigationType = AppTheme.getNavigationType(width);

        switch (platformType) {
          case PlatformType.desktop:
            return _buildDesktopLayout(context, width);
          case PlatformType.tablet:
            return _buildTabletLayout(context, width);
          case PlatformType.mobile:
            return _buildMobileLayout(context, width);
        }
      },
    );
  }

  /// DESKTOP LAYOUT (≥1200px)
  /// - Sidebar izquierdo FIJO expandido por defecto
  /// - Botón de colapso para contraer/expandir
  /// - Breadcrumbs en header
  /// - Multi-panel layout cuando sea necesario
  Widget _buildDesktopLayout(BuildContext context, double width) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar izquierdo FIJO (requerimiento específico del cliente)
          DesktopSidebar(
            isExpanded: _desktopSidebarExpanded,
            currentRoute: widget.currentRoute,
            onToggle: () {
              setState(() {
                _desktopSidebarExpanded = !_desktopSidebarExpanded;
              });
            },
            onNavigate: (route) => _handleNavigation(route),
          ),
          
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // AppBar con breadcrumbs y controles desktop
                _buildDesktopAppBar(context),
                
                // Contenido principal
                Expanded(
                  child: Container(
                    color: AppTheme.backgroundColor,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TABLET LAYOUT (768-1199px) 
  /// - NavigationRail colapsible (Material 3 style)
  /// - Iconos + labels expandibles
  /// - Swipe gestures para navegación
  /// - Grid layout optimizado para touch
  Widget _buildTabletLayout(BuildContext context, double width) {
    return Scaffold(
      appBar: _buildTabletAppBar(context),
      body: Row(
        children: [
          // NavigationRail colapsible
          TabletNavigationRail(
            isExpanded: _tabletRailExpanded,
            currentRoute: widget.currentRoute,
            onToggle: () {
              setState(() {
                _tabletRailExpanded = !_tabletRailExpanded;
              });
            },
            onNavigate: (route) => _handleNavigation(route),
          ),
          
          // Contenido principal con soporte para swipe gestures
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Swipe gestures para navegación en tablet
                if (details.primaryVelocity! > 0) {
                  // Swipe right - mostrar rail
                  setState(() {
                    _tabletRailExpanded = true;
                  });
                } else if (details.primaryVelocity! < 0) {
                  // Swipe left - ocultar rail
                  setState(() {
                    _tabletRailExpanded = false;
                  });
                }
              },
              child: Container(
                color: AppTheme.backgroundColor,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomSheet: widget.bottomSheet,
    );
  }

  /// MOBILE LAYOUT (<768px)
  /// - NO sidebar visible por defecto (requerimiento específico del cliente)
  /// - Drawer que se abre con hamburger menu ÚNICAMENTE
  /// - Bottom navigation bar para secciones principales
  /// - Layout de lista vertical optimizado para pulgar
  Widget _buildMobileLayout(BuildContext context, double width) {
    return Scaffold(
      appBar: _buildMobileAppBar(context),
      
      // Drawer oculto que SOLO se muestra al tocar hamburger menu
      drawer: MobileDrawer(
        currentRoute: widget.currentRoute,
        onNavigate: (route) {
          _handleNavigation(route);
          Navigator.pop(context); // Cerrar drawer después de navegar
        },
      ),
      
      body: Container(
        color: AppTheme.backgroundColor,
        child: widget.child,
      ),
      
      // Bottom navigation para secciones principales (requerimiento específico)
      bottomNavigationBar: MobileBottomNavigation(
        currentRoute: widget.currentRoute,
        onNavigate: (route) => _handleNavigation(route),
      ),
      
      floatingActionButton: widget.floatingActionButton,
      bottomSheet: widget.bottomSheet,
    );
  }

  /// AppBar para Desktop con breadcrumbs y controles específicos
  Widget _buildDesktopAppBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Toggle sidebar button
            IconButton(
              icon: Icon(_desktopSidebarExpanded ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() {
                  _desktopSidebarExpanded = !_desktopSidebarExpanded;
                });
              },
              tooltip: _desktopSidebarExpanded ? 'Contraer menú' : 'Expandir menú',
            ),
            
            const SizedBox(width: 16),
            
            // Breadcrumbs
            Expanded(
              child: _buildBreadcrumbs(context),
            ),
            
            // Actions específicas para desktop
            if (widget.actions != null) ...widget.actions!,
          ],
        ),
      ),
    );
  }

  /// AppBar para Tablet con controles híbridos
  PreferredSizeWidget _buildTabletAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          setState(() {
            _tabletRailExpanded = !_tabletRailExpanded;
          });
        },
        tooltip: 'Alternar menú',
      ),
      title: Text(widget.pageTitle),
      actions: [
        // Quick filters button para tablet
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showQuickFilters(context),
          tooltip: 'Filtros rápidos',
        ),
        if (widget.actions != null) ...widget.actions!,
      ],
    );
  }

  /// AppBar para Mobile optimizado para toque
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Abrir menú',
        ),
      ),
      title: Text(
        widget.pageTitle,
        style: const TextStyle(fontSize: 18), // Tamaño optimizado para mobile
      ),
      actions: [
        // Notificaciones button para mobile
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showNotifications(context),
          tooltip: 'Notificaciones',
        ),
        
        // More options para mobile
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMobileAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Actualizar'),
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye breadcrumbs para navegación desktop
  Widget _buildBreadcrumbs(BuildContext context) {
    final routeParts = widget.currentRoute.split('/');
    final breadcrumbs = <String>[];
    
    for (final part in routeParts) {
      if (part.isNotEmpty) {
        breadcrumbs.add(_getDisplayName(part));
      }
    }

    return Row(
      children: [
        const Icon(Icons.home, size: 18, color: Colors.grey),
        for (int i = 0; i < breadcrumbs.length; i++) ...[
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            breadcrumbs[i],
            style: TextStyle(
              color: i == breadcrumbs.length - 1 
                ? AppTheme.primaryColor 
                : Colors.grey,
              fontWeight: i == breadcrumbs.length - 1 
                ? FontWeight.w600 
                : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }

  String _getDisplayName(String route) {
    switch (route) {
      case 'admin': return 'Administración';
      case 'users': return 'Gestión de Usuarios';
      case 'products': return 'Productos';
      case 'sales': return 'Ventas';
      case 'inventory': return 'Inventario';
      case 'reports': return 'Reportes';
      default: return route;
    }
  }

  void _handleNavigation(String route) {
    context.go(route);
  }

  void _showQuickFilters(BuildContext context) {
    // Implementar filtros rápidos para tablet
  }

  void _showNotifications(BuildContext context) {
    // Implementar panel de notificaciones para mobile
  }

  void _handleMobileAction(String action) {
    switch (action) {
      case 'refresh':
        // Implementar refresh
        break;
      case 'settings':
        // Navegar a settings
        break;
    }
  }
}