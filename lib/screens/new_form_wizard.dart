import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laundry_app/models/company_model.dart';
import 'package:laundry_app/models/laundry_form_model.dart';
import 'package:laundry_app/providers/company_provider.dart';
import 'package:laundry_app/providers/forms_provider.dart';
import 'package:laundry_app/providers/auth_provider.dart';
import 'package:laundry_app/providers/catalog_provider.dart';
import 'package:laundry_app/models/catalog_item_model.dart';
import 'package:laundry_app/core/theme/app_theme.dart';
import 'package:laundry_app/widgets/laundry_item_counter.dart';

class NewFormWizard extends StatefulWidget {
  const NewFormWizard({super.key});

  @override
  State<NewFormWizard> createState() => _NewFormWizardState();
}

class _NewFormWizardState extends State<NewFormWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  Company? _selectedCompany;
  int _pocketCount = 0;
  int _plasticBagsSmall = 0;
  int _plasticBagsLarge = 0;
  String? _notes;

  // Counts state: { 'ItemName': { 'std': 0, 'clr': 0 } }
  Map<String, Map<String, int>> _counts = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCatalog();
    });
  }

  Future<void> _loadCatalog() async {
    final catalog = context.read<CatalogProvider>();
    await catalog.fetchCatalog();
    
    final Map<String, Map<String, int>> initialCounts = {};
    for (var item in catalog.items) {
      initialCounts[item.name] = {'std': 0, 'clr': 0};
    }
    
    if (mounted) {
      setState(() {
        _counts = initialCounts;
        _initialized = true;
      });
    }
  }

  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nuevo Registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Paso ${_currentStep + 1} de 5', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
            color: AppTheme.primaryColor,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1Header(),
                _buildSectionStep('RATINE', catalog.getItemsByCategory('TOWELS')),
                _buildSectionStep('DRAPS (Sábanas)', catalog.getItemsByCategory('BED_SHEETS')),
                _buildSectionStep('LITERIE', catalog.getItemsByCategory('COVERS')),
                _buildStep5Summary(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStep1Header() {
    final companies = context.watch<CompanyProvider>().companies;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información General', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Selecciona el cliente y los detalles básicos del lote.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          const Text('CLIENTE / COMERCIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Company>(
            value: _selectedCompany,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.business_outlined)),
            hint: const Text('Seleccionar empresa'),
            items: companies.map((c) {
              return DropdownMenuItem(value: c, child: Text(c.name));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCompany = val),
          ),
          const SizedBox(height: 24),
          _buildCounterField(
            'BOLSILLOS (Pockets)',
            _pocketCount,
            (val) => setState(() => _pocketCount = val),
          ),
          const SizedBox(height: 24),
          const Text('BOLSAS DE PLÁSTICO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCounterField(
                  'PEQUEÑAS',
                  _plasticBagsSmall,
                  (val) => setState(() => _plasticBagsSmall = val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCounterField(
                  'GRANDES',
                  _plasticBagsLarge,
                  (val) => setState(() => _plasticBagsLarge = val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionStep(String sectionTitle, List<CatalogItemModel> catalogItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: catalogItems.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sectionTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Indica las cantidades contadas.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
            ],
          );
        }
        final item = catalogItems[index - 1];
        return LaundryItemCounter(
          name: item.name,
          standardCount: _counts[item.name]?['std'] ?? 0,
          colorCount: _counts[item.name]?['clr'] ?? 0,
          onStandardChanged: (val) => setState(() => _counts[item.name]!['std'] = val),
          onColorChanged: (val) => setState(() => _counts[item.name]!['clr'] = val),
        );
      },
    );
  }

  Widget _buildStep5Summary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen Final', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Revisa los datos antes de enviar.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Cliente'),
            subtitle: Text(_selectedCompany?.name ?? 'No seleccionado'),
            leading: const Icon(Icons.business_outlined),
          ),
          ListTile(
            title: const Text('Configuración'),
            subtitle: Text('Bolsillos: $_pocketCount | Bolsas (S): $_plasticBagsSmall | Bolsas (L): $_plasticBagsLarge'),
            leading: const Icon(Icons.settings_suggest_outlined),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('NOTAS ADICIONALES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          TextField(
            onChanged: (val) => _notes = val,
            decoration: const InputDecoration(hintText: 'Escribe algo aquí...'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCounterField(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: value > 0 ? () => onChanged(value - 1) : null),
              Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(value + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0)
              TextButton(
                onPressed: _previousPage,
                child: const Text('Anterior'),
              )
            else
              const SizedBox(width: 10),
            Consumer<FormsProvider>(
              builder: (context, forms, child) {
                return ElevatedButton(
                  onPressed: (_selectedCompany == null || forms.isLoading) 
                    ? null 
                    : (_currentStep < 4 ? _nextPage : _submitFullForm),
                  child: forms.isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(_currentStep < 4 ? 'Continuar' : 'Finalizar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitFullForm() async {
    final catalog = context.read<CatalogProvider>();
    
    List<FormSectionModel> sections = [
      _mapSection('TOWELS', catalog.getItemsByCategory('TOWELS')),
      _mapSection('BED_SHEETS', catalog.getItemsByCategory('BED_SHEETS')),
      _mapSection('COVERS', catalog.getItemsByCategory('COVERS')),
    ];

    final form = LaundryForm(
      companyId: _selectedCompany!.id,
      date: DateTime.now(),
      pocketCount: _pocketCount,
      plasticBagsSmall: _plasticBagsSmall,
      plasticBagsLarge: _plasticBagsLarge,
      notes: _notes,
      sections: sections,
    );

    final success = await context.read<FormsProvider>().submitForm(form);
    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reporte enviado con éxito!')),
      );
    }
  }

  FormSectionModel _mapSection(String sectionName, List<CatalogItemModel> catalogItems) {
    final userInitials = context.read<AuthProvider>().user?.initials ?? '??';

    return FormSectionModel(
      sectionName: sectionName,
      filledByInitials: userInitials,
      items: catalogItems.map((item) {
        return FormItemModel(
          category: item.name,
          isColored: false,
          quantity: _counts[item.name]?['std'] ?? 0,
        );
      }).toList() + catalogItems.map((item) {
        return FormItemModel(
          category: item.name,
          isColored: true,
          quantity: _counts[item.name]?['clr'] ?? 0,
        );
      }).toList(),
    );
  }
}
