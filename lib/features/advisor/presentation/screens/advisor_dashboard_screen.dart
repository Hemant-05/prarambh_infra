import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_profile_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_team_screen.dart';
import 'package:provider/provider.dart';

import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_dashboard_provider.dart';
import '../../data/models/advisor_dashboard_model.dart';

import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_contests_list_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_projects_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_meeting_schedule_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/document_center_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/sales_pipeline_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_achievement_screen.dart';
import '../../../../core/utils/access_helper.dart';

class AdvisorDashboardScreen extends StatefulWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  State<AdvisorDashboardScreen> createState() => _AdvisorDashboardScreenState();
}

class _AdvisorDashboardScreenState extends State<AdvisorDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _appBarTitles = [
    'Business Dashboard',
    'Projects & Inventory',
    'Sales Pipeline',
    'My Team',
    'My Profile',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisorCode =
          context.read<AuthProvider>().currentUser?.advisorCode ?? '';
      context.read<AdvisorDashboardProvider>().fetchDashboardData(advisorCode);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      _buildDashboardContent(context),
      const AdvisorProjectsScreen(),
      const SalesPipelineScreen(),
      const AdvisorTeamScreen(),
      const AdvisorProfileScreen(),
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
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
    );
  }

  // ==========================================
  // MAIN DASHBOARD CONTENT (TAB 0)
  // ==========================================
  Widget _buildDashboardContent(BuildContext context) {
    final provider = context.watch<AdvisorDashboardProvider>();
    final advisor = context.read<AuthProvider>().currentUser;
    final primaryBlue = Theme.of(context).primaryColor;

    if (provider.isLoading || provider.data == null) {
      return Center(child: CircularProgressIndicator(color: primaryBlue));
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

                  _buildSalesConversionHeader(context),
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
        Container(
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
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    backgroundImage: data.profilePhoto.isNotEmpty
                        ? NetworkImage(data.profilePhoto)
                        : null,
                    child: data.profilePhoto.isEmpty
                        ? Icon(Icons.person, size: 30, color: primaryBlue)
                        : null,
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
                          'ID: ${data.advisorId}',
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
                          'Parent: ',
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

    return Container(
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
                Text(
                  data.currentLevel,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'NEXT: ${data.nextLevel}',
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
          Text(
            '${data.progressPercent}%',
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E2A47),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesConversionHeader(BuildContext context) {
    return _buildSectionTitle(context, 'Sales Conversion');
  }

  Widget _buildSalesConversionCards(
    BuildContext context,
    SalesConversion sales,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: [
          _buildSalesCard(
            context,
            sales.suspecting.toString(),
            'SUSPECTING',
            const Color(0xFF2962FF),
          ),
          _buildSalesCard(
            context,
            sales.prospecting.toString(),
            'PROSPECTING',
            const Color(0xFF448AFF),
          ),
          _buildSalesCard(
            context,
            sales.siteVisit.toString(),
            'SITE VISIT',
            const Color(0xFFFF9100),
          ),
          _buildSalesCard(
            context,
            sales.booking.toString(),
            'BOOKING',
            const Color(0xFF4CAF50),
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
    final cardColor = isDark
        ? Theme.of(context).cardColor
        : accentColor.withOpacity(0.1);
    final valueColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? accentColor : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(isDark ? 0.4 : 0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: labelColor,
            ),
          ),
        ],
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
        childAspectRatio: 1.1,
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
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  actions[index]['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
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
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;
    final primaryBlue = Theme.of(context).primaryColor;

    if (metrics.isEmpty) {
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
            "No promotion metrics set yet.",
            style: GoogleFonts.montserrat(color: secondaryTextColor),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.getBorderColor(context).withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'METRIC',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'TARGET',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ACHIEVED',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...metrics.map(
            (m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.getBorderColor(context)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      m.metric,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: m.metric.contains('Team Booking')
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      m.target,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      m.achieved,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContestsHeader(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(context, 'Active Contests'),
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: primaryBlue.withOpacity(0.1),
                  backgroundImage: data != null && data.profilePhoto.isNotEmpty
                      ? NetworkImage(data.profilePhoto)
                      : null,
                  child: data == null || data.profilePhoto.isEmpty
                      ? Icon(Icons.person, size: 35, color: primaryBlue)
                      : null,
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
          _drawerItem(context, Icons.description_outlined, 'Document View', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DocumentCenterScreen(),
              ),
            );
          }),
          _drawerItem(context, Icons.emoji_events_outlined, 'Contests', () {
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
            'My Income',
            () {
              Navigator.pushNamed(context, '/my_income_analytics');
            },
          ),
          _drawerItem(
            context,
            Icons.event_available_outlined,
            'Upcoming Installment',
            () {
              Navigator.pushNamed(context, '/upcoming_installments');
            },
          ),
          _drawerItem(
            context,
            Icons.military_tech_outlined,
            'Achievements',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvisorAchievementScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.calculate_outlined,
            'Calculator - INSTALLMENT',
            () {
              Navigator.pushNamed(context, '/installment_calculator');
            },
          ),
          _drawerItem(
            context,
            Icons.badge_outlined,
            'Meeting & Attendance',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvisorMeetingScheduleScreen(),
                ),
              );
            },
          ),
          _drawerItem(context, Icons.leaderboard_outlined, 'Leader board', () {
            Navigator.pushNamed(context, '/advisor_leaderboard');
          }),
          _drawerItem(context, Icons.people_outline, 'My Recruitment', () {
            if (AdvisorAccessHelper.check(context, feature: 'recruitment')) {
              Navigator.pushNamed(context, '/recruiter_dashboard');
            }
          }),
          _drawerItem(context, Icons.campaign_outlined, 'Promotions', () {}),
          _drawerItem(
            context,
            Icons.groups_outlined,
            'Business plan - click 6 points',
            () {},
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
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
              context.read<AuthProvider>().logout();
            },
          ),
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
}
