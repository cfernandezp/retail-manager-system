import 'package:flutter/material.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';

/// Widget para visualizar colores únicos y múltiples de manera consistente
class ColorVisualizador extends StatelessWidget {
  final ColorData color;
  final double size;
  final bool showLabel;
  final bool showTypeIndicator;

  const ColorVisualizador({
    Key? key,
    required this.color,
    this.size = 40,
    this.showLabel = false,
    this.showTypeIndicator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: color.esColorUnico
                    ? _buildColorUnico()
                    : _buildColorMultiple(),
              ),
            ),
            if (showTypeIndicator && color.esColorMultiple)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Icon(
                    Icons.palette,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        if (showLabel) ...[
          SizedBox(height: size * 0.1),
          SizedBox(
            width: size * 1.5,
            child: Column(
              children: [
                Text(
                  color.nombre,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (color.esColorMultiple && color.descripcionCompleta != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    color.descripcionCompleta!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColorUnico() {
    return Container(
      color: _parseHexColor(color.hexColor),
    );
  }

  Widget _buildColorMultiple() {
    return FutureBuilder<List<ColorData>>(
      future: ProductsRepository().getColoresComponentes(color.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey[600]!,
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.error_outline,
              size: size * 0.4,
              color: Colors.grey[600],
            ),
          );
        }

        final coloresComponentes = snapshot.data!;
        if (coloresComponentes.isEmpty) {
          return Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.palette,
              size: size * 0.4,
              color: Colors.grey[600],
            ),
          );
        }

        return _buildMultiColorDisplay(coloresComponentes);
      },
    );
  }

  Widget _buildMultiColorDisplay(List<ColorData> coloresComponentes) {
    final maxColors = coloresComponentes.length.clamp(2, 3);
    final coloresLimitados = coloresComponentes.take(maxColors).toList();

    if (coloresLimitados.length == 2) {
      // Mostrar dos colores en diagonal
      return Stack(
        children: [
          // Color inferior derecho
          Positioned.fill(
            child: Container(
              color: _parseHexColor(coloresLimitados[1].hexColor),
            ),
          ),
          // Color superior izquierdo (triángulo)
          Positioned.fill(
            child: ClipPath(
              clipper: DiagonalClipper(),
              child: Container(
                color: _parseHexColor(coloresLimitados[0].hexColor),
              ),
            ),
          ),
        ],
      );
    } else {
      // Mostrar tres colores en franjas verticales
      return Row(
        children: coloresLimitados.map((comp) {
          return Expanded(
            child: Container(
              color: _parseHexColor(comp.hexColor),
            ),
          );
        }).toList(),
      );
    }
  }

  Color _parseHexColor(String hexColor) {
    try {
      // Remover # si existe
      String cleanHex = hexColor.replaceAll('#', '');

      // Asegurar que tenga 6 caracteres
      if (cleanHex.length == 3) {
        cleanHex = cleanHex.split('').map((char) => char + char).join();
      }

      if (cleanHex.length != 6) {
        return Colors.grey[400]!;
      }

      return Color(int.parse('0xFF$cleanHex'));
    } catch (e) {
      return Colors.grey[400]!;
    }
  }
}

/// Clipper para crear efecto diagonal en colores dobles
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Widget compacto para mostrar color en listas o dropdowns
class ColorChip extends StatelessWidget {
  final ColorData color;
  final VoidCallback? onTap;
  final bool isSelected;

  const ColorChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorVisualizador(
              color: color,
              size: 16,
              showTypeIndicator: false,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                color.nombre,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (color.esColorMultiple)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Multi',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar colores en grids
class ColorGridItem extends StatelessWidget {
  final ColorData color;
  final VoidCallback? onTap;
  final bool isSelected;

  const ColorGridItem({
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
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ColorVisualizador(
            color: color,
            size: 48,
            showLabel: true,
          ),
        ),
      ),
    );
  }
}