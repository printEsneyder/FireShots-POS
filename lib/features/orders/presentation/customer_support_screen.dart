import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/providers/system_settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSupportScreen extends ConsumerStatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  ConsumerState<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends ConsumerState<CustomerSupportScreen> {
  String _phone1 = AppConstants.phone1;
  String _instagramUrl = AppConstants.instagramUrl;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ref.read(systemSettingsServiceProvider).getAllSettings();
      if (mounted) {
        setState(() {
          _phone1 = settings['phone1'] as String? ?? AppConstants.phone1;
          _instagramUrl = settings['instagramUrl'] as String? ?? AppConstants.instagramUrl;
        });
      }
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'logos/logo_fireshots.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_fire_department,
                color: AppConstants.primaryGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Atención al Cliente',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Image.asset(
            'logos/logo_fireshots.png',
            height: 60,
            errorBuilder: (_, __, ___) => Icon(
              Icons.local_fire_department,
              size: 48,
              color: AppConstants.primaryGold,
            ),
          ),
          const SizedBox(height: 24),
          _SupportCard(
            icon: Icons.calendar_today,
            title: 'Reservas',
            subtitle: 'Reserva tu mesa vía WhatsApp',
            onTap: () => _openWhatsApp(context),
          ),
          const SizedBox(height: 16),
          _SupportCard(
            icon: Icons.phone,
            title: 'Teléfono',
            subtitle: _phone1,
            onTap: () => launchUrl(Uri.parse('tel:$_phone1'),
                mode: LaunchMode.externalApplication),
          ),
          const SizedBox(height: 16),
          _SupportCard(
            icon: Icons.feedback_outlined,
            title: 'PQRS',
            subtitle: 'Peticiones, quejas, reclamos o sugerencias',
            onTap: () => _showPqrsForm(context),
          ),
          const SizedBox(height: 16),
          _SupportCard(
            icon: Icons.camera_alt_outlined,
            title: 'Instagram',
            subtitle: '@fireshotspasto',
            onTap: () => _openInstagram(context),
          ),
          const SizedBox(height: 24),
          Image.asset(
            'logos/logo_plaza_norte.png',
            height: 40,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Plaza Norte',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textGray,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppConstants.textGray),
          const SizedBox(height: 16),
          const Text(
            '© 2026 Fire Shots. Todos los derechos reservados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.textGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'El mejor lugar para vivirse la noche en grande',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.textGray,
            ),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp(BuildContext context) {
    final message = Uri.encodeComponent(AppConstants.whatsappMessage);
    final uri = Uri.parse(
        'https://wa.me/57$_phone1?text=$message');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openInstagram(BuildContext context) {
    launchUrl(Uri.parse(_instagramUrl),
        mode: LaunchMode.externalApplication);
  }

  void _showPqrsForm(BuildContext context) {
    final messageController = TextEditingController();
    String selectedType = 'Petición';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppConstants.backgroundCard,
          title: const Text('PQRS'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: ['Petición', 'Queja', 'Reclamo', 'Sugerencia']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu PQRS a continuación',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final subject = Uri.encodeComponent(
                    'PQRS FireShots - $selectedType');
                final body = Uri.encodeComponent(
                  'Tipo: $selectedType\n\n'
                  '${messageController.text}',
                );
                launchUrl(
                  Uri.parse(
                      'mailto:pqrsibarra@gmail.com?subject=$subject&body=$body'),
                  mode: LaunchMode.externalApplication,
                );
                Navigator.pop(ctx);
              },
              child: const Text('ENVIAR'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryGold.withAlpha(51),
          child: Icon(icon, color: AppConstants.primaryGold),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
