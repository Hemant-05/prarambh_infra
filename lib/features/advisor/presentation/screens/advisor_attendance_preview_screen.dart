import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/advisor_meeting_model.dart';
import '../providers/advisor_attendance_provider.dart';

class AdvisorAttendancePreviewScreen extends StatelessWidget {
  final AdvisorMeetingModel meeting;
  final File imageFile;
  final bool isCheckIn;

  const AdvisorAttendancePreviewScreen({
    super.key,
    required this.meeting,
    required this.imageFile,
    this.isCheckIn = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final provider = context.watch<AdvisorAttendanceProvider>();
    final authProvider = context.read<AuthProvider>();
    final advisorId = authProvider.currentUser?.id.toString() ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isCheckIn ? 'Verify Check-in' : 'Verify Check-out',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Preview Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryBlue, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.file(
                      imageFile,
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LIVE CAPTURE',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Meeting Details
            Text(
              meeting.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: primaryBlue, size: 16),
                const SizedBox(width: 6),
                Text(
                  isCheckIn ? 'Meeting starts: ' : 'Ongoing since: ',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                Text(
                  isCheckIn ? meeting.startTime : (meeting.checkInTime ?? '--:--'),
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, color: primaryBlue, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    meeting.location,
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: provider.isSaving
                    ? null
                    : () async {
                        final success = await provider.submitAttendance(
                          meeting.id,
                          advisorId,
                          imageFile,
                          isCheckIn,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isCheckIn ? 'Check-in successful!' : 'Check-out successful!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Pop back to Schedule screen (Camera screen was already popped)
                          Navigator.pop(context);
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to verify. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                icon: provider.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_outlined, color: Colors.white),
                label: Text(
                  provider.isSaving
                      ? 'VERIFYING...'
                      : (isCheckIn ? 'VERIFY CHECK-IN' : 'VERIFY CHECK-OUT'),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: provider.isSaving ? null : () => Navigator.pop(context),
                icon: Icon(Icons.replay, color: isDark ? Colors.white70 : Colors.grey[700]),
                label: Text(
                  'RETAKE PHOTO',
                  style: GoogleFonts.montserrat(
                    color: isDark ? Colors.white70 : Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
