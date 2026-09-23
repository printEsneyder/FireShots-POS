import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/features/cloakroom/data/cloakroom_service.dart';
import 'package:fireshots_pos/features/cloakroom/data/cloakroom_model.dart';

final cloakroomServiceProvider = Provider<CloakroomService>((ref) {
  return CloakroomService();
});

final activeCloakroomItemsProvider = StreamProvider<List<CloakroomItem>>((ref) {
  return ref.watch(cloakroomServiceProvider).getActiveItems();
});

final allCloakroomItemsProvider = StreamProvider<List<CloakroomItem>>((ref) {
  return ref.watch(cloakroomServiceProvider).getAllItems();
});
