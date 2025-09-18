import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';
import '../../widgets/common/shimmer_widget.dart';
import '../../widgets/products/categoria_card.dart';
import '../../widgets/products/categoria_form_dialog.dart';

/// Página de gestión completa de categorías
class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final ProductsRepository _repository = ProductsRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Categoria> _categorias = [];
  List<Categoria> _filteredCategorias = [];
  bool _isLoading = true;
  String? _error;
  bool _showInactiveCategorias = false;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategorias() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categorias = await _repository.getCategorias();
      setState(() {
        _categorias = categorias;
        _filteredCategorias = _applyFilters(categorias);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Categoria> _applyFilters(List<Categoria> categorias) {
    List<Categoria> filtered = categorias;

    // Filtro por estado activo/inactivo
    if (!_showInactiveCategorias) {
      filtered = filtered.where((categoria) => categoria.activo).toList();
    }

    // Filtro por búsqueda
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((categoria) {
        return categoria.nombre.toLowerCase().contains(searchQuery) ||
               (categoria.descripcion?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredCategorias = _applyFilters(_categorias);
    });
  }

  void _toggleShowInactive() {
    setState(() {
      _showInactiveCategorias = !_showInactiveCategorias;
      _filteredCategorias = _applyFilters(_categorias);
    });
  }

  Future<void> _showCreateCategoriaDialog() async {
    final result = await showDialog<Categoria>(
      context: context,
      builder: (context) => CategoriaFormDialog(
        title: 'Crear Nueva Categoría',
        existingCategorias: _categorias,
      ),
    );

    if (result != null) {
      await _loadCategorias();
      _showSuccessMessage('Categoría "${result.nombre}" creada exitosamente');
    }
  }

  Future<void> _showEditCategoriaDialog(Categoria categoria) async {
    final result = await showDialog<Categoria>(
      context: context,
      builder: (context) => CategoriaFormDialog(
        title: 'Editar Categoría',
        categoria: categoria,
        existingCategorias: _categorias.where((c) => c.id != categoria.id).toList(),
      ),
    );

    if (result != null) {
      await _loadCategorias();
      _showSuccessMessage('Categoría "${result.nombre}" actualizada exitosamente');
    }
  }

  Future<void> _toggleCategoriaStatus(Categoria categoria) async {
    try {
      final updatedCategoria = await _repository.updateCategoria(categoria.id, {
        'activo': !categoria.activo,
      });

      await _loadCategorias();

      final action = updatedCategoria.activo ? 'activada' : 'desactivada';
      _showSuccessMessage('Categoría "${categoria.nombre}" $action exitosamente');
    } catch (e) {
      _showErrorMessage('Error al cambiar estado de la categoría: ${e.toString()}');
    }
  }

  Future<void> _deleteCategoria(Categoria categoria) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la categoría "${categoria.nombre}"?\n\n'
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
        await _repository.deleteCategoria(categoria.id);
        await _loadCategorias();
        _showSuccessMessage('Categoría "${categoria.nombre}" eliminada exitosamente');
      } catch (e) {
        _showErrorMessage('Error al eliminar categoría: ${e.toString()}');
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
        onPressed: _showCreateCategoriaDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Categoría'),
        backgroundColor: AppTheme.primaryTurquoise,
      ),
    );
  }

  Widget _buildHeader() {
    final activeCount = _categorias.where((c) => c.activo).length;
    final inactiveCount = _categorias.length - activeCount;

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
                          Icons.category_outlined,
                          color: AppTheme.primaryTurquoise,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Gestión de Categorías',
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
                      'Total: ${_categorias.length} categorías • Activas: $activeCount • Inactivas: $inactiveCount',
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
                    onPressed: _loadCategorias,
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
                    hintText: 'Buscar por nombre o descripción...',
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
                selected: _showInactiveCategorias,
                onSelected: (_) => _toggleShowInactive(),
                avatar: Icon(
                  _showInactiveCategorias ? Icons.visibility : Icons.visibility_off,
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

    if (_filteredCategorias.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCategoriasGrid();
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
            'Error al cargar categorías',
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
            onPressed: _loadCategorias,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasFilters = !_showInactiveCategorias;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.category_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Sin resultados' : 'No hay categorías',
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
                : 'Comienza creando tu primera categoría',
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
                      _showInactiveCategorias = true;
                      _filteredCategorias = _applyFilters(_categorias);
                    });
                  }
                : _showCreateCategoriaDialog,
            icon: Icon(hasSearch || hasFilters ? Icons.clear_all : Icons.add),
            label: Text(hasSearch || hasFilters ? 'Limpiar Filtros' : 'Crear Categoría'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: _filteredCategorias.length,
        itemBuilder: (context, index) {
          final categoria = _filteredCategorias[index];
          return CategoriaCard(
            categoria: categoria,
            onEdit: () => _showEditCategoriaDialog(categoria),
            onToggleStatus: () => _toggleCategoriaStatus(categoria),
            onDelete: () => _deleteCategoria(categoria),
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