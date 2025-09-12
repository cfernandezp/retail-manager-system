import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';
import '../../bloc/products/products_bloc.dart';
import '../../widgets/products/product_master_card.dart';
import '../../widgets/products/product_filters.dart';
import '../../widgets/common/shimmer_widget.dart';

/// Página principal de gestión de productos con interfaz web-first
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();
  
  bool _isFiltersCollapsed = false;
  late AnimationController _headerAnimationController;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    // Configurar scroll listener para infinite scroll
    _scrollController.addListener(_onScroll);

    // Cargar productos al iniciar
    context.read<ProductsBloc>().add(const LoadProducts());
    context.read<ProductsBloc>().add(const SubscribeToChanges());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    _headerAnimationController.dispose();
    context.read<ProductsBloc>().add(const UnsubscribeFromChanges());
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ProductsBloc>().add(const LoadMoreProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is ProductDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto eliminado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Row(
            children: [
              // Filters Sidebar
              if (state is ProductsLoaded)
                ProductFiltersWidget(
                  filters: state.filters,
                  marcas: state.marcas,
                  categorias: state.categorias,
                  tallas: state.tallas,
                  onFiltersChanged: (newFilters) {
                    context.read<ProductsBloc>().add(FilterProducts(newFilters));
                  },
                  onClearFilters: () {
                    context.read<ProductsBloc>().add(
                      const FilterProducts(ProductFilters()),
                    );
                  },
                  isCollapsed: _isFiltersCollapsed,
                  onToggleCollapse: () {
                    setState(() {
                      _isFiltersCollapsed = !_isFiltersCollapsed;
                    });
                  },
                ),

              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Header with Search and Actions
                    _buildHeader(state),

                    // Content Area
                    Expanded(
                      child: _buildContent(state),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProductsState state) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeOutBack,
          )),
          child: Container(
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
                // Title and Actions Row
                Row(
                  children: [
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                color: AppTheme.primaryTurquoise,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Productos',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (state is ProductsLoaded)
                            Text(
                              'Catálogo de ${state.totalCount} productos • ${_getSelectedFiltersText(state.filters)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            )
                          else
                            Text(
                              'Gestión del catálogo de productos',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        if (state is ProductsLoaded) ...[
                          // Export Button
                          OutlinedButton.icon(
                            onPressed: () => _showExportDialog(context),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Exportar'),
                          ),
                          const SizedBox(width: 8),
                          // Import Button  
                          OutlinedButton.icon(
                            onPressed: () => _showImportDialog(context),
                            icon: const Icon(Icons.upload, size: 18),
                            label: const Text('Importar'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // New Product Button
                        ElevatedButton.icon(
                          onPressed: () => _navigateToCreateProduct(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nuevo Producto'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          hintText: 'Buscar productos por nombre o SKU...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.textSecondaryColor,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<ProductsBloc>().add(
                                      const SearchProducts(''),
                                    );
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                        ),
                        onChanged: (query) {
                          // Debounced search
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_searchController.text == query) {
                              context.read<ProductsBloc>().add(SearchProducts(query));
                            }
                          });
                        },
                        onSubmitted: (query) {
                          context.read<ProductsBloc>().add(SearchProducts(query));
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 12),

                    // View Options
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Toggle grid view
                            },
                            icon: const Icon(Icons.grid_view, size: 18),
                            tooltip: 'Vista de cuadrícula',
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey[300],
                          ),
                          IconButton(
                            onPressed: () {
                              // Toggle list view
                            },
                            icon: const Icon(Icons.view_list, size: 18),
                            tooltip: 'Vista de lista',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Refresh Button
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.read<ProductsBloc>().add(const RefreshProducts());
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(ProductsState state) {
    if (state is ProductsLoading) {
      return _buildLoadingState();
    } else if (state is ProductsLoaded) {
      return _buildProductsGrid(state);
    } else if (state is ProductsError) {
      return _buildErrorState(state.message);
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppTheme.getCrossAxisCount(
            MediaQuery.of(context).size.width - 280,
          ),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => const ShimmerWidget(
          child: Card(
            child: SizedBox(height: 280),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(ProductsLoaded state) {
    if (state.products.isEmpty) {
      return _buildEmptyState(hasFilters: state.filters.hasFilters);
    }

    final crossAxisCount = AppTheme.getCrossAxisCount(
      MediaQuery.of(context).size.width - (_isFiltersCollapsed ? 60 : 280),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: state.products.length + (state.isLoadingMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= state.products.length) {
            // Loading more items
            return const ShimmerWidget(
              child: Card(child: SizedBox(height: 280)),
            );
          }

          final product = state.products[index];
          return ProductMasterCard(
            product: product,
            onTap: () => _navigateToProductDetail(product.productoId),
            onEdit: () => _navigateToEditProduct(product.productoId),
            onDuplicate: () => _duplicateProduct(product),
            onDelete: () => _deleteProduct(product),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({bool hasFilters = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'Sin resultados' : 'No hay productos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Intenta ajustar los filtros de búsqueda'
                : 'Comienza agregando tu primer producto',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: hasFilters
                ? () {
                    context.read<ProductsBloc>().add(
                      const FilterProducts(ProductFilters()),
                    );
                  }
                : _navigateToCreateProduct,
            icon: Icon(hasFilters ? Icons.clear_all : Icons.add),
            label: Text(hasFilters ? 'Limpiar Filtros' : 'Crear Producto'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
            'Error al cargar productos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProductsBloc>().add(const LoadProducts());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  String _getSelectedFiltersText(ProductFilters filters) {
    List<String> filterTexts = [];
    
    if (filters.searchQuery?.isNotEmpty == true) {
      filterTexts.add('búsqueda activa');
    }
    if (filters.marcaIds.isNotEmpty) {
      filterTexts.add('${filters.marcaIds.length} marcas');
    }
    if (filters.categoriaIds.isNotEmpty) {
      filterTexts.add('${filters.categoriaIds.length} categorías');
    }
    if (filters.soloConStock == true) {
      filterTexts.add('con stock');
    }

    return filterTexts.isEmpty ? 'sin filtros' : filterTexts.join(' • ');
  }

  void _navigateToCreateProduct() {
    context.push('/products/create');
  }

  void _navigateToProductDetail(String productId) {
    context.push('/products/$productId');
  }

  void _navigateToEditProduct(String productId) {
    context.push('/products/$productId/edit');
  }

  void _duplicateProduct(CatalogoCompleto product) {
    // Implementar duplicación de producto
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicar Producto'),
        content: Text('¿Duplicar "${product.productoNombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar lógica de duplicación
            },
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(CatalogoCompleto product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Eliminar "${product.productoNombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductsBloc>().add(DeleteProduct(product.productoId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    // Implementar diálogo de exportación
  }

  void _showImportDialog(BuildContext context) {
    // Implementar diálogo de importación
  }
}