import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClearSelection;
  final VoidCallback? onApproveSelected;
  final VoidCallback? onRejectSelected;
  final VoidCallback? onSuspendSelected;
  final bool canApproveSelected;
  final bool canRejectSelected;
  final bool canSuspendSelected;

  const SelectionToolbar({
    super.key,
    required this.selectedCount,
    this.onSelectAll,
    this.onClearSelection,
    this.onApproveSelected,
    this.onRejectSelected,
    this.onSuspendSelected,
    this.canApproveSelected = false,
    this.canRejectSelected = false,
    this.canSuspendSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: selectedCount > 0 ? 80 : 0,
      child: selectedCount > 0 
          ? Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Contador y acciones de selección
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$selectedCount usuario${selectedCount != 1 ? 's' : ''} seleccionado${selectedCount != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: onSelectAll,
                                icon: const Icon(Icons.select_all, size: 16),
                                label: const Text('Seleccionar todo'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: onClearSelection,
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text('Limpiar'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade600,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Acciones masivas
                    Row(
                      children: [
                        if (canApproveSelected)
                          _buildActionButton(
                            icon: Icons.check_circle,
                            label: 'Aprobar',
                            color: AppTheme.successColor,
                            onPressed: onApproveSelected,
                          ),
                        if (canApproveSelected && (canRejectSelected || canSuspendSelected))
                          const SizedBox(width: 8),
                        if (canRejectSelected)
                          _buildActionButton(
                            icon: Icons.cancel,
                            label: 'Rechazar',
                            color: AppTheme.errorColor,
                            onPressed: onRejectSelected,
                          ),
                        if (canRejectSelected && canSuspendSelected)
                          const SizedBox(width: 8),
                        if (canSuspendSelected)
                          _buildActionButton(
                            icon: Icons.pause_circle,
                            label: 'Suspender',
                            color: AppTheme.warningColor,
                            onPressed: onSuspendSelected,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}