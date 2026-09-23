import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireshots_pos/features/orders/providers/external_debt_provider.dart';
import 'package:fireshots_pos/core/constants/app_constants.dart';
import 'package:fireshots_pos/features/orders/data/external_debt_model.dart';
import 'package:intl/intl.dart';

class ExternalDebtListScreen extends ConsumerStatefulWidget {
  const ExternalDebtListScreen({super.key});

  @override
  ConsumerState<ExternalDebtListScreen> createState() =>
      _ExternalDebtListScreenState();
}

class _ExternalDebtListScreenState
    extends ConsumerState<ExternalDebtListScreen> {
  DateTime? _selectedDate;
  String _statusFilter = 'all';
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(allDebtsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas Externas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, '/external-debt-form'),
          ),
        ],
      ),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (debts) {
          final filtered = _filterDebts(debts);

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_outlined,
                                size: 64, color: AppConstants.textGray),
                            const SizedBox(height: 16),
                            const Text('No hay deudas',
                                style: TextStyle(
                                    color: AppConstants.textGray)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _DebtCard(
                            debt: filtered[index],
                            dateFormat: _dateFormat,
                            timeFormat: _timeFormat,
                            onMarkSettled: () => ref
                                .read(externalDebtServiceProvider)
                                .markAsSettled(filtered[index].id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: AppConstants.backgroundCard,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedDate != null
                        ? _dateFormat.format(_selectedDate!)
                        : 'Todas las fechas',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _filterLast10Hours,
                  icon: const Icon(Icons.access_time, size: 16),
                  label: const Text('Últimas 10 h',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statusChip('Todas', 'all'),
              const SizedBox(width: 8),
              _statusChip('Pendientes', 'pending'),
              const SizedBox(width: 8),
              _statusChip('Pagadas', 'settled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'settled'
                      ? Colors.green
                      : value == 'pending'
                          ? Colors.red
                          : AppConstants.primaryGold)
                  .withAlpha(51)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (value == 'settled'
                        ? Colors.green
                        : value == 'pending'
                            ? Colors.red
                            : AppConstants.primaryGold)
                    .withAlpha(153)
                : Colors.grey.withAlpha(77),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? (value == 'settled'
                        ? Colors.green
                        : value == 'pending'
                            ? Colors.red
                            : AppConstants.primaryGold)
                : AppConstants.textGray,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _filterLast10Hours() {
    setState(() {
      _selectedDate = null;
      final now = DateTime.now();
      _selectedDate = now.subtract(const Duration(hours: 10));
    });
  }

  List<ExternalDebt> _filterDebts(List<ExternalDebt> debts) {
    var filtered = debts;

    if (_statusFilter == 'pending') {
      filtered = filtered.where((d) => !d.isSettled).toList();
    } else if (_statusFilter == 'settled') {
      filtered = filtered.where((d) => d.isSettled).toList();
    }

    if (_selectedDate != null) {
      filtered = filtered.where((d) {
        final debtDate = DateTime(d.date.year, d.date.month, d.date.day);
        if (d.date.isAfter(DateTime.now().subtract(const Duration(hours: 10))) &&
            _selectedDate!
                .isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
          return d.date
              .isAfter(DateTime.now().subtract(const Duration(hours: 10)));
        }
        return debtDate == _selectedDate;
      }).toList();
    }

    return filtered;
  }
}

class _DebtCard extends StatelessWidget {
  final ExternalDebt debt;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final VoidCallback onMarkSettled;

  const _DebtCard({
    required this.debt,
    required this.dateFormat,
    required this.timeFormat,
    required this.onMarkSettled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: debt.isSettled
          ? Colors.green.withAlpha(13)
          : AppConstants.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: debt.isSettled
              ? Colors.green.withAlpha(77)
              : Colors.red.withAlpha(77),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: debt.isSettled
                          ? Colors.green.withAlpha(26)
                          : Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      debt.isSettled ? 'PAGADA' : 'PENDIENTE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            debt.isSettled ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  Text(
                    AppConstants.formatCurrency(debt.amount),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: debt.isSettled
                          ? Colors.green
                          : AppConstants.primaryGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                debt.source,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppConstants.textWhite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                debt.description,
                style: const TextStyle(
                  color: AppConstants.textGray,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 12, color: AppConstants.textGray),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(debt.date)} ${timeFormat.format(debt.date)}',
                    style: const TextStyle(
                      color: AppConstants.textGray,
                      fontSize: 11,
                    ),
                  ),
                  if (debt.createdBy != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.person_outline,
                        size: 12, color: AppConstants.textGray),
                    const SizedBox(width: 4),
                    Text(
                      debt.createdBy!,
                      style: const TextStyle(
                        color: AppConstants.textGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              if (!debt.isSettled) ...[
                const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onMarkSettled,
                      icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('MARCAR COMO PAGADA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.backgroundCard,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: debt.isSettled
                    ? Colors.green.withAlpha(26)
                    : Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                debt.isSettled ? 'PAGADA' : 'PENDIENTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: debt.isSettled ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Origen: ${debt.source}',
                  style: const TextStyle(color: AppConstants.textWhite)),
              const SizedBox(height: 12),
              Text('Descripción:',
                  style: const TextStyle(color: AppConstants.textGray)),
              const SizedBox(height: 4),
              Text(debt.description,
                  style: const TextStyle(color: AppConstants.textWhite)),
              const SizedBox(height: 12),
              Text(
                'Valor: ${AppConstants.formatCurrency(debt.amount)}',
                style: const TextStyle(
                  color: AppConstants.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Fecha: ${dateFormat.format(debt.date)} ${timeFormat.format(debt.date)}',
                style: const TextStyle(color: AppConstants.textGray)),
              if (debt.createdBy != null) ...[
                const SizedBox(height: 4),
                Text('Registró: ${debt.createdBy}',
                    style: const TextStyle(color: AppConstants.textGray)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
