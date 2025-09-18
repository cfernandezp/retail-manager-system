import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';
import '../../widgets/common/shimmer_widget.dart';
import '../../widgets/products/color_card.dart';
import '../../widgets/products/color_form_dialog.dart';

/// Página de gestión completa de colores
class ColorsPage extends StatefulWidget {
  const ColorsPage({super.key});

  @override
  State<ColorsPage> createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> {
  final ProductsRepository _repository = ProductsRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ColorData> _colors = [];
  List<ColorData> _filteredColors = [];
  bool _isLoading = true;
  String? _error;
  bool _showInactiveColors = false;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadColors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final colors = await _repository.getColores();
      setState(() {
        _colors = colors;
        _filteredColors = _applyFilters(colors);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ColorData> _applyFilters(List<ColorData> colors) {
    List<ColorData> filtered = colors;

    // Filtro por estado activo/inactivo
    if (!_showInactiveColors) {
      filtered = filtered.where((color) => color.activo).toList();
    }

    // Filtro por búsqueda
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((color) {
        return color.nombre.toLowerCase().contains(searchQuery) ||
               (color.codigoAbrev?.toLowerCase().contains(searchQuery) ?? false) ||
               (color.hexColor?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredColors = _applyFilters(_colors);
    });
  }

  void _toggleShowInactive() {
    setState(() {
      _showInactiveColors = !_showInactiveColors;
      _filteredColors = _applyFilters(_colors);
    });
  }

  Future<void> _showCreateColorDialog() async {
    final result = await showDialog<ColorData>(
      context: context,
      builder: (context) => ColorFormDialog(
        title: 'Crear Nuevo Color',
        existingColors: _colors,
      ),
    );

    if (result != null) {
      await _loadColors();
      _showSuccessMessage('Color "${result.nombre}" creado exitosamente');
    }
  }

  Future<void> _showEditColorDialog(ColorData color) async {
    final result = await showDialog<ColorData>(
      context: context,
      builder: (context) => ColorFormDialog(
        title: 'Editar Color',
        color: color,
        existingColors: _colors.where((c) => c.id != color.id).toList(),
      ),
    );

    if (result != null) {
      await _loadColors();
      _showSuccessMessage('Color "${result.nombre}" actualizado exitosamente');
    }
  }

  Future<void> _toggleColorStatus(ColorData color) async {
    try {
      final updatedColor = await _repository.updateColor(color.id, {
        'activo': !color.activo,
      });

      await _loadColors();

      final action = updatedColor.activo ? 'activado' : 'desactivado';
      _showSuccessMessage('Color "${color.nombre}" $action exitosamente');
    } catch (e) {
      _showErrorMessage('Error al cambiar estado del color: ${e.toString()}');
    }
  }

  Future<void> _deleteColor(ColorData color) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Color'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el color "${color.nombre}"?\n\n'
          'Esta acción no se puede deshacer y puede afectar productos existentes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteColor(color.id);
        await _loadColors();
        _showSuccessMessage('Color "${color.nombre}" eliminado exitosamente');
      } catch (e) {
        _showErrorMessage('Error al eliminar color: ${e.toString()}');
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateColorDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Color'),
        backgroundColor: AppTheme.primaryTurquoise,
      ),
    );
  }

  Widget _buildHeader() {
    final activeCount = _colors.where((c) => c.activo).length;
    final inactiveCount = _colors.length - activeCount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título y estadísticas
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          color: AppTheme.primaryTurquoise,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Gestión de Colores',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${_colors.length} colores • Activos: $activeCount • Inactivos: $inactiveCount',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de acción
              Row(
                children: [
                  // Botón volver a productos
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Volver a Productos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTurquoise,
                      side: BorderSide(color: AppTheme.primaryTurquoise),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _loadColors,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar exportación
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Exportar'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de búsqueda y filtros
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, código o hex...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.textSecondaryColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

              const SizedBox(width: 16),

              // Toggle mostrar inactivos
              FilterChip(
                label: Text('Mostrar inactivos'),
                selected: _showInactiveColors,
                onSelected: (_) => _toggleShowInactive(),
                avatar: Icon(
                  _showInactiveColors ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredColors.isEmpty) {
      return _buildEmptyState();
    }

    return _buildColorsGrid();
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => const ShimmerWidget(
          child: Card(
            child: SizedBox(height: 120),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar colores',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadColors,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasFilters = !_showInactiveColors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.palette_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Sin resultados' : 'No hay colores',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Intenta ajustar la búsqueda o los filtros'
                : 'Comienza creando tu primer color',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: hasSearch || hasFilters
                ? () {
                    _searchController.clear();
                    setState(() {
                      _showInactiveColors = true;
                      _filteredColors = _applyFilters(_colors);
                    });
                  }
                : _showCreateColorDialog,
            icon: Icon(hasSearch || hasFilters ? Icons.clear_all : Icons.add),
            label: Text(hasSearch || hasFilters ? 'Limpiar Filtros' : 'Crear Color'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: _filteredColors.length,
        itemBuilder: (context, index) {
          final color = _filteredColors[index];
          return ColorCard(
            color: color,
            onEdit: () => _showEditColorDialog(color),
            onToggleStatus: () => _toggleColorStatus(color),
            onDelete: () => _deleteColor(color),
          );
        },
      ),
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}