import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
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
      context.read<AdvisorAttendanceProvider>().fetchMeetings(advisorId, date: _selectedDate);
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
    final activeMeeting = provider.activeMeeting;

    return Scaffold(
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
            onPressed: () => provider.fetchMeetings(advisorId, date: _selectedDate),
          ),
        ],
      ),
      body: provider.isLoading
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

                  // Action Card removed to focus on meeting list mechanics

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
    );
  }

  Widget _buildActionCard(dynamic meeting, Color primaryBlue) {
    bool isCheckInDone = meeting.checkInTime != null;
    bool isCheckOutDone = meeting.checkOutTime != null;
    String buttonText = "Check In";
    if (isCheckInDone && !isCheckOutDone) buttonText = "Check Out";
    if (isCheckOutDone) buttonText = "Completed";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCheckOutDone 
            ? [Colors.grey.shade600, Colors.grey.shade400] 
            : [primaryBlue, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isCheckOutDone ? Colors.grey : primaryBlue).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCheckOutDone ? 'Meeting Finished' : 'Mark Attendance',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCheckOutDone ? Icons.check_circle_outline : Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'At ${meeting.location}',
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!isCheckOutDone)
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  isCheckInDone ? 'Ongoing since ${meeting.checkInTime}' : 'Starts at ${meeting.startTime}',
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCheckOutDone ? null : () {
                if (AdvisorAccessHelper.check(context, feature: 'attendance')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdvisorCameraScreen(
                        meeting: meeting,
                        // Passing isCheckIn flag through the constructor logic would be cleaner
                        // but for now we'll handle it inside the camera/preview screen based on model
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                disabledBackgroundColor: Colors.white.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.montserrat(
                  color: isCheckOutDone ? Colors.white54 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
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

  /// Converts a 24-hour time string (e.g. "14:30" or "14:30:00") to
  /// a 12-hour display string (e.g. "2:30 PM"). Returns the original
  /// string unchanged if parsing fails (e.g. "--:--").
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
