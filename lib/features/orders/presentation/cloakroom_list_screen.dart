import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/cloakroom/providers/cloakroom_provider.dart';
import 'package:intl/intl.dart';

class CloakroomListScreen extends ConsumerWidget {
  const CloakroomListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(activeCloakroomItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardarropa Activo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, '/cloakroom-form'),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: AppConstants.textGray),
                  SizedBox(height: 16),
                  Text('No hay artículos en guardarropa',
                      style: TextStyle(color: AppConstants.textGray)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final dateFormat = DateFormat('HH:mm');
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.primaryGold.withAlpha(51),
                    child: Text(
                      '#${item.ticketNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGold,
                      ),
                    ),
                  ),
                  title: Text(item.customerName),
                  subtitle: Text(
                    '${item.itemType} - ${dateFormat.format(item.createdAt)}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(cloakroomServiceProvider)
                          .markAsReturned(item.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('ENTREGADO'),
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
