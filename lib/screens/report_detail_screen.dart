import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/laundry_form_model.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/forms_provider.dart';
import 'new_form_wizard.dart';

class ReportDetailScreen extends StatefulWidget {
  final LaundryForm form;

  const ReportDetailScreen({super.key, required this.form});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _isApproving = false;
  bool _isDeleting = false;
  late LaundryForm _currentForm;

  @override
  void initState() {
    super.initState();
    _currentForm = widget.form;
  }

  String _translateSection(String section) {
    return section.toUpperCase();
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
          'This report will be deleted and hidden from listings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      final success = await context.read<FormsProvider>().deleteForm(_currentForm.id!);
      if (mounted) {
        setState(() => _isDeleting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted successfully.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete report.')),
          );
        }
      }
    }
  }

  Future<void> _handleApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Report'),
        content: const Text('Are you sure you want to mark this report as APPROVED? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Approve')),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isApproving = true);
      final success = await context.read<FormsProvider>().approveForm(_currentForm.id!);
      if (mounted) {
        setState(() => _isApproving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report approved successfully!')));
          // Para actualizar el estado visualmente, recargamos la info si es necesario o cerramos
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to approve report.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final bool canDelete = (user?.hasPermission('Forms', 'Delete') ?? false) &&
        _currentForm.status != FormStatus.APPROVED;
    final bool canEdit = (user?.hasPermission('Forms', 'Edit') ?? false) &&
        _currentForm.status != FormStatus.APPROVED;
    final bool canApprove = (user?.hasPermission('Forms', 'Approve') ?? false) && 
        _currentForm.status == FormStatus.PENDING_APPROVAL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewFormWizard(existingForm: _currentForm),
                  ),
                );
              },
            ),
        ],
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
            const Text('SECTION BREAKDOWN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            ..._currentForm.sections.map((section) => _buildSectionDetail(section)),
            if (_currentForm.notes != null && _currentForm.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('ADDITIONAL NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_currentForm.notes!, style: const TextStyle(height: 1.5)),
              ),
            ],
            const SizedBox(height: 20),
            if (canApprove)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isApproving ? null : _handleApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isApproving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                  label: Text(_isApproving ? 'Approving...' : 'Approve Report'),
                ),
              ),
            if (canDelete) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _isDeleting ? null : _handleDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isDeleting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                    : const Icon(Icons.delete_outline),
                  label: Text(_isDeleting ? 'Deleting...' : 'Delete Report'),
                ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _currentForm.company?.name ?? 'Unknown Client',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
            _buildStatusBadge(_currentForm.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Logged on ${DateFormat('dd MMMM, yyyy', 'en').format(_currentForm.date)}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(FormStatus status) {
    Color color;
    String label;
    switch (status) {
      case FormStatus.APPROVED: color = Colors.green; label = 'APPROVED'; break;
      case FormStatus.PENDING_APPROVAL: color = Colors.orange; label = 'PENDING'; break;
      default: color = Colors.grey; label = 'DRAFT';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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
      child: Column(
        children: [
          const Text('PACKAGING & HAND-FINISH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(label: 'Pockets', value: '${_currentForm.pocketCount}', icon: Icons.work_outline),
              _SummaryItem(label: 'Bags (S)', value: '${_currentForm.plasticBagsSmall}', icon: Icons.shopping_bag_outlined),
              _SummaryItem(label: 'Bags (L)', value: '${_currentForm.plasticBagsLarge}', icon: Icons.shopping_bag),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryItem(label: 'H-Finished Pillowcases', value: '${_currentForm.totalTaiesMain}', icon: Icons.cleaning_services_outlined),
              _SummaryItem(label: 'H-Finished Sheets', value: '${_currentForm.totalDrapsMain}', icon: Icons.straighten_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDetail(FormSectionModel section) {
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
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_translateSection(section.sectionName), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                Text('Filled by: ${section.filledByInitials}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                      Expanded(child: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w500))),
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
        color: value > 0 ? color.withOpacity(0.1) : Colors.grey[100],
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
