import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/helper/helper_function.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import '../providers/advisor_project_provider.dart';
import 'advisor_unit_details_screen.dart';

class AdvisorProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;
  const AdvisorProjectDetailsScreen({super.key, required this.project});

  @override
  State<AdvisorProjectDetailsScreen> createState() => _AdvisorProjectDetailsScreenState();
}

class _AdvisorProjectDetailsScreenState extends State<AdvisorProjectDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvisorProjectProvider>().fetchUnitsForProject(widget.project.id.toString());
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
    String displayImage = widget.project.images.isNotEmpty ? widget.project.images.first : '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
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
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    displayImage.isNotEmpty
                        ? Image.network(displayImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.white54))
                        : Container(color: Colors.blueGrey, child: const Icon(Icons.image, size: 50, color: Colors.white54)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
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
                  labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Market Value', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 12),
          Text(
            '₹${formatPrice(widget.project.marketValue)}',
            style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[600], height: 1.6,fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text('Description', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 12),
          Text(
            widget.project.description.isNotEmpty ? widget.project.description : 'No description provided.',
            style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[600], height: 1.6),
          ),
          const SizedBox(height: 24),

          // Details Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDetailItem(Icons.business_center_outlined, 'Type', widget.project.projectType, cardColor, primaryBlue),
              _buildDetailItem(Icons.construction_outlined, 'Status', widget.project.constructionStatus, cardColor, primaryBlue),
              _buildDetailItem(Icons.verified_user_outlined, 'RERA', widget.project.reraNumber, cardColor, primaryBlue),
              _buildDetailItem(Icons.aspect_ratio_outlined, 'Area', widget.project.buildArea, cardColor, primaryBlue),
            ],
          ),
          const SizedBox(height: 24),

          // Amenities
          if (widget.project.amenities.isNotEmpty) ...[
            Text('Amenities', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.project.amenities.map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryBlue.withOpacity(0.2))),
                  child: Text(amenity, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: primaryBlue)),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color cardColor, Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value.isNotEmpty ? value : 'N/A', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
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
                Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No inventory available for this project.", style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
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
            final bool isAvailable = unit.availabilityStatus.toLowerCase() == 'available';

            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdvisorUnitDetailsScreen(unit: unit, project: widget.project)));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60, width: 60,
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.apartment, color: primaryBlue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${unit.towerName} - ${unit.unitNumber}', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: (isAvailable ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  unit.availabilityStatus.toUpperCase(),
                                  style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: isAvailable ? Colors.green : Colors.red),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${unit.configuration} • ${unit.areaSqft} SqFt', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            '₹${formatPrice(unit.calculatedPrice)}',
                            style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold, color: primaryBlue),
                          ),
                        ],
                      ),
                    )
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}