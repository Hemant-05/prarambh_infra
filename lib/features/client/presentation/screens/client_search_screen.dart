import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/client_dashboard_provider.dart';
import 'client_property_details_screen.dart';
import '../../../admin/data/models/project_model.dart';

class ClientSearchScreen extends StatefulWidget {
  const ClientSearchScreen({super.key});

  @override
  State<ClientSearchScreen> createState() => _ClientSearchScreenState();
}

class _ClientSearchScreenState extends State<ClientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientDashboardProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textColor),
        title: _buildSearchTextField(context, provider, primaryBlue, isDark),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Recent Search Section
            if (provider.recentSearches.isNotEmpty) _buildRecentSearchSection(context, provider, isDark),
            
            const SizedBox(height: 32),
            
            // Recent View Section
            if (provider.recentViews.isNotEmpty) _buildRecentViewSection(context, provider.recentViews, isDark),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context, ClientDashboardProvider provider, Color accentColor, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.montserrat(fontSize: 14, color: textColor),
        onSubmitted: (value) {
          provider.addSearch(value);
          // Navigate to results or filter list (for now just history)
        },
        decoration: InputDecoration(
          hintText: "Search property...",
          hintStyle: GoogleFonts.montserrat(color: secondaryTextColor, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: accentColor, size: 20),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: secondaryTextColor, size: 18),
            onPressed: () => _searchController.clear(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildRecentSearchSection(BuildContext context, ClientDashboardProvider provider, bool isDark) {
    final textColor = Theme.of(context).textTheme.titleLarge?.color ?? Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Recent Search",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...provider.recentSearches.map((query) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            query,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.close, color: secondaryTextColor?.withOpacity(0.5), size: 18),
            onPressed: () => provider.removeSearch(query),
          ),
          onTap: () {
            _searchController.text = query;
          },
        )).toList(),
      ],
    );
  }

  Widget _buildRecentViewSection(BuildContext context, List<ProjectModel> views, bool isDark) {
    final textColor = Theme.of(context).textTheme.titleLarge?.color ?? Theme.of(context).textTheme.bodyLarge?.color;
    final primaryBlue = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Recent View",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: views.length,
          itemBuilder: (context, index) {
            final item = views[index];
            final cardColor = Theme.of(context).cardColor;
            final bodyTextColor = Theme.of(context).textTheme.bodyLarge?.color;
            final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientPropertyDetailsScreen(project: item))),
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
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                        child: Icon(Icons.favorite, color: primaryBlue, size: 12),
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
                              Text("4.9", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: bodyTextColor)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(item.projectType.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 8, color: primaryBlue, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.projectName,
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: bodyTextColor),
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
                              Text("1,225", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: bodyTextColor)),
                              const SizedBox(width: 12),
                              Icon(Icons.bed, size: 12, color: secondaryTextColor?.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              Text("3.0", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: bodyTextColor)),
                              const Spacer(),
                              Text("₹${item.budgetRange}", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
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
      ],
    );
  }
}
