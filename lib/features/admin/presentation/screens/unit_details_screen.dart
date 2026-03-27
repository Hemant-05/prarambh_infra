import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/unit_model.dart';

class UnitDetailsScreen extends StatelessWidget {
  final UnitModel unit;
  const UnitDetailsScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor =
        unit.availabilityStatus.toUpperCase().contains('AVAILABLE')
        ? Colors.green
        : unit.availabilityStatus == 'BOOKED'
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Consumer<AdminProjectProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  // DELETE BUTTON
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              // Confirm deletion
                              bool confirm =
                                  await showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Delete Unit?'),
                                      content: const Text(
                                        'This cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (confirm) {
                                final success = await provider.removeUnit(
                                  unit.id.toString(),
                                  unit.projectId.toString(),
                                );
                                if (success) {
                                  Navigator.pop(
                                    context,
                                  ); // Go back to inventory
                                }
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.montserrat(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // UPDATE STATUS BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              // In a real app, open a bottom sheet to select "Booked" or "Sold"
                              // Here we simulate an instant update to 'Booked'
                              final success = await provider.modifyUnit(
                                unit.id.toString(),
                                {"availability_status": "Booked"},
                                unit.projectId.toString(),
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status Updated!'),
                                  ),
                                );
                                Navigator.pop(
                                  context,
                                ); // Pop to see refreshed inventory
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: provider.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Update Status',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Unit Details',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/logos.png',
                    fit: BoxFit.cover,
                  ), // Replace with unit image
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black12, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '1/8',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unit ${unit.unitNumber}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Prarambh Enclave',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                unit.availabilityStatus,
                                style: GoogleFonts.montserrat(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRICE',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  unit.basePrice.toString(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Floor Plan',
                                  style: GoogleFonts.montserrat(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: primaryBlue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specifications
                  Text(
                    'SPECIFICATIONS',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildSpecBox(
                        Icons.square_foot,
                        'Super Area',
                        unit.areaSqft.toString(),
                        cardColor,
                      ),
                      _buildSpecBox(
                        Icons.bed,
                        'Configuration',
                        unit.propertyType,
                        cardColor,
                      ),
                      _buildSpecBox(
                        Icons.explore,
                        'Facing',
                        unit.facing,
                        cardColor,
                      ),
                      _buildSpecBox(
                        Icons.layers,
                        'Floor',
                        unit.floorNumber,
                        cardColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Features
                  if (unit.configuration.isNotEmpty) ...[
                    Text(
                      'UNIT FEATURES',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      unit.configuration,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    /*...unit.configuration.map((feature) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Icon(Icons.check_circle_outline, color: primaryBlue, size: 20), const SizedBox(width: 12), Text(feature, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87))]))).toList(),
                    const SizedBox(height: 24),*/
                  ],

                  // Pricing Breakdown
                  /*if (unit.pricingBreakdown.isNotEmpty) ...[
                    Text('PRICING BREAKDOWN', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                      child: Column(
                        children: [
                          ...unit.pricingBreakdown.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(entry.key, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[700])), Text(entry.value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold))]))).toList(),
                          const Divider(height: 24),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total Cost', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)), Text(unit.totalCost, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue))]),
                          const SizedBox(height: 8),
                          Text('* Registration & Stamp Duty extra as applicable', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],*/
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBox(
    IconData icon,
    String title,
    String value,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.blue[800]),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
