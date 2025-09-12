import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../common/safe_hover_widget.dart';

/// Widget KPI Card para métricas clave del dashboard
/// 
/// Características:
/// - Diseño Material 3 con elevación sutil
/// - Icono principal y valor destacado
/// - Indicador de tendencia opcional
/// - Animaciones suaves en hover
/// - Optimizado para web desktop
class KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool showTrending;
  final bool isIncreasing;
  final String? trendingValue;
  final bool isLoading;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
    this.showTrending = true,
    this.isIncreasing = true,
    this.trendingValue,
    this.isLoading = false,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeHoverWidget(
      onHover: () => _onHover(true),
      onExit: () => _onHover(false),
      builder: (context, isHovered) {
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isHovered 
                          ? widget.color.withOpacity(0.3) 
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isHovered ? 0.15 : 0.08
                        ),
                        blurRadius: isHovered ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.isLoading
                        ? _buildLoadingSkeleton()
                        : _buildContent(context),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con icono y tendencia
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icono principal
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: 32,
                color: widget.color,
              ),
            ),

            // Indicador de tendencia
            if (widget.showTrending)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, 
                  vertical: 4
                ),
                decoration: BoxDecoration(
                  color: widget.isIncreasing
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isIncreasing
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 16,
                      color: widget.isIncreasing
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                    if (widget.trendingValue != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        widget.trendingValue!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.isIncreasing
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Valor principal
        Text(
          widget.value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 8),

        // Título y subtítulo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Value skeleton
        Container(
          width: 120,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(height: 8),

        // Title skeleton
        Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (_isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}