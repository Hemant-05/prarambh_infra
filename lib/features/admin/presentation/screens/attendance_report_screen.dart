import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_attendance_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/attendance_verification_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/attendance_model.dart';

class AttendanceReportScreen extends StatefulWidget {
  final String meetingId;
  final String meetingTitle;
  final String meetingDate;

  // Added constructor parameters so it can dynamically load any meeting
  const AttendanceReportScreen({
    super.key,
    this.meetingId = '1',
    this.meetingTitle = 'Project Launch: Sky High Towers',
    this.meetingDate = 'Oct 24, 2023'
  });

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // THE FIX: Use fetchMeeting instead of the deleted fetchReport
      context.read<AdminAttendanceProvider>().fetchMeeting(widget.meetingId);
    });
  }

  // THE FIX: Safely parse the attendance records from the backend's currentMeeting object
  List<AttendanceModel> _extractRecords(dynamic meetingData) {
    if (meetingData == null) return [];
    try {
      if (meetingData is Map && meetingData['attendance'] != null) {
        return (meetingData['attendance'] as List)
            .map((e) => AttendanceModel.fromJson(e))
            .toList();
      } else if (meetingData is List) {
        return meetingData.map((e) => AttendanceModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error parsing attendance records: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminAttendanceProvider>();

    // Extract records dynamically
    final records = _extractRecords(provider.currentMeeting);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Attendance Report',
          style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.meetingTitle,
                      style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 12, width: 1, color: Colors.grey[400],
                    ),
                    Text(
                      widget.meetingDate,
                      style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tabs
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    // THE FIX: Changed withOpacity to withAlpha to clear deprecation warnings
                    border: Border.all(color: Colors.grey.withAlpha(77)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4)],
                    ),
                    labelColor: primaryBlue,
                    labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
                    unselectedLabelColor: Colors.grey[600],
                    indicatorSize: TabBarIndicatorSize.tab,
                    padding: const EdgeInsets.all(4),
                    tabs: [
                      Tab(text: 'Present (${records.length})'),
                      const Tab(text: 'Absent (0)'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withAlpha(77)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search broker name...',
                      hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                // Present Tab
                records.isEmpty
                    ? const Center(child: Text("No attendance records found for this meeting."))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) => _buildAttendanceCard(records[index], cardColor, isDark),
                ),

                // Absent Tab
                const Center(child: Text("No absences to display")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceModel record, Color cardColor, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceVerificationScreen(
              meetingName: widget.meetingTitle,
              meetingDate: widget.meetingDate,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const AssetImage('assets/images/logos.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.advisorName,
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                      ),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('Duration: ${record.duration}', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeBlock('CHECK IN', record.checkInTime, record.checkInStatus, record.checkInPhoto),
                Container(width: 1, height: 40, color: Colors.grey[300]), // Vertical Divider
                _buildTimeBlock('CHECK OUT', record.checkOutTime, record.checkOutStatus, record.checkOutPhoto),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBlock(String label, String time, String status, String photoUrl) {
    final bool isVerified = status == 'Verified';
    final Color statusColor = isVerified ? Colors.green : Colors.deepOrange;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
              Text(time, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (isVerified) const Icon(Icons.check_circle, size: 10, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(status, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Photo Thumbnail
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: photoUrl.isEmpty ? Border.all(color: Colors.grey.withAlpha(77), style: BorderStyle.solid) : null,
              image: photoUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: photoUrl.isEmpty
                ? const Icon(Icons.image_not_supported, size: 16, color: Colors.grey)
                : const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.visibility, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}