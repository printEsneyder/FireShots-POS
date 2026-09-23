import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/menu/providers/menu_provider.dart';
import 'package:fireshots_pos/features/orders/providers/orders_provider.dart';
import 'package:fireshots_pos/features/orders/data/order_model.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _tableController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tableController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final tableText = _tableController.text.trim();
    if (tableText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el número de mesa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tableNumber = int.tryParse(tableText) ?? 0;
    if (tableNumber <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Número de mesa inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ordersService = ref.read(ordersServiceProvider);

      final isActive = await ordersService.isTableActive(tableNumber);
      if (isActive) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La mesa #$tableNumber ya tiene un pedido activo'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final cart = ref.read(cartProvider);

      final items = cart.entries.map((e) {
        final item = e.value;
        return OrderItem(
          productId: item.product.id,
          name: item.product.name,
          price: item.product.price,
          quantity: item.quantity,
        );
      }).toList();

      final totalAmount = ref.read(cartProvider.notifier).totalAmount;

      final order = OrderModel(
        id: '',
        customerName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        tableNumber: tableNumber,
        items: items,
        totalAmount: totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ordersService.createOrder(order);
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        _showPaymentInfo(totalAmount, order.tableNumber);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPaymentInfo(double totalAmount, int tableNumber) async {
    final settings = await ref
        .read(systemSettingsServiceProvider)
        .getAllSettings();
    final nequiNumber = settings['nequiNumber'] as String? ?? AppConstants.nequiNumber;
    final nequiName = settings['nequiName'] as String? ?? AppConstants.nequiName;
    final brebNumber = settings['brebNumber'] as String? ?? AppConstants.brebNumber;
    final brebName = settings['brebName'] as String? ?? AppConstants.brebName;
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              'Pedido enviado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mesa #$tableNumber',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textGray,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total a pagar: ${AppConstants.formatCurrency(totalAmount)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGold,
              ),
            ),
            const SizedBox(height: 24),
            _buildPaymentOption(
              icon: Icons.qr_code,
              title: 'Paga con Nequi',
              number: nequiNumber,
              name: nequiName,
              imageAsset: 'qr/qr_nequi.png',
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              icon: Icons.qr_code,
              title: 'Paga con Bre-B',
              number: brebNumber,
              name: brebName,
              imageAsset: 'qr/qr_breb.png',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryGold.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppConstants.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verifica el nombre y número antes de pagar',
                      style: TextStyle(
                        color: AppConstants.primaryGold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil('/customer-menu', (r) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'VOLVER AL MENÚ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String number,
    required String name,
    String? subtitle,
    required String imageAsset,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.textGray.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.backgroundCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConstants.textGray.withAlpha(51)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  icon,
                  size: 40,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppConstants.textWhite,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryGold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppConstants.textGray,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.textGray,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final total = cartNotifier.totalAmount;

    return Scaffold(
      backgroundColor: AppConstants.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundCard,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Confirmar Pedido',
          style: TextStyle(color: AppConstants.textWhite),
        ),
        iconTheme: const IconThemeData(color: AppConstants.textWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: AppConstants.backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del pedido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textWhite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...cart.entries.map((entry) {
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.product.name}',
                                style: const TextStyle(
                                  color: AppConstants.textWhite,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              AppConstants.formatCurrency(
                                  item.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryGold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20, color: AppConstants.textGray),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textWhite,
                          ),
                        ),
                        Text(
                          AppConstants.formatCurrency(total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Número de mesa',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tableController,
              decoration: InputDecoration(
                hintText: 'Ej: 1, 2, 3...',
                prefixIcon: const Icon(Icons.table_restaurant),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Tu nombre (opcional)',
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'ENVIAR PEDIDO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
