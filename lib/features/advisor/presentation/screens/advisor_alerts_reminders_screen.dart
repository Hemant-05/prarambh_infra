import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import '../providers/advisor_dashboard_provider.dart';
import '../providers/advisor_project_provider.dart';
import '../../data/models/resale_unit_model.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_unit_details_screen.dart';
import 'package:prarambh_infra/features/admin/data/models/unit_model.dart';
import 'package:prarambh_infra/features/admin/data/models/project_model.dart';

class AdvisorAlertsRemindersScreen extends StatefulWidget {
  const AdvisorAlertsRemindersScreen({super.key});

  @override
  State<AdvisorAlertsRemindersScreen> createState() => _AdvisorAlertsRemindersScreenState();
}

class _AdvisorAlertsRemindersScreenState extends State<AdvisorAlertsRemindersScreen> {
  void _handleResaleTap(BuildContext context, ResaleUnitModel resale) {
    final projectProvider = context.read<AdvisorProjectProvider>();
    ProjectModel? project = projectProvider.projects.firstWhere(
      (p) => p.id == resale.projectId,
      orElse: () => ProjectModel(
        id: resale.projectId,
        projectName: resale.colonyName,
        description: 'Project details for ${resale.colonyName}',
        developerName: 'N/A',
        reraNumber: 'N/A',
        tncpNumber: '',
        landOwnerName: '',
        projectType: resale.propertyType,
        constructionStatus: 'Ready to Move',
        status: 'Active',
        fullAddress: resale.colonyName,
        locationMapUrl: '',
        city: 'N/A',
        marketValue: resale.totalValue,
        totalPlots: 0,
        buildArea: '',
        budgetRange: '',
        ratePerSqft: double.tryParse(resale.ratePerSqft) ?? 0,
        videoUrl: '',
        brochureUrl: '',
        brochureFile: '',
        images: resale.unitImages,
        amenities: [],
        specialties: [],
        createdAt: DateTime.now(),
      ),
    );

    final unit = UnitModel(
      id: resale.id,
      projectId: resale.projectId,
      towerName: resale.towerName,
      floorNumber: resale.floorNumber,
      unitNumber: resale.unitNumber,
      configuration: resale.configuration,
      propertyType: resale.propertyType,
      saleCategory: resale.saleCategory,
      facing: resale.facing,
      location: 'N/A',
      plotNumber: resale.plotNumber,
      plotDimensions: resale.plotDimensions,
      areaSqft: double.tryParse(resale.areaSqft) ?? 0,
      ratePerSqft: double.tryParse(resale.ratePerSqft) ?? 0,
      size: resale.areaSqft,
      availabilityStatus: resale.availabilityStatus,
      unitImages: resale.unitImages,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdvisorUnitDetailsScreen(unit: unit, project: project)),
    );
  }

  Widget _buildResaleCard(ResaleUnitModel unit, Color blue, bool isDark) {
    final isAvailable = unit.isAvailable;
    final statusColor = isAvailable ? Colors.green : Colors.red;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final totalVal = unit.totalValue;
    final formatted = totalVal >= 100000
        ? '₹${(totalVal / 100000).toStringAsFixed(1)}L'
        : '₹${NumberFormat('#,##0', 'en_IN').format(totalVal)}';

    return InkWell(
      onTap: () => _handleResaleTap(context, unit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.home_work_outlined, size: 14, color: Colors.amber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      unit.colonyName.trim(),
                      style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2340)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(unit.configuration, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: blue)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(isAvailable ? 'Available' : 'Sold Out', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Plot ${unit.plotNumber}  ·  ${unit.plotDimensions}', style: GoogleFonts.montserrat(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text('${unit.areaSqft} sq.ft  ·  ${unit.propertyType}', style: GoogleFonts.montserrat(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey.shade500)),
                  const SizedBox(height: 10),
                  Text(formatted, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: blue)),
                  Text('₹${unit.ratePerSqft}/sq.ft', style: GoogleFonts.montserrat(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdvisorDashboardProvider>();
    final allActions = provider.data?.pendingActions ?? [];
    final resaleUnits = provider.resaleUnits.where((u) => u.isAvailable).toList();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text(
          "Alerts & Reminders",
          style: GoogleFonts.montserrat(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: primaryBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.assignment, color: primaryBlue, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  'TASKS & ALERTS',
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
          
          // Tasks list
          Expanded(
            child: _buildTaskList(allActions, isDark, primaryBlue),
          )
        ],
      )
    );
  }

  Widget _buildTaskList(List actions, bool isDark, Color primaryBlue) {
    if (actions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('All caught up!', style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final task = actions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(task.iconType == 'bell' ? Icons.notifications : Icons.event, color: primaryBlue, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(task.subtitle, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(task.time, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
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
    );
  }
}
