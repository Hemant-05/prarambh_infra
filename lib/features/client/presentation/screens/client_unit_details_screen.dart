import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/unit_model.dart';

class ClientUnitDetailsScreen extends StatefulWidget {
  final UnitModel unit;
  const ClientUnitDetailsScreen({super.key, required this.unit});

  @override
  State<ClientUnitDetailsScreen> createState() => _ClientUnitDetailsScreenState();
}

class _ClientUnitDetailsScreenState extends State<ClientUnitDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final unit = widget.unit;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // Hero Image Section
          _buildHeroImage(context, unit),
          
          // Content Section
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Handle bar
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 24),
                    
                    // Title and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${unit.towerName} - Unit ${unit.unitNumber}",
                                style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D1B34)),
                              ),
                              const SizedBox(height: 4),
                              Text(unit.location, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${(unit.calculatedPrice / 100000).toStringAsFixed(2)} Lakh",
                              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
                            ),
                            Text("Total Value", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Stats Row
                    _buildStatsRow(unit),
                    
                    const SizedBox(height: 32),
                    
                    // Tab Bar
                    _buildTabBar(primaryBlue, isDark),
                    
                    const SizedBox(height: 24),
                    
                    // Tab View Content (Simplified list for performance in details screen)
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildDescription(unit, isDark),
                          _buildGallery(unit),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Bottom Action Bar
          _buildBottomAction(primaryBlue, isDark),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, UnitModel unit) {
    return Positioned(
      top: 0, left: 0, right: 0,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(unit.unitImages.isNotEmpty ? unit.unitImages[0] : 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=600'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(backgroundColor: Colors.white.withOpacity(0.3), child: BackButton(color: Colors.white)),
                  CircleAvatar(backgroundColor: Colors.white.withOpacity(0.3), child: Icon(Icons.favorite_border, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UnitModel unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem(Icons.square_foot, "${unit.areaSqft.toInt()} Sqft", "Area"),
        _statItem(Icons.bed, unit.configuration, "Config"),
        _statItem(Icons.layers, "Floor ${unit.floorNumber}", "Level"),
        _statItem(Icons.explore, unit.facing, "Facing"),
      ],
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: Colors.blue[600], size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildTabBar(Color primaryBlue, bool isDark) {
    return TabBar(
      controller: _tabController,
      labelColor: primaryBlue,
      unselectedLabelColor: Colors.grey[500],
      indicatorColor: primaryBlue,
      indicatorWeight: 3,
      labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
      tabs: const [Tab(text: "Description"), Tab(text: "Gallery")],
    );
  }

  Widget _buildDescription(UnitModel unit, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Unit Details",
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          "This ${unit.configuration} unit is located on floor ${unit.floorNumber} facing ${unit.facing}. It offers ${unit.areaSqft} sqft of prime residential space in active ${unit.saleCategory} category. Perfect for those looking for a premium lifestyle with ${unit.propertyType} amenities.",
          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 32),
        Text(
          "Facilities",
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             _facilityIcon(Icons.wifi, "High-speed WiFi"),
             _facilityIcon(Icons.pool, "Common Pool"),
             _facilityIcon(Icons.security, "24/7 Security"),
             _facilityIcon(Icons.park, "Green Park"),
          ],
        ),
      ],
    );
  }

  Widget _facilityIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 28),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildGallery(UnitModel unit) {
    if (unit.unitImages.isEmpty) return Center(child: Text("No images available"));
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: unit.unitImages.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(unit.unitImages[index], fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildBottomAction(Color primaryBlue, bool isDark) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rate", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
                Text("₹${widget.unit.ratePerSqft}/sqft", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text("Express Interest", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
