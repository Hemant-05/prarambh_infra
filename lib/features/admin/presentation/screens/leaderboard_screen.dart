import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_leaderboard_provider.dart';
import '../../data/models/advisor_rank_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeaderboardProvider>().fetchLeaderboard('sales');
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final provider = context.watch<AdminLeaderboardProvider>();

    return Scaffold(
      backgroundColor: primaryBlue, // Top part is blue
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ADVISOR LEADERBOARD',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Custom Toggle Switch
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
                    _buildTab(context, 'Sales Volume', provider, primaryBlue),
                    _buildTab(context, 'Recruitment', provider, primaryBlue),
                  ],
                ),
              ),
            ),

            Expanded(
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryBlue))
                  : RefreshIndicator(
                color: primaryBlue,
                onRefresh: () => provider.fetchLeaderboard(provider.currentTab.toLowerCase().contains('sales') ? 'sales' : 'recruitment'),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top 3', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 20),

                      // Podium Layout
                      if (provider.topThree.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (provider.topThree.length >= 2)
                              Expanded(child: _buildPodiumProfile(provider.topThree[1], 2, primaryBlue, isDark)),
                            if (provider.topThree.isNotEmpty)
                              Expanded(child: _buildPodiumProfile(provider.topThree[0], 1, primaryBlue, isDark, isCenter: true)),
                            if (provider.topThree.length >= 3)
                              Expanded(child: _buildPodiumProfile(provider.topThree[2], 3, primaryBlue, isDark)),
                          ],
                        ),

                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('All Advisors', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          Row(
                            children: [
                              Text('Rank ', style: GoogleFonts.montserrat(fontSize: 14, color: primaryBlue, fontWeight: FontWeight.w600)),
                              Icon(Icons.arrow_downward, size: 16, color: primaryBlue),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Remaining List
                      ...provider.remainingAdvisors.map((advisor) => _buildListItem(advisor, primaryBlue, isDark)).toList(),
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

  Widget _buildTab(BuildContext context, String title, AdminLeaderboardProvider provider, Color primaryBlue) {
    final isSelected = provider.currentTab == title;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumProfile(AdvisorRankModel advisor, int rank, Color primaryBlue, bool isDark, {bool isCenter = false}) {
    final double avatarSize = isCenter ? 45 : 35;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(isCenter ? 3 : 0), // Outer ring for Rank 1
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isCenter ? Border.all(color: primaryBlue, width: 2) : null,
              ),
              child: CircleAvatar(
                radius: avatarSize,
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage(logo), // Replace with actual avatar
              ),
            ),
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA), width: 2),
                ),
                child: Text('$rank', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        SizedBox(height: isCenter ? 12 : 8),
        Text(advisor.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: textColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(advisor.primaryValue, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlue)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(advisor.isTrendPositive ? Icons.arrow_outward : Icons.south_east, size: 10, color: Colors.grey[600]),
            Text(advisor.trend, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        if (isCenter) const SizedBox(height: 10), // Push the center one up slightly
      ],
    );
  }

  Widget _buildListItem(AdvisorRankModel advisor, Color primaryBlue, bool isDark) {
    final cardColor = AppColors.getCardColor(context);
    final textColor = isDark ? Colors.white : Colors.black87;
    final trendColor = advisor.isTrendPositive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          SizedBox(width: 20, child: Text('${advisor.rank}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: const AssetImage(logo), // Replace with actual avatar
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(advisor.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: advisor.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(advisor.primaryValue, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              Text(advisor.secondaryValue, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[600])),
              Text('${advisor.isTrendPositive ? '+' : '-'}${advisor.trend}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)),
            ],
          )
        ],
      ),
    );
  }
}