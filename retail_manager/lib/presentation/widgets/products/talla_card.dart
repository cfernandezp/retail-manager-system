import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../common/safe_hover_widget.dart';

/// Tarjeta que muestra información de una talla con acciones de administración
class TallaCard extends StatelessWidget {
  final Talla talla;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const TallaCard({
    super.key,
    required this.talla,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeMaterialButton(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: talla.activo ? 2 : 1,
      onTap: onEdit,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: talla.activo
                  ? Colors.grey[300]!
                  : Colors.grey[400]!,
              width: 1,
            ),
            color: talla.activo
                ? Colors.white
                : Colors.grey[50],
          ),
          child: Column(
            children: [
              // Header con ícono y estado
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: talla.activo
                      ? AppTheme.primaryTurquoise.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Ícono de talla
                    Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: talla.activo
                              ? AppTheme.primaryTurquoise.withOpacity(0.2)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.straighten,
                          color: talla.activo
                              ? AppTheme.primaryTurquoise
                              : Colors.grey[600],
                          size: 30,
                        ),
                      ),
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
                          color: talla.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          talla.activo ? 'ACTIVA' : 'INACTIVA',
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

              // Información de la talla
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Valor de la talla (principal)
                      Text(
                        talla.valor.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: talla.activo
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Nombre de la talla (si existe) - más compacto
                      if (talla.nombre != null && talla.nombre!.isNotEmpty && talla.nombre != talla.valor)
                        Text(
                          _capitalize(talla.nombre!),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 4),

                      // Row para tipo y código - más compacto
                      Row(
                        children: [
                          // Tipo de talla
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _getTipoColor(talla.tipo).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              _getTipoDisplayName(talla.tipo),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: _getTipoColor(talla.tipo),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Código de la talla
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTurquoise.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                'COD: ${talla.codigo}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryTurquoise,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Botones de acción - más compactos
                      Row(
                        children: [
                          // Botón editar
                          Expanded(
                            child: IconButton(
                              onPressed: onEdit,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: AppTheme.primaryTurquoise,
                              ),
                              iconSize: 14,
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              tooltip: 'Editar',
                            ),
                          ),

                          // Botón toggle estado
                          Expanded(
                            child: IconButton(
                              onPressed: onToggleStatus,
                              icon: Icon(
                                talla.activo
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 14,
                                color: talla.activo
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                              ),
                              iconSize: 14,
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              tooltip: talla.activo ? 'Desactivar' : 'Activar',
                            ),
                          ),

                          // Botón eliminar
                          Expanded(
                            child: IconButton(
                              onPressed: onDelete,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 14,
                                color: AppTheme.errorColor,
                              ),
                              iconSize: 14,
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROPA':
        return Colors.blue;
      case 'CALZADO':
        return Colors.orange;
      case 'ACCESORIOS':
        return Colors.green;
      case 'INDIVIDUAL':
        return Colors.purple;
      default:
        return AppTheme.primaryTurquoise;
    }
  }

  String _getTipoDisplayName(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROPA':
        return 'ROPA';
      case 'CALZADO':
        return 'CALZADO';
      case 'ACCESORIOS':
        return 'ACCESORIO';
      case 'INDIVIDUAL':
        return 'ÚNICA';
      default:
        return tipo.toUpperCase();
    }
  }
}