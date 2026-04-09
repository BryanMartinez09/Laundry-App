import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/laundry_form_model.dart';
import '../core/theme/app_theme.dart';

class ReportDetailScreen extends StatelessWidget {
  final LaundryForm form;

  const ReportDetailScreen({super.key, required this.form});

  String _translateSection(String section) {
    return section.toUpperCase(); // Mantener en inglés original
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildGeneralInfo(),
            const SizedBox(height: 32),
            const Text('DESGLOSE POR SECCIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            ...form.sections.map((section) => _buildSectionDetail(section)),
            if (form.notes != null && form.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('NOTAS ADICIONALES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(form.notes!, style: const TextStyle(height: 1.5)),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          form.company?.name ?? 'Cliente Desconocido',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Registro del ${DateFormat('dd MMMM, yyyy', 'es').format(form.date)}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGeneralInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryItem(label: 'Bolsillos', value: '${form.pocketCount}', icon: Icons.work_outline),
          _SummaryItem(label: 'Bolsas (S)', value: '${form.plasticBagsSmall}', icon: Icons.shopping_bag_outlined),
          _SummaryItem(label: 'Bolsas (L)', value: '${form.plasticBagsLarge}', icon: Icons.shopping_bag),
        ],
      ),
    );
  }

  Widget _buildSectionDetail(FormSectionModel section) {
    // Agrupar items por categoría para mostrar Standard vs Color juntos
    final Map<String, Map<String, int>> grouped = {};
    for (var item in section.items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = {'std': 0, 'clr': 0};
      }
      if (item.isColored) {
        grouped[item.category]!['clr'] = item.quantity;
      } else {
        grouped[item.category]!['std'] = item.quantity;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_translateSection(section.sectionName), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                Text('Llenado por: ${section.filledByInitials}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: grouped.entries.map((entry) {
                final itemName = entry.key;
                final std = entry.value['std']!;
                final clr = entry.value['clr']!;
                
                if (std == 0 && clr == 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      _CountBadge(label: 'ST', value: std, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      _CountBadge(label: 'CL', value: clr, color: Colors.indigo),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: value > 0 ? color.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 9, color: value > 0 ? color : Colors.grey, fontWeight: FontWeight.bold)),
          Text('$value', style: TextStyle(fontSize: 12, color: value > 0 ? color : Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
