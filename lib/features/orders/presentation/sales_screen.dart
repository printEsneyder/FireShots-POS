import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/providers/orders_provider.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';
import 'package:fireshots_pos/features/orders/data/order_model.dart';
import 'package:intl/intl.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false),
          ),
        ],
      ),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allOrders) {
          final active = allOrders
              .where((o) => o.status != 'paid')
              .toList();
          final pending =
              active.where((o) => o.status == 'pending').toList();
          final acknowledged =
              active.where((o) => o.status == 'acknowledged').toList();
          final delivered =
              active.where((o) => o.status == 'delivered').toList();

          return Column(
            children: [
              _SummaryRow(
                totalActivas: active.length,
                totalNuevas: pending.length,
                totalRecibidas: acknowledged.length,
                totalEntregadas: delivered.length,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: active.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: AppConstants.textGray),
                            SizedBox(height: 16),
                            Text('No hay pedidos activos',
                                style: TextStyle(
                                    color: AppConstants.textGray)),
                          ],
                        ),
                      )
                    : ListView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          if (pending.isNotEmpty)
                            _SectionHeader(
                                title:
                                    'NUEVAS (${pending.length})',
                                color: Colors.orange),
                          ...pending.map((o) => _OrderCard(
                                key: ValueKey('pending_${o.id}'),
                                order: o,
                                isBlinking: true,
                              )),
                          if (acknowledged.isNotEmpty)
                            _SectionHeader(
                                title:
                                    'RECIBIDAS (${acknowledged.length})',
                                color: Colors.blue),
                          ...acknowledged.map((o) => _OrderCard(
                                key: ValueKey('ack_${o.id}'),
                                order: o,
                                isBlinking: false,
                              )),
                          if (delivered.isNotEmpty)
                            _SectionHeader(
                                title:
                                    'ENTREGADAS (${delivered.length})',
                                color: Colors.green),
                          ...delivered.map((o) => _OrderCard(
                                key: ValueKey('del_${o.id}'),
                                order: o,
                                isBlinking: false,
                              )),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int totalActivas;
  final int totalNuevas;
  final int totalRecibidas;
  final int totalEntregadas;

  const _SummaryRow({
    required this.totalActivas,
    required this.totalNuevas,
    required this.totalRecibidas,
    required this.totalEntregadas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          _Chip(
              label: 'Activas: $totalActivas',
              color: AppConstants.primaryGold),
          const SizedBox(width: 6),
          _Chip(
              label: 'Nuevas: $totalNuevas',
              color: totalNuevas > 0
                  ? Colors.orange
                  : AppConstants.textGray),
          const SizedBox(width: 6),
          _Chip(
              label: 'Recibidas: $totalRecibidas',
              color: totalRecibidas > 0
                  ? Colors.blue
                  : AppConstants.textGray),
          const SizedBox(width: 6),
          _Chip(
              label: 'Entregadas: $totalEntregadas',
              color: totalEntregadas > 0
                  ? Colors.green
                  : AppConstants.textGray),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader(
      {required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Row(
        children: [
          Container(width: 4, height: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final bool isBlinking;

  const _OrderCard({
    super.key,
    required this.order,
    required this.isBlinking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isBlinking
        ? _BlinkingCard(order: order)
        : _OrderCardContent(order: order);
  }
}

class _BlinkingCard extends StatefulWidget {
  final OrderModel order;
  const _BlinkingCard({required this.order});

  @override
  State<_BlinkingCard> createState() => _BlinkingCardState();
}

class _BlinkingCardState extends State<_BlinkingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _blinkColor(double value) {
    if (value < 0.33) {
      return Color.lerp(
          Colors.red, Colors.orange, value / 0.33)!;
    } else if (value < 0.66) {
      return Color.lerp(
          Colors.orange, Colors.amber, (value - 0.33) / 0.33)!;
    } else {
      return Color.lerp(
          Colors.amber, AppConstants.primaryGold, (value - 0.66) / 0.34)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = _blinkColor(_controller.value);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: color.withAlpha(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color, width: 2),
          ),
          child: child,
        );
      },
      child: _OrderCardContent(order: widget.order),
    );
  }
}

class _OrderCardContent extends ConsumerWidget {
  final OrderModel order;

  const _OrderCardContent({required this.order});

  IconData _statusIcon() {
    switch (order.status) {
      case 'pending':
        return Icons.notifications_active;
      case 'acknowledged':
        return Icons.visibility;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'paid':
        return Icons.paid;
      default:
        return Icons.circle;
    }
  }

  String _statusLabel() {
    switch (order.status) {
      case 'pending':
        return 'NUEVO PEDIDO';
      case 'acknowledged':
        return 'RECIBIDA';
      case 'delivered':
        return 'ENTREGADA';
      default:
        return order.status.toUpperCase();
    }
  }

  Color _statusColor() {
    switch (order.status) {
      case 'pending':
        return Colors.orange;
      case 'acknowledged':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'paid':
        return AppConstants.primaryGold;
      default:
        return AppConstants.textGray;
    }
  }

  Color _statusBgColor() {
    return _statusColor().withAlpha(26);
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(order.createdAt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) {
      return 'hace ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return 'hace ${diff.inHours}h ${diff.inMinutes % 60}min';
    }
    return DateFormat('MM/dd HH:mm').format(order.createdAt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = order.status == 'pending';
    final isAcknowledged = order.status == 'acknowledged';
    final isDelivered = order.status == 'delivered';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.red.withAlpha(51)
                      : _statusBgColor(),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: isPending
                          ? Colors.red.withAlpha(128)
                          : _statusColor().withAlpha(77)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(),
                        size: 14,
                        color: isPending
                            ? Colors.red
                            : _statusColor()),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: isPending
                            ? Colors.red
                            : _statusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(),
                style: const TextStyle(
                  color: AppConstants.textGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGold.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppConstants.primaryGold
                          .withAlpha(51)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.table_restaurant,
                        size: 22,
                        color: AppConstants.primaryGold),
                    const SizedBox(width: 6),
                    Text(
                      'Mesa ${order.tableNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppConstants.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (order.customerName != null &&
                  order.customerName!.isNotEmpty)
                Expanded(
                  child: Text(
                    order.customerName!,
                    style: const TextStyle(
                      color: AppConstants.textWhite,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppConstants.textGray),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryGold
                            .withAlpha(26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryGold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.name,
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Text(
                      AppConstants.formatCurrency(
                          item.price * item.quantity),
                      style: const TextStyle(
                        color: AppConstants.primaryGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppConstants.textGray),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                AppConstants.formatCurrency(order.totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppConstants.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isPending)
            _ActionButton(
              label: 'RECIBIR',
              icon: Icons.visibility,
              color: Colors.blue,
              onTap: () {
                ref
                    .read(ordersServiceProvider)
                    .updateOrderStatus(
                        order.id, 'acknowledged');
              },
            ),
          if (isAcknowledged)
            _ActionButton(
              label: 'ENTREGAR',
              icon: Icons.check,
              color: Colors.green,
              onTap: () {
                ref
                    .read(ordersServiceProvider)
                    .updateOrderStatus(
                        order.id, 'delivered');
              },
            ),
          if (isDelivered)
            _ActionButton(
              label: 'COBRAR',
              icon: Icons.payments,
              color: AppConstants.primaryGold,
              onTap: () =>
                  _showPaymentDialog(context, ref, order),
        ),
      ],
    ),
    );
  }

  void _showPaymentDialog(
      BuildContext context, WidgetRef ref, OrderModel order) {
    String selectedMethod = 'Efectivo';
    String? servedBy;
    List<String> staffList = List.from(AppConstants.staffNames);

    ref
        .read(systemSettingsServiceProvider)
        .getAllSettings()
        .then((settings) {
      final names = settings['staffNames'] as List<dynamic>?;
      if (names != null && names.isNotEmpty) {
        staffList = names.cast<String>();
      }
    });

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppConstants.backgroundCard,
          title: Row(
            children: [
              Icon(Icons.payments,
                  color: AppConstants.primaryGold),
              const SizedBox(width: 8),
              const Text('Registrar Pago'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGold.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.table_restaurant,
                        color: AppConstants.primaryGold),
                    const SizedBox(width: 8),
                    Text(
                      'Mesa ${order.tableNumber} - ${AppConstants.formatCurrency(order.totalAmount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: AppConstants.paymentMethods.map((m) {
                  return DropdownMenuItem(
                      value: m, child: Text(m));
                }).toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedMethod = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                hint: const Text('Atendido por (opcional)'),
                decoration: const InputDecoration(
                  labelText: 'Atendido por',
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  ...staffList.map((n) => DropdownMenuItem(
                      value: n, child: Text(n))),
                  const DropdownMenuItem(
                      value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) =>
                    setDialogState(() => servedBy = v),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.orange.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '¿Ya verificaste que se recibió el pago correctamente?',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: ctx,
                  barrierDismissible: false,
                  builder: (confirmCtx) => AlertDialog(
                    backgroundColor:
                        AppConstants.backgroundCard,
                    title:
                        const Text('Confirmar Pago'),
                    content: Text(
                      '¿Estás seguro de que el cliente de la Mesa ${order.tableNumber} ya realizó el pago por ${AppConstants.formatCurrency(order.totalAmount)}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(confirmCtx),
                        child:
                            const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(ordersServiceProvider)
                              .updateOrderStatus(
                                  order.id, 'paid');
                          if (servedBy != null) {
                            await ref
                                .read(
                                    ordersServiceProvider)
                                .updateOrderPayment(
                                  order.id,
                                  selectedMethod,
                                  servedBy,
                                );
                          }
                          if (confirmCtx.mounted) {
                            Navigator.pop(confirmCtx);
                          }
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text(
                            'SÍ, CONFIRMAR PAGO'),
                      ),
                    ],
                  ),
                );
              },
              icon:
                  const Icon(Icons.check_circle),
              label:
                  const Text('PROCESAR PAGO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label:
            Text(label, style: const TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withAlpha(204),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
