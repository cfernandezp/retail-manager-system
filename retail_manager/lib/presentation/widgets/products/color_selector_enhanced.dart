import 'package:flutter/material.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';
import 'color_visualizer.dart';

/// Enhanced color selector that works with ColorData from database
/// Supports both single and multiple color types
class ColorSelectorEnhanced extends StatefulWidget {
  final List<ColorData> coloresDisponibles;
  final String? selectedColorId;
  final Function(String?) onColorChanged;
  final bool allowMultiple; // Permite colores múltiples además de únicos
  final String? label;
  final String? hintText;
  final bool isRequired;

  const ColorSelectorEnhanced({
    Key? key,
    required this.coloresDisponibles,
    required this.selectedColorId,
    required this.onColorChanged,
    this.allowMultiple = true, // Por defecto permite ambos tipos
    this.label,
    this.hintText,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<ColorSelectorEnhanced> createState() => _ColorSelectorEnhancedState();
}

class _ColorSelectorEnhancedState extends State<ColorSelectorEnhanced> {
  late List<ColorData> _coloresFiltrados;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateColoresFiltrados();
  }

  @override
  void didUpdateWidget(ColorSelectorEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coloresDisponibles != widget.coloresDisponibles ||
        oldWidget.allowMultiple != widget.allowMultiple) {
      _updateColoresFiltrados();
    }
  }

