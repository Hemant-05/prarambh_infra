import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../data/datasources/remote/api_client.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/full_screen_image_viewer.dart';

class AttendanceReviewScreen extends StatefulWidget {
  final String attendanceId;
  final String meetingId;
  final String advisorName;
  final String advisorId;
  final String checkInTime;
  final String checkOutTime;
  final String checkInPhoto;
  final String checkOutPhoto;

  const AttendanceReviewScreen({
    super.key,
    required this.attendanceId,
    required this.meetingId,
    required this.advisorName,
    required this.advisorId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInPhoto,
    required this.checkOutPhoto,
  });

  @override
  State<AttendanceReviewScreen> createState() => _AttendanceReviewScreenState();
}

class _AttendanceReviewScreenState extends State<AttendanceReviewScreen> {
  String selectedStatus = 'Present'; // 'Present' or 'Absent'
  bool _isUploadingVideo = false;

  Future<void> _uploadVideo() async {
    if (widget.meetingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Meeting ID')));
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() => _isUploadingVideo = true);
      try {
        final file = File(result.files.single.path!);
        final api = context.read<ApiClient>();
        await api.uploadAttendanceVideo(widget.meetingId, file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video uploaded successfully!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload video: $e')));
        }
      } finally {
        setState(() => _isUploadingVideo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).cardColor : primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Attendance Review',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              color: isDark ? Colors.grey[900] : Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    child: Text(
                      widget.advisorName.isNotEmpty
                          ? widget.advisorName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.advisorName,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: textColor,
                              ),
                            ),
                            if (widget.advisorId.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#${widget.advisorId}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VISUAL EVIDENCE',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Check-In Block
                  _buildEvidenceBlock(
                    'Check-In',
                    widget.checkInTime.isNotEmpty &&
                            widget.checkInTime != '--:--'
                        ? _formatTime(widget.checkInTime)
                        : '--:--',
                    Icons.login,
                    Colors.green,
                    cardColor,
                    widget.checkInPhoto,
                    context,
                  ),
                  const SizedBox(height: 24),

                  // Check-Out Block
                  _buildEvidenceBlock(
                    'Check-Out',
                    widget.checkOutTime.isNotEmpty &&
                            widget.checkOutTime != '--:--'
                        ? _formatTime(widget.checkOutTime)
                        : '--:--',
                    Icons.logout,
                    primaryBlue,
                    cardColor,
                    widget.checkOutPhoto,
                    context,
                  ),
                  const SizedBox(height: 24),
                  if (widget.meetingId.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploadingVideo ? null : _uploadVideo,
                        icon: _isUploadingVideo
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.video_call, color: Colors.white),
                        label: Text(
                          _isUploadingVideo ? 'Uploading...' : 'Upload Video Evidence',
                          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceBlock(
    String title,
    String time,
    IconData icon,
    Color color,
    Color cardColor,
    String photoUrl,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                time,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Image Placeholder matching screenshot proportions
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: photoUrl.isNotEmpty
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          imageUrl: photoUrl,
                          heroTag: 'admin_attendance_${title}_${widget.advisorId}',
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'admin_attendance_${title}_${widget.advisorId}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
        ),
      ],
    );
  }



  String _formatTime(String timeStr) {
    if (timeStr.isEmpty || timeStr == '--:--') return timeStr;
    try {
      final upper = timeStr.toUpperCase();
      if (upper.contains('AM') || upper.contains('PM')) return timeStr;
      
      String t = timeStr;
      if (t.contains('T')) {
        t = t.split('T').last;
      } else if (t.contains(' ')) {
        t = t.split(' ').last;
      }
      
      final parts = t.split(':');
      if (parts.isEmpty) return timeStr;
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }
}
