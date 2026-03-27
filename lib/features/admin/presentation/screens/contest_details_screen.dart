import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/contest_model.dart';

class ContestDetailsScreen extends StatelessWidget {
  final ContestModel contest;
  const ContestDetailsScreen({super.key, required this.contest});

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Image with transparent AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Contest Details',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for the palm tree image
                  Container(
                    color: Colors.blueGrey,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black12,
                          Colors.black87.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.deepOrange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'LIVE NOW',
                              style: GoogleFonts.montserrat(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contest.title,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reward: ${contest.rewardText}',
                              style: GoogleFonts.montserrat(
                                color: Colors.white70,
                                fontSize: 14,
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

          // Body Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF121212)
                    : const Color(0xFFF0F4F8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TIME REMAINING',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Ends ${contest.endDate ?? ""}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeBox('15', 'DAYS', cardColor, primaryBlue),
                      _buildTimeBox('08', 'HRS', cardColor, primaryBlue),
                      _buildTimeBox('45', 'MINS', cardColor, primaryBlue),
                      _buildTimeBox('12', 'SECS', cardColor, primaryBlue),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Top Performers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Performers',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'View Leaderboard>',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (contest.topPerformers != null)
                    ...contest.topPerformers!.asMap().entries.map((entry) {
                      int rank = entry.key + 1;
                      Color rankColor = rank == 1
                          ? Colors.amber[100]!
                          : rank == 2
                          ? Colors.grey[200]!
                          : Colors.orange[100]!;
                      Color rankTextColor = rank == 1
                          ? Colors.amber[900]!
                          : rank == 2
                          ? Colors.grey[700]!
                          : Colors.orange[900]!;
                      Color avatarBg = rank == 1
                          ? Colors.purple[100]!
                          : rank == 2
                          ? Colors.teal[100]!
                          : Colors.pink[100]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: rankColor,
                              child: Text(
                                '$rank',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: rankTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: avatarBg,
                              child: Text(
                                entry.value.initials,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value.name,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    entry.value.location,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              entry.value.units,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  // Rules
                  Text(
                    'Contest Rules',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (contest.rules != null)
                    ...contest.rules!.map(
                      (rule) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rule,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildTimeBox(
    String value,
    String label,
    Color cardColor,
    Color primaryBlue,
  ) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
