import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/recruitment_provider.dart';
import '../../data/models/recruitment_model.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() => _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final advisorId = authProvider.currentUser?.id.toString() ?? '';
      if (advisorId.isNotEmpty) {
        context.read<RecruitmentProvider>().fetchDashboard(advisorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecruitmentProvider>();
    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text('My Recruitment', style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/advisor_registration'),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text("Add Advisor", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading || provider.data == null
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : RefreshIndicator(
        onRefresh: () async {
          final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
          await context.read<RecruitmentProvider>().fetchDashboard(id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeaderProfileCard(context, provider.data!.leaderInfo, primaryBlue),
              const SizedBox(height: 24),
              _buildStatsGrid(context, provider.data!.stats),
              const SizedBox(height: 32),
              Text('Team Members (${provider.data!.teamMembers.length})', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              provider.data!.teamMembers.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(30.0), child: Text("No team members yet.", style: GoogleFonts.montserrat(color: Colors.grey))))
                  : _buildRecentRecruitmentsList(context, provider.data!.teamMembers, isDark),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderProfileCard(BuildContext context, LeaderInfoModel leader, Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, primaryBlue.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          _buildAvatar(context, leader.fullName, leader.imageUrl, radius: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leader.fullName,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(leader.designation, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text('•  ${leader.advisorCode}', style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, RecruitmentStatsModel stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Total\nMembers', stats.totalRecruits, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Active\nMembers', stats.activeRecruits, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Pending\nApprovals', stats.pendingRecruits, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int count, Color color) {
    final cardColor = Theme.of(context).cardColor;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text('$count', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: secondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildRecentRecruitmentsList(BuildContext context, List<RecruitedAdvisorModel> recruitments, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recruitments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recruit = recruitments[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(context)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              _buildAvatar(context, recruit.name, recruit.imageUrl, radius: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recruit.name,
                      style: GoogleFonts.montserrat(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 12, color: secondaryTextColor),
                        const SizedBox(width: 4),
                        Text(recruit.advisorCode, style: GoogleFonts.montserrat(color: secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today_outlined, size: 12, color: secondaryTextColor),
                        const SizedBox(width: 4),
                        Text(recruit.dateJoined, style: GoogleFonts.montserrat(color: secondaryTextColor, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusPill(context, recruit.status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, String name, String imageUrl, {required double radius}) {
    final primaryBlue = Theme.of(context).primaryColor;

    // Avoid crashing on broken PDF/XLSX image uploads from backend testing
    bool isInvalidImage = imageUrl.toLowerCase().endsWith('.xlsx') || imageUrl.toLowerCase().endsWith('.pdf');

    if (imageUrl.isNotEmpty && !isInvalidImage) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: primaryBlue.withOpacity(0.1),
      );
    }

    String initials = name.isNotEmpty ? name.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').take(2).join().toUpperCase() : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: primaryBlue.withOpacity(0.1),
      child: Text(
        initials,
        style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: radius * 0.6),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, String status) {
    Color bgColor;
    Color textColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green;
        textColor = Colors.green;
        break;
      case 'pending':
        bgColor = Colors.orange;
        textColor = Colors.orange;
        break;
      case 'inactive':
      case 'suspended':
        bgColor = Colors.red;
        textColor = Colors.red;
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: isDark ? textColor.withOpacity(0.15) : bgColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.3))
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.montserrat(color: isDark ? textColor.withOpacity(0.9) : textColor, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}