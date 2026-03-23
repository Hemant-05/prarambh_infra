import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart';
import 'project_inventory_screen.dart';

class ProjectDetailsAdminScreen extends StatelessWidget {
  final ProjectModel project;
  const ProjectDetailsAdminScreen({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250, pinned: true,
            backgroundColor: primaryBlue,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/logos.png', fit: BoxFit.cover), // Replace with NetworkImage
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black12, Colors.black87.withOpacity(0.6)]))),
                  Positioned(
                    bottom: 20, right: 20,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)), child: Text('1 / 10', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12))),
                  ),
                  const Center(child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 50)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF121212) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(project.name, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text('RERA Approved', style: GoogleFonts.montserrat(color: primaryBlue, fontSize: 10, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(project.location, style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 12))]),
                  const SizedBox(height: 20),

                  // Developer Row
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.business, color: Colors.grey)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DEVELOPER', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)), Text(project.developer, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold))])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('RERA NO.', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)), Row(children: [Text(project.reraNo, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)), const SizedBox(width: 4), Icon(Icons.download, size: 14, color: primaryBlue)])]),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(child: _buildStatBox('Total Area', '4.5 Acres')), const SizedBox(width: 12),
                      Expanded(child: _buildStatBox('Total Units', project.totalUnits)), const SizedBox(width: 12),
                      Expanded(child: _buildStatBox('Start Rate', project.baseRate)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Quick Actions
                  Text('Quick Actions', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(Icons.map, 'Map', 'Download', primaryBlue),
                      _buildQuickAction(Icons.description, 'Brochure', 'Download', primaryBlue),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectInventoryScreen(project: project))),
                        child: _buildQuickAction(Icons.grid_view, 'Inventory', 'Manage', primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Availability Card
                  Container(
                    padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Plot Availability', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectInventoryScreen(project: project))), child: Text('View All', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)))]),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLegendItem(Colors.green, 'Available'), _buildLegendItem(Colors.orange, 'Booked'),
                            _buildLegendItem(Colors.red, 'Sold Out'), _buildLegendItem(Colors.amber, 'Resale'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('FEATURED PLOT', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Row(children: [Text('No. 123', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text('20x30 sq.ft', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey))])]),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text('AVAILABLE', style: GoogleFonts.montserrat(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))), const SizedBox(height: 4), Text('₹ 2,151/sq.ft', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]))]),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [Text(title, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)), const SizedBox(height: 4), Text(value, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle, Color primaryBlue) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primaryBlue)),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(subtitle, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(children: [Icon(Icons.circle, size: 10, color: color), const SizedBox(width: 4), Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[700]))]);
  }
}