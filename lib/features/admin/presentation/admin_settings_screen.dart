import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _nequiNumberController = TextEditingController();
  final _nequiNameController = TextEditingController();
  final _brebNumberController = TextEditingController();
  final _brebNameController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _instagramUrlController = TextEditingController();
  final _waiterController = TextEditingController();
  List<String> _waiters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref
        .read(systemSettingsServiceProvider)
        .getAllSettings();
    setState(() {
      _nequiNumberController.text =
          settings['nequiNumber'] as String? ?? AppConstants.nequiNumber;
      _nequiNameController.text =
          settings['nequiName'] as String? ?? AppConstants.nequiName;
      _brebNumberController.text =
          settings['brebNumber'] as String? ?? AppConstants.brebNumber;
      _brebNameController.text =
          settings['brebName'] as String? ?? AppConstants.brebName;
      _phone1Controller.text =
          settings['phone1'] as String? ?? AppConstants.phone1;
      _phone2Controller.text =
          settings['phone2'] as String? ?? AppConstants.phone2;
      _instagramUrlController.text =
          settings['instagramUrl'] as String? ?? AppConstants.instagramUrl;
      _waiters = (settings['staffNames'] as List<dynamic>?)
              ?.cast<String>() ??
          List.from(AppConstants.staffNames);
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    await ref.read(systemSettingsServiceProvider).updateSettings({
      'nequiNumber': _nequiNumberController.text.trim(),
      'nequiName': _nequiNameController.text.trim(),
      'brebNumber': _brebNumberController.text.trim(),
      'brebName': _brebNameController.text.trim(),
      'phone1': _phone1Controller.text.trim(),
      'phone2': _phone2Controller.text.trim(),
      'instagramUrl': _instagramUrlController.text.trim(),
      'staffNames': _waiters,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addWaiter() {
    final name = _waiterController.text.trim();
    if (name.isNotEmpty && !_waiters.contains(name)) {
      setState(() {
        _waiters.add(name);
        _waiterController.clear();
      });
    }
  }

  void _removeWaiter(String name) {
    setState(() => _waiters.remove(name));
  }

  @override
  void dispose() {
    _nequiNumberController.dispose();
    _nequiNameController.dispose();
    _brebNumberController.dispose();
    _brebNameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _waiterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Métodos de Pago'),
            const SizedBox(height: 8),
            _buildNequiSection(),
            const SizedBox(height: 16),
            _buildBreBSection(),
            const SizedBox(height: 24),
            _sectionTitle('Contacto'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phone1Controller,
              decoration: const InputDecoration(
                labelText: 'Teléfono principal',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone2Controller,
              decoration: const InputDecoration(
                labelText: 'Teléfono secundario',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instagramUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de Instagram',
                prefixIcon: Icon(Icons.camera_alt),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Meseros'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _waiterController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del mesero',
                      prefixIcon: Icon(Icons.person_add),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addWaiter,
                  child: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _waiters.map((name) {
                return Chip(
                  label: Text(name),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeWaiter(name),
                  backgroundColor: AppConstants.primaryGold.withAlpha(51),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR CONFIGURACIÓN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGold,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNequiSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: AppConstants.primaryGold),
                const SizedBox(width: 8),
                const Text('Nequi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nequiNumberController,
              decoration: const InputDecoration(
                labelText: 'Número Nequi',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nequiNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del titular',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreBSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: AppConstants.primaryGold),
                const SizedBox(width: 8),
                const Text('Bre-B',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brebNumberController,
              decoration: const InputDecoration(
                labelText: 'Número Bre-B',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brebNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del titular',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
