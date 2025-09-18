import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';
import '../../widgets/common/shimmer_widget.dart';
import '../../widgets/products/talla_card.dart';
import '../../widgets/products/talla_form_dialog.dart';

/// Página de gestión completa de tallas
class TallasPage extends StatefulWidget {
  const TallasPage({super.key});

  @override
  State<TallasPage> createState() => _TallasPageState();
}

class _TallasPageState extends State<TallasPage> {
  final ProductsRepository _repository = ProductsRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Talla> _tallas = [];
  List<Talla> _filteredTallas = [];
  bool _isLoading = true;
  String? _error;
  bool _showInactiveTallas = false;

  @override
  void initState() {
    super.initState();
    _loadTallas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTallas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tallas = await _repository.getTallas();
      setState(() {
        _tallas = tallas;
        _filteredTallas = _applyFilters(tallas);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Talla> _applyFilters(List<Talla> tallas) {
    List<Talla> filtered = tallas;

    // Filtro por estado activo/inactivo
    if (!_showInactiveTallas) {
      filtered = filtered.where((talla) => talla.activo).toList();
    }

    // Filtro por búsqueda
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((talla) {
        return talla.codigo.toLowerCase().contains(searchQuery) ||
               talla.valor.toLowerCase().contains(searchQuery) ||
               (talla.nombre?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredTallas = _applyFilters(_tallas);
    });
  }

  void _toggleShowInactive() {
    setState(() {
      _showInactiveTallas = !_showInactiveTallas;
      _filteredTallas = _applyFilters(_tallas);
    });
  }

  Future<void> _showCreateTallaDialog() async {
    final result = await showDialog<Talla>(
      context: context,
      builder: (context) => TallaFormDialog(
        title: 'Crear Nueva Talla',
        existingTallas: _tallas,
      ),
    );

    if (result != null) {
      await _loadTallas();
      _showSuccessMessage('Talla "${result.valor}" creada exitosamente');
    }
  }

  Future<void> _showEditTallaDialog(Talla talla) async {
    final result = await showDialog<Talla>(
      context: context,
      builder: (context) => TallaFormDialog(
        title: 'Editar Talla',
        talla: talla,
        existingTallas: _tallas.where((t) => t.id != talla.id).toList(),
      ),
    );

    if (result != null) {
      await _loadTallas();
      _showSuccessMessage('Talla "${result.valor}" actualizada exitosamente');
    }
  }

  Future<void> _toggleTallaStatus(Talla talla) async {
    try {
      final updatedTalla = await _repository.updateTalla(talla.id, {
        'activo': !talla.activo,
      });

      await _loadTallas();

      final action = updatedTalla.activo ? 'activada' : 'desactivada';
      _showSuccessMessage('Talla "${talla.valor}" $action exitosamente');
    } catch (e) {
      _showErrorMessage('Error al cambiar estado de la talla: ${e.toString()}');
    }
  }

  Future<void> _deleteTalla(Talla talla) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Talla'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la talla "${talla.valor}"?\n\n'
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
        await _repository.deleteTalla(talla.id);
        await _loadTallas();
        _showSuccessMessage('Talla "${talla.valor}" eliminada exitosamente');
      } catch (e) {
        _showErrorMessage('Error al eliminar talla: ${e.toString()}');
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
        onPressed: _showCreateTallaDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Talla'),
        backgroundColor: AppTheme.primaryTurquoise,
      ),
    );
  }

  Widget _buildHeader() {
    final activeCount = _tallas.where((t) => t.activo).length;
    final inactiveCount = _tallas.length - activeCount;

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
                          Icons.straighten_outlined,
                          color: AppTheme.primaryTurquoise,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Gestión de Tallas',
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
                      'Total: ${_tallas.length} tallas • Activas: $activeCount • Inactivas: $inactiveCount',
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
                    onPressed: _loadTallas,
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
                    hintText: 'Buscar por código, valor o nombre...',
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
                label: Text('Mostrar inactivas'),
                selected: _showInactiveTallas,
                onSelected: (_) => _toggleShowInactive(),
                avatar: Icon(
                  _showInactiveTallas ? Icons.visibility : Icons.visibility_off,
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

    if (_filteredTallas.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTallasGrid();
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
            'Error al cargar tallas',
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
            onPressed: _loadTallas,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasFilters = !_showInactiveTallas;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.straighten_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Sin resultados' : 'No hay tallas',
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
                : 'Comienza creando tu primera talla',
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
                      _showInactiveTallas = true;
                      _filteredTallas = _applyFilters(_tallas);
                    });
                  }
                : _showCreateTallaDialog,
            icon: Icon(hasSearch || hasFilters ? Icons.clear_all : Icons.add),
            label: Text(hasSearch || hasFilters ? 'Limpiar Filtros' : 'Crear Talla'),
          ),
        ],
      ),
    );
  }

  Widget _buildTallasGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: _filteredTallas.length,
        itemBuilder: (context, index) {
          final talla = _filteredTallas[index];
          return TallaCard(
            talla: talla,
            onEdit: () => _showEditTallaDialog(talla),
            onToggleStatus: () => _toggleTallaStatus(talla),
            onDelete: () => _deleteTalla(talla),
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