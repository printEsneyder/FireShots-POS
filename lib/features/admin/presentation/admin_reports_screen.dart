import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/features/orders/providers/orders_provider.dart';
import 'package:fireshots_pos/features/orders/data/order_model.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  DateTime? _selectedDate;
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: _filterLast10Hours,
            tooltip: 'Últimas 10 horas',
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) {
          final paidOrders = orders.where((o) => o.status == 'paid').toList();
          final filtered = _filterOrders(paidOrders);

          final totalRevenue = filtered.fold(0.0, (sum, o) => sum + o.totalAmount);
          final totalOrders = filtered.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Chip(
                          label: Text(
                            _selectedDate!.isAfter(
                                    DateTime.now().subtract(const Duration(days: 1)))
                                ? 'Últimas 10 horas'
                                : _dateFormat.format(_selectedDate!),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _selectedDate = null),
                          backgroundColor: AppConstants.primaryGold.withAlpha(51),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Ventas Totales',
                        value: AppConstants.formatCurrency(totalRevenue),
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Órdenes',
                        value: '$totalOrders',
                        icon: Icons.receipt_long,
                        color: AppConstants.primaryGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Ventas por Mesero',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                ..._salesByStaff(filtered).entries.map((entry) {
                  final percentage = totalRevenue > 0
                      ? (entry.value / totalRevenue * 100)
                      : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              AppConstants.formatCurrency(entry.value),
                              style: const TextStyle(
                                color: AppConstants.primaryGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor:
                                AppConstants.primaryGold.withAlpha(26),
                            color: AppConstants.primaryGold,
                            minHeight: 8,
                          ),
                        ),
                        Text('${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                color: AppConstants.textGray, fontSize: 12)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Text('Ventas',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                ...filtered.map((order) => _OrderFactureCard(
                      order: order,
                      dateFormat: _dateFormat,
                      timeFormat: _timeFormat,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _filterLast10Hours() {
    setState(() {
      _selectedDate = DateTime.now().subtract(const Duration(hours: 10));
    });
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedDate == null) return orders;
    return orders.where((o) {
      if (_selectedDate!.isAfter(
          DateTime.now().subtract(const Duration(days: 1)))) {
        return o.createdAt
            .isAfter(DateTime.now().subtract(const Duration(hours: 10)));
      }
      final orderDate =
          DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
      final filterDate =
          DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      return orderDate == filterDate;
    }).toList();
  }

  Map<String, double> _salesByStaff(List<OrderModel> orders) {
    final map = <String, double>{};
    for (final o in orders) {
      if (o.servedBy != null) {
        map[o.servedBy!] = (map[o.servedBy!] ?? 0) + o.totalAmount;
      }
    }
    if (map.isEmpty) map['Sin asignar'] = 0;
    return map;
  }
}

class _OrderFactureCard extends StatelessWidget {
  final OrderModel order;
  final DateFormat dateFormat;
  final DateFormat timeFormat;

  const _OrderFactureCard({
    required this.order,
    required this.dateFormat,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppConstants.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.table_restaurant,
                          color: AppConstants.primaryGold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Mesa #${order.tableNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppConstants.textWhite,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    AppConstants.formatCurrency(order.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppConstants.primaryGold,
                    ),
                  ),
                ],
              ),
              if (order.customerName != null) ...[
                const SizedBox(height: 4),
                Text('Cliente: ${order.customerName}',
                    style: const TextStyle(color: AppConstants.textGray, fontSize: 13)),
              ],
              const Divider(height: 16),
              ...order.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: const TextStyle(
                                color: AppConstants.textWhite, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          AppConstants.formatCurrency(item.price * item.quantity),
                          style: const TextStyle(
                              color: AppConstants.textGray, fontSize: 13),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 3)
                Text('+${order.items.length - 3} items más',
                    style: const TextStyle(
                        color: AppConstants.textGray, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: AppConstants.textGray),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(order.createdAt)} ${timeFormat.format(order.createdAt)}',
                    style: const TextStyle(
                        color: AppConstants.textGray, fontSize: 11),
                  ),
                  if (order.servedBy != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.person_outline, size: 12, color: AppConstants.textGray),
                    const SizedBox(width: 4),
                    Text(order.servedBy!,
                        style: const TextStyle(
                            color: AppConstants.textGray, fontSize: 11)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.backgroundCard,
        title: Text('Mesa #${order.tableNumber}',
            style: const TextStyle(color: AppConstants.textWhite)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (order.customerName != null)
                Text('Cliente: ${order.customerName}',
                    style: const TextStyle(color: AppConstants.textGray)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity}x ${item.name}',
                            style: const TextStyle(color: AppConstants.textWhite)),
                        Text(AppConstants.formatCurrency(item.price * item.quantity),
                            style: const TextStyle(color: AppConstants.primaryGold)),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textWhite,
                          fontSize: 16)),
                  Text(AppConstants.formatCurrency(order.totalAmount),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryGold,
                          fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Atendió: ${order.servedBy ?? 'N/A'}',
                  style: const TextStyle(color: AppConstants.textGray)),
              Text(
                '${dateFormat.format(order.createdAt)} ${timeFormat.format(order.createdAt)}',
                style: const TextStyle(color: AppConstants.textGray),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
            Text(title,
                style: const TextStyle(color: AppConstants.textGray)),
          ],
        ),
      ),
    );
  }
}
