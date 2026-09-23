import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/providers/orders_provider.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';
import 'package:fireshots_pos/features/orders/data/order_model.dart';
import 'package:intl/intl.dart';

class StaffKDSScreen extends ConsumerWidget {
  const StaffKDSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingOrdersStreamProvider);
    final acknowledgedAsync = ref.watch(acknowledgedOrdersStreamProvider);
    final deliveredAsync = ref.watch(deliveredOrdersStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FireShots - KDS'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendientes'),
              Tab(text: 'Entregados'),
            ],
          ),
        ),
        drawer: _buildDrawer(context, ref),
        body: TabBarView(
          children: [
            _KDSOrdersList(
              pendingAsync: pendingAsync,
              acknowledgedAsync: acknowledgedAsync,
            ),
            _OrdersList(
              ordersAsync: deliveredAsync,
              status: 'delivered',
              emptyMessage: 'No hay pedidos entregados',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppConstants.backgroundCard,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppConstants.backgroundDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.local_fire_department,
                    size: 48, color: AppConstants.primaryGold),
                const SizedBox(height: 8),
                const Text(
                  'FireShots Staff',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Ventas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sales');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Órdenes (KDS)'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Guardarropa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cloakroom-form');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Deudas Externas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/external-debt-form');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_outlined),
            title: const Text('Atención al Cliente'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/customer-support');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
    );
  }
}

class _KDSOrdersList extends ConsumerWidget {
  final AsyncValue<List<OrderModel>> pendingAsync;
  final AsyncValue<List<OrderModel>> acknowledgedAsync;

  const _KDSOrdersList({
    required this.pendingAsync,
    required this.acknowledgedAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = pendingAsync.asData?.value ?? [];
    final acknowledged = acknowledgedAsync.asData?.value ?? [];
    final all = [...pending, ...acknowledged];

    if (all.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppConstants.textGray),
            SizedBox(height: 16),
            Text('No hay pedidos pendientes',
                style: TextStyle(color: AppConstants.textGray)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: all.length,
      itemBuilder: (context, index) =>
          _OrderCard(order: all[index], status: all[index].status),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final AsyncValue<List<OrderModel>> ordersAsync;
  final String status;
  final String emptyMessage;

  const _OrdersList({
    required this.ordersAsync,
    required this.status,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 64, color: AppConstants.textGray),
                const SizedBox(height: 16),
                Text(emptyMessage,
                    style: const TextStyle(color: AppConstants.textGray)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: orders.length,
          itemBuilder: (context, index) =>
              _OrderCard(order: orders[index], status: status),
        );
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final String status;

  const _OrderCard({required this.order, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_restaurant,
                        color: AppConstants.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Mesa ${order.tableNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormat.format(order.createdAt),
                  style: const TextStyle(color: AppConstants.textGray),
                ),
              ],
            ),
            if (order.customerName != null) ...[
              const SizedBox(height: 4),
              Text('Cliente: ${order.customerName}',
                  style: const TextStyle(color: AppConstants.textGray)),
            ],
            const Divider(),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.name}'),
                      Text(
                        AppConstants.formatCurrency(item.price * item.quantity),
                        style: const TextStyle(color: AppConstants.primaryGold),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 12),
            if (status == 'pending' || status == 'acknowledged')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(ordersServiceProvider)
                        .updateOrderStatus(order.id, 'delivered');
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('ENTREGAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            if (status == 'delivered')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context, ref, order),
                  icon: const Icon(Icons.payments),
                  label: const Text('COBRAR'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, OrderModel order) {
    String selectedMethod = 'Efectivo';
    String? servedBy;
    List<String> staffList = [];

    ref.read(systemSettingsServiceProvider).getAllSettings().then((settings) {
      final names = settings['staffNames'] as List<dynamic>?;
      if (names != null && names.isNotEmpty) {
        staffList = names.cast<String>();
      } else {
        staffList = List.from(AppConstants.staffNames);
      }
    });

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppConstants.backgroundCard,
          title: const Text('Registrar Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedMethod,
                decoration: const InputDecoration(labelText: 'Método de Pago'),
                items: AppConstants.paymentMethods.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (v) => setDialogState(() => selectedMethod = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                hint: const Text('Atendido por (opcional)'),
                decoration: const InputDecoration(labelText: 'Atendido por'),
                items: [
                  ...staffList.map((n) =>
                      DropdownMenuItem(value: n, child: Text(n))),
                  const DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) => setDialogState(() => servedBy = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(ordersServiceProvider).updateOrderStatus(
                      order.id,
                      'paid',
                    );
                if (servedBy != null) {
                  await ref.read(ordersServiceProvider).updateOrderPayment(
                        order.id,
                        selectedMethod,
                        servedBy,
                      );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('CONFIRMAR PAGO'),
            ),
          ],
        ),
      ),
    );
  }
}
