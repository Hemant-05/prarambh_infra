import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/add_unit_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/unit_details_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart';
import '../../data/models/unit_model.dart';

class ProjectInventoryScreen extends StatefulWidget {
  final ProjectModel project;
  const ProjectInventoryScreen({super.key, required this.project});

  @override
  State<ProjectInventoryScreen> createState() => _ProjectInventoryScreenState();
}

class _ProjectInventoryScreenState extends State<ProjectInventoryScreen> {
  String selectedFilter = 'All';
  bool isSelectionMode = false;
  final Set<int> selectedUnitIds = {};

  void _toggleSelection(int unitId) {
    setState(() {
      if (selectedUnitIds.contains(unitId)) {
        selectedUnitIds.remove(unitId);
        if (selectedUnitIds.isEmpty) isSelectionMode = false;
      } else {
        selectedUnitIds.add(unitId);
      }
    });
  }

  void _enterSelectionMode(int unitId) {
    setState(() {
      isSelectionMode = true;
      selectedUnitIds.add(unitId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedUnitIds.clear();
    });
  }

  void _selectAll(List<UnitModel> units) {
    setState(() {
      if (selectedUnitIds.length == units.length) {
        selectedUnitIds.clear();
        isSelectionMode = false;
      } else {
        selectedUnitIds.addAll(units.map((u) => u.id));
        isSelectionMode = true;
      }
    });
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<AdminProjectProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: Text(
              'Deleting Units',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  provider.bulkProgress,
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProjectProvider>().fetchInventory(widget.project.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminProjectProvider>();

    // Apply local filtering
    List<UnitModel> filteredInventory = provider.inventory;
    if (selectedFilter != 'All') {
      filteredInventory = provider.inventory
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
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: !isSelectionMode,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _exitSelectionMode,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        title: isSelectionMode
            ? Text(
                '${selectedUnitIds.length} Selected',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            : Text(
                'Project Inventory',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: Icon(
                selectedUnitIds.length == filteredInventory.length
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: Colors.white,
              ),
              onPressed: () => _selectAll(filteredInventory),
              tooltip: 'Select All',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                bool confirm = await showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Selected Units?'),
                        content: Text(
                            'Are you sure you want to delete ${selectedUnitIds.length} units? This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm && context.mounted) {
                  _showProgressDialog();
                  final success = await provider.bulkRemoveUnits(
                    selectedUnitIds.map((id) => id.toString()).toList(),
                    widget.project.id.toString(),
                  );
                  if (context.mounted) Navigator.pop(context); // Close progress dialog
                  if (success) {
                    _exitSelectionMode();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Units deleted successfully')),
                      );
                    }
                  }
                }
              },
              tooltip: 'Delete Selected',
            ),
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddUnitScreen(projectId: widget.project.id),
          ),
        ),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Unit',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            child: provider.isLoadingInventory
                ? const Center(child: CircularProgressIndicator())
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

    final isSelected = selectedUnitIds.contains(unit.id);

    return GestureDetector(
      onLongPress: () {
        if (!isSelectionMode) {
          _enterSelectionMode(unit.id);
        }
      },
      onTap: () {
        if (isSelectionMode) {
          _toggleSelection(unit.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UnitDetailsScreen(unit: unit)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Stack(
          children: [
            Column(
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
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
