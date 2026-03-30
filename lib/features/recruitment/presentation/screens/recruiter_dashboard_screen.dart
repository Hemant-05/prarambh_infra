import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/recruitment_provider.dart';
import '../../data/models/recruitment_model.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() =>
      _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruitmentProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecruitmentProvider>();
    final primaryBlue = AppColors.getPrimaryBlue(
      context,
    ); // Or const Color(0xFF0056A4)

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: IconButton(
        onPressed: () => Navigator.pushNamed(context, '/advisor_registration'),
        icon: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: SafeArea(
        child: provider.isLoading || provider.data == null
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : RefreshIndicator(
                onRefresh: () => provider.fetchDashboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(provider.data!),
                      const SizedBox(height: 32),
                      _buildRecentRecruitmentsHeader(primaryBlue),
                      const SizedBox(height: 16),
                      _buildRecentRecruitmentsList(
                        provider.data!.recentRecruitments,
                      ),
                      const SizedBox(height: 80), // Padding for FAB
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Recruitment Portal',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF11223A), // Dark navy
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=11',
              ), // Current User Avatar
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(RecruitmentDashboardModel data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3, // Adjusts height of cards
      children: [
        _buildStatCard(
          'TOTAL',
          data.totalBrokers.toString(),
          'Brokers',
          Icons.people_outline,
          Colors.blueGrey,
        ),
        _buildStatCard(
          'ACTIVE',
          data.activeBrokers.toString(),
          'Onboarded',
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildStatCard(
          'PENDING',
          data.pendingBrokers.toString(),
          'Verification',
          Icons.assignment_late_outlined,
          Colors.orange,
        ),
        _buildStatCard(
          'SUSPENDED',
          data.suspendedBrokers.toString(),
          'Action Req.',
          Icons.block,
          Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: Colors.blueGrey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            count,
            style: GoogleFonts.montserrat(
              color: const Color(0xFF11223A),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              color: Colors.blueGrey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecruitmentsHeader(Color primaryBlue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Recruitments',
          style: GoogleFonts.montserrat(
            color: const Color(0xFF11223A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'View All',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRecruitmentsList(
    List<RecruitedAdvisorModel> recruitments,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recruitments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recruit = recruitments[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueGrey.shade100, width: 1),
          ),
          child: Row(
            children: [
              _buildAvatar(recruit.name, recruit.imageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recruit.name,
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF11223A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.blueGrey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Joined ${recruit.dateJoined}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            color: Colors.blueGrey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusPill(recruit.status),
              // const SizedBox(width: 2),
              Icon(Icons.chevron_right, color: Colors.blueGrey[300]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String name, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(radius: 22, backgroundImage: NetworkImage(imageUrl));
    }

    // Fallback: Use initials if no image is available
    String initials = name.isNotEmpty
        ? name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.blue.shade50,
      child: Text(
        initials,
        style: GoogleFonts.montserrat(
          color: Colors.blue.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.montserrat(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
