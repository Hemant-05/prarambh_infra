import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../data/models/meeting_model.dart';
import '../providers/admin_attendance_provider.dart';
import 'create_meeting_screen.dart';
import 'attendance_report_screen.dart';

class MeetingManagementScreen extends StatefulWidget {
  const MeetingManagementScreen({super.key});

  @override
  State<MeetingManagementScreen> createState() => _MeetingManagementScreenState();
}

class _MeetingManagementScreenState extends State<MeetingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAttendanceProvider>().fetchAllMeetings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MeetingModel> _filter(List<MeetingModel> all, String statusFilter) {
    return all.where((m) {
      final matchesStatus = statusFilter == 'all' || m.status.toLowerCase() == statusFilter;
      final matchesSearch = _search.isEmpty ||
          m.title.toLowerCase().contains(_search.toLowerCase()) ||
          m.location.toLowerCase().contains(_search.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminAttendanceProvider>();

    final upcoming = _filter(provider.meetings, 'upcoming');
    final ongoing = _filter(provider.meetings, 'ongoing');
    final completed = _filter(provider.meetings, 'completed');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateMeetingScreen()),
          );
          if (created == true && context.mounted) {
            context.read<AdminAttendanceProvider>().fetchAllMeetings();
          }
        },
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Meeting', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: !isDark),
        title: Text('Meeting & Attendance',
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<AdminAttendanceProvider>().fetchAllMeetings(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.montserrat(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search meetings...',
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stats summary
          if (!provider.isLoading && provider.meetings.isNotEmpty)
            _buildStatsRow(provider.meetings, primaryBlue, isDark),

          const SizedBox(height: 4),

          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : provider.error != null && provider.meetings.isEmpty
                    ? _buildErrorState(provider, primaryBlue)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMeetingList(upcoming, primaryBlue, isDark, provider),
                          _buildMeetingList(ongoing, primaryBlue, isDark, provider),
                          _buildMeetingList(completed, primaryBlue, isDark, provider),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<MeetingModel> meetings, Color blue, bool isDark) {
    final total = meetings.length;
    final upcoming = meetings.where((m) => m.status.toLowerCase() == 'upcoming').length;
    final completed = meetings.where((m) => m.status.toLowerCase() == 'completed').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statChip('Total', '$total', Colors.blueGrey, isDark),
          const SizedBox(width: 10),
          _statChip('Upcoming', '$upcoming', Colors.orange, isDark),
          const SizedBox(width: 10),
          _statChip('Completed', '$completed', Colors.green, isDark),
        ],
      ),
    );
  }

  Widget _statChip(String label, String count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(count, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildMeetingList(List<MeetingModel> meetings, Color blue, bool isDark, AdminAttendanceProvider provider) {
    if (meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No meetings found', style: GoogleFonts.montserrat(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w600)),
            if (_search.isNotEmpty)
              Text('Try a different search term', style: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (ctx, i) => _buildMeetingCard(meetings[i], blue, isDark, provider),
    );
  }

  Widget _buildMeetingCard(MeetingModel m, Color blue, bool isDark, AdminAttendanceProvider provider) {
    final statusColor = {
      'upcoming': Colors.orange,
      'ongoing': Colors.green,
      'completed': Colors.blue,
    }[m.status.toLowerCase()] ?? Colors.grey;

    final statusIcon = {
      'upcoming': Icons.schedule,
      'ongoing': Icons.play_circle_outline,
      'completed': Icons.check_circle_outline,
    }[m.status.toLowerCase()] ?? Icons.circle_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.event_outlined, color: blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (m.agenda.isNotEmpty)
                      Text(m.agenda, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    Text(m.status.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
                  ]),
                ),
              ],
            ),
          ),

          // Date / Time / Location row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                if (m.date.isNotEmpty) _infoChip(Icons.calendar_today_outlined, m.date, Colors.grey[600]!),
                if (m.time.isNotEmpty) _infoChip(Icons.access_time_outlined, m.time, Colors.grey[600]!),
                if (m.location.isNotEmpty) _infoChip(Icons.location_on_outlined, m.location, Colors.grey[600]!),
              ],
            ),
          ),

          // Attendance summary (completed meetings)
          if (m.status.toLowerCase() == 'completed' && m.attendanceRecords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _attendancePill(Icons.check_circle, '${m.presentCount} Present', Colors.green),
                const SizedBox(width: 8),
                _attendancePill(Icons.cancel_outlined, '${m.absentCount} Absent', Colors.red),
              ]),
            ),

          // Action buttons
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(children: [
              // View Report
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendanceReportScreen(meetingId: m.id, meetingTitle: m.title, meetingDate: m.date)),
                ),
                icon: Icon(Icons.bar_chart_outlined, size: 16, color: blue),
                label: Text('Report', style: GoogleFonts.montserrat(color: blue, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              // Delete
              TextButton.icon(
                onPressed: () => _confirmDelete(context, m, provider),
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: color)),
    ]);
  }

  Widget _attendancePill(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _buildErrorState(AdminAttendanceProvider provider, Color blue) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Failed to load meetings', style: GoogleFonts.montserrat(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: provider.fetchAllMeetings,
          style: ElevatedButton.styleFrom(backgroundColor: blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
          label: Text('Retry', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, MeetingModel m, AdminAttendanceProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Meeting', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${m.title}"? This action cannot be undone.', style: GoogleFonts.montserrat(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.montserrat())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await provider.deleteMeeting(m.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Meeting deleted.' : 'Failed to delete meeting.'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
              }
            },
            child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
