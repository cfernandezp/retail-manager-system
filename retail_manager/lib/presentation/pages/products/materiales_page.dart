import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart' as models;
import '../../../data/models/product_models.dart' show MaterialModel;
import '../../../data/repositories/products_repository_simple.dart';
import '../../widgets/common/shimmer_widget.dart';
import '../../widgets/products/material_card.dart';
import '../../widgets/products/material_form_dialog.dart';

/// Página de gestión completa de materiales
class MaterialesPage extends StatefulWidget {
  const MaterialesPage({super.key});

  @override
  State<MaterialesPage> createState() => _MaterialesPageState();
}

class _MaterialesPageState extends State<MaterialesPage> {
  final ProductsRepository _repository = ProductsRepository();
  final TextEditingController _searchController = TextEditingController();

  List<MaterialModel> _materiales = [];
  List<MaterialModel> _filteredMateriales = [];
  bool _isLoading = true;
  String? _error;
  bool _showInactiveMateriales = false;

  @override
  void initState() {
    super.initState();
    _loadMateriales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMateriales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final materiales = await _repository.getMateriales();
      setState(() {
        _materiales = materiales;
        _filteredMateriales = _applyFilters(materiales);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<MaterialModel> _applyFilters(List<MaterialModel> materiales) {
    List<MaterialModel> filtered = materiales;

    // Filtro por estado activo/inactivo
    if (!_showInactiveMateriales) {
      filtered = filtered.where((material) => material.activo).toList();
    }

    // Filtro por búsqueda
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((material) {
        return material.nombre.toLowerCase().contains(searchQuery) ||
               (material.descripcion?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredMateriales = _applyFilters(_materiales);
    });
  }

  void _toggleShowInactive() {
    setState(() {
      _showInactiveMateriales = !_showInactiveMateriales;
      _filteredMateriales = _applyFilters(_materiales);
    });
  }

  Future<void> _showCreateMaterialDialog() async {
    final result = await showDialog<MaterialModel>(
      context: context,
      builder: (context) => MaterialFormDialog(
        title: 'Crear Nuevo Material',
        existingMateriales: _materiales,
      ),
    );

    if (result != null) {
      await _loadMateriales();
      _showSuccessMessage('Material "${result.nombre}" creado exitosamente');
    }
  }

  Future<void> _showEditMaterialDialog(MaterialModel material) async {
    final result = await showDialog<MaterialModel>(
      context: context,
      builder: (context) => MaterialFormDialog(
        title: 'Editar Material',
        material: material,
        existingMateriales: _materiales.where((m) => m.id != material.id).toList(),
      ),
    );

    if (result != null) {
      await _loadMateriales();
      _showSuccessMessage('Material "${result.nombre}" actualizado exitosamente');
    }
  }

  Future<void> _toggleMaterialStatus(MaterialModel material) async {
    try {
      final updatedMaterial = await _repository.updateMaterial(material.id, {
        'activo': !material.activo,
      });

      await _loadMateriales();

      final action = updatedMaterial.activo ? 'activado' : 'desactivado';
      _showSuccessMessage('Material "${material.nombre}" $action exitosamente');
    } catch (e) {
      _showErrorMessage('Error al cambiar estado del material: ${e.toString()}');
    }
  }

  Future<void> _deleteMaterial(MaterialModel material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el material "${material.nombre}"?\n\n'
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
        await _repository.deleteMaterial(material.id);
        await _loadMateriales();
        _showSuccessMessage('Material "${material.nombre}" eliminado exitosamente');
      } catch (e) {
        _showErrorMessage('Error al eliminar material: ${e.toString()}');
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
        onPressed: _showCreateMaterialDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Material'),
        backgroundColor: AppTheme.primaryTurquoise,
      ),
    );
  }

  Widget _buildHeader() {
    final activeCount = _materiales.where((m) => m.activo).length;
    final inactiveCount = _materiales.length - activeCount;

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
                          Icons.fiber_manual_record_outlined,
                          color: AppTheme.primaryTurquoise,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Gestión de Materiales',
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
                      'Total: ${_materiales.length} materiales • Activos: $activeCount • Inactivos: $inactiveCount',
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
                    onPressed: _loadMateriales,
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
                label: Text('Mostrar inactivos'),
                selected: _showInactiveMateriales,
                onSelected: (_) => _toggleShowInactive(),
                avatar: Icon(
                  _showInactiveMateriales ? Icons.visibility : Icons.visibility_off,
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

    if (_filteredMateriales.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMaterialesGrid();
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
            'Error al cargar materiales',
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
            onPressed: _loadMateriales,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasFilters = !_showInactiveMateriales;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.fiber_manual_record_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Sin resultados' : 'No hay materiales',
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
                : 'Comienza creando tu primer material',
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
                      _showInactiveMateriales = true;
                      _filteredMateriales = _applyFilters(_materiales);
                    });
                  }
                : _showCreateMaterialDialog,
            icon: Icon(hasSearch || hasFilters ? Icons.clear_all : Icons.add),
            label: Text(hasSearch || hasFilters ? 'Limpiar Filtros' : 'Crear Material'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialesGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: _filteredMateriales.length,
        itemBuilder: (context, index) {
          final material = _filteredMateriales[index];
          return MaterialCard(
            material: material,
            onEdit: () => _showEditMaterialDialog(material),
            onToggleStatus: () => _toggleMaterialStatus(material),
            onDelete: () => _deleteMaterial(material),
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