import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../admin/data/models/project_model.dart';
import 'contact_us_screen.dart';

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
    final primaryBlue = Theme.of(context).primaryColor;
    final item = widget.project;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        decoration: BoxDecoration(color: Theme.of(context).cardColor.withOpacity(0.9), shape: BoxShape.circle),
        child: Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
      ),
    );
  }

  Widget _buildTitleSection(ProjectModel item, bool isDark) {
    final textColor = Theme.of(context).textTheme.headlineSmall?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 16),
              const SizedBox(width: 4),
              Text("4.9 (6.8k review)", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryTextColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(item.projectType.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 10, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.projectName,
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: secondaryTextColor?.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text(
                item.city,
                style: GoogleFonts.montserrat(fontSize: 13, color: secondaryTextColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color primaryBlue, bool isDark) {
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: primaryBlue,
        unselectedLabelColor: secondaryTextColor,
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
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard(Icons.aspect_ratio, item.buildArea, "sqft", isDark),
              _statCard(Icons.bed_outlined, "3.0", "BHK", isDark),
              _statCard(Icons.bathtub_outlined, "1.0", "Bath", isDark),
              _statCard(Icons.verified_user_outlined, "4,457", "Safety", isDark),
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
            style: GoogleFonts.montserrat(fontSize: 13, color: secondaryTextColor, height: 1.5),
          ),
          const SizedBox(height: 16),
          // Mock Map
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              image: const DecorationImage(
                image: NetworkImage('https://miro.medium.com/max/1400/1*q6ybgv9X0E7oW7R8q8A8pQ.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text("LOCATION", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
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
    final primaryBlue = Theme.of(context).primaryColor;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 4,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: secondaryTextColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAgentTile(ProjectModel item, bool isDark) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
              Text(item.developerName.isEmpty ? "Sandeep S." : item.developerName, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
              Text("Developer Partner", style: GoogleFonts.montserrat(fontSize: 12, color: secondaryTextColor)),
            ],
          ),
        ),
        _actionIcon(Icons.mail_outline, Theme.of(context).primaryColor, isDark),
        const SizedBox(width: 12),
        _actionIcon(Icons.phone_outlined, Theme.of(context).primaryColor, isDark),
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

    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Icon(facilities[index]['icon'] as IconData, color: Theme.of(context).primaryColor, size: 24),
            ),
            const SizedBox(height: 4),
            Text(facilities[index]['label'] as String, style: GoogleFonts.montserrat(fontSize: 10, color: secondaryTextColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1),
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
          _sectionHeader("Gallery (${item.images.length})", isDark),
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
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    return Center(child: Text("Coming Soon", style: TextStyle(color: secondaryTextColor)));
  }

  Widget _sectionHeader(String title, bool isDark) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: textColor));
  }

  Widget _buildBottomPriceBar(ProjectModel item, Color primaryBlue, bool isDark) {
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Starting From", style: GoogleFonts.montserrat(fontSize: 12, color: secondaryTextColor, fontWeight: FontWeight.w500)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${item.budgetRange}", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              },
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
