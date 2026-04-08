import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/project_details_admin_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/project_inventory_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart';
import 'add_project_screen.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProjectProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminProjectProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProjectScreen()),
        ),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Project',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context, provider, primaryBlue, isDark),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredProjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No projects found matching your criteria',
                          style: GoogleFonts.montserrat(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            provider.clearFilters();
                          },
                          child: const Text('Clear All Filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.filteredProjects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(
                        provider.filteredProjects[index],
                        primaryBlue,
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(
    BuildContext context,
    AdminProjectProvider provider,
    Color primaryBlue,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => provider.setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                onPressed: () => _showFilterBottomSheet(context, provider),
                icon: Icon(
                  Icons.tune,
                  color:
                      (provider.filterType != 'All' ||
                          provider.filterConstruction != 'All' ||
                          provider.filterStatus != 'All')
                      ? primaryBlue
                      : Colors.grey,
                ),
              ),
              if (provider.filterType != 'All' ||
                  provider.filterConstruction != 'All' ||
                  provider.filterStatus != 'All')
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    AdminProjectProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<AdminProjectProvider>(
          builder: (context, provider, _) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Projects',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          _searchCtrl.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    'Project Type',
                    ['All', 'Residential', 'Commercial', 'Mixed Use'],
                    provider.filterType,
                    (val) => provider.setFilters(type: val),
                  ),
                  const SizedBox(height: 20),
                  _buildFilterSection(
                    'Construction Status',
                    [
                      'All',
                      'New Launch',
                      'Under Construction',
                      'Ready to Move',
                    ],
                    provider.filterConstruction,
                    (val) => provider.setFilters(construction: val),
                  ),
                  const SizedBox(height: 20),
                  _buildFilterSection(
                    'Project Status',
                    ['All', 'Completed', 'Ongoing', 'Upcoming'],
                    provider.filterStatus,
                    (val) => provider.setFilters(status: val),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
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
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String currentValue,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = currentValue == option;
            return ChoiceChip(
              checkmarkColor: AppColors.getPrimaryBlue(context),
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelected(option);
              },
              selectedColor: AppColors.getPrimaryBlue(context).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              labelStyle: GoogleFonts.montserrat(
                fontSize: 12,
                color: isSelected
                    ? AppColors.getPrimaryBlue(context)
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProjectCard(
    ProjectModel project,
    Color primaryBlue,
    bool isDark,
  ) {
    final cardColor = AppColors.getCardColor(context);

    Color statusColor;
    if (project.status.contains('RERA')) {
      statusColor = Colors.green;
    } else if (project.status.contains('FEW'))
      statusColor = Colors.orange;
    else
      statusColor = Colors.deepOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Header
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: project.images.isNotEmpty
                        ? NetworkImage(project.images[0]) as ImageProvider
                        : const AssetImage(logo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    project.status,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.projectName,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project.locationMapUrl,
                          style: GoogleFonts.montserrat(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Area',
                  '${project.buildArea} sqft',
                  primaryBlue,
                ),
                _buildStatColumn(
                  'Units',
                  project.totalPlots.toString(),
                  primaryBlue,
                ),
                _buildStatColumn(
                  'Rate',
                  '${project.ratePerSqft.toString()}/sqft',
                  primaryBlue,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProjectDetailsAdminScreen(project: project),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Details',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProjectInventoryScreen(project: project),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Inventory',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // NEW DELETE BUTTON
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    final provider = context.read<AdminProjectProvider>();
                    bool confirm =
                        await showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text('Delete ${project.projectName}?'),
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

                    if (confirm) {
                      await provider.removeProject(project.id.toString());
                      // Provider automatically updates the UI
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, Color primaryBlue) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }
}
