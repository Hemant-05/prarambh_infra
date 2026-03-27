import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_contest_provider.dart';
import 'create_contest_screen.dart';
import 'contest_details_screen.dart';

class ContestsListScreen extends StatefulWidget {
  const ContestsListScreen({super.key});

  @override
  State<ContestsListScreen> createState() => _ContestsListScreenState();
}

class _ContestsListScreenState extends State<ContestsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminContestProvider>().fetchContests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminContestProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text(
          'Running Contests',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateContestScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Create Contest',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', true, primaryBlue),
                _buildFilterChip('Ending Soon', false, primaryBlue),
                _buildFilterChip('High Reward', false, primaryBlue),
                _buildFilterChip('Newest', false, primaryBlue),
              ],
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: provider.contests.length,
                    itemBuilder: (context, index) {
                      final contest = provider.contests[index];
                      final isLive = contest.status == 'LIVE';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: isLive
                                            ? Colors.deepOrange
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${contest.status} • ${contest.rewardText}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    contest.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildIconText(
                                    Icons.track_changes,
                                    contest.targetText,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildIconText(
                                    Icons.calendar_today_outlined,
                                    contest.dateRange,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ContestDetailsScreen(
                                          contest: contest,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isLive
                                          ? primaryBlue
                                          : Colors.grey[200],
                                      foregroundColor: isLive
                                          ? Colors.white
                                          : Colors.grey[600],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      isLive ? 'View Details' : 'Coming Soon',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Image placeholder
                            Container(
                              width: 90,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/logos.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, Color primaryBlue) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : Colors.transparent,
        border: Border.all(
          color: isActive ? primaryBlue : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
