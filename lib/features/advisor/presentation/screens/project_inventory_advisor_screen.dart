import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/data/models/inventory_filter_state.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_project_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_unit_details_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';


class ProjectInventoryAdvisorScreen extends StatefulWidget {
  final ProjectModel project;
  const ProjectInventoryAdvisorScreen({super.key, required this.project});

  @override
  State<ProjectInventoryAdvisorScreen> createState() =>
      _ProjectInventoryAdvisorScreenState();
}

class _ProjectInventoryAdvisorScreenState
    extends State<ProjectInventoryAdvisorScreen> {
  String selectedFilter = 'All';
  final InventoryFilterState _filterState = InventoryFilterState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AdvisorProjectProvider>()
          .fetchUnitsForProject(widget.project.id.toString());
    });
  }

  void _showFilterBottomSheet(List<UnitModel> units) {
    final types = ['All', ...units.map((u) => u.propertyType).toSet()];
    final configurations = ['All', ...units.map((u) => u.configuration).toSet()];
    final checkCategories = [
      'All',
      ...units.map((u) => u.saleCategory).toSet()
    ];
    final facings = ['All', ...units.map((u) => u.facing).toSet()];
    final locations = ['All', ...units.map((u) => u.location).toSet()];

    // Calculate dynamic ranges
    double minArea = units.isEmpty
        ? 0
        : units.map((u) => u.areaSqft).reduce((a, b) => a < b ? a : b);
    double maxArea = units.isEmpty
        ? 5000
        : units.map((u) => u.areaSqft).reduce((a, b) => a > b ? a : b);
    double minRate = units.isEmpty
        ? 0
        : units.map((u) => u.ratePerSqft).reduce((a, b) => a < b ? a : b);
    double maxRate = units.isEmpty
        ? 10000
        : units.map((u) => u.ratePerSqft).reduce((a, b) => a > b ? a : b);

    // Padding ranges to avoid slider errors if min == max
    if (minArea == maxArea) maxArea += 1;
    if (minRate == maxRate) maxRate += 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setInternalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FILTERS',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _filterState.reset());
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Reset',
                          style: GoogleFonts.montserrat(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildDropdownFilter(
                          'Type', types, _filterState.type, (v) {
                        setInternalState(() => _filterState.type = v!);
                      }),
                      _buildDropdownFilter('Configuration', configurations,
                          _filterState.configuration, (v) {
                        setInternalState(() => _filterState.configuration = v!);
                      }),
                      _buildDropdownFilter('Sale Category', checkCategories,
                          _filterState.saleCategory, (v) {
                        setInternalState(() => _filterState.saleCategory = v!);
                      }),
                      _buildDropdownFilter('Facing', facings,
                          _filterState.facing, (v) {
                        setInternalState(() => _filterState.facing = v!);
                      }),
                      _buildDropdownFilter('Location', locations,
                          _filterState.location, (v) {
                        setInternalState(() => _filterState.location = v!);
                      }),
                      const SizedBox(height: 20),
                      Text(
                        'Area Sqft: ${_filterState.minArea?.toInt() ?? minArea.toInt()} - ${_filterState.maxArea?.toInt() ?? maxArea.toInt()}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RangeSlider(
                        values: RangeValues(
                          _filterState.minArea ?? minArea,
                          _filterState.maxArea ?? maxArea,
                        ),
                        min: minArea,
                        max: maxArea,
                        divisions: maxArea == minArea ? 1 : 100,
                        activeColor: AppColors.getPrimaryBlue(context),
                        onChanged: (values) {
                          setInternalState(() {
                            _filterState.minArea = values.start;
                            _filterState.maxArea = values.end;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Rate / Sqft: ${_filterState.minRate?.toInt() ?? minRate.toInt()} - ${_filterState.maxRate?.toInt() ?? maxRate.toInt()}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RangeSlider(
                        values: RangeValues(
                          _filterState.minRate ?? minRate,
                          _filterState.maxRate ?? maxRate,
                        ),
                        min: minRate,
                        max: maxRate,
                        divisions: maxRate == minRate ? 1 : 100,
                        activeColor: AppColors.getPrimaryBlue(context),
                        onChanged: (values) {
                          setInternalState(() {
                            _filterState.minRate = values.start;
                            _filterState.maxRate = values.end;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getPrimaryBlue(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownFilter(String label, List<String> options,
      String currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                isExpanded: true,
                items: options
                    .map((opt) => DropdownMenuItem(
                          value: opt,
                          child: Text(
                            opt,
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdvisorProjectProvider>();

    // Apply local filtering
    List<UnitModel> filteredInventory = _filterState.apply(provider.units);
    if (selectedFilter != 'All') {
      filteredInventory = filteredInventory
          .where(
            (u) =>
                (selectedFilter == 'Sold Out' &&
                    (u.availabilityStatus.toLowerCase() == 'sold' ||
                        u.availabilityStatus.toLowerCase() == 'sold out')) ||
                (selectedFilter == 'Resale' &&
                    u.saleCategory.toLowerCase() == 'resale') ||
                u.availabilityStatus.toUpperCase() ==
                    selectedFilter.toUpperCase(),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(provider.units),
            icon: Stack(
              children: [
                const Icon(Icons.tune, color: Colors.white),
                if (_filterState.isActive)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('All', selectedFilter == 'All', primaryBlue),
                _buildFilterChip(
                  'Available',
                  selectedFilter == 'Available',
                  primaryBlue,
                ),
                _buildFilterChip(
                  'Booked',
                  selectedFilter == 'Booked',
                  primaryBlue,
                ),
                _buildFilterChip(
                  'Sold Out',
                  selectedFilter == 'Sold Out',
                  primaryBlue,
                ),
                _buildFilterChip(
                  'Resale',
                  selectedFilter == 'Resale',
                  primaryBlue,
                ),
              ],
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatText(
                  '${provider.totalUnitsCount}',
                  'TOTAL UNITS',
                  Colors.black,
                ),
                _buildStatText(
                  '${provider.availableUnitsCount}',
                  'AVAILABLE',
                  Colors.green,
                ),
                _buildStatText(
                  '${provider.bookedUnitsCount}',
                  'BOOKED',
                  Colors.orange,
                ),
                _buildStatText(
                  '${provider.soldUnitsCount}',
                  'SOLD',
                  Colors.red,
                ),
                _buildStatText(
                  '${provider.resaleUnitsCount}',
                  'RESALE',
                  Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Inventory Grid
          Expanded(
            child: provider.isLoadingUnits
                ? const Center(child: CircularProgressIndicator())
                : filteredInventory.isEmpty
                    ? Center(
                        child: Text(
                          "No units found",
                          style: GoogleFonts.montserrat(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredInventory.length,
                        itemBuilder: (context, index) {
                          final unit = filteredInventory[index];
                          return _buildUnitCard(unit, context);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color primaryBlue) {
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatText(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitCard(UnitModel unit, BuildContext context) {
    Color bgColor;
    Color textColor;
    if (unit.saleCategory.toLowerCase() == 'resale') {
      bgColor = Colors.purple[50]!;
      textColor = Colors.purple[800]!;
    } else if (unit.availabilityStatus.toUpperCase() == 'AVAILABLE') {
      bgColor = const Color(0xFFE8F5E9);
      textColor = Colors.green[800]!;
    } else if (unit.availabilityStatus.toUpperCase() == 'BOOKED') {
      bgColor = const Color(0xFFFFF8E1);
      textColor = Colors.orange[800]!;
    } else if (unit.availabilityStatus.toUpperCase() == 'SOLD' ||
        unit.availabilityStatus.toUpperCase() == 'SOLD OUT') {
      bgColor = const Color(0xFFFCE4EC);
      textColor = Colors.red[800]!;
    } else {
      bgColor = Colors.grey[200]!;
      textColor = Colors.grey[700]!;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdvisorUnitDetailsScreen(
              unit: unit,
              project: widget.project,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                unit.saleCategory.toLowerCase() == 'resale'
                    ? 'RESALE (${unit.availabilityStatus})'
                    : unit.availabilityStatus,
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${unit.towerName}-${unit.unitNumber.isNotEmpty ? unit.unitNumber : unit.plotNumber.isNotEmpty ? unit.plotNumber : 'N/A'}',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              unit.propertyType,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${unit.calculatedPrice.toStringAsFixed(0)}',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
