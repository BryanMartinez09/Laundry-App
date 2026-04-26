import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forms_provider.dart';
import '../widgets/report_card.dart';

class ReportsHistoryScreen extends StatefulWidget {
  const ReportsHistoryScreen({super.key});

  @override
  State<ReportsHistoryScreen> createState() => _ReportsHistoryScreenState();
}

class _ReportsHistoryScreenState extends State<ReportsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormsProvider>().fetchRecentForms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formsProvider = context.watch<FormsProvider>();

    return RefreshIndicator(
      onRefresh: () => formsProvider.fetchRecentForms(),
      child: _buildBody(formsProvider),
    );
  }

  Widget _buildBody(FormsProvider provider) {
    if (provider.isLoading && provider.recentForms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.recentForms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No reports registered yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.recentForms.length,
      itemBuilder: (context, index) {
        final form = provider.recentForms[index];
        return ReportCard(form: form);
      },
    );
  }
}
