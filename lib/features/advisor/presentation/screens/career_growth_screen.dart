import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../providers/advisor_dashboard_provider.dart';
import '../../data/models/advisor_dashboard_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CareerGrowthScreen extends StatelessWidget {
  const CareerGrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<AdvisorDashboardProvider>();
    final isDark = AppColors.isDark(context);
    final primaryBlue = AppColors.getPrimaryBlue(context);
    
    if (dashboardProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = dashboardProvider.data;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryBlue,
          elevation: 0,
          leading: backButton(isDark: false),
          title: Text(
            'Career Progression',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: const Center(child: Text("No progression data available")),
      );
    }

    final scaffoldBg = AppColors.getScaffoldColor(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: false,
        leading: const backButton(isDark: true), // Force true for white icons on blue appbar
        title: Text(
          'Level Progression',
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
              final advisor = context.read<AuthProvider>().currentUser;
              if (advisor != null) {
                dashboardProvider.fetchDashboardData(advisor.advisorCode!);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCareerPathCard(context, data, isDark),
            const SizedBox(height: 24),
            _buildProgressCard(context, data, isDark),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'PROMOTION CHECKLIST'),
            const SizedBox(height: 16),
            _buildPromotionChecklist(context, data, isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextColor(context),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCareerPathCard(BuildContext context, AdvisorDashboardModel data, bool isDark) {
    final levels = [
      'Adviser',
      'Supervisor',
      'Manager',
      'Senior Manager',
      'Chief Manager',
      'Director',
    ];

    int currentIndex = levels.indexWhere(
      (l) => l.toLowerCase() == data.currentLevel.toLowerCase(),
    );
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CAREER PATH",
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.getSecondaryTextColor(context),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(levels.length, (index) {
                bool isDone = index < currentIndex;
                bool isCurrent = index == currentIndex;
                bool isLocked = index > currentIndex;
                
                return Row(
                  children: [
                    _buildStepperNode(context, levels[index], isDone, isCurrent, isLocked, isDark),
                    if (index != levels.length - 1)
                      _buildStepperLine(context, isDone, isDark),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperNode(BuildContext context, String label, bool isDone, bool isCurrent, bool isLocked, bool isDark) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? primaryBlue
                : (isCurrent
                      ? AppColors.getCardColor(context)
                      : (isDark ? Colors.grey[800] : const Color(0xFFF1F5F9))),
            border: isCurrent ? Border.all(color: primaryBlue, width: 2) : null,
          ),
          child: Icon(
            isDone
                ? Icons.check
                : (isCurrent ? Icons.star : Icons.lock_outline),
            size: 16,
            color: isDone
                ? Colors.white
                : (isCurrent ? primaryBlue : Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent
                ? primaryBlue
                : AppColors.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperLine(BuildContext context, bool isDone, bool isDark) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isDone
          ? AppColors.getPrimaryBlue(context)
          : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
    );
  }

  Widget _buildProgressCard(BuildContext context, AdvisorDashboardModel data, bool isDark) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "CURRENT RANK",
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.currentLevel,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Next rank: ",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      TextSpan(
                        text: data.nextLevel,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildCircularProgress(context, data.progressPercent.toDouble(), isDark),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(BuildContext context, double percentage, bool isDark) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    
    return Container(
      width: 85,
      height: 85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(85, 85),
            painter: CircularProgressPainter(
              percentage: percentage,
              isDark: isDark,
              primaryColor: primaryBlue,
              trackColor: isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${percentage.toInt()}%",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
              ),
              Text(
                "DONE",
                style: GoogleFonts.montserrat(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionChecklist(BuildContext context, AdvisorDashboardModel data, bool isDark) {
    final metrics = data.promotionStatus;
    if (metrics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text("No specific promotion targets found.")),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getBorderColor(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ...metrics.asMap().entries.map((entry) {
                final index = entry.key;
                final m = entry.value;
                return Column(
                  children: [
                    _buildChecklistItem(context, m, isDark),
                    if (index < metrics.length - 1)
                      Divider(
                        height: 32,
                        color: AppColors.getBorderColor(context),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(BuildContext context, PromotionMetric metric, bool isDark) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    bool isDone = metric.achievedNumber >= metric.targetNumber;
    bool isLagging = !isDone && (metric.achievedNumber / metric.targetNumber < 0.5);

    Color statusColor = isDone
        ? const Color(0xFF22C55E)
        : (isLagging ? const Color(0xFFF97316) : primaryBlue);
    String statusText = isDone ? "COMPLETED" : (isLagging ? "LAGGING" : "IN PROGRESS");

    IconData icon;
    // Clean up metric name
    String metricTitle = metric.metric
        .replaceAll("Personal Sales - ", "")
        .replaceAll("Personal Sales ", "");

    if (metric.metric.contains("Sell") || metric.metric.contains("Personal")) {
      icon = Icons.shopping_bag_outlined;
    } else if (metric.metric.contains("Team") && metric.metric.contains("member")) {
      icon = Icons.group_add_outlined;
    } else if (metric.metric.contains("properties")) {
      icon = Icons.apartment_rounded;
    } else {
      icon = Icons.event_note_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metricTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                Text(
                  statusText,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  metric.metric.contains("attendance")
                      ? "${metric.achievedNumber}%"
                      : "${metric.achievedNumber}/${metric.targetNumber}",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                Text(
                  "ACHIEVED",
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (metric.achievedNumber / metric.targetNumber).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              metric.metric.contains("attendance")
                  ? "Required: ${metric.targetNumber}%"
                  : "Target Goal: ${metric.targetNumber}",
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: AppColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${((metric.achievedNumber / metric.targetNumber) * 100).clamp(0, 100).toInt()}% Complete",
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final bool isDark;
  final Color primaryColor;
  final Color trackColor;

  CircularProgressPainter({
    required this.percentage,
    required this.isDark,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      arcAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
