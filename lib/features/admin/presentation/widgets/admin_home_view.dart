import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/profile_image.dart';
import 'package:prarambh_infra/core/helper/helper_function.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_advisor_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_deal_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/deal_management_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/priority_leads_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/review_application_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_deals_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/lead_management_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/advisor_applications_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/lead_details_screen.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';
import 'package:prarambh_infra/features/admin/data/models/admin_dashboard_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectProvider = context.read<AdminProjectProvider>();
      final adminProvider = context.read<AdminProvider>();

      await projectProvider.fetchProjects();

      if (projectProvider.projects.isNotEmpty &&
          adminProvider.selectedProjectId == null) {
        adminProvider.setProjectId(
          projectProvider.projects.first.id.toString(),
        );
      } else {
        adminProvider.fetchDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final adminState = context.watch<AdminProvider>();
    final projectState = context.watch<AdminProjectProvider>();
    final authState = context.watch<AuthProvider>();
    final currentUser = authState.currentUser;

    if (adminState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adminState.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: UIHelper.buildInlineError(
            context: context,
            message: adminState.errorMessage!,
            onRetry: () => adminState.fetchDashboardData(),
          ),
        ),
      );
    }

    final data = adminState.dashboardData;
    if (data == null) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.montserrat(color: Colors.grey),
        ),
      );
    }
    final double monthlyProgressDec = (data.monthlyProgressPercent / 100.0)
        .clamp(0.0, 1.0);

    final int maxLeads = [
      data.suspectingLeads,
      data.prospectingLeads,
      data.siteVisitingLeads,
      data.bookingLeads,
      data.referralLeads,
    ].reduce(max);

    double getPercent(int leads) {
      if (maxLeads == 0) return 0.0;
      return leads / maxLeads;
    }

    return RefreshIndicator(
      onRefresh: () => adminState.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overlapping Header
            SizedBox(
              height: 140,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: InkWell(
                      onTap: () =>
                          context.read<AdminProvider>().setDashboardIndex(4),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.getBorderColor(context),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ProfileImage(
                                  imageUrl: currentUser?.profilePhoto != null 
                                      ? "https://workiees.com/${currentUser?.profilePhoto}"
                                      : null,
                                  initials: currentUser?.name.isNotEmpty ?? false
                                      ? currentUser!.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                      : 'A',
                                  heroTag: 'admin_home_profile',
                                  radius: 32,
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentUser?.name ?? 'Admin User',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    currentUser?.role.toUpperCase() ??
                                        'ADMINISTRATOR',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Selector
                  if (projectState.projects.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.getBorderColor(context),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: adminState.selectedProjectId,
                          isExpanded: true,
                          hint: Text(
                            "Select Project",
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: primaryBlue,
                          ),
                          dropdownColor: cardColor,
                          items: projectState.projects.map((project) {
                            return DropdownMenuItem<String>(
                              value: project.id.toString(),
                              child: Text(
                                project.projectName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              adminState.setProjectId(val);
                            }
                          },
                        ),
                      ),
                    ),

                  // Units Progress Card
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, '/admin_sales_analytics'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  primaryBlue.withOpacity(0.8),
                                  primaryBlue.withOpacity(0.6),
                                ]
                              : [primaryBlue, primaryBlue.withBlue(255)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.transparent
                                : primaryBlue.withOpacity(0.3),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Units Sold',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        data.unitsSold.toString(),
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' / ${data.unitsTarget}',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Monthly Progress',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${data.monthlyProgressPercent}%',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: monthlyProgressDec,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildPendingActionsSection(
                    context,
                    data,
                    cardColor,
                    primaryBlue,
                    textColor,
                    secondaryTextColor,
                    isDark,
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'High Priority Leads',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PriorityLeadsScreen(),
                          ),
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.montserrat(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  data.priorityLeads.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No priority leads available",
                              style: GoogleFonts.montserrat(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 170,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: data.priorityLeads.length,
                            itemBuilder: (context, index) {
                              final leadData = data.priorityLeads[index];
                              return _buildPriorityLeadCard(
                                context,
                                Map<String, dynamic>.from(leadData),
                                cardColor,
                                primaryBlue,
                                textColor,
                              );
                            },
                          ),
                        ),

                  const SizedBox(height: 30),

                  // Sales Overview
                  Text(
                    'Sales Overview',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                        ),
                      ],
                      border: isDark
                          ? Border.all(color: AppColors.getBorderColor(context))
                          : null,
                    ),
                    child: Column(
                      children: [
                        _buildSalesRow(
                          context,
                          'Suspecting',
                          data.suspectingLeads.toString(),
                          getPercent(data.suspectingLeads),
                          const Color(0xFF2962FF),
                          null,
                          1,
                        ),
                        const SizedBox(height: 16),
                        _buildSalesRow(
                          context,
                          'Prospecting',
                          data.prospectingLeads.toString(),
                          getPercent(data.prospectingLeads),
                          const Color(0xFF448AFF),
                          null,
                          2,
                        ),
                        const SizedBox(height: 16),
                        _buildSalesRow(
                          context,
                          'Site Visiting',
                          data.siteVisitingLeads.toString(),
                          getPercent(data.siteVisitingLeads),
                          const Color(0xFFFF9100),
                          Icons.warning_amber_rounded,
                          3,
                        ),
                        const SizedBox(height: 16),
                        _buildSalesRow(
                          context,
                          'Booking',
                          data.bookingLeads.toString(),
                          getPercent(data.bookingLeads),
                          const Color(0xFF90CAF9),
                          null,
                          4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Pending Verifications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pending Verifications',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/advisor_applications',
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.montserrat(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  data.pendingVerifications.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No pending verifications',
                              style: GoogleFonts.montserrat(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: min(data.pendingVerifications.length, 3),
                          itemBuilder: (context, index) {
                            final ad = data.pendingVerifications[index];
                            return _buildVerificationCard(
                              context,
                              ad['id'].toString(),
                              ad['full_name'].toString(),
                              ad['applied_time_ago'].toString(),
                              ad['profile_photo']?.toString(),
                              cardColor,
                              primaryBlue,
                              textColor,
                            );
                          },
                        ),

                  const SizedBox(height: 30),

                  // Recent Deal Closures
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Deal Done',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDealsScreen(),
                          ),
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.montserrat(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  data.recentClosures.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: min(data.recentClosures.length, 3),
                          itemBuilder: (context, index) {
                            final closure = data.recentClosures[index];
                            final statusColor = Colors.green;
                            return InkWell(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                                try {
                                  final deal = await context
                                      .read<AdminDealProvider>()
                                      .getSingleDeal(closure['id'].toString());
                                  if (deal != null && context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DealManagementScreen(deal: deal),
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            closure['client_name']
                                                    ?.toString() ??
                                                'Unknown Client',
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: textColor,
                                            ),
                                          ),
                                          Text(
                                            (closure['created_at'] ?? '')
                                                .toString()
                                                .split(' ')[0],
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              color: secondaryTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${formatPrice(double.tryParse(closure['payment_amount'])!)}',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.greenAccent
                                                : Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.getBorderColor(context),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'No closures recorded today',
                              style: GoogleFonts.montserrat(
                                color: secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesRow(
    BuildContext context,
    String title,
    String count,
    double percent,
    Color barColor,
    IconData? icon,
    int tabIndex,
  ) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeadManagementScreen(initialIndex: tabIndex),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 4),
                    Icon(icon, size: 14, color: Colors.orange),
                  ],
                ],
              ),
              Row(
                children: [
                  Text(
                    count,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    ' leads',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.getBorderColor(context),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
    BuildContext context,
    String id,
    String name,
    String time,
    String? profilePhoto,
    Color cardColor,
    Color primaryBlue,
    Color? textColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
        border: isDark
            ? Border.all(color: AppColors.getBorderColor(context))
            : null,
      ),
      child: Row(
        children: [
          ProfileImage(
            imageUrl: profilePhoto != null ? "https://workiees.com/$profilePhoto" : null,
            initials: name.isNotEmpty 
                ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                : '?',
            heroTag: 'admin_verify_$id',
            radius: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              final advisor = await context
                  .read<AdminAdvisorProvider>()
                  .getSingleAdvisor(id);
              if (context.mounted) {
                Navigator.pop(context);
                if (advisor != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReviewApplicationScreen(advisor: advisor),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Review',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityLeadCard(
    BuildContext context,
    Map<String, dynamic> lead,
    Color cardColor,
    Color primaryBlue,
    Color? textColor,
  ) {
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
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
                builder: (context) =>
                    LeadDetailsScreen(lead: fetchedLead, isAdmin: true),
              ),
            );
          }
        }
      },
      child: Container(
        width: 200, // Reduced width
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getBorderColor(context)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (lead['created_at'] ?? '').toString().split(' ')[0],
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final number = lead['client_number']?.toString();
                    if (number != null && number.isNotEmpty) {
                      final Uri url = Uri.parse('tel:$number');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      size: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lead['client_name']?.toString() ?? 'Unknown',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              lead['client_number']?.toString() ?? '',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActionsSection(
    BuildContext context,
    AdminDashboardModel data,
    Color cardColor,
    Color primaryBlue,
    Color? textColor,
    Color? secondaryTextColor,
    bool isDark,
  ) {
    if (data.pendingActions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Actions',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                '${data.totalPendingTasks} Tasks',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...data.pendingActions.map(
          (action) => _buildPendingActionCard(
            context,
            action,
            cardColor,
            primaryBlue,
            textColor,
            secondaryTextColor,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActionCard(
    BuildContext context,
    PendingAction action,
    Color cardColor,
    Color primaryBlue,
    Color? textColor,
    Color? secondaryTextColor,
    bool isDark,
  ) {
    IconData iconData;
    Color iconBgColor;
    Color iconColor;

    switch (action.iconType) {
      case 'document_check':
        iconData = Icons.verified_user_outlined;
        iconBgColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
        break;
      case 'user_add':
        iconData = Icons.person_add_outlined;
        iconBgColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade700;
        break;
      case 'briefcase':
        iconData = Icons.work_outline;
        iconBgColor = Colors.purple.shade50;
        iconColor = Colors.purple.shade700;
        break;
      default:
        iconData = Icons.notifications_none;
        iconBgColor = Colors.grey.shade100;
        iconColor = Colors.grey.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (action.title.toLowerCase().contains("career enquiries")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AdvisorApplicationsScreen(initialIndex: 1),
              ),
            );
          } else if (action.title.toLowerCase().contains("kyc approvals")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AdvisorApplicationsScreen(initialIndex: 0),
              ),
            );
          } else if (action.title.toLowerCase().contains("deal verification")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDealsScreen(
                  initialVerificationStatus: 'not verified',
                ),
              ),
            );
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? iconColor.withOpacity(0.1) : iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: secondaryTextColor, size: 20),
          ],
        ),
      ),
    );
  }
}
