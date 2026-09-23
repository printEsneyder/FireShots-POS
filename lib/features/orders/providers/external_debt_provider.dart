import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/features/orders/data/external_debt_service.dart';
import 'package:fireshots_pos/features/orders/data/external_debt_model.dart';

final externalDebtServiceProvider = Provider<ExternalDebtService>((ref) {
  return ExternalDebtService();
});

final allDebtsStreamProvider = StreamProvider<List<ExternalDebt>>((ref) {
  return ref.watch(externalDebtServiceProvider).getDebts();
});

final pendingDebtsStreamProvider = StreamProvider<List<ExternalDebt>>((ref) {
  return ref.watch(externalDebtServiceProvider).getDebtsByStatus(false);
});
