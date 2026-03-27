import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/verification_success_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/advisor_application_model.dart';

class ReviewApplicationScreen extends StatelessWidget {
  final AdvisorApplicationModel advisor;

  const ReviewApplicationScreen({super.key, required this.advisor});

  void _showRejectionDialog(BuildContext context, Color primaryBlue) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reason for rejection',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue),
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Call provider to reject, then close
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application Rejected')),
              );
              Navigator.pop(context); // Go back to list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4F8), // Soft blue/grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text(
          'Review Application',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      // Sticky bottom action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VerificationSuccessScreen(advisor: advisor),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Verify & Approve Broker',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    _showRejectionDialog(context, primaryBlue);
                  },
                  icon: const Icon(Icons.block, color: Colors.red),
                  label: Text(
                    'Reject Application',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ), // Placeholder for image
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    advisor.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${advisor.displayId}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          size: 14,
                          color: Color(0xFFE65100),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'VERIFICATION PENDING',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Contact Details Card
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'CONTACT DETAILS',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  _buildContactRow(
                    Icons.phone_outlined,
                    advisor.phone,
                    'Mobile',
                    'Call',
                    primaryBlue,
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                  _buildContactRow(
                    Icons.email_outlined,
                    advisor.email,
                    'Email',
                    'Email',
                    primaryBlue,
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                  _buildContactRow(
                    Icons.location_on_outlined,
                    advisor.location,
                    'Location',
                    'Map',
                    primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KYC Documents Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KYC DOCUMENTS',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${advisor.documents.length} files',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Document Grid
                  Row(
                    children: advisor.documents
                        .map(
                          (doc) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        doc.type == 'PDF'
                                            ? const Icon(
                                                Icons.picture_as_pdf,
                                                color: Colors.red,
                                                size: 40,
                                              )
                                            : const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                                size: 40,
                                              ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.visibility,
                                              size: 14,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    doc.name,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${doc.size} • ${doc.type}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String title,
    String subtitle,
    String action,
    Color primaryBlue,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              action,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
