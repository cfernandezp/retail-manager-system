import 'package:flutter/material.dart';
import '../../../data/models/product_models.dart';
import '../../../core/theme/app_theme.dart';

/// Widget para filtros de productos con sidebar colapsible
class ProductFiltersWidget extends StatefulWidget {
  final ProductFilters filters;
  final List<Marca> marcas;
  final List<Categoria> categorias;
  final List<Talla> tallas;
  final ValueChanged<ProductFilters> onFiltersChanged;
  final VoidCallback? onClearFilters;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const ProductFiltersWidget({
    super.key,
    required this.filters,
    required this.marcas,
    required this.categorias,
    required this.tallas,
    required this.onFiltersChanged,
    this.onClearFilters,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  State<ProductFiltersWidget> createState() => _ProductFiltersWidgetState();
}

class _ProductFiltersWidgetState extends State<ProductFiltersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  final TextEditingController _precioMinController = TextEditingController();
  final TextEditingController _precioMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (!widget.isCollapsed) {
      _animationController.forward();
    }

    // Inicializar controladores de precio
    if (widget.filters.precioMinimo != null) {
      _precioMinController.text = widget.filters.precioMinimo.toString();
    }
    if (widget.filters.precioMaximo != null) {
      _precioMaxController.text = widget.filters.precioMaximo.toString();
    }
  }

  @override
  void didUpdateWidget(ProductFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _precioMinController.dispose();
    _precioMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isCollapsed ? 60 : 280,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryTurquoise.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (!widget.isCollapsed) ...[
                  Icon(
                    Icons.filter_list,
                    color: AppTheme.primaryTurquoise,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTurquoise,
                      ),
                    ),
                  ),
                  if (widget.filters.hasFilters)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTurquoise,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getActiveFiltersCount().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: widget.onToggleCollapse,
                  icon: Icon(
                    widget.isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    color: AppTheme.primaryTurquoise,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return widget.isCollapsed
                    ? _buildCollapsedContent()
                    : Opacity(
                        opacity: _slideAnimation.value,
                        child: _buildExpandedContent(),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (widget.filters.hasFilters)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryTurquoise.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getActiveFiltersCount().toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTurquoise,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón limpiar filtros
          if (widget.filters.hasFilters) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onClearFilters,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Limpiar Filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryTurquoise,
                  side: const BorderSide(color: AppTheme.primaryTurquoise),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Filtro por Marca
          _buildFilterSection(
            'Marca',
            Icons.branding_watermark_outlined,
            widget.marcas.map((m) => FilterChipData(m.id, m.nombre)).toList(),
            widget.filters.marcaIds,
            (selected) {
              widget.onFiltersChanged(
                widget.filters.copyWith(marcaIds: selected),
              );
            },
          ),

          const SizedBox(height: 20),

          // Filtro por Categoría
          _buildFilterSection(
            'Categoría',
            Icons.category_outlined,
            widget.categorias.map((c) => FilterChipData(c.id, c.nombre)).toList(),
            widget.filters.categoriaIds,
            (selected) {
              widget.onFiltersChanged(
                widget.filters.copyWith(categoriaIds: selected),
              );
            },
          ),

          const SizedBox(height: 20),

          // Filtro por Talla
          _buildFilterSection(
            'Talla',
            Icons.straighten_outlined,
            widget.tallas.map((t) => FilterChipData(t.id, t.valor)).toList(),
            widget.filters.tallaIds,
            (selected) {
              widget.onFiltersChanged(
                widget.filters.copyWith(tallaIds: selected),
              );
            },
          ),

          const SizedBox(height: 20),

          // Filtro por rango de precios
          _buildPriceRangeFilter(),

          const SizedBox(height: 20),

          // Filtros adicionales
          _buildAdditionalFilters(),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    List<FilterChipData> options,
    List<String> selectedIds,
    ValueChanged<List<String>> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((option) {
            final isSelected = selectedIds.contains(option.id);
            return FilterChip(
              label: Text(
                option.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                List<String> newSelection = List.from(selectedIds);
                if (selected) {
                  newSelection.add(option.id);
                } else {
                  newSelection.remove(option.id);
                }
                onChanged(newSelection);
              },
              backgroundColor: AppTheme.surfaceColor,
              selectedColor: AppTheme.primaryTurquoise.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryTurquoise,
              side: BorderSide(
                color: isSelected 
                    ? AppTheme.primaryTurquoise 
                    : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_money_outlined,
              size: 18,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            const Text(
              'Rango de Precios',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _precioMinController,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  prefixText: 'S/ ',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  final precio = double.tryParse(value);
                  widget.onFiltersChanged(
                    widget.filters.copyWith(precioMinimo: precio),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text('—', style: TextStyle(color: AppTheme.textSecondaryColor)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _precioMaxController,
                decoration: const InputDecoration(
                  labelText: 'Max',
                  prefixText: 'S/ ',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  final precio = double.tryParse(value);
                  widget.onFiltersChanged(
                    widget.filters.copyWith(precioMaximo: precio),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disponibilidad',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text(
            'Solo con stock',
            style: TextStyle(fontSize: 13),
          ),
          value: widget.filters.soloConStock ?? false,
          onChanged: (value) {
            widget.onFiltersChanged(
              widget.filters.copyWith(soloConStock: value),
            );
          },
          activeColor: AppTheme.primaryTurquoise,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text(
            'Solo productos activos',
            style: TextStyle(fontSize: 13),
          ),
          value: widget.filters.soloActivos ?? true,
          onChanged: (value) {
            widget.onFiltersChanged(
              widget.filters.copyWith(soloActivos: value),
            );
          },
          activeColor: AppTheme.primaryTurquoise,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (widget.filters.searchQuery?.isNotEmpty == true) count++;
    if (widget.filters.marcaIds.isNotEmpty) count++;
    if (widget.filters.categoriaIds.isNotEmpty) count++;
    if (widget.filters.tallaIds.isNotEmpty) count++;
    if (widget.filters.soloConStock == true) count++;
    if (widget.filters.precioMinimo != null) count++;
    if (widget.filters.precioMaximo != null) count++;
    return count;
  }
}

/// Clase auxiliar para datos de FilterChip
class FilterChipData {
  final String id;
  final String label;

  const FilterChipData(this.id, this.label);
}