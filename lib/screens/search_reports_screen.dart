import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/forms_provider.dart';
import '../providers/company_provider.dart';
import '../models/company_model.dart';
import '../widgets/report_card.dart';
import '../core/theme/app_theme.dart';

class SearchReportsScreen extends StatefulWidget {
  const SearchReportsScreen({super.key});

  @override
  State<SearchReportsScreen> createState() => _SearchReportsScreenState();
}

class _SearchReportsScreenState extends State<SearchReportsScreen> {
  String? _selectedCompanyId;
  DateTimeRange? _dateRange;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProvider>().fetchCompanies();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _handleSearch() {
    final Map<String, dynamic> filters = {};
    if (_selectedCompanyId != null) filters['companyId'] = _selectedCompanyId;
    if (_dateRange != null) {
      filters['startDate'] = _dateRange!.start.toIso8601String();
      filters['endDate'] = _dateRange!.end.toIso8601String();
    }

    context.read<FormsProvider>().fetchRecentForms(filters: filters);
    setState(() {
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final formsProvider = context.watch<FormsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda Avanzada', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilterPanel(companyProvider),
          Expanded(child: _buildResultsList(formsProvider)),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(CompanyProvider companyProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Selector de Cliente
          DropdownButtonFormField<String>(
            value: _selectedCompanyId,
            decoration: InputDecoration(
              hintText: 'Seleccionar Cliente (Opcional)',
              prefixIcon: const Icon(Icons.business),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos los clientes')),
              ...companyProvider.companies.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              )),
            ],
            onChanged: (val) => setState(() => _selectedCompanyId = val),
          ),
          const SizedBox(height: 16),
          
          // Selector de Rango de Fechas
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateRange == null 
                        ? 'Cualquier fecha' 
                        : '${DateFormat('dd/MM/yy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yy').format(_dateRange!.end)}',
                      style: TextStyle(color: _dateRange == null ? Colors.grey[600] : Colors.black),
                    ),
                  ),
                  if (_dateRange != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _dateRange = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botón de Búsqueda
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('BUSCAR REPORTES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(FormsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[200]),
            const SizedBox(height: 16),
            const Text('Aplica filtros para buscar reportes', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (provider.recentForms.isEmpty) {
      return const Center(child: Text('No se encontraron resultados'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.recentForms.length,
      itemBuilder: (context, index) => ReportCard(form: provider.recentForms[index]),
    );
  }
}
