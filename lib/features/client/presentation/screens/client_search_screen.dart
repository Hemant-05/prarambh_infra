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
    final primaryBlue = AppColors.getPrimaryBlue(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black87),
        title: _buildSearchTextField(provider, primaryBlue, isDark),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Recent Search Section
            if (provider.recentSearches.isNotEmpty) _buildRecentSearchSection(provider, isDark),
            
            const SizedBox(height: 32),
            
            // Recent View Section
            if (provider.recentViews.isNotEmpty) _buildRecentViewSection(provider.recentViews, isDark),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTextField(ClientDashboardProvider provider, Color accentColor, bool isDark) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.montserrat(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
        onSubmitted: (value) {
          provider.addSearch(value);
          // Navigate to results or filter list (for now just history)
        },
        decoration: InputDecoration(
          hintText: "Search property...",
          hintStyle: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(Icons.search, color: accentColor, size: 20),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
            onPressed: () => _searchController.clear(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildRecentSearchSection(ClientDashboardProvider provider, bool isDark) {
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
              color: isDark ? Colors.white : const Color(0xFF0D1B34),
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
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
            onPressed: () => provider.removeSearch(query),
          ),
          onTap: () {
            _searchController.text = query;
          },
        )).toList(),
      ],
    );
  }

  Widget _buildRecentViewSection(List<ProjectModel> views, bool isDark) {
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
              color: isDark ? Colors.white : const Color(0xFF0D1B34),
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
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientPropertyDetailsScreen(project: item))),
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
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.favorite, color: Colors.blue[600], size: 12),
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
      ],
    );
  }
}
