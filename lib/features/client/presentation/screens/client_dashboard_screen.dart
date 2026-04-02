import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/client_dashboard_provider.dart';
import 'client_search_screen.dart';
import 'client_property_details_screen.dart';
import 'client_filter_screen.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import 'client_unit_details_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientDashboardProvider>().fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientDashboardProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchInitialData(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeader(user?.name ?? 'Guest', user?.profilePhoto ?? '', isDark),
                      
                      // Search & Filter Section
                      _buildSearchBar(context, primaryBlue, isDark),
                      
                      const SizedBox(height: 24),
                      
                      // Category Tabs
                      _buildCategoryTabs(provider, primaryBlue, isDark),
                      
                      const SizedBox(height: 24),
                      
                      // Featured / Recommended horizontal list
                      _buildFeaturedList(provider.projects, isDark),
                      
                      const SizedBox(height: 32),
                      
                      // Available Units Section
                      _buildUnitsHeader(isDark),
                      _buildUnitsList(provider.units, isDark),
                      
                      const SizedBox(height: 32),
                      
                      // Near You Section
                      _buildNearYouHeader(isDark),
                      _buildNearYouList(provider.projects, isDark),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(String name, String profilePhoto, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let's Find your",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Favorite Home",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0D1B34),
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade50,
            backgroundImage: profilePhoto.isNotEmpty ? NetworkImage(profilePhoto) : null,
            child: profilePhoto.isEmpty ? Icon(Icons.person, color: Colors.blue[700]) : null,
          ),
          IconButton(onPressed: (){
            context.read<AuthProvider>().logout;
            Navigator.pushNamed(context, '/login');
          }, icon: Icon(Icons.logout, color: isDark ? Colors.white54 : Colors.red, size: 24),)
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Color primaryBlue, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientSearchScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.blue.shade300, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      "Search by Address, City, or ZIP",
                      style: GoogleFonts.montserrat(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientFilterScreen())),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ClientDashboardProvider provider, Color activeColor, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: provider.categories.map((cat) {
          final isSelected = provider.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => provider.selectCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor.withOpacity(0.1) : (isDark ? Colors.grey[900] : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? activeColor : Colors.transparent),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? activeColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedList(List<ProjectModel> projects, bool isDark) {
    // If no projects, show a nice placeholder
    if (projects.isEmpty) return const SizedBox();

    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final item = projects[index];
          return GestureDetector(
            onTap: () {
              context.read<ClientDashboardProvider>().addToRecentViews(item);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClientPropertyDetailsScreen(project: item)));
            },
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(item.images.isNotEmpty ? item.images[0] : 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=400'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 18, right: 18,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(Icons.bookmark, color: Colors.blue[600], size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.projectName,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0D1B34),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "₹${item.budgetRange}/month",
                              style: GoogleFonts.montserrat(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[400], size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.city,
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearYouHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Near You",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B34),
            ),
          ),
          Text(
            "More",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearYouList(List<ProjectModel> projects, bool isDark) {
    if (projects.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projects.length > 5 ? 5 : projects.length,
        itemBuilder: (context, index) {
          final item = projects[index];
          return GestureDetector(
            onTap: () {
              context.read<ClientDashboardProvider>().addToRecentViews(item);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClientPropertyDetailsScreen(project: item)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(item.images.isNotEmpty ? item.images[0] : 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=400'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber[600], size: 14),
                            const SizedBox(width: 4),
                            Text("4.9", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Text(item.projectType.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 8, color: Colors.blue[700], fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.projectName,
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[400], size: 12),
                            const SizedBox(width: 2),
                            Expanded(child: Text(item.city, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.aspect_ratio, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text("1,225", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Icon(Icons.bed, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text("3.0", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text("₹${item.ratePerSqft}", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[600])),
                            Text("/month", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildUnitsHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Available Units",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D1B34),
            ),
          ),
          Text(
            "More",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsList(List<UnitModel> units, bool isDark) {
    if (units.isEmpty) return const SizedBox();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: units.length,
        itemBuilder: (context, index) {
          final item = units[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClientUnitDetailsScreen(unit: item)));
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(item.unitImages.isNotEmpty ? item.unitImages[0] : 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=300'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item.towerName} - ${item.unitNumber}",
                          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.configuration,
                          style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${(item.calculatedPrice / 100000).toStringAsFixed(1)} Lakh",
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
