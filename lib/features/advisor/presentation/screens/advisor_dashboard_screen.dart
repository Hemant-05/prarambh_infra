import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/core/widgets/profile_image.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_profile_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_profile_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_team_screen.dart';
import 'package:provider/provider.dart';

import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_dashboard_provider.dart';
import '../../data/models/advisor_dashboard_model.dart';
import '../../data/models/resale_unit_model.dart';
import '../providers/advisor_lead_provider.dart';
import '../providers/advisor_project_provider.dart';
import '../providers/advisor_team_provider.dart';
import '../providers/advisor_profile_provider.dart';

import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_contests_list_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_projects_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_meeting_schedule_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/document_center_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/sales_pipeline_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_edit_profile_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_promotion_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_achievement_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/career_growth_screen.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../../../../core/utils/access_helper.dart';
import '../../../../core/utils/ui_helper.dart';
import '../../../../core/globals.dart';
import '../../../../core/widgets/top_performers_dialog.dart';

class AdvisorDashboardScreen extends StatefulWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  State<AdvisorDashboardScreen> createState() => _AdvisorDashboardScreenState();
}

class _AdvisorDashboardScreenState extends State<AdvisorDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _appBarTitles = [
    'ADVISOR DASHBOARD',
    'MY PROFILE',
    'PROJECTS & INVENTORY',
    'SALES PIPELINE',
    'MY TEAM',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisor = context.read<AuthProvider>().currentUser;
      final advisorCode = advisor?.advisorCode ?? '';

      context.read<AdvisorDashboardProvider>().fetchDashboardData(advisorCode);

      TopPerformersDialog.show(
        context,
        userId: advisor?.id.toString() ?? '1',
        onViewTeam: () {
          setState(() {
            _selectedIndex = 4; // Team tab index is 3
          });
        },
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleGlobalRefresh() async {
    final authProvider = context.read<AuthProvider>();
    final advisorCode = authProvider.currentUser?.advisorCode ?? '';
    final advisorId = authProvider.currentUser?.id.toString() ?? '';

    switch (_selectedIndex) {
      case 0:
        final timeframe = context
            .read<AdvisorDashboardProvider>()
            .selectedTimeframe;
        await context.read<AdvisorDashboardProvider>().fetchDashboardData(
          advisorCode,
          timeframe: timeframe,
        );
        break;
      case 1:
        await context.read<AdvisorProfileProvider>().fetchProfileByCode(
          advisorCode,
        );
        break;
      case 2:
        await context.read<AdvisorProjectProvider>().fetchProjects();
        break;
      case 3:
        await context.read<AdvisorLeadProvider>().fetchLeads(
          advisorCode: advisorCode,
        );
        break;
      case 4:
        await context.read<AdvisorTeamProvider>().fetchTeamTree(advisorId);
        break;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_appBarTitles[_selectedIndex]} Refreshed'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>();
    if (authState.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      _buildDashboardContent(context),
      const AdvisorProfileScreen(),
      const AdvisorProjectsScreen(),
      const SalesPipelineScreen(),
      const AdvisorTeamScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryBlue,
        title: Text(
          _appBarTitles[_selectedIndex],
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleGlobalRefresh,
          ),
          if (_selectedIndex == 1)
            Consumer<AdvisorProfileProvider>(
              builder: (context, profileProvider, _) {
                if (profileProvider.profile == null) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const Icon(Icons.edit_note, size: 28),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdvisorEditProfileScreen(
                        profile: profileProvider.profile!,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: primaryBlue,
          unselectedItemColor: isDark ? Colors.white60 : Colors.grey.shade500,
          selectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.dashboard_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.dashboard_rounded),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person),
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.business_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.business),
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.trending_up_rounded),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.trending_up, size: 26),
              ),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.people_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.people),
              ),
              label: 'Team',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildGlobalTaskReminderBar(context),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: screens),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAIN DASHBOARD CONTENT (TAB 0)
  // ==========================================
  Widget _buildDashboardContent(BuildContext context) {
    final provider = context.watch<AdvisorDashboardProvider>();
    final advisor = context.read<AuthProvider>().currentUser;
    final primaryBlue = Theme.of(context).primaryColor;

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryBlue));
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: UIHelper.buildInlineError(
            context: context,
            message: provider.errorMessage!,
            onRetry: () =>
                provider.fetchDashboardData(advisor?.advisorCode ?? ''),
          ),
        ),
      );
    }

    if (provider.data == null) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.montserrat(color: Colors.grey),
        ),
      );
    }

    final data = provider.data!;

    return RefreshIndicator(
      onRefresh: () => provider.fetchDashboardData(advisor?.advisorCode ?? ''),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopProfileCard(context, data),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Career Progress'),
                  _buildCareerProgress(context, data),
                  const SizedBox(height: 24),

                  _buildSalesConversionHeader(
                    context,
                    provider,
                    advisor?.advisorCode ?? '',
                  ),
                  const SizedBox(height: 12),
                  _buildSalesConversionCards(context, data.sales),
                  const SizedBox(height: 24),

                  _buildSectionTitle(context, 'Quick Actions'),
                  _buildQuickActionsGrid(context),
                  const SizedBox(height: 24),

                  _buildPendingActionsHeader(
                    context,
                    data.pendingActions.length,
                  ),
                  _buildPendingActionsList(context, data.pendingActions),
                  const SizedBox(height: 24),

                  _buildSectionTitle(context, 'Promotion Status'),
                  _buildPromotionStatusTable(context, data.promotionStatus),
                  const SizedBox(height: 24),

                  _buildActiveContestsHeader(context),
                  _buildActiveContestsList(context, data.activeContests),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UI WIDGET COMPONENTS
  // ==========================================
  Widget _buildTopProfileCard(
    BuildContext context,
    AdvisorDashboardModel data,
  ) {
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdvisorProfileScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBorderColor(context)),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProfileImage(
                      imageUrl: data.profilePhoto.isNotEmpty
                          ? data.profilePhoto
                          : null,
                      initials: data.initials,
                      heroTag: 'top_profile_photo',
                      radius: 35,
                    ),
                    Positioned(
                      bottom: -8,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data.status.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          data.role,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ADV CODE: ${data.advisorId}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Leader: ',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              data.parentName,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
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
        ),
      ],
    );
  }

  Widget _buildCareerProgress(
    BuildContext context,
    AdvisorDashboardModel data,
  ) {
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CareerGrowthScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark
                    ? primaryBlue.withOpacity(0.2)
                    : const Color(0xFF1E2A47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.star_border, color: Colors.white, size: 30),
                  Positioned(
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'LVL',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        data.currentLevel,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${data.progressPercent}%',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E2A47),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'NEXT PROMOTION: ${data.nextLevel}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_outward, size: 12, color: primaryBlue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesConversionHeader(
    BuildContext context,
    AdvisorDashboardProvider provider,
    String advisorCode,
  ) {
    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timeframes = [
      {'label': 'All Time', 'value': ''},
      {'label': 'Weekly', 'value': 'weekly'},
      {'label': 'Monthly', 'value': 'monthly'},
      {'label': 'Quarterly', 'value': 'quarterly'},
      {'label': 'Yearly', 'value': 'yearly'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(context, 'Sales Conversion'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedTimeframe,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: primaryBlue,
              ),
              elevation: 16,
              style: GoogleFonts.montserrat(
                color: primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              dropdownColor: Theme.of(context).cardColor,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  provider.updateTimeframe(advisorCode, newValue);
                }
              },
              items: timeframes.map<DropdownMenuItem<String>>((
                Map<String, String> tf,
              ) {
                return DropdownMenuItem<String>(
                  value: tf['value'],
                  child: Text(tf['label']!),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesConversionCards(
    BuildContext context,
    SalesConversion sales,
  ) {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSalesCard(
            context,
            sales.suspecting.toString(),
            'SUSPECTING',
            const Color(0xFF6366F1),
          ),
          _buildSalesCard(
            context,
            sales.prospecting.toString(),
            'PROSPECTING',
            const Color(0xFF3B82F6), // Blue
          ),
          _buildSalesCard(
            context,
            sales.siteVisit.toString(),
            'SITE VISIT',
            const Color(0xFFF59E0B), // Amber
          ),
          _buildSalesCard(
            context,
            sales.booking.toString(),
            'BOOKING',
            const Color(0xFF10B981), // Emerald
          ),
          _buildSalesCard(
            context,
            sales.completed.toString(),
            'COMPLETED',
            const Color(0xFF059669), // Green
          ),
        ],
      ),
    );
  }

  Widget _buildSalesCard(
    BuildContext context,
    String value,
    String label,
    Color accentColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : accentColor.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.05 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;

    final actions = [
      {'icon': Icons.description_outlined, 'label': 'Document\nView'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'My Income'},
      {
        'icon': Icons.event_available_outlined,
        'label': 'Upcoming\nInstallment',
      },
      {'icon': Icons.event_note_outlined, 'label': 'Attendance'},
      {'icon': Icons.calculate_outlined, 'label': 'Calculator'},
      {'icon': Icons.pie_chart_outline, 'label': 'Business Plan'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (actions[index]['label'] == 'Calculator') {
              Navigator.pushNamed(context, '/installment_calculator');
            }
            if (actions[index]['label'] == 'Document\nView') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DocumentCenterScreen()),
              );
            }
            if (actions[index]['label'] == 'Attendance') {
              if (AdvisorAccessHelper.check(context, feature: 'attendance')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdvisorMeetingScheduleScreen(),
                  ),
                );
              }
            }
            if (actions[index]['label'] == 'Upcoming\nInstallment') {
              Navigator.pushNamed(context, '/upcoming_installments');
            }
            if (actions[index]['label'] == 'My Income') {
              Navigator.pushNamed(context, '/my_income_analytics');
            }
            if (actions[index]['label'] == 'Business Plan') {
              Navigator.pushNamed(context, '/business_plan');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryBlue.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  actions[index]['icon'] as IconData,
                  color: primaryBlue,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  actions[index]['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    color: primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingActionsHeader(BuildContext context, int count) {
    final primaryBlue = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(context, 'Pending Actions'),
        Text(
          '$count Tasks',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActionsList(
    BuildContext context,
    List<PendingAction> actions,
  ) {
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;

    if (actions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getBorderColor(context)),
        ),
        child: Center(
          child: Text(
            "No pending tasks! 🎉",
            style: GoogleFonts.montserrat(color: secondaryTextColor),
          ),
        ),
      );
    }

    List<Color> iconColors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.teal,
    ];
    List<IconData> icons = [
      Icons.shortcut,
      Icons.assignment_outlined,
      Icons.calendar_today_outlined,
      Icons.schedule,
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppColors.getBorderColor(context)),
        itemBuilder: (context, index) {
          final action = actions[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColors[index % iconColors.length].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icons[index % icons.length],
                color: iconColors[index % iconColors.length],
              ),
            ),
            title: Text(
              action.title,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            subtitle: Text(
              action.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
            trailing: Text(
              action.time,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotionStatusTable(
    BuildContext context,
    List<PromotionMetric> metrics,
  ) {
    if (metrics.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getBorderColor(context)),
        ),
        child: Center(
          child: Text(
            "No promotion metrics available right now.",
            style: GoogleFonts.montserrat(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: metrics.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;

          double progress = (double.tryParse(m.achieved) ?? 0) / 100;
          if (progress > 1.0) progress = 1.0;
          if (progress < 0) progress = 0;

          IconData metricIcon = Icons.auto_graph;
          if (m.metric.contains('Booking')) {
            metricIcon = Icons.shopping_bag_outlined;
          }
          if (m.metric.contains('Team Size')) {
            metricIcon = Icons.groups_outlined;
          }
          if (m.metric.contains('Attendance')) {
            metricIcon = Icons.event_available_outlined;
          }

          return Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(metricIcon, size: 18, color: primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            m.metric,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${m.achieved}%',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Colors.green : primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Achieved: ',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            m.metric.contains('Attendance')
                                ? '${m.achievedNumber}%'
                                : m.achievedNumber.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Target: ',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            m.metric.contains('Attendance')
                                ? '${m.targetNumber}%'
                                : m.targetNumber.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (index < metrics.length - 1)
                Divider(height: 32, color: AppColors.getBorderColor(context)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveContestsHeader(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(context, 'Active Contest'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'RUNNING',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveContestsList(
    BuildContext context,
    List<ActiveContest> contests,
  ) {
    final cardColor = Theme.of(context).cardColor;
    final primaryBlue = Theme.of(context).primaryColor;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    if (contests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getBorderColor(context)),
        ),
        child: Center(
          child: Text(
            "No active contests right now.",
            style: GoogleFonts.montserrat(color: secondaryTextColor),
          ),
        ),
      );
    }

    List<IconData> icons = [
      Icons.military_tech_outlined,
      Icons.location_on_outlined,
      Icons.calendar_month_outlined,
      Icons.card_giftcard_outlined,
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contests.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(context)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icons[index % icons.length], color: primaryBlue),
            ),
            title: Text(
              contests[index].title,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            subtitle: contests[index].subtitle != null
                ? Text(
                    contests[index].subtitle!,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: primaryBlue,
                    ),
                  )
                : null,
            trailing: Icon(Icons.chevron_right, color: secondaryTextColor),
            onTap: () {
              // Navigator to contest details
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Text(
    title,
    style: GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    ),
  );

  // ==========================================
  // SIDE DRAWER WIDGET
  // ==========================================
  Widget _buildDrawer() {
    final provider = context.watch<AdvisorDashboardProvider>();
    final data = provider.data;
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ProfileImage(
                  imageUrl: (data != null && data.profilePhoto.isNotEmpty)
                      ? data.profilePhoto
                      : null,
                  initials: data?.initials ?? '?',
                  heroTag: 'drawer_profile_photo',
                  radius: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  data?.name ?? 'Loading...',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '${data?.role.toUpperCase() ?? ''} : #${data?.advisorId ?? ''}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.getBorderColor(context)),
          _drawerItem(context, Icons.description_outlined, 'DOCUMENT VIEW', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DocumentCenterScreen(),
              ),
            );
          }),
          _drawerItem(context, Icons.emoji_events_outlined, 'CONTEST', () {
            if (AdvisorAccessHelper.check(context, feature: 'contests')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvisorContestsListScreen(),
                ),
              );
            }
          }),
          _drawerItem(
            context,
            Icons.account_balance_wallet_outlined,
            'MY INCOME',
            () {
              Navigator.pushNamed(context, '/my_income_analytics');
            },
          ),
          _drawerItem(
            context,
            Icons.event_available_outlined,
            'UPCOMING INSTALLMENT',
            () {
              Navigator.pushNamed(context, '/upcoming_installments');
            },
          ),
          _drawerItem(context, Icons.military_tech_outlined, 'ACHIEVEMENT', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdvisorAchievementScreen(),
              ),
            );
          }),
          _drawerItem(
            context,
            Icons.calculate_outlined,
            'CALCULATOR - INSTALLMENT',
            () {
              Navigator.pushNamed(context, '/installment_calculator');
            },
          ),
          _drawerItem(
            context,
            Icons.badge_outlined,
            'MEETING & ATTENDANCE',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvisorMeetingScheduleScreen(),
                ),
              );
            },
          ),
          _drawerItem(context, Icons.leaderboard_outlined, 'STARWALL', () {
            Navigator.pushNamed(context, '/advisor_leaderboard');
          }),
          _drawerItem(context, Icons.people_outline, 'MY RECRUITMENT', () {
            if (AdvisorAccessHelper.check(context, feature: 'recruitment')) {
              Navigator.pushNamed(context, '/recruiter_dashboard');
            }
          }),
          _drawerItem(context, Icons.campaign_outlined, 'PROMOTION', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CareerGrowthScreen(),
              ),
            );
          }),
          _drawerItem(
            context,
            Icons.groups_outlined,
            'BUSINESS PLAN', // Shortened label
            () {
              if (AdvisorAccessHelper.check(
                context,
                feature: 'business_plan',
              )) {
                Navigator.pushNamed(context, '/business_plan');
              }
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'EXTERNAL LINKS',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _drawerItem(
            context,
            Icons.gavel_outlined,
            'RERA COMPLIANCE',
            () => launchUrl(Uri.parse('https://rera.mp.gov.in')),
          ),
          _drawerItem(
            context,
            Icons.language_outlined,
            'COMPANY WEBSITE',
            () => launchUrl(Uri.parse('https://prarambhinfra.com')),
          ),
          Divider(color: AppColors.getBorderColor(context)),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Log Out',
              style: GoogleFonts.montserrat(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              // 1. Close drawer
              Navigator.pop(context);
              // 2. Clear Auth State (Sets currentUser=null and wipes storage)
              await context.read<AuthProvider>().logout();
              // 3. Navigate away using Nav Key to ensure context is valid
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildGlobalTaskReminderBar(BuildContext context) {
    return Consumer<AdvisorDashboardProvider>(
      builder: (context, provider, _) {
        final tasks = provider.data?.pendingActions ?? [];
        if (tasks.isEmpty) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: () => _showPendingTasksBottomSheet(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.orange.withOpacity(0.2),
                        Colors.orange.withOpacity(0.1),
                      ]
                    : [Colors.orange.shade50, Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.orange.withOpacity(isDark ? 0.3 : 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notification_important,
                    size: 16,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alerts",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.orange
                              : Colors.orange.shade900,
                        ),
                      ),
                      Text(
                        "${tasks.length} tasks · Resale properties available",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "VIEW ALL",
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPendingTasksBottomSheet(BuildContext context) {
    final provider = context.read<AdvisorDashboardProvider>();
    final tasks = provider.data?.pendingActions ?? [];
    final resaleUnits = provider.resaleUnits.where((u) => u.isAvailable).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Alerts & Reminders",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${tasks.length} Tasks",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                  children: [
                    // ── Resale Properties Section ──────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.home_work_outlined,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'RESALE PROPERTIES',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${resaleUnits.length} Listed',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    resaleUnits.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.04)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'No resale properties available',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 170,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: resaleUnits.length,
                              itemBuilder: (ctx, i) => _buildResaleCard(
                                resaleUnits[i],
                                primaryBlue,
                                isDark,
                              ),
                            ),
                          ),

                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8),

                    // ── Pending Tasks Section ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.task_alt_outlined,
                              color: primaryBlue,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PENDING TASKS',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (tasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 40,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'All caught up!',
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...tasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    task.iconType == 'bell'
                                        ? Icons.notifications
                                        : Icons.event,
                                    color: primaryBlue,
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
                                        task.title,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.subtitle,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            task.time,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
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
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        );
      },
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

    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.home_work_outlined,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    unit.colonyName.trim(),
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A2340),
                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        unit.configuration,
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Sold Out',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Plot ${unit.plotNumber}  ·  ${unit.plotDimensions}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${unit.areaSqft} sq.ft  ·  ${unit.propertyType}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatted,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
                Text(
                  '₹${unit.ratePerSqft}/sq.ft',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
