import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EnhancedFilters extends StatelessWidget {
  final String? selectedEstado;
  final String? selectedRol;
  final String? searchQuery;
  final bool showOnlyUrgent;
  final ValueChanged<String?> onEstadoChanged;
  final ValueChanged<String?> onRolChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onUrgentToggle;
  final VoidCallback? onClearFilters;
  final FocusNode? searchFocusNode;

  const EnhancedFilters({
    super.key,
    this.selectedEstado,
    this.selectedRol,
    this.searchQuery,
    this.showOnlyUrgent = false,
    required this.onEstadoChanged,
    required this.onRolChanged,
    required this.onSearchChanged,
    required this.onUrgentToggle,
    this.onClearFilters,
    this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y clear filters
          Row(
            children: [
              const Icon(Icons.filter_list, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Barra de búsqueda
          _buildSearchBar(),
          
          const SizedBox(height: 16),
          
          // Filtros principales
          isTablet
              ? _buildTabletFilters()
              : _buildMobileFilters(),
          
          const SizedBox(height: 16),
          
          // Filtros adicionales (chips)
          _buildAdditionalFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        focusNode: searchFocusNode,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o email...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.backgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabletFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            label: 'Estado',
            value: selectedEstado,
            items: const [
              'TODOS',
              'PENDIENTE_APROBACION',
              'ACTIVA',
              'SUSPENDIDA',
              'RECHAZADA',
            ],
            onChanged: onEstadoChanged,
            icon: Icons.account_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFilterDropdown(
            label: 'Rol',
            value: selectedRol,
            items: const [
              'TODOS',
              'SUPER_ADMIN',
              'ADMIN',
              'VENDEDOR',
              'OPERARIO',
            ],
            onChanged: onRolChanged,
            icon: Icons.work,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        _buildFilterDropdown(
          label: 'Estado',
          value: selectedEstado,
          items: const [
            'TODOS',
            'PENDIENTE_APROBACION',
            'ACTIVA',
            'SUSPENDIDA',
            'RECHAZADA',
          ],
          onChanged: onEstadoChanged,
          icon: Icons.account_circle,
        ),
        const SizedBox(height: 12),
        _buildFilterDropdown(
          label: 'Rol',
          value: selectedRol,
          items: const [
            'TODOS',
            'SUPER_ADMIN',
            'ADMIN',
            'VENDEDOR',
            'OPERARIO',
          ],
          onChanged: onRolChanged,
          icon: Icons.work,
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      _getStatusIcon(item),
                      const SizedBox(width: 8),
                      Text(
                        _getDisplayText(item),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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

  Widget _buildAdditionalFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          label: 'Solo urgentes',
          isSelected: showOnlyUrgent,
          onTap: () => onUrgentToggle(!showOnlyUrgent),
          icon: Icons.priority_high,
          color: AppTheme.errorColor,
        ),
        _buildFilterChip(
          label: 'Email verificado',
          isSelected: false, // Implementar lógica según necesidades
          onTap: () {}, // Implementar callback
          icon: Icons.verified,
          color: AppTheme.successColor,
        ),
        _buildFilterChip(
          label: 'Recientes',
          isSelected: false, // Implementar lógica según necesidades
          onTap: () {}, // Implementar callback
          icon: Icons.schedule,
          color: AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'ACTIVA':
        return const Icon(Icons.check_circle, size: 16, color: AppTheme.successColor);
      case 'PENDIENTE_APROBACION':
        return const Icon(Icons.hourglass_empty, size: 16, color: AppTheme.warningColor);
      case 'SUSPENDIDA':
        return const Icon(Icons.pause_circle, size: 16, color: AppTheme.errorColor);
      case 'RECHAZADA':
        return Icon(Icons.cancel, size: 16, color: Colors.grey.shade600);
      case 'SUPER_ADMIN':
        return const Icon(Icons.admin_panel_settings, size: 16, color: Colors.purple);
      case 'ADMIN':
        return const Icon(Icons.manage_accounts, size: 16, color: Colors.blue);
      case 'VENDEDOR':
        return const Icon(Icons.point_of_sale, size: 16, color: Colors.green);
      case 'OPERARIO':
        return const Icon(Icons.engineering, size: 16, color: Colors.orange);
      default:
        return Icon(Icons.filter_list, size: 16, color: Colors.grey.shade600);
    }
  }

  String _getDisplayText(String value) {
    switch (value) {
      case 'TODOS': return 'Todos';
      case 'PENDIENTE_APROBACION': return 'Pendiente aprobación';
      case 'ACTIVA': return 'Activa';
      case 'SUSPENDIDA': return 'Suspendida';
      case 'RECHAZADA': return 'Rechazada';
      case 'SUPER_ADMIN': return 'Super Admin';
      case 'ADMIN': return 'Admin';
      case 'VENDEDOR': return 'Vendedor';
      case 'OPERARIO': return 'Operario';
      default: return value;
    }
  }

  bool _hasActiveFilters() {
    return (selectedEstado != null && selectedEstado != 'TODOS') ||
           (selectedRol != null && selectedRol != 'TODOS') ||
           (searchQuery != null && searchQuery!.isNotEmpty) ||
           showOnlyUrgent;
  }
}