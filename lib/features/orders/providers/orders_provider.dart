import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/features/orders/data/orders_service.dart';
import 'package:fireshots_pos/features/orders/data/order_model.dart';

final ordersServiceProvider = Provider<OrdersService>((ref) {
  return OrdersService();
});

final pendingOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(ordersServiceProvider).getOrdersByStatus('pending');
});

final acknowledgedOrdersStreamProvider =
    StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(ordersServiceProvider).getOrdersByStatus('acknowledged');
});

final deliveredOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(ordersServiceProvider).getOrdersByStatus('delivered');
});

final activeOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(ordersServiceProvider).getActiveOrders();
});

final allOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(ordersServiceProvider).getAllOrders();
});

final paidOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(ordersServiceProvider).getOrdersByStatus('paid');
});
