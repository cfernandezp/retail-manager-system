import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user_management/user_management_bloc.dart';
import '../../../core/theme/app_theme.dart';

enum SmartSelection {
  urgentUsers,
  unverifiedEmail,
  newThisWeek,
  inactiveUsers,
}

class EnhancedFilterPanel extends StatefulWidget {
  const EnhancedFilterPanel({super.key});

  @override
  State<EnhancedFilterPanel> createState() => _EnhancedFilterPanelState();
}

class _EnhancedFilterPanelState extends State<EnhancedFilterPanel> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedEstado = 'TODOS';
  String? selectedRol = 'TODOS';
  String? selectedTienda = 'TODOS';
  String? selectedPeriodo = 'TODOS';

  final List<String> estados = [
    'TODOS',
    'PENDIENTE_EMAIL',
    'PENDIENTE_APROBACION',
    'ACTIVA',
    'SUSPENDIDA',
    'RECHAZADA',
  ];

  final List<String> roles = [
    'TODOS',
    'SUPER_ADMIN',
    'ADMIN',
    'VENDEDOR',
    'OPERARIO',
  ];

  final List<String> tiendas = [
    'TODOS',
    'T001 - Tienda Central',
    'T002 - Tienda Norte',
    'T003 - Tienda Sur',
    'T004 - Tienda Este',
  ];

  final List<String> periodos = [
    'TODOS',
    'HOY',
    'ESTA_SEMANA',
    'ESTE_MES',
    'ULTIMOS_30_DIAS',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isMobile = size.width < 600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildSearchBar(context),
          const SizedBox(height: 16),
          if (isMobile)
            _buildMobileFilters(context)
          else if (isTablet)
            _buildTabletFilters(context)
          else
            _buildDesktopFilters(context),
          const SizedBox(height: 16),
          _buildQuickActionChips(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.filter_list,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'Filtros Inteligentes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _clearAllFilters,
          child: const Text(
            'Limpiar todo',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, email, DNI...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : const Icon(Icons.keyboard, color: Colors.grey, size: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        onChanged: (value) {
          setState(() {});
          _debounceSearch(value);
        },
      ),
    );
  }

  Widget _buildDesktopFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            label: 'Estado',
            value: selectedEstado,
            items: estados,
            onChanged: (value) {
              setState(() {
                selectedEstado = value;
              });
              _applyFilters();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFilterDropdown(
            label: 'Rol',
            value: selectedRol,
            items: roles,
            onChanged: (value) {
              setState(() {
                selectedRol = value;
              });
              _applyFilters();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFilterDropdown(
            label: 'Tienda',
            value: selectedTienda,
            items: tiendas,
            onChanged: (value) {
              setState(() {
                selectedTienda = value;
              });
              _applyFilters();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFilterDropdown(
            label: 'Período',
            value: selectedPeriodo,
            items: periodos,
            onChanged: (value) {
              setState(() {
                selectedPeriodo = value;
              });
              _applyFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabletFilters(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                label: 'Estado',
                value: selectedEstado,
                items: estados,
                onChanged: (value) {
                  setState(() {
                    selectedEstado = value;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                label: 'Rol',
                value: selectedRol,
                items: roles,
                onChanged: (value) {
                  setState(() {
                    selectedRol = value;
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                label: 'Tienda',
                value: selectedTienda,
                items: tiendas,
                onChanged: (value) {
                  setState(() {
                    selectedTienda = value;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                label: 'Período',
                value: selectedPeriodo,
                items: periodos,
                onChanged: (value) {
                  setState(() {
                    selectedPeriodo = value;
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFilters(BuildContext context) {
    return Column(
      children: [
        _buildFilterDropdown(
          label: 'Estado',
          value: selectedEstado,
          items: estados,
          onChanged: (value) {
            setState(() {
              selectedEstado = value;
            });
            _applyFilters();
          },
        ),
        const SizedBox(height: 8),
        _buildFilterDropdown(
          label: 'Rol',
          value: selectedRol,
          items: roles,
          onChanged: (value) {
            setState(() {
              selectedRol = value;
            });
            _applyFilters();
          },
        ),
        const SizedBox(height: 8),
        _buildFilterDropdown(
          label: 'Tienda',
          value: selectedTienda,
          items: tiendas,
          onChanged: (value) {
            setState(() {
              selectedTienda = value;
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    _getDisplayText(item),
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtros Rápidos',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSmartSelectionChip(
              SmartSelection.urgentUsers,
              '🚨 Urgentes',
              'Pendientes >3 días',
              Colors.red.shade600,
            ),
            _buildSmartSelectionChip(
              SmartSelection.unverifiedEmail,
              '✉️ Sin verificar',
              'Email pendiente',
              Colors.orange.shade600,
            ),
            _buildSmartSelectionChip(
              SmartSelection.newThisWeek,
              '⏰ Nuevos',
              'Registrados esta semana',
              Colors.blue.shade600,
            ),
            _buildSmartSelectionChip(
              SmartSelection.inactiveUsers,
              '😴 Inactivos',
              'Sin acceso >30 días',
              Colors.grey.shade600,
            ),
            _buildSmartSelectionButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartSelectionChip(
    SmartSelection selection,
    String label,
    String tooltip,
    Color color,
  ) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      onPressed: () => _handleSmartSelection(selection),
      tooltip: tooltip,
    );
  }

  Widget _buildSmartSelectionButton(BuildContext context) {
    return PopupMenuButton<SmartSelection>(
      child: Chip(
        avatar: const Icon(Icons.auto_awesome, size: 16),
        label: const Text(
          'Más opciones',
          style: TextStyle(fontSize: 12),
        ),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      tooltip: 'Selecciones inteligentes',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: SmartSelection.urgentUsers,
          child: ListTile(
            leading: Icon(Icons.schedule, color: Colors.orange),
            title: Text('Usuarios urgentes'),
            subtitle: Text('Pendientes >3 días'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: SmartSelection.newThisWeek,
          child: ListTile(
            leading: Icon(Icons.new_label, color: Colors.blue),
            title: Text('Nuevos esta semana'),
            subtitle: Text('Registrados recientemente'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: SmartSelection.inactiveUsers,
          child: ListTile(
            leading: Icon(Icons.person_off, color: Colors.red),
            title: Text('Usuarios inactivos'),
            subtitle: Text('Sin actividad >30 días'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: _handleSmartSelection,
    );
  }

  void _handleSmartSelection(SmartSelection selection) {
    switch (selection) {
      case SmartSelection.urgentUsers:
        setState(() {
          selectedEstado = 'PENDIENTE_APROBACION';
          selectedRol = 'TODOS';
          selectedTienda = 'TODOS';
          selectedPeriodo = 'TODOS';
        });
        // TODO: Agregar filtro por días urgentes
        break;
      case SmartSelection.unverifiedEmail:
        setState(() {
          selectedEstado = 'PENDIENTE_EMAIL';
          selectedRol = 'TODOS';
          selectedTienda = 'TODOS';
          selectedPeriodo = 'TODOS';
        });
        break;
      case SmartSelection.newThisWeek:
        setState(() {
          selectedEstado = 'TODOS';
          selectedRol = 'TODOS';
          selectedTienda = 'TODOS';
          selectedPeriodo = 'ESTA_SEMANA';
        });
        break;
      case SmartSelection.inactiveUsers:
        setState(() {
          selectedEstado = 'ACTIVA';
          selectedRol = 'TODOS';
          selectedTienda = 'TODOS';
          selectedPeriodo = 'TODOS';
        });
        // TODO: Agregar filtro por inactividad
        break;
    }
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      selectedEstado = 'TODOS';
      selectedRol = 'TODOS';
      selectedTienda = 'TODOS';
      selectedPeriodo = 'TODOS';
    });
    _applyFilters();
  }

  void _applyFilters() {
    final searchQuery = _searchController.text.trim();
    
    context.read<UserManagementBloc>().add(
      FilterUsers(
        estado: selectedEstado == 'TODOS' ? null : selectedEstado,
        rol: selectedRol == 'TODOS' ? null : selectedRol,
      ),
    );

    // TODO: Agregar más filtros específicos cuando esté disponible en el BLoC
    if (searchQuery.isNotEmpty) {
      // context.read<UserManagementBloc>().add(SearchUsers(query: searchQuery));
    }
  }

  void _debounceSearch(String query) {
    // Implementar debounce para la búsqueda
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        _applyFilters();
      }
    });
  }

  String _getDisplayText(String value) {
    switch (value) {
      case 'TODOS': return 'Todos';
      case 'PENDIENTE_EMAIL': return 'Email pendiente';
      case 'PENDIENTE_APROBACION': return 'Pendiente aprobación';
      case 'ACTIVA': return 'Activa';
      case 'SUSPENDIDA': return 'Suspendida';
      case 'RECHAZADA': return 'Rechazada';
      case 'SUPER_ADMIN': return 'Super Admin';
      case 'ADMIN': return 'Admin';
      case 'VENDEDOR': return 'Vendedor';
      case 'OPERARIO': return 'Operario';
      case 'HOY': return 'Hoy';
      case 'ESTA_SEMANA': return 'Esta semana';
      case 'ESTE_MES': return 'Este mes';
      case 'ULTIMOS_30_DIAS': return 'Últimos 30 días';
      default: return value;
    }
  }
}