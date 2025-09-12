import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget Chart Card para mostrar gráficos dummy en el dashboard
/// 
/// Características:
/// - Placeholder para gráficos de líneas y barras
/// - Header con título y controles
/// - Área de contenido con dimensiones definidas
/// - Estados de loading y error
/// - Optimizado para layout web
class ChartCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final ChartType chartType;
  final List<ChartDataPoint> data;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  const ChartCard({
    super.key,
    required this.title,
    required this.chartType,
    required this.data,
    this.subtitle,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          // Divider
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
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
          ),
          
          // Controles
          Row(
            children: [
              // Filtro de tiempo
              _buildTimeFilter(),
              const SizedBox(width: 8),
              
              // Botón de actualizar
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Actualizar datos',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            'Último mes',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return _buildLoadingState();
    }
    
    if (widget.errorMessage != null) {
      return _buildErrorState();
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _buildChart(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando datos...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            widget.errorMessage!,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onRefresh,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (widget.chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
    }
  }

  Widget _buildLineChart() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Grid de fondo
          _buildGrid(),
          
          // Línea del gráfico (dummy)
          CustomPaint(
            size: Size.infinite,
            painter: LineChartPainter(
              data: widget.data,
              color: AppTheme.primaryColor,
            ),
          ),
          
          // Labels y valores
          _buildChartLabels(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Grid de fondo
          _buildGrid(),
          
          // Barras del gráfico (dummy)
          _buildBars(),
          
          // Labels
          _buildChartLabels(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(),
    );
  }

  Widget _buildBars() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint = entry.value;
        final maxValue = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
        final heightRatio = dataPoint.value / maxValue;
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  height: (heightRatio * 200).clamp(10.0, 200.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.8),
                        AppTheme.primaryColor,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dataPoint.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartLabels() {
    if (widget.chartType == ChartType.bar) {
      return const SizedBox.shrink(); // Las barras ya tienen sus labels
    }
    
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.data.map((dataPoint) {
          return Text(
            dataPoint.label,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Enums y modelos de datos
enum ChartType { line, bar }

class ChartDataPoint {
  final String label;
  final double value;
  final Color? color;

  ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

// Custom painters para los gráficos
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Líneas horizontales
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Líneas verticales
    for (int i = 0; i <= 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color color;

  LineChartPainter({
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - (size.height * (data[i].value - minValue) / (maxValue - minValue));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Puntos en la línea
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - (size.height * (data[i].value - minValue) / (maxValue - minValue));
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}