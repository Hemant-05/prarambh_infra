import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../providers/admin_provider.dart';
import '../providers/admin_lead_provider.dart';
import '../../../advisor/presentation/screens/lead_details_screen.dart';

class PriorityLeadsScreen extends StatelessWidget {
  const PriorityLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    final adminState = context.watch<AdminProvider>();
    final leadProvider = context.watch<AdminLeadProvider>();
    final leads = adminState.dashboardData?.priorityLeads ?? [];

    // Listen for transient errors from LeadProvider (e.g. on click)
    if (leadProvider.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UIHelper.showError(context, leadProvider.errorMessage!);
        leadProvider.clearError();
      });
    }

    Widget body;
    if (adminState.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (adminState.hasError) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: UIHelper.buildInlineError(
            context: context,
            message: adminState.errorMessage!,
            onRetry: () => adminState.fetchDashboardData(),
          ),
        ),
      );
    } else if (leads.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.priority_high_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No priority leads found',
              style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: leads.length,
        itemBuilder: (context, index) {
          final lead = Map<String, dynamic>.from(leads[index]);
          return _buildPriorityLeadListItem(
            context,
            lead,
            cardColor,
            primaryBlue,
            textColor,
            secondaryTextColor,
            isDark,
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text(
          'All Priority Leads',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildPriorityLeadListItem(
    BuildContext context,
    Map<String, dynamic> lead,
    Color cardColor,
    Color primaryBlue,
    Color? textColor,
    Color? secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
            final fetchedLead = await context
                .read<AdminLeadProvider>()
                .getSingleLead(lead['id'].toString());
            if (context.mounted) {
              Navigator.pop(context);
              if (fetchedLead != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeadDetailsScreen(lead: fetchedLead, isAdmin: true),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(
                        (lead['stage'] ?? 'Pending').toString().toUpperCase().replaceAll('_', ' '),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    Text(
                      (lead['created_at'] ?? '').toString().split(' ')[0],
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  lead['client_name']?.toString() ?? 'Unknown Client',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_android, size: 14, color: primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      lead['client_number']?.toString() ?? '',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.priority_high, size: 14, color: Colors.orange.shade800),
                        const SizedBox(width: 4),
                        Text(
                          'HIGH ATTENTION REQUIRED',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.orange.shade800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, size: 18, color: primaryBlue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
