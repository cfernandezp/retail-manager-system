import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../bloc/products/products_bloc.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_message.dart';

/// Página completa de Vista Detalle de Producto
class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductsBloc _productsBloc;
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _productsBloc = BlocProvider.of<ProductsBloc>(context);
    // Cargar detalles del producto
    _productsBloc.add(LoadProductDetails(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(ProductsState state) {
    if (state is ProductsLoading ||
        (state is ProductsLoaded && state.isLoadingDetails)) {
      return _buildLoadingView();
    }

    if (state is ProductDetailsLoaded) {
      return _buildDetailView(
        state.product,
        state.articulos,
      );
    }

    if (state is ProductsLoaded && state.selectedProduct != null) {
      return _buildDetailView(
        state.selectedProduct!,
        state.selectedProductArticulos ?? [],
      );
    }

    if (state is ProductsError) {
      return _buildErrorView(state.message);
    }

    return _buildLoadingView();
  }

  Widget _buildLoadingView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargando Producto...'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: const Center(
        child: LoadingIndicator(message: 'Cargando detalles del producto...'),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: Center(
        child: ErrorMessage(
          message: error,
          onRetry: () {
            _productsBloc.add(LoadProductDetails(widget.productId));
          },
        ),
      ),
    );
  }

  Widget _buildDetailView(ProductoMaster product, List<Articulo> articulos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: _buildAppBar(product),
          body: _buildResponsiveLayout(product, articulos, constraints.maxWidth),
          floatingActionButton: _buildFloatingActionButton(product),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ProductoMaster product) {
    return AppBar(
      title: Text(
        product.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/products'),
      ),
      actions: [
        // Botón Editar
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _navigateToEdit(product.id),
          tooltip: 'Editar Producto',
        ),
        // Menu overflow
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, product),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.content_copy_outlined),
                title: Text('Duplicar Producto'),
                dense: true,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Eliminar Producto', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveLayout(ProductoMaster product, List<Articulo> articulos, double width) {
    if (AppTheme.isDesktop(width)) {
      return _buildDesktopLayout(product, articulos);
    } else if (AppTheme.isTablet(width)) {
      return _buildTabletLayout(product, articulos);
    } else {
      return _buildMobileLayout(product, articulos);
    }
  }

  Widget _buildDesktopLayout(ProductoMaster product, List<Articulo> articulos) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel izquierdo - Información básica
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildProductInfo(product),
          ),
        ),
        // Panel derecho - Variantes y stock
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildVariantsAndStock(product, articulos),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(ProductoMaster product, List<Articulo> articulos) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProductInfo(product),
          const SizedBox(height: 24),
          _buildVariantsAndStock(product, articulos),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ProductoMaster product, List<Articulo> articulos) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProductInfo(product, isMobile: true),
          const SizedBox(height: 16),
          _buildVariantsAndStock(product, articulos, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ProductoMaster product, {bool isMobile = false}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del producto
            _buildProductHeader(product, isMobile),
            const SizedBox(height: 24),

            // Información básica
            _buildBasicInfo(product, isMobile),
            const SizedBox(height: 20),

            // Precios
            _buildPriceInfo(product, isMobile),
            const SizedBox(height: 20),

            // Métricas generales
            _buildGeneralMetrics(product, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(ProductoMaster product, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.nombre,
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildInfoChip(
              product.marca?.nombre ?? 'Sin marca',
              Icons.business_outlined,
              AppTheme.primaryTurquoise,
            ),
            _buildInfoChip(
              product.categoria?.nombre ?? 'Sin categoría',
              Icons.category_outlined,
              AppTheme.successColor,
            ),
            if (product.material != null)
              _buildInfoChip(
                product.material!.nombre,
                Icons.texture_outlined,
                AppTheme.warningColor,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfo(ProductoMaster product, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Talla Base', product.talla?.valor ?? 'Sin talla'),
        _buildInfoRow('Tipo de Talla', product.talla?.tipo.toUpperCase() ?? '-'),
        _buildInfoRow('Fecha de Creación',
          DateFormat('dd/MM/yyyy HH:mm').format(product.createdAt)),
        _buildInfoRow('Estado', product.activo ? 'ACTIVO' : 'INACTIVO'),
      ],
    );
  }

  Widget _buildPriceInfo(ProductoMaster product, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Precios',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryTurquoise.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primaryTurquoise.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.monetization_on_outlined,
                color: AppTheme.primaryTurquoise,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Precio Sugerido',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  Text(
                    currencyFormatter.format(product.precioSugerido),
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTurquoise,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralMetrics(ProductoMaster product, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas del Producto',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Artículos',
                '${product.articulos?.length ?? 0}',
                Icons.palette_outlined,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Stock Total',
                _calculateTotalStock(product.articulos ?? []).toString(),
                Icons.inventory_2_outlined,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariantsAndStock(ProductoMaster product, List<Articulo> articulos, {bool isMobile = false}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Variantes y Stock',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            if (articulos.isEmpty)
              _buildNoVariantsMessage()
            else
              _buildVariantsList(articulos, isMobile),

            const SizedBox(height: 20),
            _buildStockByStore(articulos, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVariantsMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.palette_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No hay variantes creadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Este producto aún no tiene colores o variantes asignadas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsList(List<Articulo> articulos, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colores Disponibles',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (isMobile)
          _buildMobileVariantsList(articulos)
        else
          _buildDesktopVariantsGrid(articulos),
      ],
    );
  }

  Widget _buildMobileVariantsList(List<Articulo> articulos) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articulos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final articulo = articulos[index];
        final totalStock = _calculateArticuloStock(articulo);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Color chip
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getColorFromHex(articulo.color?.hexColor),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[400]!),
                ),
              ),
              const SizedBox(width: 12),
              // Info del color
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      articulo.color?.nombre ?? 'Color sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'SKU: ${articulo.skuAuto}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Stock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: totalStock > 0
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalStock unidades',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: totalStock > 0
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopVariantsGrid(List<Articulo> articulos) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: articulos.map((articulo) {
        final totalStock = _calculateArticuloStock(articulo);

        return Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color visual
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getColorFromHex(articulo.color?.hexColor),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      articulo.color?.nombre ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'SKU: ${articulo.skuAuto}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Precio: ${currencyFormatter.format(articulo.precioSugerido)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: totalStock > 0
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalStock unidades',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: totalStock > 0
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStockByStore(List<Articulo> articulos, bool isMobile) {
    // Por ahora mostramos información simplificada del stock
    // En el futuro esto se podría expandir para mostrar stock por tienda

    final totalStock = articulos.fold<int>(
      0,
      (sum, articulo) => sum + _calculateArticuloStock(articulo),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Stock',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: totalStock > 0
                ? AppTheme.successColor.withOpacity(0.1)
                : AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: totalStock > 0
                  ? AppTheme.successColor.withOpacity(0.3)
                  : AppTheme.errorColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                totalStock > 0 ? Icons.check_circle : Icons.warning,
                color: totalStock > 0 ? AppTheme.successColor : AppTheme.errorColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Total Disponible',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '$totalStock unidades',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: totalStock > 0 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                    Text(
                      '${articulos.length} variantes de color',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ProductoMaster product) {
    return FloatingActionButton.extended(
      onPressed: () => _duplicateProduct(product),
      backgroundColor: AppTheme.primaryTurquoise,
      icon: const Icon(Icons.content_copy, color: Colors.white),
      label: const Text(
        'Duplicar Producto',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey[400]!;
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('0xFF$hex'));
    } catch (e) {
      return Colors.grey[400]!;
    }
  }

  int _calculateTotalStock(List<Articulo> articulos) {
    return articulos.fold<int>(
      0,
      (sum, articulo) => sum + _calculateArticuloStock(articulo),
    );
  }

  int _calculateArticuloStock(Articulo articulo) {
    // Por ahora retornamos un valor simulado
    // En el futuro esto calculará el stock real desde inventarios
    return articulo.inventarios?.fold<int>(
          0,
          (sum, inventario) => sum + inventario.stockActual,
        ) ??
        0;
  }

  void _navigateToEdit(String productId) {
    context.go('/products/$productId/edit');
  }

  void _handleMenuAction(String action, ProductoMaster product) {
    switch (action) {
      case 'duplicate':
        _duplicateProduct(product);
        break;
      case 'delete':
        _deleteProduct(product);
        break;
    }
  }

  void _duplicateProduct(ProductoMaster product) {
    // Mostrar dialog de confirmación para duplicar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicar Producto'),
        content: Text(
          '¿Deseas duplicar el producto "${product.nombre}"?\n\n'
          'Se creará una copia con el mismo nombre seguido de "(Copia)".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDuplication(product);
            },
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(ProductoMaster product) {
    // Mostrar dialog de confirmación para eliminar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el producto "${product.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDeletion(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performDuplication(ProductoMaster product) {
    final duplicateData = {
      'nombre': '${product.nombre} (Copia)',
      'marca_id': product.marcaId,
      'categoria_id': product.categoriaId,
      'talla_id': product.tallaId,
      'material_id': product.materialId,
      'precio_sugerido': product.precioSugerido,
      'activo': true,
    };

    _productsBloc.add(CreateProduct(
      productData: duplicateData,
      colores: [], // Se podrían agregar los colores originales
      inventarioInicial: [],
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto duplicado exitosamente'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _performDeletion(ProductoMaster product) {
    _productsBloc.add(DeleteProduct(product.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto eliminado exitosamente'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    // Navegar de vuelta a la lista
    context.go('/products');
  }
}