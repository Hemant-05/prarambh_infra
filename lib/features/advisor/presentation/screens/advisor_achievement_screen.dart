import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_achievement_provider.dart';
import '../../data/models/achievement_model.dart';

class AdvisorAchievementScreen extends StatefulWidget {
  const AdvisorAchievementScreen({super.key});

  @override
  State<AdvisorAchievementScreen> createState() => _AdvisorAchievementScreenState();
}

class _AdvisorAchievementScreenState extends State<AdvisorAchievementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode ?? '';
      context.read<AdvisorAchievementProvider>().fetchAchievements(advisorCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdvisorAchievementProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textColor),
        title: Text(
          "My Achievements",
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: textColor),
            onPressed: () {}, // Share functionality
          ),
        ],
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : provider.error != null
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () {
                    final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode ?? '';
                    return provider.fetchAchievements(advisorCode);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trophy Case Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Trophy Case",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "View All",
                                  style: GoogleFonts.montserrat(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Trophy Case Horizontal List
                        _buildTrophyCase(context, provider.achievements, isDark),

                        const SizedBox(height: 24),

                        // Achievement KPI Summary (Static placeholders based on mockup or data if available)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(child: _buildKPICard(context, "LIFETIME VOLUME", "₹15 Cr", Icons.bar_chart_rounded, const Color(0xFFE3F2FD), Colors.blue)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildKPICard(context, "COMMISSION", "₹35 L", Icons.account_balance_wallet_outlined, const Color(0xFFFFF3E0), Colors.orange)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Filter Pills
                        _buildYearFilters(provider, primaryBlue, isDark),

                        const SizedBox(height: 10),

                        // Achievements Timeline
                        _buildAchievementTimeline(context, provider.filteredAchievements, isDark),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTrophyCase(BuildContext context, List<AchievementModel> achievements, bool isDark) {
    if (achievements.isEmpty) return const SizedBox();
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return SizedBox(
      height: 210,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: achievements.length > 5 ? 5 : achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05), 
                    blurRadius: 10, 
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: index == 0 
                      ? Opacity(
                          opacity: isDark ? 0.9 : 1.0,
                          child: Image.network('https://cdn-icons-png.flaticon.com/512/1910/1910340.png', fit: BoxFit.contain),
                        )
                      : Icon(achievement.icon, size: 50, color: achievement.color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Achieved ${achievement.year}",
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.amber[300] : Colors.amber[700],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildKPICard(BuildContext context, String label, String value, IconData icon, Color bgColor, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cardColor : bgColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? iconColor.withOpacity(0.3) : AppColors.getBorderColor(context)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0, top: 0,
            child: Icon(icon, color: iconColor.withOpacity(isDark ? 0.3 : 0.15), size: 32),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: secondaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _miniBar(12, iconColor.withOpacity(0.3)),
                  const SizedBox(width: 2),
                  _miniBar(18, iconColor.withOpacity(0.3)),
                  const SizedBox(width: 2),
                  _miniBar(14, iconColor.withOpacity(0.3)),
                  const SizedBox(width: 2),
                  _miniBar(22, iconColor),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBar(double height, Color color) {
    return Container(
      width: 4, height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _buildYearFilters(AdvisorAchievementProvider provider, Color activeColor, bool isDark) {
    final years = provider.availableYears;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final isSelected = provider.selectedYear == years[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(
                years[index],
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : secondaryTextColor,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => provider.selectYear(years[index]),
              selectedColor: activeColor,
              backgroundColor: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? activeColor : AppColors.getBorderColor(context)),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementTimeline(BuildContext context, List<AchievementModel> achievements, bool isDark) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final primaryBlue = Theme.of(context).primaryColor;

    if (achievements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: secondaryTextColor?.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text("No achievements found for this period.", style: GoogleFonts.montserrat(color: secondaryTextColor)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Line
              Column(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: index == 0 ? primaryBlue.withOpacity(0.1) : Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: index == 0 ? primaryBlue.withOpacity(0.2) : AppColors.getBorderColor(context)),
                    ),
                    child: Icon(achievement.icon, color: index == 0 ? primaryBlue : secondaryTextColor, size: 18),
                  ),
                  if (index != achievements.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.getBorderColor(context),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Achievement Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.getBorderColor(context)),
                      boxShadow: [
                         BoxShadow(
                           color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.02), 
                           blurRadius: 5, 
                           offset: const Offset(0, 2),
                         ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                achievement.title,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                achievement.type.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 9, 
                                  fontWeight: FontWeight.bold, 
                                  color: isDark ? Colors.greenAccent : Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.formattedDate,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (achievement.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            achievement.description,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: secondaryTextColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
