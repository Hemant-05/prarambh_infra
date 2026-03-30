import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/advisor_leaderboard_provider.dart';
import '../../data/models/advisor_leaderboard_model.dart';

class AdvisorLeaderboardScreen extends StatefulWidget {
  const AdvisorLeaderboardScreen({super.key});

  @override
  State<AdvisorLeaderboardScreen> createState() => _AdvisorLeaderboardScreenState();
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
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://i.pravatar.cc/150?img=11'; 
    if (path.startsWith('http')) return path;
    return 'https://workiees.com/api/public/$path'; 
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final provider = context.watch<AdvisorLeaderboardProvider>();

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
          'LEADER BOARD',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          if (provider.topThree.isNotEmpty)
                            _buildPodiumLayer(provider.topThree, primaryBlue, isDark),

                          const SizedBox(height: 40),
                          if (provider.remainingAdvisors.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rankings',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Total Sales ',
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
                            ...List.generate(provider.remainingAdvisors.length, (index) {
                              final advisor = provider.remainingAdvisors[index];
                              final rank = index + 4; // Top 3 are ranked 1,2,3
                              return _buildListItem(advisor, rank, primaryBlue, isDark);
                            }),
                          ]
                        ],
                      ),
                    ),
              ),
      ),
    );
  }

  Widget _buildPodiumLayer(List<AdvisorLeaderboardModel> topThree, Color primaryBlue, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (topThree.length >= 2)
          Expanded(
            child: _buildPodiumProfile(topThree[1], 2, primaryBlue, isDark),
          ),
        if (topThree.isNotEmpty)
          Expanded(
            child: _buildPodiumProfile(topThree[0], 1, primaryBlue, isDark, isCenter: true),
          ),
        if (topThree.length >= 3)
          Expanded(
            child: _buildPodiumProfile(topThree[2], 3, primaryBlue, isDark),
          ),
      ],
    );
  }

  Widget _buildPodiumProfile(AdvisorLeaderboardModel advisor, int rank, Color primaryBlue, bool isDark, {bool isCenter = false}) {
    final double avatarSize = isCenter ? 45 : 35;
    final textColor = isDark ? Colors.white : Colors.black87;

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
                border: isCenter ? Border.all(color: primaryBlue, width: 2) : null,
              ),
              child: CircleAvatar(
                radius: avatarSize,
                backgroundColor: primaryBlue.withValues(alpha: 0.1),
                backgroundImage: NetworkImage(_getImageUrl(advisor.profilePhoto)),
                onBackgroundImageError: (_, __) {},
                child: advisor.profilePhoto == null || advisor.profilePhoto!.isEmpty ? Text(
                  advisor.fullName.isNotEmpty ? advisor.fullName.substring(0, 1).toUpperCase() : 'A',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                    fontSize: isCenter ? 24 : 18,
                  ),
                ) : null, 
              ),
            ),
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCenter ? Colors.amber : (rank == 2 ? Colors.grey[400] : Colors.brown[300]),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
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
          advisor.designation,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          _formatCurrency(advisor.totalSales),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: primaryBlue,
          ),
        ),
        if (isCenter) const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildListItem(AdvisorLeaderboardModel advisor, int rank, Color primaryBlue, bool isDark) {
    final cardColor = AppColors.getCardColor(context);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: primaryBlue.withValues(alpha: 0.1),
            backgroundImage: NetworkImage(_getImageUrl(advisor.profilePhoto)),
            onBackgroundImageError: (_, __) {},
            child: advisor.profilePhoto == null || advisor.profilePhoto!.isEmpty ? Text(
              advisor.fullName.isNotEmpty ? advisor.fullName.substring(0, 1).toUpperCase() : 'A',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: primaryBlue,
                fontSize: 16,
              ),
            ) : null,
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
                Text(
                  advisor.designation,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(advisor.totalSales),
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryBlue) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No leaderboard data available',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
