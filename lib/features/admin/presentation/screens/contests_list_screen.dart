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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).cardColor : primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text(
          'Running Contests',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Create Contest',
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.contests.isEmpty
                ? Center(child: Text("No contests found.", style: GoogleFonts.montserrat(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.contests.length,
              itemBuilder: (context, index) {
                final contest = provider.contests[index];
                
                // Functional Status Logic
                String statusText = 'INACTIVE';
                Color statusColor = Colors.grey;
                if (contest.isLive) {
                  statusText = 'LIVE';
                  statusColor = Colors.deepOrange;
                } else if (contest.isUpcoming) {
                  statusText = 'UPCOMING';
                  statusColor = Colors.blue;
                } else if (contest.isEnded) {
                  statusText = 'ENDED';
                  statusColor = Colors.red;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  '$statusText  •  ${contest.rewardText}',
                                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              contest.title,
                              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            _buildIconText(Icons.adjust, contest.targetText),
                            const SizedBox(height: 4),
                            _buildIconText(Icons.calendar_today_outlined, contest.dateRange),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContestDetailsScreen(contest: contest))),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !contest.isEnded ? primaryBlue : Colors.grey[200],
                                foregroundColor: !contest.isEnded ? Colors.white : Colors.grey[600],
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                contest.isEnded ? 'Contest Ended' : 'View Details',
                                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 100,
                        height: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: contest.imageUrl.isNotEmpty
                              ? Image.network(
                            contest.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
                          )
                              : const Icon(Icons.image, color: Colors.grey, size: 40),
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

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blueGrey[400]),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.blueGrey[600], fontWeight: FontWeight.w500)),
      ],
    );
  }
}