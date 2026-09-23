import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/cloakroom/data/cloakroom_model.dart';
import 'package:intl/intl.dart';

class CloakroomReceiptScreen extends ConsumerWidget {
  const CloakroomReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as CloakroomItem?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se encontró el ticket')),
      );
    }

    final dateFormat = DateFormat('HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket de Guardarropa'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppConstants.primaryGold,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2,
                        size: 64, color: AppConstants.primaryGold),
                    const SizedBox(height: 16),
                    Text(
                      'TICKET #${args.ticketNumber}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _infoRow('Cliente', args.customerName),
                    _infoRow('Artículo', args.itemType),
                    if (args.observations.isNotEmpty)
                      _infoRow('Observaciones', args.observations),
                    _infoRow('Recibido por', args.receivedBy),
                    _infoRow('Hora', dateFormat.format(args.createdAt)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Toma una foto de esta pantalla como comprobante',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppConstants.primaryGold,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamedAndRemoveUntil(context, '/staff-dashboard', (_) => false),
                    icon: const Icon(Icons.home),
                    label: const Text('VOLVER AL DASHBOARD'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamedAndRemoveUntil(context, '/cloakroom-form', (_) => false),
                    icon: const Icon(Icons.add),
                    label: const Text('NUEVO TICKET'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryGold,
                      side: const BorderSide(color: AppConstants.primaryGold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppConstants.textGray)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
