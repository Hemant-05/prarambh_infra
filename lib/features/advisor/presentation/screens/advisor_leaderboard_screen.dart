import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:prarambh_infra/core/widgets/profile_image.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/advisor_leaderboard_provider.dart';
import '../../data/models/advisor_leaderboard_model.dart';

class AdvisorLeaderboardScreen extends StatefulWidget {
  const AdvisorLeaderboardScreen({super.key});

  @override
  State<AdvisorLeaderboardScreen> createState() =>
      _AdvisorLeaderboardScreenState();
}

class _AdvisorLeaderboardScreenState extends State<AdvisorLeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvisorLeaderboardProvider>().fetchLeaderboard();
    });
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(1)}L";
    } else if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(1)}K";
    }
    return "₹${amount.toStringAsFixed(0)}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final provider = context.watch<AdvisorLeaderboardProvider>();

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: !isDark),
        title: Text(
          'STARWALL',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () => _showDateFilter(context, provider),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Category Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    _buildTab('Sales', provider, primaryBlue, isDark),
                    _buildTab('Recruitment', provider, primaryBlue, isDark),
                    _buildTab('Attendance', provider, primaryBlue, isDark),
                  ],
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryBlue))
                  : RefreshIndicator(
                      color: primaryBlue,
                      onRefresh: () => provider.fetchLeaderboard(),
                      child: provider.allAdvisors.isEmpty
                          ? _buildEmptyState(primaryBlue)
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      'Top Performers',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  if (provider.topThree.isNotEmpty)
                                    _buildPodiumLayer(
                                      provider.topThree,
                                      primaryBlue,
                                      isDark,
                                      provider.currentTab,
                                    ),
                                  const SizedBox(height: 40),
                                  if (provider.remainingAdvisors.isNotEmpty) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rankings',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              provider.currentTab == 'Sales'
                                                  ? 'Total Sales '
                                                  : (provider.currentTab ==
                                                            'Recruitment'
                                                        ? 'Team Size '
                                                        : 'Rank '),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                color: primaryBlue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_downward,
                                              size: 14,
                                              color: primaryBlue,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...List.generate(
                                      provider.remainingAdvisors.length,
                                      (index) {
                                        final advisor =
                                            provider.remainingAdvisors[index];
                                        final rank = index + 4;
                                        return _buildListItem(
                                          advisor,
                                          rank,
                                          primaryBlue,
                                          isDark,
                                          provider.currentTab,
                                          provider.allAdvisors.first,
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumLayer(
    List<AdvisorLeaderboardModel> topThree,
    Color primaryBlue,
    bool isDark,
    String currentTab,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (topThree.length >= 2)
          Expanded(
            child: _buildPodiumProfile(
              topThree[1],
              2,
              primaryBlue,
              isDark,
              currentTab,
            ),
          ),
        if (topThree.isNotEmpty)
          Expanded(
            child: _buildPodiumProfile(
              topThree[0],
              1,
              primaryBlue,
              isDark,
              currentTab,
              isCenter: true,
            ),
          ),
        if (topThree.length >= 3)
          Expanded(
            child: _buildPodiumProfile(
              topThree[2],
              3,
              primaryBlue,
              isDark,
              currentTab,
            ),
          ),
      ],
    );
  }

  Widget _buildPodiumProfile(
    AdvisorLeaderboardModel advisor,
    int rank,
    Color primaryBlue,
    bool isDark,
    String currentTab, {
    bool isCenter = false,
  }) {
    final double avatarSize = isCenter ? 45 : 35;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    String mainValue = "";
    String trendLabel = "";
    if (currentTab == 'Sales') {
      mainValue = advisor.formattedRevenue;
      trendLabel = "${advisor.totalDeals} Deals";
    } else if (currentTab == 'Recruitment') {
      mainValue = "${advisor.teamSize}";
      trendLabel = "Members";
    } else {
      mainValue = "${advisor.attendancePercentage.toStringAsFixed(0)}%";
      trendLabel = "Attendance";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(isCenter ? 3 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isCenter
                    ? Border.all(color: primaryBlue, width: 2)
                    : null,
              ),
              child: ProfileImage(
                imageUrl: (advisor.profilePhoto != null && advisor.profilePhoto!.isNotEmpty)
                    ? advisor.avatarUrl
                    : null,
                initials: advisor.fullName.isNotEmpty 
                    ? advisor.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                    : 'A',
                heroTag: 'leaderboard_podium_${advisor.id}',
                radius: avatarSize,
              ),
            ),
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCenter
                      ? Colors.amber
                      : (rank == 2 ? Colors.grey[400] : Colors.brown[300]),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  '$rank',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isCenter ? 12 : 8),
        Text(
          advisor.fullName,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          mainValue,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: primaryBlue,
          ),
        ),
        Text(
          trendLabel,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 10,
            color: secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (isCenter) const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildListItem(
    AdvisorLeaderboardModel advisor,
    int rank,
    Color primaryBlue,
    bool isDark,
    String currentTab,
    AdvisorLeaderboardModel topAdvisor,
  ) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    double progress = 0;
    String statusLabel = "";
    String secondaryLabel = "";

    if (currentTab == 'Sales') {
      progress = topAdvisor.totalRevenue > 0
          ? (advisor.totalRevenue / topAdvisor.totalRevenue)
          : 0;
      statusLabel = advisor.formattedRevenue;
      secondaryLabel = "${advisor.totalDeals} Deals";
    } else if (currentTab == 'Recruitment') {
      progress = topAdvisor.teamSize > 0
          ? (advisor.teamSize / topAdvisor.teamSize)
          : 0;
      statusLabel = "${advisor.teamSize}";
      secondaryLabel = "Members";
    } else {
      progress = (advisor.attendancePercentage / 100);
      statusLabel = "${advisor.attendancePercentage.toStringAsFixed(0)}%";
      secondaryLabel = "Attendance";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ProfileImage(
            imageUrl: (advisor.profilePhoto != null && advisor.profilePhoto!.isNotEmpty)
                ? advisor.avatarUrl
                : null,
            initials: advisor.fullName.isNotEmpty 
                ? advisor.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                : 'A',
            heroTag: 'leaderboard_list_${advisor.id}',
            radius: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisor.fullName,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Stack(
                  children: [
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statusLabel,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.greenAccent : const Color(0xFF2E7D32),
                ),
              ),
              Text(
                secondaryLabel,
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryBlue) {
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final hintColor = Theme.of(context).hintColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 80,
            color: hintColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No StarWall data available',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    String title,
    AdvisorLeaderboardProvider provider,
    Color primaryBlue,
    bool isDark,
  ) {
    final isSelected = provider.currentTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTab(title),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showDateFilter(
    BuildContext context,
    AdvisorLeaderboardProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter Timeframe",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: provider.selectedMonth,
                      decoration: const InputDecoration(
                        labelText: "Month",
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(_getMonthName(i + 1)),
                        ),
                      ),
                      onChanged: (val) {
                        provider.setTimeframe(val!, provider.selectedYear);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: provider.selectedYear,
                      decoration: const InputDecoration(
                        labelText: "Year",
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        3,
                        (i) => DropdownMenuItem(
                          value: 2024 + i,
                          child: Text((2024 + i).toString()),
                        ),
                      ),
                      onChanged: (val) {
                        provider.setTimeframe(provider.selectedMonth, val!);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
