import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../providers/admin_leaderboard_provider.dart';
import '../../data/models/advisor_rank_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeaderboardProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final provider = context.watch<AdminLeaderboardProvider>();

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ADVISOR STARWALL',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
            // Updated Toggle Switch for 3 Tabs
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
                    _buildTab('Sales Volume', provider, primaryBlue, isDark),
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
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top 3',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Premium Podium Layout
                            if (provider.topThree.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (provider.topThree.length >= 2)
                                    Expanded(
                                      child: _buildPodiumProfile(
                                        provider.topThree[1],
                                        2,
                                        primaryBlue,
                                        isDark,
                                        provider.currentTab,
                                      ),
                                    ),
                                  if (provider.topThree.isNotEmpty)
                                    Expanded(
                                      child: _buildPodiumProfile(
                                        provider.topThree[0],
                                        1,
                                        primaryBlue,
                                        isDark,
                                        provider.currentTab,
                                        isCenter: true,
                                      ),
                                    ),
                                  if (provider.topThree.length >= 3)
                                    Expanded(
                                      child: _buildPodiumProfile(
                                        provider.topThree[2],
                                        3,
                                        primaryBlue,
                                        isDark,
                                        provider.currentTab,
                                      ),
                                    ),
                                ],
                              ),

                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'All Advisors',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Rank ',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: primaryBlue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Remaining List
                            if (provider.remainingAdvisors.isEmpty && provider.topThree.length < 4)
                               Center(child: Padding(
                                 padding: const EdgeInsets.only(top: 40),
                                 child: Text("No more advisors", style: TextStyle(color: Colors.grey[600])),
                               ))
                            else
                              ...provider.remainingAdvisors.map(
                                (advisor) =>
                                    _buildListItem(advisor, primaryBlue, isDark, provider.currentTab, provider.allAdvisors.first),
                              ),
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

  Widget _buildTab(
    String title,
    AdminLeaderboardProvider provider,
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
            title == 'Sales Volume' ? 'Sales' : title,
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

  Widget _buildPodiumProfile(
    AdvisorRankModel advisor,
    int rank,
    Color primaryBlue,
    bool isDark,
    String currentTab, {
    bool isCenter = false,
  }) {
    final double avatarSize = isCenter ? 42 : 32;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    String mainValue = "";
    String trendValue = "";
    if (currentTab == 'Sales Volume') {
      mainValue = advisor.formattedRevenue;
      trendValue = "${advisor.totalDeals} Deals";
    } else if (currentTab == 'Recruitment') {
      mainValue = "${advisor.teamSize}";
      trendValue = "Members";
    } else {
      mainValue = "${advisor.attendancePercentage.toStringAsFixed(0)}%";
      trendValue = "Attendance";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCenter ? Colors.amber : (rank == 2 ? Colors.grey.shade400 : Colors.brown.shade300),
                  width: isCenter ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: InkWell(
                onTap: () {
                  if (advisor.profilePhoto != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          imageUrl: advisor.avatarUrl,
                          heroTag: 'admin_leaderboard_podium_${advisor.id}',
                        ),
                      ),
                    );
                  }
                },
                child: Hero(
                  tag: 'admin_leaderboard_podium_${advisor.id}',
                  child: CircleAvatar(
                    radius: avatarSize,
                    backgroundColor: Colors.white,
                    backgroundImage: advisor.profilePhoto != null ? NetworkImage(advisor.avatarUrl) : null,
                    child: advisor.profilePhoto == null ? Text(advisor.fullName[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)) : null,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
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
        const SizedBox(height: 18),
        Text(
          advisor.fullName,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
            fontSize: 15,
            color: primaryBlue,
          ),
        ),
        Text(
          trendValue,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isCenter) const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildListItem(
    AdvisorRankModel advisor,
    Color primaryBlue,
    bool isDark,
    String currentTab,
    AdvisorRankModel topAdvisor,
  ) {
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    double progress = 0;
    String statusLabel = "";
    String secondaryLabel = "";
    
    if (currentTab == 'Sales Volume') {
      progress = topAdvisor.totalRevenue > 0 ? (advisor.totalRevenue / topAdvisor.totalRevenue) : 0;
      statusLabel = advisor.formattedRevenue;
      secondaryLabel = "${advisor.totalDeals} Deals";
    } else if (currentTab == 'Recruitment') {
      progress = topAdvisor.teamSize > 0 ? (advisor.teamSize / topAdvisor.teamSize) : 0;
      statusLabel = "${advisor.teamSize}";
      secondaryLabel = "Members";
    } else {
      progress = (advisor.attendancePercentage / 100);
      statusLabel = "${advisor.attendancePercentage.toStringAsFixed(0)}%";
      secondaryLabel = "Attendance";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              '${advisor.rank}',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              if (advisor.profilePhoto != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageViewer(
                      imageUrl: advisor.avatarUrl,
                      heroTag: 'admin_leaderboard_list_${advisor.id}',
                    ),
                  ),
                );
              }
            },
            child: Hero(
              tag: 'admin_leaderboard_list_${advisor.id}',
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage: advisor.profilePhoto != null ? NetworkImage(advisor.avatarUrl) : null,
                child: advisor.profilePhoto == null ? Text(advisor.fullName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)) : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisor.fullName,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 6,
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
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statusLabel,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
              Text(
                secondaryLabel,
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDateFilter(BuildContext context, AdminLeaderboardProvider provider) {
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
                      decoration: const InputDecoration(labelText: "Month", border: OutlineInputBorder()),
                      items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_getMonthName(i + 1)))),
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
                      decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
                      items: List.generate(3, (i) => DropdownMenuItem(value: 2024 + i, child: Text((2024 + i).toString()))),
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

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}
