import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/client_dashboard_provider.dart';
import '../providers/property_filter_provider.dart';
import 'client_unit_details_screen.dart';

class ClientFilteredUnitsScreen extends StatelessWidget {
  const ClientFilteredUnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<ClientDashboardProvider>();
    final filterProvider = context.watch<PropertyFilterProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);

    // Apply Filter logic
    final filteredUnits = filterProvider.getFilteredUnits(dashboardProvider.units);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black87),
        title: Text(
          "Found ${filteredUnits.length} Units",
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : const Color(0xFF0D1B34),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: filteredUnits.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredUnits.length,
              itemBuilder: (context, index) {
                final unit = filteredUnits[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ClientUnitDetailsScreen(unit: unit)));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(unit.unitImages.isNotEmpty ? unit.unitImages[0] : 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=300'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${unit.towerName} - ${unit.unitNumber}",
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${unit.configuration} | Floor ${unit.floorNumber}",
                                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: primaryBlue),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(unit.location, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    "₹${(unit.calculatedPrice / 100000).toStringAsFixed(2)} Lakh",
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBlue),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                                    child: Text(unit.availabilityStatus, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.green[700], fontWeight: FontWeight.bold)),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No units match your filters",
            style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your price range or BHK",
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
