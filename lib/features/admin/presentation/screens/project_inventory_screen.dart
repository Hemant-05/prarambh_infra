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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Project Inventory',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                  Colors.black87,
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
    if (unit.availabilityStatus.toUpperCase() == 'AVAILABLE') {
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UnitDetailsScreen(unit: unit)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unit.availabilityStatus,
              style: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              unit.unitNumber,
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
