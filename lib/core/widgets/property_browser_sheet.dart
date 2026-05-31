import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../../features/admin/data/models/project_model.dart';
import '../../features/admin/data/models/unit_model.dart';
import '../../features/admin/presentation/providers/admin_project_provider.dart';

class PropertyBrowserSheet extends StatefulWidget {
  final Function(String, int, UnitModel, ProjectModel) onSelect;
  /// Optional override for what happens when a unit is tapped.
  /// Return true to proceed with selection, false/null to cancel.
  final Future<bool?> Function(BuildContext, UnitModel, ProjectModel)? onUnitTapOverride;

  const PropertyBrowserSheet({
    super.key,
    required this.onSelect,
    this.onUnitTapOverride,
  });

  @override
  State<PropertyBrowserSheet> createState() => _PropertyBrowserSheetState();
}

class _PropertyBrowserSheetState extends State<PropertyBrowserSheet> {
  String _searchQuery = '';
  String? _selectedConfig;
  String? _selectedType;
  String? _selectedCategory;
  String? _selectedFacing;
  final TextEditingController _minPriceCtrl = TextEditingController(text: '0');
  final TextEditingController _maxPriceCtrl = TextEditingController(text: '10000000');
  final TextEditingController _minAreaCtrl = TextEditingController(text: '0');
  final TextEditingController _maxAreaCtrl = TextEditingController(text: '10000');
  bool _isHighValueOnly = false;

