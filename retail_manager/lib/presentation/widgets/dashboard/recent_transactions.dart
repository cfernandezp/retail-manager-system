import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Widget para mostrar transacciones recientes en el dashboard
/// 
/// Características:
/// - Lista de últimas 5 transacciones
/// - Información resumida por transacción
/// - Estados de loading y empty state
/// - Scroll vertical si es necesario
/// - Optimizado para layout web
class RecentTransactions extends StatelessWidget {
  final List<TransactionData> transactions;
  final bool isLoading;
  final VoidCallback? onViewAll;

  const RecentTransactions({
    super.key,
    required this.transactions,
    this.isLoading = false,
    this.onViewAll,
  });

  // Datos dummy para demostración
  static final List<TransactionData> dummyTransactions = [
    TransactionData(
      id: 'TXN-001',
      customerName: 'María González',
      amount: 89.50,
      items: 3,
      date: DateTime.now().subtract(const Duration(minutes: 15)),
      status: TransactionStatus.completed,
      paymentMethod: 'Efectivo',
    ),
    TransactionData(
      id: 'TXN-002',
      customerName: 'Carlos Ruiz',
      amount: 156.75,
      items: 5,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      status: TransactionStatus.completed,
      paymentMethod: 'Tarjeta',
    ),
    TransactionData(
      id: 'TXN-003',
      customerName: 'Ana Torres',
      amount: 45.00,
      items: 2,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: TransactionStatus.pending,
      paymentMethod: 'Transferencia',
    ),
    TransactionData(
      id: 'TXN-004',
      customerName: 'Luis Mendoza',
      amount: 234.25,
      items: 8,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      status: TransactionStatus.completed,
      paymentMethod: 'Efectivo',
    ),
    TransactionData(
      id: 'TXN-005',
      customerName: 'Elena Castro',
      amount: 67.80,
      items: 2,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      status: TransactionStatus.refunded,
      paymentMethod: 'Tarjeta',
    ),
  ];

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transacciones Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Últimas ${transactions.isEmpty ? dummyTransactions.length : transactions.length} operaciones',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          // Botón para ver todas
          TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Ver todas'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }

    final displayTransactions = transactions.isEmpty 
        ? dummyTransactions 
        : transactions;

    if (displayTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: displayTransactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return TransactionTile(
          transaction: displayTransactions[index],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const TransactionSkeletonTile();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay transacciones recientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las transacciones aparecerán aquí una vez que se realicen ventas',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatefulWidget {
  final TransactionData transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered 
              ? AppTheme.primaryColor.withOpacity(0.05) 
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered 
                ? AppTheme.primaryColor.withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Avatar/Icono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Información principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primera línea: Cliente y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.transaction.customerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Segunda línea: Detalles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.transaction.items} items • ${widget.transaction.paymentMethod}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(widget.transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Monto
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'S/ ${widget.transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.transaction.status == TransactionStatus.refunded
                        ? AppTheme.errorColor
                        : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  widget.transaction.id,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.transaction.status) {
      case TransactionStatus.completed:
        return AppTheme.successColor;
      case TransactionStatus.pending:
        return AppTheme.warningColor;
      case TransactionStatus.refunded:
        return AppTheme.errorColor;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.transaction.status) {
      case TransactionStatus.completed:
        return Icons.check_circle_outline;
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.refunded:
        return Icons.undo;
    }
  }

  String _getStatusText() {
    switch (widget.transaction.status) {
      case TransactionStatus.completed:
        return 'Completado';
      case TransactionStatus.pending:
        return 'Pendiente';
      case TransactionStatus.refunded:
        return 'Reembolsado';
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}

class TransactionSkeletonTile extends StatelessWidget {
  const TransactionSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar skeleton
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 16),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Amount skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 80,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Enums y modelos de datos
enum TransactionStatus { completed, pending, refunded }

class TransactionData {
  final String id;
  final String customerName;
  final double amount;
  final int items;
  final DateTime date;
  final TransactionStatus status;
  final String paymentMethod;

  TransactionData({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.items,
    required this.date,
    required this.status,
    required this.paymentMethod,
  });
}