import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Meeting',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const AssetImage('assets/images/logos.png'),
              backgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              /* Submit via Provider */
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Meeting',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ), // Fixed typo from screenshot
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting Details',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure the meeting to generate QR codes for attendance tracking.',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('MEETING NAME'),
                  _buildTextField(
                    'e.g., Weekly Site Inspection',
                    Icons.edit_outlined,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DATE'),
                            _buildTextField(
                              'mm/dd/yyyy',
                              Icons.calendar_today_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TIME'),
                            _buildTextField('--:-- --', Icons.access_time),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('LOCATION'),
                  _buildTextField(
                    'e.g., Sector 45, Prarambh HQ',
                    Icons.location_on_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: primaryBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'A unique QR code will be generated for this meeting. Attendees can scan it upon arrival to mark their presence automatically.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    ),
  );

  Widget _buildTextField(String hint, IconData icon) {
    return TextField(
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