  final List<String> _configs = ['1BHK', '2BHK', '3BHK', '4BHK'];
  final List<String> _types = ['Apartment', 'Plot', 'Villa', 'Flat'];
  final List<String> _categories = ['Buy', 'Rent', 'Resale'];
  final List<String> _facings = ['East', 'West', 'North', 'South'];

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _minAreaCtrl.dispose();
    _maxAreaCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProjectProvider>().fetchProjects();
    });
  }

  bool _unitMatchesFilters(UnitModel u) {
    if (_selectedConfig != null && u.configuration != _selectedConfig) {
      return false;
    }
    if (_selectedType != null && u.propertyType != _selectedType) return false;
    if (_selectedCategory != null && u.saleCategory != _selectedCategory) {
      return false;
    }
    if (_selectedFacing != null && u.facing != _selectedFacing) return false;

    double minPrice = double.tryParse(_minPriceCtrl.text) ?? 0;
    double maxPrice = double.tryParse(_maxPriceCtrl.text) ?? 10000000;
    double minArea = double.tryParse(_minAreaCtrl.text) ?? 0;
    double maxArea = double.tryParse(_maxAreaCtrl.text) ?? 10000;

    if (_isHighValueOnly) {
      if (u.calculatedPrice < 10000000) return false;
    } else {
      if (u.calculatedPrice < minPrice ||
          u.calculatedPrice > maxPrice) {
        return false;
      }
    }

    if (u.areaSqft < minArea || u.areaSqft > maxArea) {
      return false;
    }
    return true;
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String? selected,
    Function(String) onSelect,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);

    final dropdownOptions = ['Select', ...options];
    final displayValue = selected ?? 'Select';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: displayValue,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: primaryBlue,
              ),
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              items: dropdownOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onSelect(newValue == 'Select' ? 'None' : newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final sidebarWidth = screenWidth > 800 ? 280.0 : screenWidth * 0.38;

    return Consumer<AdminProjectProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Browse Properties',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: sidebarWidth,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'FILTERS',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedConfig = null;
                                        _selectedType = null;
                                        _selectedCategory = null;
                                        _selectedFacing = null;
                                        _minPriceCtrl.text = '0';
                                        _maxPriceCtrl.text = '10000000';
                                        _minAreaCtrl.text = '0';
                                        _maxAreaCtrl.text = '10000';
                                        _isHighValueOnly = false;
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: const Icon(Icons.refresh, size: 14),
                                    tooltip: 'Clear All',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[850] : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: 12,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search...',
                                    prefixIcon: Icon(Icons.search, size: 16),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFilterSection(
                                'Configuration',
                                _configs,
                                _selectedConfig,
                                (v) => setState(() => _selectedConfig = v == 'None' ? null : v),
                              ),
                              const SizedBox(height: 12),
                              _buildFilterSection(
                                'Type',
                                _types,
                                _selectedType,
                                (v) => setState(() => _selectedType = v == 'None' ? null : v),
                              ),
                              const SizedBox(height: 12),
                              _buildFilterSection(
                                'Sale',
                                _categories,
                                _selectedCategory,
                                (v) => setState(() => _selectedCategory = v == 'None' ? null : v),
                              ),
                              const SizedBox(height: 12),
                              _buildFilterSection(
                                'Facing',
                                _facings,
                                _selectedFacing,
                                (v) => setState(() => _selectedFacing = v == 'None' ? null : v),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Price Range (\u20b9)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!_isHighValueOnly)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _minPriceCtrl,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => setState(() {}),
                                        style: const TextStyle(fontSize: 10),
                                        decoration: InputDecoration(
                                          hintText: 'Min',
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _maxPriceCtrl,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => setState(() {}),
                                        style: const TextStyle(fontSize: 10),
                                        decoration: InputDecoration(
                                          hintText: 'Max',
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              InkWell(
                                onTap: () => setState(() => _isHighValueOnly = !_isHighValueOnly),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _isHighValueOnly,
                                        onChanged: (v) => setState(() => _isHighValueOnly = v ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('1Cr+', style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Area (Sqft)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _minAreaCtrl,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setState(() {}),
                                      style: const TextStyle(fontSize: 10),
                                      decoration: InputDecoration(
                                        hintText: 'Min',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _maxAreaCtrl,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setState(() {}),
                                      style: const TextStyle(fontSize: 10),
                                      decoration: InputDecoration(
                                        hintText: 'Max',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                physics: const BouncingScrollPhysics(),
                                itemCount: provider.projects.length,
                                itemBuilder: (context, i) {
                                  final project = provider.projects[i];
                                  if (_searchQuery.isNotEmpty &&
                                      !project.projectName.toLowerCase().contains(_searchQuery) &&
                                      !project.city.toLowerCase().contains(_searchQuery)) {
                                    return const SizedBox.shrink();
                                  }
                                  return ProjectCard(
                                    project: project,
                                    primaryBlue: primaryBlue,
                                    isDark: isDark,
                                    searchQuery: _searchQuery,
                                    unitFilter: _unitMatchesFilters,
                                    onSelectUnit: (unit) async {
                                      if (widget.onUnitTapOverride != null) {
                                        final bool? selected = await widget.onUnitTapOverride!(context, unit, project);
                                        if (selected == true) {
                                          widget.onSelect(
                                            '${project.projectName} (${unit.towerName}-${unit.unitNumber})',
                                            unit.id,
                                            unit,
                                            project,
                                          );
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        widget.onSelect(
                                          '${project.projectName} (${unit.towerName}-${unit.unitNumber})',
                                          unit.id,
                                          unit,
                                          project,
                                        );
                                        Navigator.pop(context);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final Color primaryBlue;
  final bool isDark;
  final String searchQuery;
  final bool Function(UnitModel) unitFilter;
  final Function(UnitModel) onSelectUnit;

  const ProjectCard({super.key, 
    required this.project,
    required this.primaryBlue,
    required this.isDark,
    required this.searchQuery,
    required this.unitFilter,
    required this.onSelectUnit,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) async {
            setState(() => _expanded = val);
            if (val) {
              await context.read<AdminProjectProvider>().fetchInventory(project.id.toString());
            }
          },
          title: Text(
            project.projectName,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${project.city} \u2022 ${project.projectType}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            color: widget.primaryBlue,
            size: 20,
          ),
          children: [
            Consumer<AdminProjectProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final units = provider.inventory.where((u) {
                  if (u.projectId != project.id) return false;
                  if (!widget.unitFilter(u)) return false;
                  if (widget.searchQuery.isNotEmpty) {
                    final q = widget.searchQuery;
                    return u.unitNumber.toLowerCase().contains(q) ||
                        u.towerName.toLowerCase().contains(q) ||
                        u.configuration.toLowerCase().contains(q) ||
                        u.location.toLowerCase().contains(q);
                  }
                  return true;
                }).toList();

                if (units.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No matching units',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: units.map((unit) {
                    final isAvailable = unit.availabilityStatus.toLowerCase() == 'available';
                    final price = unit.calculatedPrice;
                    final priceStr = price >= 10000000
                        ? '\u20b9${(price / 10000000).toStringAsFixed(2)} Cr'
                        : '\u20b9${(price / 100000).toStringAsFixed(2)} L';

                    return GestureDetector(
                      onTap: isAvailable ? () => widget.onSelectUnit(unit) : null,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isAvailable ? widget.primaryBlue.withOpacity(0.04) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAvailable ? widget.primaryBlue.withOpacity(0.2) : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${unit.towerName} - ${unit.unitNumber}',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isAvailable ? null : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${unit.plotDimensions} \u2022 ${unit.areaSqft.toStringAsFixed(0)} sqft',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  priceStr,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? widget.primaryBlue : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    unit.availabilityStatus,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
