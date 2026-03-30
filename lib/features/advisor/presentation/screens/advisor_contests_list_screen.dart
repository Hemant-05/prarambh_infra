import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_contest_details_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_contest_provider.dart';

class AdvisorContestsListScreen extends StatefulWidget {
  const AdvisorContestsListScreen({super.key});

  @override
  State<AdvisorContestsListScreen> createState() => _AdvisorContestsListScreenState();
}

class _AdvisorContestsListScreenState extends State<AdvisorContestsListScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvisorContestProvider>().fetchContests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final provider = context.watch<AdvisorContestProvider>();
    final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text(
          'Running Contests',
          style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: Icon(Icons.filter_list, color: isDark ? Colors.white : Colors.black87), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.contests.isEmpty
                ? Center(child: Text("No contests running right now.", style: GoogleFonts.montserrat(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.contests.length,
              itemBuilder: (context, index) {
                final contest = provider.contests[index];
                final isLive = contest.status.toUpperCase() == 'ACTIVE' || contest.status.toUpperCase() == 'LIVE';

                // Check participation
                final isJoined = contest.participants.any((p) => p.advisorCode == advisorCode);
                final myData = isJoined ? contest.participants.firstWhere((p) => p.advisorCode == advisorCode) : null;

                int targetSales = 5; // Default target
                int currentSales = myData?.units ?? 0;
                int progressPercent = (currentSales / targetSales * 100).clamp(0, 100).toInt();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.circle, size: 8, color: isLive ? Colors.deepOrange : Colors.grey),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${isLive ? "LIVE" : contest.status.toUpperCase()}  •  ${contest.rewardText}',
                                        style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: isLive ? Colors.deepOrange : Colors.grey[600]),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  contest.title,
                                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                _buildIconText(Icons.adjust, 'Sell $targetSales Units'),
                                const SizedBox(height: 4),
                                _buildIconText(Icons.calendar_today_outlined, contest.dateRange),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdvisorContestDetailsScreen(contest: contest))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isLive ? primaryBlue : Colors.grey[200],
                                    foregroundColor: isLive ? Colors.white : Colors.grey[600],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(isLive ? 'View Details' : 'Coming Soon', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Reward Image
                          Container(
                            width: 100, height: 110,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: isDark ? Colors.grey[850] : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: contest.imageUrl.isNotEmpty
                                  ? Image.network(contest.imageUrl, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Colors.grey))
                                  : const Icon(Icons.image, color: Colors.grey, size: 40),
                            ),
                          ),
                        ],
                      ),
                      // Advisor Progress Bar (Only show if LIVE & Joined)
                      if (isLive && isJoined) ...[
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressPercent / 100,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${contest.daysLeft} DAYS LEFT', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey[400], letterSpacing: 0.5)),
                            Text('$progressPercent% COMPLETED', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey[400], letterSpacing: 0.5)),
                          ],
                        ),
                      ]
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