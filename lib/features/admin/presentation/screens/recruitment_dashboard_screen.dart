import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_recruitment_provider.dart';
import 'recruiter_detail_screen.dart';

class RecruitmentDashboardScreen extends StatefulWidget {
  const RecruitmentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<RecruitmentDashboardScreen> createState() => _RecruitmentDashboardScreenState();
}

class _RecruitmentDashboardScreenState extends State<RecruitmentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminRecruitmentProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final provider = context.watch<AdminRecruitmentProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: backButton(isDark: isDark),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(radius: 18, backgroundImage: const AssetImage('assets/images/logos.png'), backgroundColor: Colors.grey[200]),
                Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
              ],
            ),
          )
        ],
      ),
      body: provider.isLoading || provider.dashboardData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,', style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 14)),
            Text('Recruiter Portal', style: GoogleFonts.montserrat(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // 2x2 Grid Stats
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              childAspectRatio: 1.4,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('TOTAL', provider.dashboardData!.totalBrokers.toString(), 'Brokers', Icons.people_outline, primaryBlue, cardColor, isDark),
                _buildStatCard('ACTIVE', provider.dashboardData!.activeBrokers.toString(), 'Onboarded', Icons.check_circle_outline, Colors.green, cardColor, isDark),
                _buildStatCard('PENDING', provider.dashboardData!.pendingVerification.toString(), 'Verification', Icons.pending_actions_outlined, Colors.orange, cardColor, isDark),
                _buildStatCard('SUSPENDED', provider.dashboardData!.suspendedActionReq.toString(), 'Action Req.', Icons.block_outlined, Colors.red, cardColor, isDark),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Recruiters', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                Text('View All', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBlue)),
              ],
            ),
            const SizedBox(height: 16),

            // Modified List View
            ...provider.dashboardData!.topRecruiters.map((recruiter) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecruiterDetailScreen(recruiterName: recruiter.name, advisorId: recruiter.id))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22, backgroundColor: Colors.blue[50],
                      child: Text(recruiter.initials, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: primaryBlue)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recruiter.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(recruiter.joinedDate, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // The modification: Showing recruit count instead of a status pill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${recruiter.recruitCount}', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
                        Text('Recruits', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String subtitle, IconData icon, Color iconColor, Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor), const SizedBox(width: 6),
              Text(title, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(count, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          Text(subtitle, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}