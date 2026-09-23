import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/cloakroom/data/cloakroom_model.dart';
import 'package:fireshots_pos/features/cloakroom/providers/cloakroom_provider.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';

class CloakroomFormScreen extends ConsumerStatefulWidget {
  const CloakroomFormScreen({super.key});

  @override
  ConsumerState<CloakroomFormScreen> createState() =>
      _CloakroomFormScreenState();
}

class _CloakroomFormScreenState extends ConsumerState<CloakroomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _observationsController = TextEditingController();
  String _selectedType = 'Chaqueta';
  String? _receivedBy;
  String? _otherType;
  String? _otherReceivedBy;
  bool _isLoading = false;
  bool _showOtherTypeField = false;
  bool _showOtherReceivedBy = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<int> _getNextTicketNumber() async {
    final items = await ref
        .read(cloakroomServiceProvider)
        .getActiveItems()
        .first;
    final usedNumbers = items
        .map((e) => int.tryParse(e.ticketNumber) ?? 0)
        .toList();
    for (int i = 1; i <= AppConstants.maxCloakroomTickets; i++) {
      if (!usedNumbers.contains(i)) return i;
    }
    return -1;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final ticketNum = await _getNextTicketNumber();
      if (ticketNum == -1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay tickets disponibles (máximo 15)'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final itemType = _showOtherTypeField && _otherType != null
          ? _otherType!
          : _selectedType;
      final receivedBy = _showOtherReceivedBy && _otherReceivedBy != null
          ? _otherReceivedBy!
          : (_receivedBy ?? 'Staff');

      final cloakItem = CloakroomItem(
        id: '',
        ticketNumber: ticketNum.toString().padLeft(3, '0'),
        itemType: itemType,
        customerName: _customerNameController.text.trim(),
        observations: _observationsController.text.trim(),
        receivedBy: receivedBy,
        createdAt: DateTime.now(),
      );

      final docId = await ref
          .read(cloakroomServiceProvider)
          .createItem(cloakItem);

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/cloakroom-receipt',
          arguments: cloakItem.copyWith(id: docId),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardarropa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Artículo',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Artículo',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.cloakroomItemTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedType = v!;
                    _showOtherTypeField = v == 'Otro';
                  });
                },
              ),
              if (_showOtherTypeField) ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Especifica el tipo',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  onChanged: (v) => _otherType = v,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Nombre obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Ej: Chaqueta gris con logos',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final staffAsync = ref.watch(staffNamesProvider);
                  return staffAsync.when(
                    loading: () => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Recibido por',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: const [],
                      onChanged: null,
                    ),
                    error: (_, __) => DropdownButtonFormField<String>(
                      initialValue: _receivedBy,
                      decoration: const InputDecoration(
                        labelText: 'Recibido por',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: [
                        const DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _receivedBy = v;
                          _showOtherReceivedBy = v == 'Otro';
                        });
                      },
                    ),
                    data: (staff) => DropdownButtonFormField<String>(
                      initialValue: _receivedBy,
                      hint: const Text('Quién recibe'),
                      decoration: const InputDecoration(
                        labelText: 'Recibido por',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: [
                        ...staff.map((n) =>
                            DropdownMenuItem(value: n, child: Text(n))),
                        const DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _receivedBy = v;
                          _showOtherReceivedBy = v == 'Otro';
                        });
                      },
                    ),
                  );
                },
              ),
              if (_showOtherReceivedBy) ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Especifica quién recibe',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  onChanged: (v) => _otherReceivedBy = v,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('GENERAR TICKET'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
