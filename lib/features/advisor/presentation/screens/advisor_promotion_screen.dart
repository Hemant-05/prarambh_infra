import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/advisor_performance_model.dart';
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
      final advisorId =
          context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      context.read<AdvisorTeamProvider>().fetchPerformance(advisorId);
    });
  }

  String _formatAmount(double amount) {
    return '₹${NumberFormat('#,##0', 'en_IN').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdvisorTeamProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F4F8);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2340);
    final subTextColor = isDark ? Colors.white60 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: backButton(isDark: !isDark),
        title: Text(
          'Team Performance',
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
              final id = context
                      .read<AuthProvider>()
                      .currentUser
                      ?.id
                      .toString() ??
                  '';
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
                    final id = context
                            .read<AuthProvider>()
                            .currentUser
                            ?.id
                            .toString() ??
                        '';
                    await provider.fetchPerformance(id);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Team Sales Table ───────────────────────────────
                        _buildTeamSalesSection(
                          provider.performanceData!.salesDetails.teamSales,
                          primaryBlue,
                          cardColor,
                          textColor,
                          subTextColor,
                          isDark,
                        ),
                        const SizedBox(height: 16),

                        // ── Team Activity Card ─────────────────────────────
                        _buildTeamActivityCard(primaryBlue, isDark, cardColor),
                        const SizedBox(height: 16),

                        // ── Recruitment Stats ──────────────────────────────
                        _buildRecruitmentStats(
                          provider.performanceData!.recruitmentStats,
                          cardColor,
                          textColor,
                          subTextColor,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ─── Team Sales Section ───────────────────────────────────────────────────

  Widget _buildTeamSalesSection(
    List<TeamSale> sales,
    Color blue,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.groups_outlined, color: blue, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TEAM SALES',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${sales.length} transactions',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: blue.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Scroll →',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : Colors.grey.shade100,
          ),

          sales.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 36, color: subTextColor),
                        const SizedBox(height: 8),
                        Text(
                          'No team sales records found',
                          style: GoogleFonts.montserrat(
                            color: subTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Column Header Row ──────────────────────────────
                      _buildTableHeader(subTextColor, isDark),
                      // ── Data Rows ──────────────────────────────────────
                      ...sales.asMap().entries.map(
                            (entry) => _buildTableRow(
                              entry.key,
                              entry.value,
                              textColor,
                              subTextColor,
                              blue,
                              isDark,
                              cardColor,
                            ),
                          ),
                    ],
                  ),
                ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTableHeader(Color subTextColor, bool isDark) {
    final style = GoogleFonts.montserrat(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: subTextColor,
      letterSpacing: 0.5,
    );

    return Container(
      color: isDark
          ? Colors.white.withOpacity(0.04)
          : const Color(0xFFF8FAFF),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _headerCell('SR', 44, style, TextAlign.center),
          _headerCell('ADVISOR', 130, style, TextAlign.left),
          _headerCell('COLONY', 140, style, TextAlign.left),
          _headerCell('PLOT', 60, style, TextAlign.center),
          _headerCell('SIZE (sq.ft)', 90, style, TextAlign.right),
          _headerCell('GROSS', 90, style, TextAlign.right),
          _headerCell('NET', 90, style, TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerCell(
      String text, double width, TextStyle style, TextAlign align) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _buildTableRow(
    int index,
    TeamSale s,
    Color textColor,
    Color subTextColor,
    Color blue,
    bool isDark,
    Color cardColor,
  ) {
    final isEven = index % 2 == 0;
    final rowBg = isDark
        ? (isEven ? Colors.transparent : Colors.white.withOpacity(0.02))
        : (isEven ? Colors.white : const Color(0xFFFAFBFF));

    final valueStyle = GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textColor,
    );

    return Container(
      color: rowBg,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          // SR
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              s.sr.toString().padLeft(2, '0'),
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Advisor Name
          Container(
            width: 130,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              s.advisorName,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: blue,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          // Colony
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              s.colony.trim(),
              style: valueStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          // Plot No
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              s.plotNo,
              style: valueStyle,
              textAlign: TextAlign.center,
            ),
          ),
          // Size
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              s.size,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
          // Gross
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatAmount(s.gross),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          // Net
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatAmount(s.net),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Team Activity Card ───────────────────────────────────────────────────

  Widget _buildTeamActivityCard(Color blue, bool isDark, Color cardColor) {
    return InkWell(
      onTap: () {
        final code =
            context.read<AuthProvider>().currentUser?.advisorCode ?? '';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeamActivityAttendanceScreen(advisorCode: code),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: blue.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.calendar_today_outlined, color: blue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEAM ACTIVITY & ATTENDANCE',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View meeting attendance & booking reports',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: blue),
          ],
        ),
      ),
    );
  }

  // ─── Recruitment Stats ────────────────────────────────────────────────────

  Widget _buildRecruitmentStats(
    RecruitmentStats stats,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Row(
      children: [
        _statBox('Total', stats.totalRecruits.toString(), Colors.blue,
            cardColor, subTextColor, isDark),
        const SizedBox(width: 10),
        _statBox('Active', stats.activeRecruits.toString(), Colors.green,
            cardColor, subTextColor, isDark),
        const SizedBox(width: 10),
        _statBox('Pending', stats.pendingRecruits.toString(), Colors.orange,
            cardColor, subTextColor, isDark),
      ],
    );
  }

  Widget _statBox(
    String label,
    String value,
    Color color,
    Color cardColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Error ────────────────────────────────────────────────────────────────

  Widget _buildErrorPlaceholder(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error ?? 'Failed to load data',
              style: GoogleFonts.montserrat()),
          TextButton(
            onPressed: () {
              final id = context
                      .read<AuthProvider>()
                      .currentUser
                      ?.id
                      .toString() ??
                  '';
              context.read<AdvisorTeamProvider>().fetchPerformance(id);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
