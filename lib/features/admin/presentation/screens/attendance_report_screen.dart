import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../providers/admin_attendance_provider.dart';

class AttendanceReportScreen extends StatefulWidget {
  final String meetingId;
  final String meetingTitle;
  final String meetingDate; // Expected format: YYYY-MM-DD

  const AttendanceReportScreen({
    super.key,
    required this.meetingId,
    this.meetingTitle = '',
    this.meetingDate = '',
  });

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Hit the new API with the date parameter
      context.read<AdminAttendanceProvider>().fetchDailyAttendance(widget.meetingDate);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _presentRecords(dynamic report) {
    if (report == null || report['present_advisors'] == null) return [];
    List items = report['present_advisors'];
    if (_search.isEmpty) return items;
    return items.where((r) {
      final name = (r['full_name'] ?? '').toString().toLowerCase();
      final code = (r['Advisor_code'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase()) || code.contains(_search.toLowerCase());
    }).toList();
  }

  List<dynamic> _absentRecords(dynamic report) {
    if (report == null || report['absent_advisors'] == null) return [];
    List items = report['absent_advisors'];
    if (_search.isEmpty) return items;
    return items.where((r) {
      final name = (r['full_name'] ?? '').toString().toLowerCase();
      final code = (r['Advisor_code'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase()) || code.contains(_search.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminAttendanceProvider>();
    final report = provider.dailyReport;

    final presents = _presentRecords(report);
    final absents = _absentRecords(report);

    final presentCount = report?['present_count'] ?? 0;
    final absentCount = report?['absent_count'] ?? 0;
    final totalCount = report?['total_active_advisors'] ?? 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: false),
        title: Text(
          'Daily Attendance',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Meeting header
          Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                if (widget.meetingTitle.isNotEmpty)
                  Text(
                    widget.meetingTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                  ),
                if (widget.meetingDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(widget.meetingDate, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Stats Chips based on API response
                Row(
                  children: [
                    _summaryChip('Present', presentCount, Colors.green, Icons.check_circle),
                    const SizedBox(width: 10),
                    _summaryChip('Absent', absentCount, Colors.red, Icons.cancel),
                    const SizedBox(width: 10),
                    _summaryChip('Total', totalCount, primaryBlue, Icons.people_outline),
                  ],
                ),
                const SizedBox(height: 12),

                // Tabs
                Container(
                  height: 44,
                  decoration: BoxDecoration(color: isDark ? Colors.grey[850] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(8)),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12),
                    padding: const EdgeInsets.all(3),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Present ($presentCount)'),
                      Tab(text: 'Absent ($absentCount)'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Search
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.montserrat(fontSize: 13),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey[400], size: 18),
                      hintText: 'Search advisor name...',
                      hintStyle: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : TabBarView(
              controller: _tabController,
              children: [
                _buildList(presents, isDark, primaryBlue, isAbsent: false),
                _buildList(absents, isDark, primaryBlue, isAbsent: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text('$count', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            Text(label, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> records, bool isDark, Color blue, {required bool isAbsent}) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isAbsent ? Icons.person_off_outlined : Icons.how_to_reg, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              isAbsent ? 'No absences recorded' : 'No attendance records found',
              style: GoogleFonts.montserrat(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (_, i) => _buildRecordCard(records[i], isDark, blue, isAbsent: isAbsent),
    );
  }

  Widget _buildRecordCard(dynamic r, bool isDark, Color blue, {required bool isAbsent}) {
    final bgColor = isDark ? Colors.grey[900] : Colors.white;

    // Safe parsing from JSON
    String name = r['full_name'] ?? 'Unknown';
    String code = r['Advisor_code'] ?? '';
    String profilePhoto = r['profile_photo'] ?? '';

    // Generate initials
    String initials = '?';
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      initials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : parts[0][0].toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        border: Border.all(color: Colors.grey.withOpacity(0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              profilePhoto.isNotEmpty
                  ? CircleAvatar(radius: 22, backgroundImage: NetworkImage(profilePhoto))
                  : CircleAvatar(
                radius: 22,
                backgroundColor: blue.withOpacity(0.1),
                child: Text(initials, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: blue, fontSize: 14)),
              ),
              const SizedBox(width: 12),

              // Name & Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                    ),
                    if (code.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(code, style: GoogleFonts.montserrat(fontSize: 11, color: blue, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (!isAbsent ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  !isAbsent ? 'Present' : 'Absent',
                  style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: !isAbsent ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),

          // Show Check-in/Check-out details ONLY if Present
          if (!isAbsent) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _timeBlock('CHECK IN', r['check_in_time'] ?? '--:--', r['check_in_photo'] ?? '', Colors.green, isDark)),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 8)),
                Expanded(child: _timeBlock('CHECK OUT', r['check_out_time'] ?? '--:--', r['check_out_photo'] ?? '', Colors.blue, isDark)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _timeBlock(String label, String time, String photoUrl, Color color, bool isDark) {
    final hasTime = time.isNotEmpty && time != '--:--';
    final hasPhoto = photoUrl.isNotEmpty && photoUrl != 'null';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[400])),
              const SizedBox(height: 2),
              Text(
                hasTime ? time : '--:--',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
        // Photo thumbnail
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: hasPhoto
              ? ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 16, color: Colors.grey[400])),
          )
              : Icon(Icons.camera_alt_outlined, size: 16, color: Colors.grey[400]),
        ),
      ],
    );
  }
}