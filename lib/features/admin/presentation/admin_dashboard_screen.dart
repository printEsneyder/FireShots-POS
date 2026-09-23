import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/providers/orders_provider.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';
import 'package:fireshots_pos/features/cloakroom/providers/cloakroom_provider.dart';

String _extractNameFromEmail(String email) {
  final atIndex = email.indexOf('@');
  if (atIndex <= 0) return email;
  final local = email.substring(0, atIndex);
  final parts = local.split(RegExp(r'[._\-0-9]'));
  for (final part in parts) {
    if (part.length >= 3) {
      return part[0].toUpperCase() + part.substring(1);
    }
  }
  return local;
}

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBarOpenAsync = ref.watch(isBarOpenStreamProvider);
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'admin@fireshots.com';
    final displayName = _extractNameFromEmail(email);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'logos/logo_fireshots.png',
              height: 28,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            const Text('Admin Panel'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppConstants.backgroundCard,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppConstants.primaryGold,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppConstants.textWhite,
                ),
              ),
              subtitle: Text(
                email,
                style: const TextStyle(
                  color: AppConstants.textGray,
                  fontSize: 13,
                ),
              ),
              trailing: Icon(Icons.verified, color: AppConstants.primaryGold),
            ),
          ),
          const SizedBox(height: 16),
          isBarOpenAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (isOpen) => Card(
              color: isOpen ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
              child: ListTile(
                leading: Icon(
                  isOpen ? Icons.check_circle : Icons.cancel,
                  color: isOpen ? Colors.green : Colors.red,
                  size: 32,
                ),
                title: Text(
                  isOpen ? 'Sistema Activo' : 'Sistema Apagado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOpen ? Colors.green : Colors.red,
                  ),
                ),
                trailing: Switch(
                  value: isOpen,
                  activeTrackColor: Colors.green.withAlpha(77),
                  activeThumbColor: Colors.green,
                  onChanged: (value) async {
                    await ref
                        .read(systemSettingsServiceProvider)
                        .setBarOpen(value);
                    if (!value) {
                      await ref
                          .read(cloakroomServiceProvider)
                          .deleteAllItems();
                    }
                  },
                ),
              ),
            ),
          ),
          _buildSalesSummary(ref, context),
          const SizedBox(height: 16),
          _MenuCard(
            icon: Icons.receipt_long,
            title: 'Ventas',
            subtitle: 'Pedidos en tiempo real',
            onTap: () =>
                Navigator.pushNamed(context, '/sales'),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.restaurant_menu,
            title: 'Productos',
            subtitle: 'CRUD del menú',
            onTap: () => Navigator.pushNamed(context, '/admin-products'),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.account_balance,
            title: 'Deudas Externas',
            subtitle: 'Gestionar deudas con distribuidores',
            onTap: () =>
                Navigator.pushNamed(context, '/admin-debts'),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.bar_chart,
            title: 'Reportes',
            subtitle: 'Ventas y estadísticas',
            onTap: () =>
                Navigator.pushNamed(context, '/admin-reports'),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.inventory_2,
            title: 'Guardarropa',
            subtitle: 'Ver artículos guardados',
            onTap: () =>
                Navigator.pushNamed(context, '/cloakroom-list'),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.support_agent,
            title: 'Atención al Cliente',
            subtitle: 'Reservas, PQRS, Redes Sociales',
            onTap: () =>
                Navigator.pushNamed(context, '/customer-support'),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.settings,
            title: 'Configuración',
            subtitle: 'Pagos, teléfonos, meseros',
            onTap: () =>
                Navigator.pushNamed(context, '/admin-settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummary(WidgetRef ref, BuildContext context) {
    final paidAsync = ref.watch(paidOrdersStreamProvider);
    final pendingAsync = ref.watch(pendingOrdersStreamProvider);

    return paidAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (paid) {
        final pending = pendingAsync.asData?.value ?? [];
        final todayPaid = paid.where((o) {
          final now = DateTime.now();
          return o.createdAt.year == now.year &&
              o.createdAt.month == now.month &&
              o.createdAt.day == now.day;
        }).toList();
        final todayRevenue = todayPaid.fold(0.0, (s, o) => s + o.totalAmount);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt,
                    value: '${pending.length}',
                    label: 'Pendientes',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money,
                    value: AppConstants.formatCurrency(todayRevenue),
                    label: 'Hoy',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    value: '${todayPaid.length}',
                    label: 'Pagadas',
                    color: AppConstants.primaryGold,
                  ),
                ),
              ],
            ),
            if (pending.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Card(
                  color: Colors.orange.withAlpha(26),
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber, color: Colors.orange),
                    title: Text(
                      '${pending.length} pedido(s) pendiente(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/staff-dashboard'),
                      child: const Text('VER'),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConstants.backgroundCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppConstants.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryGold.withAlpha(51),
          child: Icon(icon, color: AppConstants.primaryGold),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
