import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/features/menu/data/menu_service.dart';
import 'package:fireshots_pos/features/menu/data/product_model.dart';

final menuServiceProvider = Provider<MenuService>((ref) {
  return MenuService();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(menuServiceProvider).getProducts();
});

final availableProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(menuServiceProvider).getAvailableProducts();
});

final cartProvider = NotifierProvider<CartNotifier, Map<String, CartItem>>(
  CartNotifier.new,
);

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartNotifier extends Notifier<Map<String, CartItem>> {
  @override
  Map<String, CartItem> build() => {};

  void addItem(Product product) {
    if (state.containsKey(product.id)) {
      state = {
        ...state,
        product.id: CartItem(
          product: product,
          quantity: state[product.id]!.quantity + 1,
        ),
      };
    } else {
      state = {...state, product.id: CartItem(product: product)};
    }
  }

  void removeItem(String productId) {
    if (state.containsKey(productId)) {
      if (state[productId]!.quantity > 1) {
        state = {
          ...state,
          productId: CartItem(
            product: state[productId]!.product,
            quantity: state[productId]!.quantity - 1,
          ),
        };
      } else {
        final newState = Map<String, CartItem>.from(state);
        newState.remove(productId);
        state = newState;
      }
    }
  }

  void clearCart() {
    state = {};
  }

  int get itemCount =>
      state.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      state.values.fold(0.0, (sum, item) => sum + item.subtotal);
}
