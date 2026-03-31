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
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text('My Recruitment', style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
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
              _buildLeaderProfileCard(provider.data!.leaderInfo, primaryBlue),
              const SizedBox(height: 24),
              _buildStatsGrid(provider.data!.stats),
              const SizedBox(height: 32),
              Text('Team Members (${provider.data!.teamMembers.length})', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),
              provider.data!.teamMembers.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(30.0), child: Text("No team members yet.", style: GoogleFonts.montserrat(color: Colors.grey))))
                  : _buildRecentRecruitmentsList(provider.data!.teamMembers, isDark),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderProfileCard(LeaderInfoModel leader, Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, Colors.blue.shade800], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          _buildAvatar(leader.fullName, leader.imageUrl, radius: 30),
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

  Widget _buildStatsGrid(RecruitmentStatsModel stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total\nMembers', stats.totalRecruits, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Active\nMembers', stats.activeRecruits, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Pending\nApprovals', stats.pendingRecruits, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text('$count', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildRecentRecruitmentsList(List<RecruitedAdvisorModel> recruitments, bool isDark) {
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
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              _buildAvatar(recruit.name, recruit.imageUrl, radius: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recruit.name,
                      style: GoogleFonts.montserrat(color: isDark ? Colors.white : const Color(0xFF11223A), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 12, color: Colors.blueGrey[400]),
                        const SizedBox(width: 4),
                        Text(recruit.advisorCode, style: GoogleFonts.montserrat(color: Colors.blueGrey[600], fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today_outlined, size: 12, color: Colors.blueGrey[400]),
                        const SizedBox(width: 4),
                        Text(recruit.dateJoined, style: GoogleFonts.montserrat(color: Colors.blueGrey[600], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusPill(recruit.status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String name, String imageUrl, {required double radius}) {
    // Avoid crashing on broken PDF/XLSX image uploads from backend testing
    bool isInvalidImage = imageUrl.toLowerCase().endsWith('.xlsx') || imageUrl.toLowerCase().endsWith('.pdf');

    if (imageUrl.isNotEmpty && !isInvalidImage) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.blue.shade50,
      );
    }

    String initials = name.isNotEmpty ? name.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').take(2).join().toUpperCase() : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade50,
      child: Text(
        initials,
        style: GoogleFonts.montserrat(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: radius * 0.6),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'pending':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
      case 'inactive':
      case 'suspended':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: textColor.withOpacity(0.3))),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.montserrat(color: textColor, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}