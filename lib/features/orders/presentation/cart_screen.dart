import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/menu/providers/menu_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppConstants.backgroundDark,
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        backgroundColor: AppConstants.backgroundCard,
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: AppConstants.textGray),
                  SizedBox(height: 16),
                  Text('Carrito vacío',
                      style: TextStyle(color: AppConstants.textGray)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length + 1,
              itemBuilder: (context, index) {
                if (index == cart.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              AppConstants.formatCurrency(cartNotifier.totalAmount),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: AppConstants.primaryGold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                final entry = cart.entries.elementAt(index);
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppConstants.backgroundCard,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                            Text(
                              '${AppConstants.formatCurrency(item.product.price)} c/u',
                                style: const TextStyle(
                                  color: AppConstants.primaryGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cartNotifier.removeItem(
                                  item.product.id),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  cartNotifier.addItem(item.product),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            AppConstants.formatCurrency(item.subtotal),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.backgroundCard,
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          cartNotifier.clearCart();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('VACIAR'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/checkout'),
                        child: const Text('CONFIRMAR PEDIDO'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
