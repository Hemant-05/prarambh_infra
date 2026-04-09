import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class AttendanceReviewScreen extends StatefulWidget {
  final String advisorName;
  final String advisorId;
  final String checkInTime;
  final String checkOutTime;
  final String checkInPhoto;
  final String checkOutPhoto;

  const AttendanceReviewScreen({
    super.key,
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
          'Attendance Review',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
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
                        ? widget.checkInTime
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
                        ? widget.checkOutTime
                        : '--:--',
                    Icons.logout,
                    primaryBlue,
                    cardColor,
                    widget.checkOutPhoto,
                    context,
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
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                photoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 40),
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

  Widget _buildDecisionToggle(String title, IconData icon, Color color) {
    bool isSelected = selectedStatus == title;
    return GestureDetector(
      onTap: () => setState(() => selectedStatus = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
