import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:prarambh_infra/features/advisor/data/models/advisor_attendance_history_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_attendance_provider.dart';
import '../../data/models/advisor_meeting_model.dart';
import 'advisor_camera_screen.dart';
import '../../../../core/utils/access_helper.dart';

class AdvisorMeetingScheduleScreen extends StatefulWidget {
  const AdvisorMeetingScheduleScreen({super.key});

  @override
  State<AdvisorMeetingScheduleScreen> createState() =>
      _AdvisorMeetingScheduleScreenState();
}

class _AdvisorMeetingScheduleScreenState
    extends State<AdvisorMeetingScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late ScrollController _scrollController;
  final List<DateTime> _daysList = [];

  @override
  void initState() {
    super.initState();
    _generateDaysList();

    double initialOffset =
        (30 * 60.0) -
        (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width /
            2) +
        30.0;
    _scrollController = ScrollController(
      initialScrollOffset: initialOffset > 0 ? initialOffset : 0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final advisorId = auth.currentUser?.id.toString() ?? '';
      final advisorCode = auth.currentUser?.advisorCode ?? '';
      context.read<AdvisorAttendanceProvider>().fetchMeetings(advisorId, date: _selectedDate);
      context.read<AdvisorAttendanceProvider>().fetchAttendanceHistory(advisorCode);
    });
  }

  void _generateDaysList() {
    DateTime today = DateTime.now();
    for (int i = -30; i <= 30; i++) {
      _daysList.add(today.add(Duration(days: i)));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final provider = context.watch<AdvisorAttendanceProvider>();
    final auth = context.read<AuthProvider>();
    final advisorId = auth.currentUser?.id.toString() ?? '';
    
    final scaffoldBg = AppColors.getScaffoldColor(context);
    final cardColor = AppColors.getCardColor(context);
    final textColor = AppColors.getTextColor(context);
    final secondaryTextColor = AppColors.getSecondaryTextColor(context);
    final borderColor = AppColors.getBorderColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selectedDateMeetings = provider.getMeetingsForDate(_selectedDate);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: isDark ? Theme.of(context).cardColor : primaryBlue,
          elevation: 0,
          centerTitle: true,
          leading: backButton(isDark: !isDark),
          title: Text(
            'Meetings',
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
                provider.fetchMeetings(advisorId, date: _selectedDate);
                provider.fetchAttendanceHistory(auth.currentUser?.advisorCode ?? '');
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
            tabs: const [
              Tab(text: 'Schedule'),
              Tab(text: 'History & Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: SCHEDULE
            provider.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.grey),
                            Text(
                              DateFormat('MMMM yyyy').format(_selectedDate),
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                        const SizedBox(height: 16),
  
                        // Horizontal Scroll Calendar
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _daysList.length,
                            itemBuilder: (context, index) {
                              DateTime date = _daysList[index];
                              bool isSelected =
                                  date.year == _selectedDate.year &&
                                  date.month == _selectedDate.month &&
                                  date.day == _selectedDate.day;
                              bool isToday =
                                  date.year == DateTime.now().year &&
                                  date.month == DateTime.now().month &&
                                  date.day == DateTime.now().day;
  
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                  // Fetch meetings for the newly selected date
                                  provider.fetchMeetings(advisorId, date: date);
                                },
                                child: Container(
                                  width: 50,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('E').format(date)[0],
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryBlue
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: primaryBlue.withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          date.day.toString(),
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: isSelected ? Colors.white : textColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (isToday)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            color: Colors.deepOrange,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      else
                                        const SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
  
                        // Meetings List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate.day == DateTime.now().day
                                  ? 'Today\'s Meetings'
                                  : 'Meetings on ${DateFormat('MMM dd').format(_selectedDate)}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
  
                        if (selectedDateMeetings.isEmpty)
                          _buildEmptyState(cardColor, borderColor, secondaryTextColor)
                        else
                          ...selectedDateMeetings.map(
                            (m) => _buildMeetingCard(m, provider, primaryBlue, cardColor, borderColor, textColor, secondaryTextColor),
                          ),
  
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

            // TAB 2: HISTORY & STATS
            _buildHistoryTab(provider, primaryBlue, cardColor, borderColor, textColor, secondaryTextColor),
          ],
        ),
      ),
    );
  }


  Widget _buildHistoryTab(AdvisorAttendanceProvider provider, Color primaryBlue, Color cardColor, Color borderColor, Color textColor, Color secondaryTextColor) {
    if (provider.isLoadingHistory) {
      return Center(child: CircularProgressIndicator(color: primaryBlue));
    }

    final history = provider.history;
    if (history == null) {
      return Center(
        child: Text(
          'No attendance data found',
          style: GoogleFonts.montserrat(color: secondaryTextColor),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildHistoryStatCard(
                  'Attendance',
                  '${history.summary.attendancePercent.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                  cardColor,
                  borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHistoryStatCard(
                  'Total',
                  history.summary.totalMeetings.toString(),
                  Icons.event,
                  primaryBlue,
                  cardColor,
                  borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHistoryStatCard(
                  'Present',
                  history.summary.present.toString(),
                  Icons.check_circle,
                  Colors.blue,
                  cardColor,
                  borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHistoryStatCard(
                  'Absent',
                  history.summary.absent.toString(),
                  Icons.cancel,
                  Colors.red,
                  cardColor,
                  borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Text(
            'Meeting History',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          if (history.meetingDetails.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No historical records available',
                  style: GoogleFonts.montserrat(color: secondaryTextColor),
                ),
              ),
            )
          else
            ...history.meetingDetails.map((detail) => _buildHistoryDetailCard(detail, primaryBlue, cardColor, borderColor, textColor, secondaryTextColor)),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHistoryStatCard(String label, String value, IconData icon, Color color, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDetailCard(AdvisorAttendanceDetail detail, Color primaryBlue, Color cardColor, Color borderColor, Color textColor, Color secondaryTextColor) {
    final bool isAbsent = detail.status.toLowerCase() == 'absent';
    final statusColor = isAbsent ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.title,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(DateTime.parse(detail.meetingDate))} • ${_formatTime(detail.startTime)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  detail.status.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (!isAbsent) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check In',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.checkInTime != null ? _formatTime(detail.checkInTime!) : '--:--',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check Out',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.checkOutTime != null ? _formatTime(detail.checkOutTime!) : '--:--',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color cardColor, Color borderColor, Color secondaryTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "No meetings scheduled",
            style: GoogleFonts.montserrat(color: secondaryTextColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(AdvisorMeetingModel meeting, AdvisorAttendanceProvider provider, Color primaryBlue, Color cardColor, Color borderColor, Color textColor, Color secondaryTextColor) {
    bool isCompleted = meeting.checkOutTime != null || meeting.status == 'completed';
    bool isOngoing = meeting.checkInTime != null && !isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            meeting.title,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isCompleted ? Colors.blue : (isOngoing ? Colors.orange : Colors.green)).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isCompleted ? 'COMPLETED' : (isOngoing ? 'ONGOING' : 'SCHEDULED'),
                            style: GoogleFonts.montserrat(
                              color: isCompleted ? Colors.blue : (isOngoing ? Colors.orange : Colors.green),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⏱ ${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}',
                      style: GoogleFonts.montserrat(color: secondaryTextColor, fontSize: 11),
                    ),
                    if (meeting.checkInTime != null)
                      Text(
                        '✓ Checked in at ${_formatTime(meeting.checkInTime!)}',
                        style: GoogleFonts.montserrat(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              DateTime? startDateTime;
              DateTime? endDateTime;
              try {
                if (meeting.meetingDate.isNotEmpty && meeting.startTime.isNotEmpty && meeting.startTime != '--:--') {
                  startDateTime = DateTime.parse('${meeting.meetingDate} ${meeting.startTime}');
                }
                if (meeting.meetingDate.isNotEmpty && meeting.endTime.isNotEmpty && meeting.endTime != '--:--') {
                  endDateTime = DateTime.parse('${meeting.meetingDate} ${meeting.endTime}');
                }
              } catch (_) {}

              final now = DateTime.now();
              bool showCheckIn = false;
              bool showCheckOut = false;
              bool isAttending = false;

              // 1. Logic for Check In
              if (meeting.checkInTime == null && meeting.status != 'completed') {
                if (startDateTime != null) {
                  // Allow check in 15 mins before start, until end of meeting
                  DateTime earliestCheckIn = startDateTime.subtract(const Duration(minutes: 15));
                  bool notEndedYet = endDateTime == null || now.isBefore(endDateTime);
                  
                  if (now.isAfter(earliestCheckIn) && notEndedYet) {
                    showCheckIn = true;
                  }
                } else {
                  // Fallback: If times are invalid, allow check-in freely.
                  showCheckIn = true;
                }
              }

              // 2. Logic for Check Out & Attending
              if (meeting.checkInTime != null && meeting.checkOutTime == null) {
                isAttending = true;

                if (startDateTime != null && endDateTime != null) {
                  // Only show Check Out button after 10 minutes of the meeting's start time
                  DateTime unlockCheckOutTime = startDateTime.add(const Duration(minutes: 10));
                  // And restrict it from showing 10 mins after end time
                  DateTime deadlineCheckOutTime = endDateTime.add(const Duration(minutes: 10));
                  
                  if (now.isAfter(unlockCheckOutTime) && now.isBefore(deadlineCheckOutTime)) {
                    showCheckOut = true;
                  }
                } else if (startDateTime != null) {
                  DateTime unlockCheckOutTime = startDateTime.add(const Duration(minutes: 10));
                  if (now.isAfter(unlockCheckOutTime)) {
                    showCheckOut = true;
                  }
                } else {
                  // Fallback: if time format fails, just show the checkout button
                  showCheckOut = true;
                }
              }

              if (showCheckIn || showCheckOut || isAttending) {
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Status Box
                      if (isAttending) 
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          ),
                          child: Text(
                            'Attending...',
                            style: GoogleFonts.montserrat(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      
                      // Action Button
                      if (showCheckIn || showCheckOut)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: provider.isSaving 
                              ? null 
                              : () {
                                  if (AdvisorAccessHelper.check(context, feature: 'attendance')) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdvisorCameraScreen(
                                          meeting: meeting,
                                          isCheckIn: showCheckIn,
                                        ),
                                      ),
                                    );
                                  }
                                },
                            icon: provider.isSaving 
                              ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(showCheckOut ? Icons.logout : Icons.login),
                            label: Text(
                              showCheckOut ? 'Check Out' : 'Check In', 
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showCheckOut ? Colors.blue : primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                    ]
                  )
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(String time24) {
    if (time24.isEmpty || time24 == '--:--') return time24;
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return time24;
    }
  }
}
