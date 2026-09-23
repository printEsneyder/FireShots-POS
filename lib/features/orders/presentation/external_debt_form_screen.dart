import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/providers/external_debt_provider.dart';
import 'package:fireshots_pos/features/orders/data/external_debt_model.dart';
import 'package:fireshots_pos/features/auth/providers/auth_provider.dart';

class ExternalDebtFormScreen extends ConsumerStatefulWidget {
  const ExternalDebtFormScreen({super.key});

  @override
  ConsumerState<ExternalDebtFormScreen> createState() =>
      _ExternalDebtFormScreenState();
}

class _ExternalDebtFormScreenState
    extends ConsumerState<ExternalDebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _otherSourceController = TextEditingController();
  String _selectedSource = 'Rey de los Licores';
  bool _showOtherSource = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _otherSourceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authServiceProvider).authStateChanges;
      String? createdBy;
      final snapshot = await user.first;
      if (snapshot != null) {
        createdBy = await ref
            .read(authServiceProvider)
            .getUserDisplayName(snapshot.uid);
      }

      final source = _showOtherSource
          ? _otherSourceController.text.trim()
          : _selectedSource;

      final debt = ExternalDebt(
        id: '',
        source: source,
        description: _descriptionController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()) ?? 0,
        date: DateTime.now(),
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      await ref.read(externalDebtServiceProvider).addDebt(debt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deuda registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Registrar Deuda Externa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva Deuda',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Origen',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
                items: [
                  ...AppConstants.debtSources.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedSource = v!;
                    _showOtherSource = v == 'Otro';
                  });
                },
              ),
              if (_showOtherSource) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otherSourceController,
                  decoration: const InputDecoration(
                    labelText: 'Especifica el origen',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (v) => _showOtherSource && (v?.isEmpty ?? true)
                      ? 'Especifica el origen'
                      : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Productos / Descripción',
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Ej: 5 Botellas de Aguardiente Nariño',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Ingresa el valor' : null,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        color: Colors.amber[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No olvides tomarle una foto a la factura',
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                      : const Text('REGISTRAR DEUDA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
