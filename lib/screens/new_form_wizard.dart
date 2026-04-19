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
  final LaundryForm? existingForm;
  const NewFormWizard({super.key, this.existingForm});

  @override
  State<NewFormWizard> createState() => _NewFormWizardState();
}

class _NewFormWizardState extends State<NewFormWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  Company? _selectedCompany;
  DateTime _selectedDate = DateTime.now();
  int _pocketCount = 0;
  int _plasticBagsSmall = 0;
  int _plasticBagsLarge = 0;
  int _totalTaiesMain = 0;
  int _totalDrapsMain = 0;
  String? _notes;

  // Counts state: { 'ItemName': { 'std': 0, 'clr': 0 } }
  Map<String, Map<String, int>> _counts = {};
  Map<String, String> _sectionInitials = {};
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
      final String myInitials = context.read<AuthProvider>().user?.initials ?? '??';
      
      // If editing, populate from existing form
      if (widget.existingForm != null) {
        final form = widget.existingForm!;
        for (var section in form.sections) {
          _sectionInitials[section.sectionName] = section.filledByInitials;
          for (var item in section.items) {
            initialCounts[item.category] ??= {'std': 0, 'clr': 0};
            if (item.isColored) {
              initialCounts[item.category]!['clr'] = item.quantity;
            } else {
              initialCounts[item.category]!['std'] = item.quantity;
            }
          }
        }
        
        setState(() {
          _counts = initialCounts;
          _selectedCompany = context.read<CompanyProvider>().companies.firstWhere((c) => c.id == form.company?.id);
          _selectedDate = form.date;
          _pocketCount = form.pocketCount;
          _plasticBagsSmall = form.plasticBagsSmall;
          _plasticBagsLarge = form.plasticBagsLarge;
          _totalTaiesMain = form.totalTaiesMain;
          _totalDrapsMain = form.totalDrapsMain;
          _notes = form.notes;
          _initialized = true;
        });
      } else {
        setState(() {
          _counts = initialCounts;
          _sectionInitials = {
            'TOWELS': myInitials,
            'BED_SHEETS': myInitials,
            'COVERS': myInitials,
          };
          _initialized = true;
        });
      }
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

  void _showFormSummaryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final Map<String, int> totals = {'std': 0, 'clr': 0};
        final List<Widget> itemDetails = [];
        
        _counts.forEach((name, counts) {
          final std = counts['std'] ?? 0;
          final clr = counts['clr'] ?? 0;
          if (std > 0 || clr > 0) {
            totals['std'] = totals['std']! + std;
            totals['clr'] = totals['clr']! + clr;
            itemDetails.add(
              ListTile(
                dense: true,
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    if (std > 0) Text('Est: $std ', style: const TextStyle(color: Colors.blue)),
                    if (clr > 0) Text('Col: $clr', style: const TextStyle(color: Colors.orange)),
                  ],
                ),
                trailing: Text('${std + clr}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }
        });

        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('LOAD DETAILS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (itemDetails.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No items added yet.'),
                )
              else ...[
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: itemDetails,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${totals['std']! + totals['clr']!} items', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
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
            const Text('New Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Step ${_currentStep + 1} of 5', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.list_alt_rounded),
              onPressed: _showFormSummaryModal,
              tooltip: 'Ver detalle actual',
            ),
        ],
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
                _buildSectionStep('TOWELS', catalog.getItemsByCategory('TOWELS')),
                _buildSectionStep('BED SHEETS', catalog.getItemsByCategory('BED_SHEETS')),
                _buildSectionStep('COVERS', catalog.getItemsByCategory('COVERS')),
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
          const Text('General Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Select the client and basic lot details.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          const Text('CLIENT / BUSINESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Company>(
            value: _selectedCompany,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.business_outlined)),
            hint: const Text('Select company'),
            items: companies.map((c) {
              return DropdownMenuItem(value: c, child: Text(c.name));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCompany = val),
          ),
          const SizedBox(height: 24),
          const Text('DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildCounterField(
            'BOLSILLOS (Pockets)',
            _pocketCount,
            (val) => setState(() => _pocketCount = val),
          ),
          const SizedBox(height: 24),
          const Text('PLASTIC BAGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCounterField(
                  'SMALL',
                  _plasticBagsSmall,
                  (val) => setState(() => _plasticBagsSmall = val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCounterField(
                  'LARGE',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sectionTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: _sectionInitials[sectionTitle],
                      decoration: const InputDecoration(
                        labelText: 'Initials',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (val) => _sectionInitials[sectionTitle] = val,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Enter the counted quantities.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
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
    int totalItems = 0;
    _counts.forEach((_, val) => totalItems += (val['std'] ?? 0) + (val['clr'] ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Final Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Review data before submitting.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          ListTile(
            title: const Text('Client'),
            subtitle: Text(_selectedCompany?.name ?? 'Not selected'),
            leading: const CircleAvatar(child: Icon(Icons.business_outlined)),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          
          InkWell(
            onTap: _showFormSummaryModal,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('REGISTERED ITEMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('$totalItems items in total', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Text('View detail', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Icon(Icons.chevron_right, color: AppTheme.primaryColor, size: 16),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('HAND-FINISHED TOTALS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCounterField(
                  'PILLOWCASES',
                  _totalTaiesMain,
                  (val) => setState(() => _totalTaiesMain = val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCounterField(
                  'SHEETS',
                  _totalDrapsMain,
                  (val) => setState(() => _totalDrapsMain = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('PACKAGING DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryMiniStat('Pockets', '$_pocketCount'),
              const SizedBox(width: 12),
              _buildSummaryMiniStat('Small Bags', '$_plasticBagsSmall'),
              const SizedBox(width: 12),
              _buildSummaryMiniStat('Large Bags', '$_plasticBagsLarge'),
            ],
          ),

          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 8),
            child: Text('ADDITIONAL NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          TextField(
            onChanged: (val) => _notes = val,
            decoration: InputDecoration(
              hintText: 'e.g. Watch out for the silk sheet...',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryMiniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
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
                child: const Text('Back'),
              )
            else
              const SizedBox(width: 10),
            Consumer<FormsProvider>(
              builder: (context, forms, child) {
                return ElevatedButton(
                  onPressed: (_selectedCompany == null || forms.isLoading) 
                    ? null 
                    : (_currentStep < 4 ? _nextPage : _showStatusSelection),
                  child: forms.isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(_currentStep < 4 ? 'Continue' : 'Finish'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How do you want to save this report?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Select "Draft" to continue later or "Submit" to send it for approval.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.edit_note, color: Colors.white)),
                title: const Text('Save as Draft'),
                subtitle: const Text('Keeps it editable'),
                onTap: () {
                  Navigator.pop(context);
                  _submitFullForm(FormStatus.DRAFT);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check_circle_outline, color: Colors.white)),
                title: const Text('Submit for Approval'),
                subtitle: const Text('Marks it as Pending'),
                onTap: () {
                  Navigator.pop(context);
                  _submitFullForm(FormStatus.PENDING_APPROVAL);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitFullForm(FormStatus status) async {
    final catalog = context.read<CatalogProvider>();
    
    List<FormSectionModel> sections = [
      _mapSection('TOWELS', catalog.getItemsByCategory('TOWELS')),
      _mapSection('BED_SHEETS', catalog.getItemsByCategory('BED_SHEETS')),
      _mapSection('COVERS', catalog.getItemsByCategory('COVERS')),
    ];

    final form = LaundryForm(
      companyId: _selectedCompany!.id,
      date: _selectedDate,
      pocketCount: _pocketCount,
      plasticBagsSmall: _plasticBagsSmall,
      plasticBagsLarge: _plasticBagsLarge,
      totalTaiesMain: _totalTaiesMain,
      totalDrapsMain: _totalDrapsMain,
      notes: _notes,
      sections: sections,
      status: status,
    );

    final forms = context.read<FormsProvider>();
    final success = widget.existingForm != null
        ? await forms.updateForm(widget.existingForm!.id!, form)
        : await forms.submitForm(form);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingForm != null ? 'Report updated!' : 'Report submitted!')),
      );
    }
  }

  FormSectionModel _mapSection(String sectionName, List<CatalogItemModel> catalogItems) {
    final initials = _sectionInitials[sectionName] ?? context.read<AuthProvider>().user?.initials ?? '??';

    return FormSectionModel(
      sectionName: sectionName,
      filledByInitials: initials,
      items: catalogItems.map((item) {
        return FormItemModel(
          category: item.name,
          size: item.size,
          isColored: false,
          quantity: _counts[item.name]?['std'] ?? 0,
        );
      }).toList() + catalogItems.map((item) {
        return FormItemModel(
          category: item.name,
          size: item.size,
          isColored: true,
          quantity: _counts[item.name]?['clr'] ?? 0,
        );
      }).toList(),
    );
  }
}
