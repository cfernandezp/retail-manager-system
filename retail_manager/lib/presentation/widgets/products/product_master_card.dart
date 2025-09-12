import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/product_models.dart';
import '../../../core/theme/app_theme.dart';

/// Card para mostrar un producto master con métricas de negocio
class ProductMasterCard extends StatefulWidget {
  final CatalogoCompleto product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProductMasterCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.showActions = true,
  });

  @override
  State<ProductMasterCard> createState() => _ProductMasterCardState();
}

class _ProductMasterCardState extends State<ProductMasterCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/ ',
      decimalDigits: 2,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shadowColor: AppTheme.primaryTurquoise.withOpacity(0.3),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con nombre y acciones
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del producto
                            Text(
                              widget.product.productoNombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Info básica
                            Text(
                              '${widget.product.marcaNombre} • ${widget.product.categoriaNombre} • Talla: ${widget.product.tallaValor}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (widget.showActions) ...[
                        const SizedBox(width: 8),
                        _buildActionsMenu(),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Colores disponibles
                  if (widget.product.coloresDisponibles.isNotEmpty) ...[
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: widget.product.coloresDisponibles
                          .take(6) // Mostrar máximo 6 colores
                          .map((color) => _buildColorChip(color))
                          .toList(),
                    ),
                    if (widget.product.coloresDisponibles.length > 6)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${widget.product.coloresDisponibles.length - 6} más',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],

                  // Métricas de negocio
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'Artículos',
                          '${widget.product.totalArticulos} colores',
                          Icons.palette_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          'Stock Total',
                          '${widget.product.stockTotal} unidades',
                          Icons.inventory_2_outlined,
                          valueColor: widget.product.stockTotal > 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Precios
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.product.precioMinimo != widget.product.precioMaximo) ...[
                              Text(
                                'Rango de precios',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${currencyFormatter.format(widget.product.precioMinimo)} - ${currencyFormatter.format(widget.product.precioMaximo)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ] else ...[
                              Text(
                                'Precio',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                currencyFormatter.format(widget.product.precioSugerido),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Indicador de disponibilidad
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.tiendasConStock > 0
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.product.tiendasConStock}/${_getTotalStores()} tiendas',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: widget.product.tiendasConStock > 0
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Indicador de hover para actions
                  if (_isHovered && widget.showActions) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildQuickAction(
                          'Ver Detalle',
                          Icons.visibility_outlined,
                          widget.onTap,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAction(
                          'Editar',
                          Icons.edit_outlined,
                          widget.onEdit,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorChip(String color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _getColorFromName(color),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Tooltip(
        message: color,
        child: const SizedBox(),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final colors = {
      'rojo': Colors.red,
      'azul': Colors.blue,
      'verde': Colors.green,
      'amarillo': Colors.yellow,
      'negro': Colors.black,
      'blanco': Colors.white,
      'gris': Colors.grey,
      'rosado': Colors.pink,
      'morado': Colors.purple,
      'naranja': Colors.orange,
      'café': Colors.brown,
      'beige': const Color(0xFFF5F5DC),
    };

    return colors[colorName.toLowerCase()] ?? Colors.grey[400]!;
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: AppTheme.textSecondaryColor,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility_outlined, size: 18),
            title: Text('Ver Detalle'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 18),
            title: Text('Editar'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: ListTile(
            leading: Icon(Icons.content_copy_outlined, size: 18),
            title: Text('Duplicar'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, size: 18, color: Colors.red),
            title: Text('Eliminar', style: TextStyle(color: Colors.red)),
            dense: true,
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'view':
            widget.onTap?.call();
            break;
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'duplicate':
            widget.onDuplicate?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryTurquoise.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryTurquoise,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryTurquoise,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalStores() {
    // En un escenario real, esto vendría del contexto o estado global
    // Por ahora retornamos un valor fijo
    return 3;
  }
}