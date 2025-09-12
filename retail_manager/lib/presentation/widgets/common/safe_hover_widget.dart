import 'package:flutter/material.dart';

/// Widget wrapper que maneja eventos de hover de manera segura
/// para prevenir assertion failures en mouse_tracker.dart
///
/// Este widget soluciona problemas comunes donde MouseRegion + setState
/// causan conflictos durante la gestión de estado de hover.
class SafeHoverWidget extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, bool isHovered)? builder;
  final VoidCallback? onHover;
  final VoidCallback? onExit;
  final bool enabled;

  const SafeHoverWidget({
    super.key,
    this.child,
    this.builder,
    this.onHover,
    this.onExit,
    this.enabled = true,
  }) : assert(child != null || builder != null,
         'Either child or builder must be provided');

  @override
  State<SafeHoverWidget> createState() => _SafeHoverWidgetState();
}

class _SafeHoverWidgetState extends State<SafeHoverWidget> {
  bool _isHovered = false;
  bool _isMounted = true;

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _setHoverState(bool isHovered) {
    if (!_isMounted || !widget.enabled) return;
    
    // Usar post-frame callback para evitar conflictos con el layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted && mounted && _isHovered != isHovered) {
        setState(() {
          _isHovered = isHovered;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.builder?.call(context, false) ?? widget.child!;
    }

    return MouseRegion(
      onEnter: (_) {
        _setHoverState(true);
        widget.onHover?.call();
      },
      onExit: (_) {
        _setHoverState(false);
        widget.onExit?.call();
      },
      child: widget.builder?.call(context, _isHovered) ?? widget.child!,
    );
  }
}

/// Widget alternativo usando solo CSS hover para casos simples
class CSSHoverWidget extends StatelessWidget {
  final Widget child;
  final Widget? hoverChild;
  final VoidCallback? onTap;

  const CSSHoverWidget({
    super.key,
    required this.child,
    this.hoverChild,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          child,
          if (hoverChild != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: hoverChild!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Alternativa segura para Material + InkWell que evita assertion failures
class SafeMaterialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  const SafeMaterialButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.elevation = 1,
    this.padding,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      color: backgroundColor ?? Colors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Container(
          padding: padding,
          constraints: constraints,
          child: child,
        ),
      ),
    );
  }
}