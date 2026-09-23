import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/data/system_settings_service.dart';

final systemSettingsServiceProvider = Provider<SystemSettingsService>((ref) {
  return SystemSettingsService();
});

final isBarOpenStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(systemSettingsServiceProvider).isBarOpenStream;
});

final staffNamesProvider = FutureProvider<List<String>>((ref) async {
  final settings = await ref.read(systemSettingsServiceProvider).getAllSettings();
  final names = settings['staffNames'] as List<dynamic>?;
  if (names != null && names.isNotEmpty) {
    return names.cast<String>();
  }
  return List.from(AppConstants.staffNames);
});
