import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/menu/providers/menu_provider.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, '/admin-product-form'),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 64, color: AppConstants.textGray),
                  SizedBox(height: 16),
                  Text('No hay productos',
                      style: TextStyle(color: AppConstants.textGray)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppConstants.primaryGold.withAlpha(51),
                    child: Text(
                      AppConstants.formatCurrency(product.price),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppConstants.primaryGold,
                      ),
                    ),
                  ),
                  title: Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${product.category} | Stock: ${product.stock}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: product.isAvailable,
                        activeTrackColor: Colors.green.withAlpha(77),
                        activeThumbColor: Colors.green,
                        onChanged: (v) {
                          ref
                              .read(menuServiceProvider)
                              .updateProduct(product.copyWith(isAvailable: v));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppConstants.primaryGold),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/admin-product-form',
                          arguments: product,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor:
                                  AppConstants.backgroundCard,
                              title: const Text('Eliminar producto'),
                              content: Text(
                                  '¿Eliminar ${product.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('ELIMINAR'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            ref
                                .read(menuServiceProvider)
                                .deleteProduct(product.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
