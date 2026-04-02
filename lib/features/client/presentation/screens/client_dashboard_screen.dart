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
    final primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Favorite Home",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            backgroundImage: profilePhoto.isNotEmpty ? NetworkImage(profilePhoto) : null,
            child: profilePhoto.isEmpty ? Icon(Icons.person, color: Theme.of(context).primaryColor) : null,
          ),
          IconButton(onPressed: (){
            context.read<AuthProvider>().logout();
            Navigator.pushNamed(context, '/login');
          }, icon: Icon(Icons.logout, color: isDark ? Colors.white54 : Colors.red, size: 24),)
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Color primaryBlue, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final hintColor = Theme.of(context).hintColor;

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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.getBorderColor(context)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: isDark ? hintColor : primaryBlue.withOpacity(0.6), size: 22),
                    const SizedBox(width: 12),
                    Text(
                      "Search by Address, City, or ZIP",
                      style: GoogleFonts.montserrat(
                        color: hintColor,
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
    final cardColor = Theme.of(context).cardColor;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
                  color: isSelected ? activeColor.withOpacity(0.1) : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? activeColor : AppColors.getBorderColor(context)),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.montserrat(
                    color: isSelected ? activeColor : secondaryTextColor,
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
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.getBorderColor(context)),
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
                            decoration: BoxDecoration(color: cardColor.withOpacity(0.8), shape: BoxShape.circle),
                            child: Icon(Icons.bookmark, color: Theme.of(context).primaryColor, size: 16),
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
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "₹${item.budgetRange}",
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: secondaryTextColor?.withOpacity(0.5), size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.city,
                                style: GoogleFonts.montserrat(
                                  color: secondaryTextColor,
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
              color: textColor,
            ),
          ),
          Text(
            "More",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearYouList(List<ProjectModel> projects, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorderColor(context)),
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
                            Text("4.9", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(item.projectType.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 8, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.projectName,
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: secondaryTextColor?.withOpacity(0.5), size: 12),
                            const SizedBox(width: 2),
                            Expanded(child: Text(item.city, style: GoogleFonts.montserrat(fontSize: 10, color: secondaryTextColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.aspect_ratio, size: 12, color: secondaryTextColor?.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text("${item.buildArea}", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(width: 12),
                            Icon(Icons.bed, size: 12, color: secondaryTextColor?.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text("3.0", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                            const Spacer(),
                            Text("₹${item.ratePerSqft}", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                            Text("/sqft", style: GoogleFonts.montserrat(fontSize: 10, color: secondaryTextColor)),
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
              color: textColor,
            ),
          ),
          Text(
            "More",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsList(List<UnitModel> units, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

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
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.getBorderColor(context)),
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
                          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.configuration,
                          style: GoogleFonts.montserrat(fontSize: 11, color: secondaryTextColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${(item.calculatedPrice / 100000).toStringAsFixed(1)} Lakh",
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
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
