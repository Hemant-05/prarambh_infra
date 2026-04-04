import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/utils/ui_helper.dart';
import '../providers/admin_recruitment_provider.dart';
import 'broker_profile_screen.dart';

class AdminRecruitmentDashboardScreen extends StatefulWidget {
  const AdminRecruitmentDashboardScreen({super.key});

  @override
  State<AdminRecruitmentDashboardScreen> createState() =>
      _AdminRecruitmentDashboardScreenState();
}

class _AdminRecruitmentDashboardScreenState
    extends State<AdminRecruitmentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminRecruitmentProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.titleLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final provider = context.watch<AdminRecruitmentProvider>();

    Widget body;
    if (provider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.hasError) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: UIHelper.buildInlineError(
            context: context,
            message: provider.errorMessage!,
            onRetry: () => provider.fetchDashboard(),
          ),
        ),
      );
    } else if (provider.dashboardData == null) {
      body = Center(
        child: Text(
          'No data available',
          style: GoogleFonts.montserrat(color: Colors.grey),
        ),
      );
    } else {
      final data = provider.dashboardData!;
      body = RefreshIndicator(
        onRefresh: () => provider.fetchDashboard(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: 1.4,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    'TOTAL',
                    data.totalRecruits.toString(),
                    'Recruits',
                    Icons.people_outline,
                    primaryBlue,
                    cardColor,
                    isDark,
                  ),
                  _buildStatCard(
                    'ACTIVE',
                    data.activeRecruits.toString(),
                    'Onboarded',
                    Icons.check_circle_outline,
                    Colors.green,
                    cardColor,
                    isDark,
                  ),
                  _buildStatCard(
                    'PENDING',
                    data.pendingApprovals.toString(),
                    'Approval',
                    Icons.pending_actions_outlined,
                    Colors.orange,
                    cardColor,
                    isDark,
                  ),
                  _buildStatCard(
                    'SUSPENDED',
                    data.inactiveOrSuspended.toString(),
                    'Inactive',
                    Icons.block_outlined,
                    Colors.red,
                    cardColor,
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Applications',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'View All',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.recentApplications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "No recent applications found",
                      style: GoogleFonts.montserrat(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...data.recentApplications.map((applicant) {
                  bool isActive = applicant.status.toLowerCase() == 'active';
                  Color statusColor = isActive ? Colors.green : Colors.orange;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BrokerProfileScreen(
                            advisorId: applicant.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.getBorderColor(context),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: primaryBlue.withOpacity(0.1),
                            child: Text(
                              applicant.initials,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  applicant.name,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  applicant.designation,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 10,
                                      color: secondaryTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      applicant.phone,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.email,
                                      size: 10,
                                      color: secondaryTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        applicant.email,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  applicant.status,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                applicant.joinedDate,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text(
          provider.hasError ? 'Error' : 'Recruitment Dashboard',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () => Navigator.pushNamed(context, '/advisor_registration'),
        icon: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: body,
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color cardColor,
    bool isDark,
  ) {
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: secondaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
