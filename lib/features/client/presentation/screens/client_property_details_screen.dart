import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/project_model.dart';

class ClientPropertyDetailsScreen extends StatefulWidget {
  final ProjectModel project;
  const ClientPropertyDetailsScreen({super.key, required this.project});

  @override
  State<ClientPropertyDetailsScreen> createState() => _ClientPropertyDetailsScreenState();
}

class _ClientPropertyDetailsScreenState extends State<ClientPropertyDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final item = widget.project;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Header
                      _buildImageHeader(item, context, isDark),
                      
                      const SizedBox(height: 16),
                      
                      // Title & Location
                      _buildTitleSection(item, isDark),
                      
                      const SizedBox(height: 16),
                      
                      // Tab Bar
                      _buildTabBar(primaryBlue, isDark),
                      
                      // Tab Content
                      SizedBox(
                        height: 800, // Fixed height for scrollable tabs inside scrollview
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDescriptionTab(item, isDark),
                            _buildGalleryTab(item, isDark),
                            _buildReviewTab(isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Bar
              _buildBottomPriceBar(item, primaryBlue, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(ProjectModel item, BuildContext context, bool isDark) {
    return Stack(
      children: [
        Hero(
          tag: 'property-image-${item.id}',
          child: Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(item.images.isNotEmpty ? item.images[0] : 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(Icons.arrow_back, () => Navigator.pop(context), isDark),
                Row(
                  children: [
                    _circleButton(Icons.share_outlined, () {}, isDark),
                    const SizedBox(width: 12),
                    _circleButton(_isFavorite ? Icons.favorite : Icons.favorite_border, () {}, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildTitleSection(ProjectModel item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 16),
              const SizedBox(width: 4),
              Text("4.9 (6.8k review)", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                child: Text(item.projectType.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.projectName,
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D1B34)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[400], size: 14),
              const SizedBox(width: 4),
              Text(
                item.city,
                style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color primaryBlue, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: primaryBlue,
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: primaryBlue,
        indicatorWeight: 3,
        labelStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: "Description"),
          Tab(text: "Gallery"),
          Tab(text: "Review"),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(ProjectModel item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard(Icons.aspect_ratio, "1,225", "sqft", isDark),
              _statCard(Icons.bed_outlined, "3.0", "Bedrooms", isDark),
              _statCard(Icons.bathtub_outlined, "1.0", "Bathrooms", isDark),
              _statCard(Icons.verified_user_outlined, "4,457", "Safety Rank", isDark),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _sectionHeader("Listing Agent", isDark),
          const SizedBox(height: 12),
          _buildAgentTile(item, isDark),
          
          const SizedBox(height: 24),
          
          _sectionHeader("Facilities", isDark),
          const SizedBox(height: 16),
          _buildFacilitiesGrid(isDark),
          
          const SizedBox(height: 24),
          
          _sectionHeader("Address", isDark),
          const SizedBox(height: 12),
          Text(
            item.fullAddress,
            style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 16),
          // Mock Map
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[100],
              image: const DecorationImage(
                image: NetworkImage('https://miro.medium.com/max/1400/1*q6ybgv9X0E7oW7R8q8A8pQ.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Text("UNION", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, bool isDark) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 4,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[600], size: 20),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[600])),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAgentTile(ProjectModel item, bool isDark) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.developerName.isEmpty ? "Sandeep S." : item.developerName, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold)),
              Text("Partner", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
        _actionIcon(Icons.mail_outline, Colors.blue, isDark),
        const SizedBox(width: 12),
        _actionIcon(Icons.phone_outlined, Colors.blue, isDark),
      ],
    );
  }

  Widget _actionIcon(IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildFacilitiesGrid(bool isDark) {
    final facilities = [
      {'icon': Icons.car_repair, 'label': 'Car Parking'},
      {'icon': Icons.pool, 'label': 'Swimming...'},
      {'icon': Icons.fitness_center, 'label': 'Gym & Fit'},
      {'icon': Icons.restaurant, 'label': 'Restaurant'},
      {'icon': Icons.wifi, 'label': 'Wi-fi'},
      {'icon': Icons.pets, 'label': 'Pet Center'},
      {'icon': Icons.sports_basketball, 'label': 'Sports Cl...'},
      {'icon': Icons.local_laundry_service, 'label': 'Laundry'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 12, childAspectRatio: 0.9),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
              child: Icon(facilities[index]['icon'] as IconData, color: Colors.blue[600], size: 24),
            ),
            const SizedBox(height: 4),
            Text(facilities[index]['label'] as String, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1),
          ],
        );
      },
    );
  }

  Widget _buildGalleryTab(ProjectModel item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Gallery (400)", isDark),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2),
            itemCount: item.images.length > 6 ? 6 : item.images.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(item.images[index], fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab(bool isDark) {
    return Center(child: Text("Coming Soon", style: TextStyle(color: Colors.grey[500])));
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D1B34)));
  }

  Widget _buildBottomPriceBar(ProjectModel item, Color primaryBlue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Price", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${item.ratePerSqft}", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[600])),
                  Text("/month", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text("Site visit", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
