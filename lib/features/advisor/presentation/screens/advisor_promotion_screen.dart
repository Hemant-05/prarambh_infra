import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_team_provider.dart';
import 'team_activity_attendance_screen.dart';

class AdvisorPromotionScreen extends StatefulWidget {
  const AdvisorPromotionScreen({super.key});

  @override
  State<AdvisorPromotionScreen> createState() => _AdvisorPromotionScreenState();
}

class _AdvisorPromotionScreenState extends State<AdvisorPromotionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisorId = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      context.read<AdvisorTeamProvider>().fetchPerformance(advisorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdvisorTeamProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: backButton(isDark: false),
        title: Text(
          'Promotion & Career',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
              provider.fetchPerformance(id);
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.performanceData == null
              ? _buildErrorPlaceholder(provider.errorMessage)
              : RefreshIndicator(
                  onRefresh: () async {
                    final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
                    await provider.fetchPerformance(id);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(provider.performanceData!.leaderInfo, isDark),
                        const SizedBox(height: 20),
                        _buildPromotionStatusCard(provider.performanceData!.careerProgress, primaryBlue, isDark),
                        const SizedBox(height: 20),
                        _buildRecruitmentStats(provider.performanceData!.recruitmentStats, isDark),
                        const SizedBox(height: 20),
                        _buildTeamActivityCard(primaryBlue, isDark),
                        const SizedBox(height: 20),
                        _buildTeamMembersSection(provider.performanceData!.teamMembers, primaryBlue, isDark),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader(leader, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: leader.profilePhoto.isNotEmpty ? NetworkImage('https://workiees.com/${leader.profilePhoto}') : null,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: leader.profilePhoto.isEmpty ? const Icon(Icons.person, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(leader.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(leader.designation, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('#${leader.advisorCode}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(leader.status, style: GoogleFonts.montserrat(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionStatusCard(progress, Color blue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Colors.blueGrey[900]!, Colors.black] : [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Promotion Status', style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('Next: ${progress.nextLevel}', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(progress.currentLevel, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...progress.metrics.map<Widget>((m) => _buildMetricItem(m)).toList(),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Achievement', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('${progress.overallProgressPercentage}%', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(metric) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.metric, style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
              Text('Achieved: ${metric.achieved} / Target: ${metric.target}', style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: (metric.percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.tealAccent]),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${metric.percentage}% Complete', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentStats(stats, bool isDark) {
    return Row(
      children: [
        _statBox('Total', stats.totalRecruits.toString(), Colors.blue, isDark),
        const SizedBox(width: 12),
        _statBox('Active', stats.activeRecruits.toString(), Colors.green, isDark),
        const SizedBox(width: 12),
        _statBox('Pending', stats.pendingRecruits.toString(), Colors.orange, isDark),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamActivityCard(Color blue, bool isDark) {
    return InkWell(
      onTap: () {
        final code = context.read<AuthProvider>().currentUser?.advisorCode ?? '';
        Navigator.push(context, MaterialPageRoute(builder: (_) => TeamActivityAttendanceScreen(advisorCode: code)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: blue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: blue.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.analytics_outlined, color: blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Team Activity & Attendance', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('View detailed booking and attendance reports', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: blue),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMembersSection(members, Color blue, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('My Team Members', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 12),
        if (members.isEmpty)
          Center(child: Text('No team members found', style: GoogleFonts.montserrat(color: Colors.grey)))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (ctx, i) => _buildMemberCard(members[i], isDark),
          ),
      ],
    );
  }

  Widget _buildMemberCard(member, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: member.profilePhoto.isNotEmpty ? NetworkImage(member.profilePhoto) : null,
            child: member.profilePhoto.isEmpty ? Text(member.fullName[0]) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(member.designation, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text('#${member.advisorCode}', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error ?? 'Failed to load data', style: GoogleFonts.montserrat()),
          TextButton(
            onPressed: () {
              final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
              context.read<AdvisorTeamProvider>().fetchPerformance(id);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
