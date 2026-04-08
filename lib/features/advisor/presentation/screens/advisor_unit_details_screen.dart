import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/helper/helper_function.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';

class AdvisorUnitDetailsScreen extends StatelessWidget {
  final UnitModel unit;
  final ProjectModel project;
  final bool isSelectionMode;

  const AdvisorUnitDetailsScreen({
    super.key,
    required this.unit,
    required this.project,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final bool isAvailable = unit.availabilityStatus.toLowerCase() == 'available';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Text(
          '${unit.towerName} - ${unit.unitNumber}',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit Images Section
            if (unit.unitImages.isNotEmpty) ...[
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: unit.unitImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(unit.unitImages[index]),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Highlight Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (isAvailable ? Colors.green : Colors.redAccent)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAvailable ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        child: Text(
                          unit.availabilityStatus.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '₹${formatPrice(unit.calculatedPrice)}',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat(
                        'Rate/SqFt',
                        '₹${unit.ratePerSqft.toStringAsFixed(0)}',
                      ),
                      _buildMiniStat('Area', '${unit.areaSqft} SqFt'),
                      _buildMiniStat('Config', unit.configuration),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Unit Specifications',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Specs Grid
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSpecRow('Project', project.projectName, true),
                  _buildSpecRow('Tower / Block', unit.towerName, false),
                  _buildSpecRow('Floor', unit.floorNumber, true),
                  _buildSpecRow(
                    'Unit/Plot Number',
                    unit.unitNumber.isNotEmpty
                        ? unit.unitNumber
                        : unit.plotNumber.isNotEmpty
                            ? unit.plotNumber
                            : 'N/A',
                    false,
                  ),
                  _buildSpecRow('Property Type', unit.propertyType, true),
                  _buildSpecRow('Sale Category', unit.saleCategory, false),
                  _buildSpecRow('Facing', unit.facing, true),
                  _buildSpecRow(
                    'Location',
                    unit.location.isNotEmpty ? unit.location : 'Standard',
                    false,
                  ),
                  _buildSpecRow(
                    'Plot Dimensions',
                    unit.plotDimensions.isNotEmpty ? unit.plotDimensions : 'N/A',
                    true,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48), // Bottom spacing for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isSelectionMode && isAvailable
          ? Container(
              height: 56,
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: primaryBlue.withOpacity(0.4),
                ),
                child: Text(
                  'Select This Unit',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value, bool isGrey, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isGrey ? Colors.grey.withOpacity(0.03) : Colors.transparent,
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}