import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/laundry_form_model.dart';
import '../screens/report_detail_screen.dart';

class ReportCard extends StatelessWidget {
  final LaundryForm form;

  const ReportCard({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(form: form),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      form.company?.name ?? 'Unknown Client',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(status: form.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM, yyyy', 'en').format(form.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${form.sections.length} Sections',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoItem('Pockets', '${form.pocketCount}'),
                  _infoItem('Bags (S)', '${form.plasticBagsSmall}'),
                  _infoItem('Bags (L)', '${form.plasticBagsLarge}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final FormStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case FormStatus.APPROVED:
        color = Colors.green;
        label = 'APPROVED';
        break;
      case FormStatus.PENDING_APPROVAL:
        color = Colors.orange;
        label = 'PENDING';
        break;
      default:
        color = Colors.grey;
        label = 'DRAFT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
