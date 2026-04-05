import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/helper/helper_function.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW
import 'package:intl/intl.dart'; // NEW
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/project_model.dart';
import '../providers/advisor_project_provider.dart';
import 'advisor_unit_details_screen.dart';

class AdvisorProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;
  const AdvisorProjectDetailsScreen({super.key, required this.project});

  @override
  State<AdvisorProjectDetailsScreen> createState() =>
      _AdvisorProjectDetailsScreenState();
}

class _AdvisorProjectDetailsScreenState
    extends State<AdvisorProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvisorProjectProvider>().fetchUnitsForProject(
        widget.project.id.toString(),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    String displayImage = widget.project.images.isNotEmpty
        ? widget.project.images.first
        : '';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: primaryBlue,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.project.projectName,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    displayImage.isNotEmpty
                        ? Image.network(
                            displayImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.white54,
                            ),
                          )
                        : Container(
                            color: Colors.blueGrey,
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.white54,
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryBlue,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: primaryBlue,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Unit Inventory'),
                  ],
                ),
                cardColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(cardColor, primaryBlue, isDark),
            _buildInventoryTab(primaryBlue, isDark),
          ],
        ),
      ),
    );
  }

  // --- OVERVIEW TAB ---
  Widget _buildOverviewTab(Color cardColor, Color primaryBlue, bool isDark) {
    final project = widget.project;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Developer & City Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.business, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.developerName.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${project.city} • ${project.projectName}',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Project Status Badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusBadge(Icons.category, project.projectType, Colors.orange),
                const SizedBox(width: 8),
                _buildStatusBadge(Icons.construction, project.constructionStatus, Colors.blue),
                const SizedBox(width: 8),
                _buildStatusBadge(Icons.check_circle, project.status, Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pricing & Financial Stats
          Text(
            'Financial Overview',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Market Value',
                  '₹${NumberFormat.compact().format(project.marketValue)}',
                  primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Budget Range',
                  project.budgetRange,
                  primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Start Rate',
                  '₹${project.ratePerSqft}/sq.ft',
                  primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Total Units',
                  project.totalPlots.toString(),
                  primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Build Area',
                  '${project.buildArea} sq.ft',
                  primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Project Description
          if (project.description.isNotEmpty) ...[
            Text(
              'Description',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              project.description,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
          ],

          // Quick Actions Row
          Text(
            'Resources',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.map,
                  'View Map',
                  Colors.green,
                  () => _launchUrl(project.locationMapUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  Icons.description,
                  'Brochure',
                  Colors.orange,
                  () => _launchUrl(project.brochureFile),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Features Section (Amenities & Specialties)
          if (project.amenities.isNotEmpty) ...[
            Text(
              'Project Amenities',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.amenities.map((a) => _buildChip(a, Colors.teal)).toList(),
            ),
            const SizedBox(height: 30),
          ],

          if (project.specialties.isNotEmpty) ...[
            Text(
              'Features & Specialties',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.specialties.map((s) => _buildChip(s, Colors.deepPurple)).toList(),
            ),
            const SizedBox(height: 30),
          ],

          // Metadata Footer
          Center(
            child: Text(
              'Listed on: ${DateFormat('dd MMM yyyy').format(project.createdAt)}',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- NEW: Helper Methods for Unified UI ---

  Widget _buildStatBox(String title, String value, Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    String fullUrl = urlString.startsWith('http')
        ? urlString
        : 'https://workiees.com/${urlString.startsWith('/') ? urlString.substring(1) : urlString}';
    final Uri url = Uri.parse(fullUrl);
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Launch Error: $e');
    }
  }

  // --- INVENTORY TAB ---
  Widget _buildInventoryTab(Color primaryBlue, bool isDark) {
    return Consumer<AdvisorProjectProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingUnits) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }
        if (provider.units.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  "No inventory available for this project.",
                  style: GoogleFonts.montserrat(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: provider.units.length,
          itemBuilder: (context, index) {
            final unit = provider.units[index];
            final bool isAvailable =
                unit.availabilityStatus.toLowerCase() == 'available';

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
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.apartment,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${unit.towerName} - ${unit.unitNumber}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isAvailable ? Colors.green : Colors.red)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  unit.availabilityStatus.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${unit.configuration} • ${unit.areaSqft} SqFt',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${formatPrice(unit.calculatedPrice)}',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
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
      },
    );
  }
}

// Helper for SliverAppBar TabBar persistence
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _color;

  _SliverAppBarDelegate(this._tabBar, this._color);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: _color, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
