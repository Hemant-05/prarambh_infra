import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../providers/advisor_team_provider.dart';

class TeamActivityAttendanceScreen extends StatefulWidget {
  final String advisorCode;
  const TeamActivityAttendanceScreen({super.key, required this.advisorCode});

  @override
  State<TeamActivityAttendanceScreen> createState() =>
      _TeamActivityAttendanceScreenState();
}

class _TeamActivityAttendanceScreenState
    extends State<TeamActivityAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvisorTeamProvider>().fetchTeamActivity(widget.advisorCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdvisorTeamProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: backButton(isDark: false),
        title: Text(
          'Booking & Attendance',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.activityData == null
          ? _buildErrorPlaceholder(provider.errorMessage)
          : RefreshIndicator(
              onRefresh: () async =>
                  await provider.fetchTeamActivity(widget.advisorCode),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTeamBookingsSection(
                      provider.activityData!.teamBookings,
                      primaryBlue,
                      isDark,
                    ),
                    const SizedBox(height: 24),
                    _buildTeamAttendanceSection(
                      provider.activityData!.teamAttendance,
                      primaryBlue,
                      isDark,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTeamBookingsSection(bookings, Color blue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.groups_outlined, color: blue, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'TEAM BOOKINGS',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recent Activity',
                  style: GoogleFonts.montserrat(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (bookings.recentActivity.isEmpty)
            Center(
              child: Text(
                'No recent bookings',
                style: GoogleFonts.montserrat(color: Colors.grey),
              ),
            )
          else
            ...bookings.recentActivity
                .map<Widget>((act) => _buildBookingItem(act, isDark))
                .toList(),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${bookings.target} Bookings',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Achieved: ${bookings.achieved}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(activity, bool isDark) {
    final statusColor = activity.status.toLowerCase() == 'confirmed'
        ? Colors.green
        : Colors.orange;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.advisorName,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.projectDetails,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.date,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                activity.status,
                style: GoogleFonts.montserrat(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAttendanceSection(List attendance, Color blue, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'TEAM ATTENDANCE',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.blueGrey,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (attendance.isEmpty)
          Center(
            child: Text(
              'No attendance data available',
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          )
        else
          ...attendance.map((at) => _buildAttendanceCard(at, blue, isDark)),
      ],
    );
  }

  Widget _buildAttendanceCard(at, Color blue, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: at.profilePhoto != null
                    ? NetworkImage('https://workiees.com/${at.profilePhoto}')
                    : null,
                child: at.profilePhoto == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      at.advisorName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      at.designation,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${at.attendancePercent.toStringAsFixed(0)}%',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Attendance',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Present Dates:',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (at.presentDates.isEmpty)
                    Text(
                      'No present dates recorded for this month',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: at.presentDates
                          .map<Widget>((date) => _buildDateChip(date, isDark))
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String date, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        date,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
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
            onPressed: () => context
                .read<AdvisorTeamProvider>()
                .fetchTeamActivity(widget.advisorCode),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
