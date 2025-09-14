import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget para mostrar mensajes de error de manera consistente
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final IconData? icon;
  final bool showIcon;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText,
    this.icon,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Oops! Algo salió mal',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  retryButtonText ?? 'Intentar de nuevo',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTurquoise,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de error compacto para usar en línea
class InlineErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color? textColor;

  const InlineErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor ?? AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.refresh,
                  color: AppTheme.errorColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de error para formularios
class FormErrorMessage extends StatelessWidget {
  final String message;

  const FormErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}