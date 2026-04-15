import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/data/models/meeting_model.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_attendance_provider.dart';
import 'attendance_review_screen.dart';

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
      final provider = context.read<AdminAttendanceProvider>();
      provider.fetchDailyAttendance(widget.meetingDate);
      provider.fetchMeetingById(widget.meetingId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return '';
    if (url.startsWith('http')) return url;
    return "https://workiees.com/$url";
  }

  List<dynamic> _presentRecords(AdminAttendanceProvider provider) {
    final auth = context.read<AuthProvider>();
    final adminId = auth.currentUser?.id.toString();

    if (provider.selectedMeeting != null) {
      final items = provider.selectedMeeting!.attendanceRecords
          .where((r) => r.advisorId != adminId)
          .toList();
      if (_search.isEmpty) return items;
      return items.where((r) {
        final name = r.advisorName.toLowerCase();
        final code = r.advisorCode.toLowerCase();
        return name.contains(_search.toLowerCase()) ||
            code.contains(_search.toLowerCase());
      }).toList();
    }
    return [];
  }

  List<dynamic> _absentRecords(dynamic report) {
    if (report == null || report['absent_advisors'] == null) return [];
    List items = report['absent_advisors'];

    final auth = context.read<AuthProvider>();
    final adminId = auth.currentUser?.id.toString();

    // Filter out both the current admin (by ID) and the specific 'admin001' code
    items = items.where((r) {
      final id = r['advisor_id']?.toString();
      final code = (r['Advisor_code'] ?? '').toString().toLowerCase();
      return id != adminId && code != 'admin001';
    }).toList();

    if (_search.isEmpty) return items;
    return items.where((r) {
      final name = (r['full_name'] ?? '').toString().toLowerCase();
      final code = (r['Advisor_code'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase()) ||
          code.contains(_search.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminAttendanceProvider>();

    final report = provider.dailyReport;
    final meeting = provider.selectedMeeting;

    final presents = _presentRecords(provider);
    final absents = _absentRecords(report);

    final presentCount = presents.length;
    final absentCount = absents.length;
    final totalCount = presentCount + absentCount;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: !isDark),
        title: Text(
          'Attendance Report',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              provider.fetchDailyAttendance(widget.meetingDate);
              provider.fetchMeetingById(widget.meetingId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    _summaryChip(
                      'Present',
                      presentCount,
                      Colors.green,
                      Icons.check_circle,
                    ),
                    const SizedBox(width: 10),
                    _summaryChip(
                      'Absent',
                      absentCount,
                      Colors.red,
                      Icons.cancel,
                    ),
                    const SizedBox(width: 10),
                    _summaryChip(
                      'Total',
                      totalCount,
                      primaryBlue,
                      Icons.people_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.all(3),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Present ($presentCount)'),
                      Tab(text: 'Absent ($absentCount)'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                      icon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      hintText: 'Search advisor name...',
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPresentList(presents, isDark, primaryBlue),
                      _buildAbsentList(absents, isDark, primaryBlue),
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
            Text(
              '$count',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresentList(List<dynamic> records, bool isDark, Color blue) {
    if (records.isEmpty) {
      return _emptyState(Icons.how_to_reg, 'No present advisors recorded');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (_, i) => _buildPresentCard(records[i], isDark, blue),
    );
  }

  Widget _buildAbsentList(List<dynamic> records, bool isDark, Color blue) {
    if (records.isEmpty) {
      return _emptyState(Icons.person_off_outlined, 'No absences recorded');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (_, i) => _buildAbsentCard(records[i], isDark, blue),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.montserrat(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentCard(dynamic r, bool isDark, Color blue) {
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    // Data comes from AttendanceRecord model or Dynamic JSON depending on fetch state
    final String name = r is AttendanceRecord
        ? r.advisorName
        : (r['full_name'] ?? 'Unknown');
    final String code = r is AttendanceRecord
        ? r.advisorCode
        : (r['Advisor_code'] ?? '');
    final String photo = r is AttendanceRecord
        ? r.checkInPhoto
        : (r['check_in_photo'] ?? '');
    final String time = r is AttendanceRecord
        ? r.checkInTime
        : (r['check_in_time']?.toString().split(' ').last ?? '--:--');
    final String outTime = r is AttendanceRecord
        ? r.checkOutTime
        : (r['check_out_time']?.toString().split(' ').last ?? '--:--');
    final String outPhoto = r is AttendanceRecord
        ? r.checkOutPhoto
        : (r['check_out_photo'] ?? '');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceReviewScreen(
              advisorName: name,
              advisorId: code,
              checkInTime: time,
              checkOutTime: outTime,
              checkInPhoto: _formatImageUrl(photo),
              checkOutPhoto: _formatImageUrl(outPhoto),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: _cardBox(bgColor!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowHeader(name, code, true, blue, isDark),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _timeBlock(
                    'CHECK IN',
                    time,
                    _formatImageUrl(photo),
                    Colors.green,
                    isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _timeBlock(
                    'CHECK OUT',
                    outTime,
                    _formatImageUrl(outPhoto),
                    Colors.blue,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsentCard(dynamic r, bool isDark, Color blue) {
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    final String name = r['full_name'] ?? 'Unknown';
    final String code = r['Advisor_code'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: _cardBox(bgColor!),
      child: _rowHeader(name, code, false, blue, isDark),
    );
  }

  BoxDecoration _cardBox(Color bgColor) => BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
    border: Border.all(color: Colors.grey.withOpacity(0.09)),
  );

  Widget _rowHeader(
    String name,
    String code,
    bool isPresent,
    Color blue,
    bool isDark,
  ) {
    String initials = name
        .trim()
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join()
        .toUpperCase();
    if (initials.length > 2) initials = initials.substring(0, 2);

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: blue.withOpacity(0.1),
          child: Text(
            initials,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: blue,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (code.isNotEmpty)
                Text(
                  code,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isPresent ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isPresent ? 'Present' : 'Absent',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPresent ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeBlock(
    String label,
    String time,
    String photoUrl,
    Color color,
    bool isDark,
  ) {
    final hasTime = time.isNotEmpty && time != '--:--';
    final hasPhoto = photoUrl.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasTime ? time : '--:--',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: hasPhoto
              ? InkWell(
                  onTap: () => _showImageDialog(photoUrl, label),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                )
              : Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: Colors.grey[400],
                ),
        ),
      ],
    );
  }

  void _showImageDialog(String url, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
