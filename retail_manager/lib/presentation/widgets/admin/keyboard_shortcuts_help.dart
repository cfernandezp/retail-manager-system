import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.infoColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard, color: AppTheme.infoColor),
              const SizedBox(width: 8),
              const Text(
                'Atajos de teclado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.infoColor,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showShortcutsDialog(context),
                icon: const Icon(Icons.help_outline, size: 16),
                tooltip: 'Ver todos los atajos',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildShortcutChip('Ctrl + S', 'Selección múltiple'),
              _buildShortcutChip('Ctrl + A', 'Seleccionar todo'),
              _buildShortcutChip('Escape', 'Cancelar selección'),
              _buildShortcutChip('F5', 'Actualizar'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutChip(String shortcut, String description) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.keyboard, color: AppTheme.infoColor),
            SizedBox(width: 8),
            Text('Atajos de teclado disponibles'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutItem('Ctrl + S', 'Activar/desactivar modo de selección múltiple'),
              _buildShortcutItem('Ctrl + A', 'Seleccionar todos los usuarios visibles'),
              _buildShortcutItem('Escape', 'Cancelar selección y salir del modo de selección'),
              _buildShortcutItem('F5', 'Actualizar lista de usuarios'),
              _buildShortcutItem('Ctrl + F', 'Enfocar barra de búsqueda'),
              _buildShortcutItem('Enter', 'Confirmar acción en diálogos'),
              _buildShortcutItem('Tab', 'Navegar entre elementos'),
              _buildShortcutItem('Shift + Tab', 'Navegar hacia atrás entre elementos'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.warningColor, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los atajos de teclado mejoran significativamente la velocidad de trabajo para administradores experimentados.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeyboardShortcutsWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSelectionToggle;
  final VoidCallback? onSelectAll;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onRefresh;
  final VoidCallback? onFocusSearch;

  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
    this.onSelectionToggle,
    this.onSelectAll,
    this.onCancelSelection,
    this.onRefresh,
    this.onFocusSearch,
  });

  @override
  State<KeyboardShortcutsWrapper> createState() => _KeyboardShortcutsWrapperState();
}

class _KeyboardShortcutsWrapperState extends State<KeyboardShortcutsWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          // Ctrl + S: Toggle selection mode
          if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
            widget.onSelectionToggle?.call();
            return KeyEventResult.handled;
          }
          
          // Ctrl + A: Select all
          if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyA) {
            widget.onSelectAll?.call();
            return KeyEventResult.handled;
          }
          
          // Escape: Cancel selection
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onCancelSelection?.call();
            return KeyEventResult.handled;
          }
          
          // F5: Refresh
          if (event.logicalKey == LogicalKeyboardKey.f5) {
            widget.onRefresh?.call();
            return KeyEventResult.handled;
          }
          
          // Ctrl + F: Focus search
          if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
            widget.onFocusSearch?.call();
            return KeyEventResult.handled;
          }
        }
        
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}