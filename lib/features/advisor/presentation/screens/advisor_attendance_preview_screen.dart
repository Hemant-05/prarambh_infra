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

  const AdvisorAttendancePreviewScreen({
    super.key,
    required this.meeting,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final provider = context.watch<AdvisorAttendanceProvider>();
    final authProvider = context.read<AuthProvider>();
    final advisorId = authProvider.currentUser?.id.toInt() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Attendance',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: primaryBlue, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Check-in Time: ',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                Text(
                  meeting.startTime,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
                Text(
                  meeting.location,
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[600],
                    fontSize: 13,
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
                          advisorId.toString(),
                          imageFile,
                          true,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Attendance Verified!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context); // Go back to Dashboard
                        }
                      },
                icon: provider.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.verified_outlined, color: Colors.white),
                label: Text(
                  provider.isSaving
                      ? 'VERIFYING...'
                      : 'SUBMIT FOR VERIFICATION',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00448E),
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
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.replay, color: Colors.grey[700]),
                label: Text(
                  'RETAKE PHOTO',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
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
