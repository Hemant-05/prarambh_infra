import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class AttendanceReviewScreen extends StatefulWidget {
  final String advisorName;
  final String advisorId;

  const AttendanceReviewScreen({Key? key, required this.advisorName, required this.advisorId}) : super(key: key);

  @override
  State<AttendanceReviewScreen> createState() => _AttendanceReviewScreenState();
}

class _AttendanceReviewScreenState extends State<AttendanceReviewScreen> {
  String selectedStatus = 'Present'; // 'Present' or 'Absent'

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('Attendance Review', style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: cardColor,
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              // Submit verification logic here, then pop back
              Navigator.pop(context);
            },
            icon: const Icon(Icons.verified, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            label: Text('Confirm Verification', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  CircleAvatar(radius: 30, backgroundColor: Colors.orange[100], backgroundImage: const AssetImage('assets/images/logos.png')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.advisorName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text('#${widget.advisorId}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Senior Advisor • North Zone', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text('October 24, 2023', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600])),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VISUAL EVIDENCE', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 16),

                  // Check-In Block
                  _buildEvidenceBlock('Check-In', '09:02 AM', Icons.login, primaryBlue, cardColor),
                  const SizedBox(height: 24),

                  // Check-Out Block
                  _buildEvidenceBlock('Check-Out', '06:15 PM', Icons.logout, primaryBlue, cardColor),
                  const SizedBox(height: 30),

                  Text('VERIFICATION DECISION', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 12),

                  // Decision Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mark Status As:', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDecisionToggle('Present', Icons.check_circle_outline, Colors.green)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDecisionToggle('Absent', Icons.cancel_outlined, Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            text: 'Rejection Reason ', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                            children: [TextSpan(text: '(Optional if Present)', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey[500]))],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          maxLines: 3,
                          style: GoogleFonts.montserrat(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter reason for rejection or notes...',
                            hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryBlue)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceBlock(String title, String time, IconData icon, Color primaryBlue, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: primaryBlue), const SizedBox(width: 8),
                Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: primaryBlue)),
              ],
            ),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text(time, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700], letterSpacing: 1))),
          ],
        ),
        const SizedBox(height: 12),
        // Image Placeholder matching screenshot proportions
        Container(
          height: 180, width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(image: AssetImage('assets/images/logos.png'), fit: BoxFit.cover), // Replace with NetworkImage
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[700]), const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prarambh HQ, Sector 62', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Lat: 28.6219° N, Long: 77.3628° E', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildDecisionToggle(String title, IconData icon, Color color) {
    bool isSelected = selectedStatus == title;
    return GestureDetector(
      onTap: () => setState(() => selectedStatus = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.2), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : Colors.grey[600]), const SizedBox(width: 8),
            Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14, color: isSelected ? color : Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}