  void _updateColoresFiltrados() {
    _coloresFiltrados = widget.allowMultiple
        ? widget.coloresDisponibles
        : widget.coloresDisponibles.where((c) => c.esColorUnico).toList();

    if (_searchQuery.isNotEmpty) {
      _coloresFiltrados = _coloresFiltrados
          .where((color) =>
              color.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (color.descripcionCompleta?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }

    _coloresFiltrados.sort((a, b) {
      // Primero colores únicos, luego múltiples
      if (a.esColorUnico && !b.esColorUnico) return -1;
      if (!a.esColorUnico && b.esColorUnico) return 1;
      // Luego por nombre
      return a.nombre.compareTo(b.nombre);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        _buildColorDropdown(),
        if (_coloresFiltrados.length > 5) ...[
          const SizedBox(height: 8),
          _buildSearchField(),
        ],
        if (!widget.allowMultiple) ...[
          const SizedBox(height: 4),
          Text(
            'Solo se muestran colores únicos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColorDropdown() {
    return DropdownButtonFormField<String>(
      value: widget.selectedColorId,
      decoration: InputDecoration(
        labelText: widget.hintText ?? 'Seleccionar color',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: widget.selectedColorId != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => widget.onColorChanged(null),
                tooltip: 'Limpiar selección',
              )
            : null,
      ),
      isExpanded: true,
      items: _coloresFiltrados.map((color) {
        return DropdownMenuItem<String>(
          value: color.id,
          child: _buildColorDropdownItem(color),
        );
      }).toList(),
      onChanged: widget.onColorChanged,
      validator: widget.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona un color';
              }
              return null;
            }
          : null,
      selectedItemBuilder: (BuildContext context) {
        return _coloresFiltrados.map<Widget>((ColorData color) {
          return Row(
            children: [
              ColorVisualizador(
                color: color,
                size: 24,
                showTypeIndicator: false,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  color.nombre,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList();
      },
    );
  }

  Widget _buildColorDropdownItem(ColorData color) {
    return Row(
      children: [
        ColorVisualizador(
          color: color,
          size: 32,
          showTypeIndicator: true,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                color.nombre,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (color.esColorMultiple && color.descripcionCompleta != null) ...[
                const SizedBox(height: 2),
                Text(
                  color.descripcionCompleta!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (color.esColorMultiple)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Multi',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar color...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _updateColoresFiltrados();
        });
      },
    );
  }
}

/// Widget para selección múltiple de colores desde base de datos
class MultiColorSelectorFromDB extends StatefulWidget {
  final List<String> selectedColorIds;
  final Function(List<String>) onColorsChanged;
  final bool allowMultiple;
  final String? label;
  final bool isRequired;
  final int? maxSelection;

  const MultiColorSelectorFromDB({
    Key? key,
    required this.selectedColorIds,
    required this.onColorsChanged,
    this.allowMultiple = true,
    this.label,
    this.isRequired = false,
    this.maxSelection,
  }) : super(key: key);

  @override
  State<MultiColorSelectorFromDB> createState() => _MultiColorSelectorFromDBState();
}

class _MultiColorSelectorFromDBState extends State<MultiColorSelectorFromDB> {
  List<ColorData> _coloresDisponibles = [];
  List<ColorData> _coloresFiltrados = [];
  bool _isLoading = true;
  String? _error;
  String _tipoColorFilter = 'TODOS'; // 'TODOS', 'UNICO', 'VARIOS'

  @override
  void initState() {
    super.initState();
    _loadColores();
  }

  Future<void> _loadColores() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = ProductsRepository();
      final colores = widget.allowMultiple
          ? await repository.getColores()
          : await repository.getColoresUnicos();

      setState(() {
        _coloresDisponibles = colores;
        _coloresFiltrados = _applyFilters(colores);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar colores: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(
            _error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadColores,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        _buildFilterChips(),
        const SizedBox(height: 16),
        _buildColorGrid(),
        if (widget.selectedColorIds.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSelectedColorsInfo(),
        ],
      ],
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2, // Reducido de 0.8 a 1.2 para hacer más compacto
      ),
      itemCount: _coloresFiltrados.length,
      itemBuilder: (context, index) {
        final color = _coloresFiltrados[index];
        final isSelected = widget.selectedColorIds.contains(color.id);

        return ColorGridItemCompact(
          color: color,
          isSelected: isSelected,
          onTap: () => _toggleColorSelection(color.id),
        );
      },
    );
  }

  Widget _buildSelectedColorsInfo() {
    final selectedColors = _coloresDisponibles
        .where((color) => widget.selectedColorIds.contains(color.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colores seleccionados (${selectedColors.length})',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedColors.map((color) {
            return ColorChip(
              color: color,
              isSelected: true,
              onTap: () => _toggleColorSelection(color.id),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _toggleColorSelection(String colorId) {
    final selectedColorIds = List<String>.from(widget.selectedColorIds);

    if (selectedColorIds.contains(colorId)) {
      selectedColorIds.remove(colorId);
    } else {
      // Verificar límite máximo
      if (widget.maxSelection != null &&
          selectedColorIds.length >= widget.maxSelection!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Máximo ${widget.maxSelection} colores permitidos',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      selectedColorIds.add(colorId);
    }

    widget.onColorsChanged(selectedColorIds);
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        Text(
          'Filtrar por tipo:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Todos'),
          selected: _tipoColorFilter == 'TODOS',
          onSelected: (_) => _onTipoColorFilterChanged('TODOS'),
          avatar: const Icon(Icons.palette, size: 16),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Únicos'),
          selected: _tipoColorFilter == 'UNICO',
          onSelected: (_) => _onTipoColorFilterChanged('UNICO'),
          avatar: const Icon(Icons.circle, size: 16),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Múltiples'),
          selected: _tipoColorFilter == 'VARIOS',
          onSelected: (_) => _onTipoColorFilterChanged('VARIOS'),
          avatar: const Icon(Icons.palette_outlined, size: 16),
        ),
      ],
    );
  }

  void _onTipoColorFilterChanged(String tipo) {
    setState(() {
      _tipoColorFilter = tipo;
      _coloresFiltrados = _applyFilters(_coloresDisponibles);
    });
  }

  List<ColorData> _applyFilters(List<ColorData> colors) {
    List<ColorData> filtered = colors;

    // Filtro por tipo de color
    if (_tipoColorFilter != 'TODOS') {
      filtered = filtered.where((color) => color.tipoColor == _tipoColorFilter).toList();
    }

    return filtered;
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6; // Más columnas para desktop
    if (width > 800) return 4;
    return 3;
  }
}

/// Widget compacto para mostrar colores en grid de selección
class ColorGridItemCompact extends StatelessWidget {
  final ColorData color;
  final VoidCallback? onTap;
  final bool isSelected;

  const ColorGridItemCompact({
    Key? key,
    required this.color,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorVisualizador(
                color: color,
                size: 28, // Reducido de 48 a 28
                showTypeIndicator: true,
              ),
              const SizedBox(height: 4),
              Text(
                color.nombre,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 10, // Texto más pequeño
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}