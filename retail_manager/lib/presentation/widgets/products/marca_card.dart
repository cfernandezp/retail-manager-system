import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../common/safe_hover_widget.dart';

/// Tarjeta que muestra información de una marca con acciones de administración
class MarcaCard extends StatelessWidget {
  final Marca marca;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const MarcaCard({
    super.key,
    required this.marca,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeMaterialButton(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: marca.activo ? 2 : 1,
      onTap: onEdit,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: marca.activo
                  ? Colors.grey[300]!
                  : Colors.grey[400]!,
              width: 1,
            ),
            color: marca.activo
                ? Colors.white
                : Colors.grey[50],
          ),
          child: Column(
            children: [
              // Header con logo y estado
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: marca.activo
                      ? AppTheme.primaryTurquoise.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Logo o icono de marca
                    Center(
                      child: marca.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                marca.logoUrl!,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                              ),
                            )
                          : _buildDefaultLogo(),
                    ),

                    // Indicador de estado
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: marca.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          marca.activo ? 'ACTIVA' : 'INACTIVA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Información de la marca
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre de la marca
                      Text(
                        _capitalize(marca.nombre),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: marca.activo
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Descripción
                      if (marca.descripcion != null && marca.descripcion!.isNotEmpty)
                        Flexible(
                          child: Text(
                            marca.descripcion!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(height: 6),

                      // Prefijo SKU (si existe)
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
                          'SKU: ${marca.nombre.substring(0, 3).toUpperCase()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryTurquoise,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Botones de acción
                      Row(
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
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: 'Editar',
                            ),
                          ),

                          // Botón toggle estado
                          Expanded(
                            child: IconButton(
                              onPressed: onToggleStatus,
                              icon: Icon(
                                marca.activo
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 16,
                                color: marca.activo
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                              ),
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: marca.activo ? 'Desactivar' : 'Activar',
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
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: 'Eliminar',
                            ),
                          ),
                        ],
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

  Widget _buildDefaultLogo() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: AppTheme.primaryTurquoise.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.branding_watermark,
        color: AppTheme.primaryTurquoise,
        size: 30,
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}