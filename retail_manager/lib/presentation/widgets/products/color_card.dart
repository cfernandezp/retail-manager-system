import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../common/safe_hover_widget.dart';

/// Tarjeta que muestra información de un color con acciones de administración
class ColorCard extends StatelessWidget {
  final ColorData color;
  final List<ColorData>? coloresUnicos; // AGREGADO: Lista de colores únicos para resolución
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const ColorCard({
    super.key,
    required this.color,
    this.coloresUnicos,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeMaterialButton(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: color.activo ? 2 : 1,
      onTap: onEdit,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          height: 200, // AGREGADO: Altura fija para evitar overflow
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.activo
                  ? Colors.grey[300]!
                  : Colors.grey[400]!,
              width: 1,
            ),
            color: color.activo
                ? Colors.white
                : Colors.grey[50],
          ),
          child: Column(
            children: [
              // Header con preview del color y estado
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Stack(
                  children: [
                    // Preview del color (adaptado para tipo múltiple)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                        child: color.esColorUnico
                            ? Container(
                                color: _getColorFromHex(color.hexColor),
                              )
                            : _buildMultiColorPreview(),
                      ),
                    ),

                    // Indicador de tipo de color
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.esColorUnico
                              ? AppTheme.primaryTurquoise
                              : Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          color.esColorUnico ? 'Único' : 'Múltiple',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Indicador de estado
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          color.activo ? 'ACTIVO' : 'INACTIVO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Código hex centrado (solo para color único)
                    if (color.esColorUnico && color.hexColor != null)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getContrastColor(_getColorFromHex(color.hexColor))
                                .withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            color.hexColor!.toUpperCase(),
                            style: TextStyle(
                              color: _getContrastColor(_getColorFromHex(color.hexColor)) == Colors.white
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),

                    // Texto para colores múltiples
                    if (color.esColorMultiple)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${color.cantidadColores} colores',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Información del color
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del color
                      Text(
                        _capitalize(color.nombre),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color.activo
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Código abreviado
                      if (color.codigoAbrev != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTurquoise.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'COD: ${color.codigoAbrev}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryTurquoise,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Descripción para colores múltiples (más compacta)
                      if (color.esColorMultiple && color.descripcionCompleta != null) ...[
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            color.descripcionCompleta!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Botones de acción (más compactos)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            // Botón editar
                            Expanded(
                              child: IconButton(
                                onPressed: onEdit,
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppTheme.primaryTurquoise,
                                ),
                                tooltip: 'Editar',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                  minWidth: 32,
                                ),
                              ),
                            ),

                            // Botón toggle estado
                            Expanded(
                              child: IconButton(
                                onPressed: onToggleStatus,
                                icon: Icon(
                                  color.activo
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 16,
                                  color: color.activo
                                      ? AppTheme.warningColor
                                      : AppTheme.successColor,
                                ),
                                tooltip: color.activo ? 'Desactivar' : 'Activar',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                  minWidth: 32,
                                ),
                              ),
                            ),

                            // Botón eliminar
                            Expanded(
                              child: IconButton(
                                onPressed: onDelete,
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: AppTheme.errorColor,
                                ),
                                tooltip: 'Eliminar',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                  minWidth: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey[400]!;
    }

    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey[400]!;
    }
  }

  Color _getContrastColor(Color color) {
    // Calcular luminancia para determinar si usar texto claro u oscuro
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Construye el preview para colores múltiples mostrando barras de colores componentes
  Widget _buildMultiColorPreview() {
    if (color.coloresComponentes == null ||
        color.coloresComponentes!.isEmpty ||
        coloresUnicos == null) {
      // Fallback: mostrar color base si no hay componentes o colores únicos
      return Container(
        color: _getColorFromHex(color.hexColor),
      );
    }

    // Obtener los colores componentes reales
    final coloresComponentesReales = <ColorData>[];
    for (final componenteId in color.coloresComponentes!) {
      final colorComponente = coloresUnicos!
          .where((c) => c.id == componenteId)
          .firstOrNull;
      if (colorComponente != null) {
        coloresComponentesReales.add(colorComponente);
      }
    }

    if (coloresComponentesReales.isEmpty) {
      // Fallback si no se encuentran los componentes
      return Container(
        color: _getColorFromHex(color.hexColor),
      );
    }

    // Construir barra de colores dividida
    return Row(
      children: coloresComponentesReales.map((colorComponente) {
        return Expanded(
          child: Container(
            color: _getColorFromHex(colorComponente.hexColor),
          ),
        );
      }).toList(),
    );
  }
}