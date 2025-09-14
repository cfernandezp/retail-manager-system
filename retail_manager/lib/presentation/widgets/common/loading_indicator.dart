import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget de indicador de carga personalizado para el sistema retail
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? AppTheme.primaryTurquoise,
              strokeWidth: 3.0,
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de loading pequeño para usar en línea
class InlineLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const InlineLoadingIndicator({
    super.key,
    this.size = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? AppTheme.primaryTurquoise,
        strokeWidth: 2.0,
      ),
    );
  }
}

/// Widget de loading para botones
class ButtonLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const ButtonLoadingIndicator({
    super.key,
    this.size = 20.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2.0,
      ),
    );
  }
}