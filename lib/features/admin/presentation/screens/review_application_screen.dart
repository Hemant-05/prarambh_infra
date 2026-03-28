import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_advisor_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/verification_success_screen.dart';
import 'package:provider/provider.dart';
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
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);

              final success = await context.read<AdminAdvisorProvider>().changeAdvisorStatus(advisor.id, 'Rejected', reason: controller.text);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Rejected')));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Reject'),
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

    // Try to find profile photo
    final profileDoc = advisor.documents.where((d) => d.id == 'profile_photo').toList();
    final profileUrl = profileDoc.isNotEmpty ? profileDoc.first.url : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text('Review Application', style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      bottomNavigationBar: _buildBottomActionBar(context, primaryBlue, isDark),
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
                        padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: profileUrl != null
                              ? Image.network(
                            profileUrl,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            // NEW: Loading Builder
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child; // Image is fully loaded
                              return Container(
                                height: 100, width: 100, color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: primaryBlue,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null, // Shows exact progress if the server provides it
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                                height: 100, width: 100, color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 60, color: Colors.white)
                            ),
                          )
                              : Container(height: 100, width: 100, color: Colors.grey[300], child: const Icon(Icons.person, size: 60, color: Colors.white)),),
                      ),
                      Positioned(
                        bottom: -4, right: -4,
                        child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.verified, color: Colors.blue, size: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(advisor.name, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text('${advisor.designation} • ID: ${advisor.displayId}', style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pending_actions, size: 14, color: Color(0xFFE65100)), const SizedBox(width: 6),
                        Text(advisor.status.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFE65100))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Card 1: Personal Info
            _buildInfoCard(cardColor, 'PERSONAL DETAILS', [
              _buildDetailRow('Father\'s Name', advisor.fatherName),
              _buildDetailRow('Date of Birth', advisor.dob),
              _buildDetailRow('Gender', advisor.gender),
              _buildDetailRow('Occupation', advisor.occupation),
            ]),
            const SizedBox(height: 20),

            // Card 2: Contact Info
            _buildInfoCard(cardColor, 'CONTACT DETAILS', [
              _buildContactRow(Icons.phone_outlined, advisor.phone, 'Mobile', primaryBlue),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              _buildContactRow(Icons.email_outlined, advisor.email, 'Email', primaryBlue),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              _buildContactRow(Icons.location_on_outlined, '${advisor.address}, ${advisor.city}, ${advisor.state} - ${advisor.pincode}', 'Address', primaryBlue),
            ]),
            const SizedBox(height: 20),

            // Card 3: Nominee Info
            _buildInfoCard(cardColor, 'NOMINEE DETAILS', [
              _buildDetailRow('Name', advisor.nomineeName),
              _buildDetailRow('Phone', advisor.nomineePhone),
              _buildDetailRow('Relationship', advisor.relationship),
            ]),
            const SizedBox(height: 20),

            // Card 4: Verification / Bank Info
            _buildInfoCard(cardColor, 'BANK & VERIFICATION', [
              _buildDetailRow('PAN Number', advisor.panNumber),
              _buildDetailRow('Aadhaar Number', advisor.aadhaarNumber),
              Divider(height: 24, color: Colors.grey.withOpacity(0.2)),
              _buildDetailRow('Bank Name', advisor.bankName),
              _buildDetailRow('Account Number', advisor.accountNumber),
              _buildDetailRow('IFSC Code', advisor.ifscCode),
              _buildDetailRow('Assigned Slab', '${advisor.slab}%'),
            ]),
            const SizedBox(height: 20),

            // Card 5: Documents Grid
            Container(
              padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KYC DOCUMENTS', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                  const SizedBox(height: 16),
                  advisor.documents.isEmpty
                      ? Text('No documents uploaded.', style: GoogleFonts.montserrat(color: Colors.grey))
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9
                    ),
                    itemCount: advisor.documents.length,
                    itemBuilder: (context, index) {
                      final doc = advisor.documents[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: doc.type == 'IMAGE'
                                    ? Image.network(
                                    doc.url,
                                    fit: BoxFit.cover,
                                    // NEW: Loading Builder for grid images
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: SizedBox(
                                            width: 24, height: 24, // Smaller spinner for the grid
                                            child: CircularProgressIndicator(
                                              color: primaryBlue,
                                              strokeWidth: 2.5,
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (c, o, s) => const Icon(Icons.broken_image, color: Colors.grey)
                                )
                                    : const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(doc.name, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildInfoCard(Color cardColor, String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(20), child: Text(title, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500]))),
          ...children,
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600]))),
          Expanded(flex: 3, child: Text(value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String subtitle, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: primaryBlue, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, Color primaryBlue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: Consumer<AdminAdvisorProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton.icon(
                      onPressed: provider.isSaving ? null : () async {
                        final success = await provider.approveAdvisor(advisor.id);
                        if (success) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerificationSuccessScreen(advisor: advisor)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approval Failed')));
                        }
                      },
                      icon: provider.isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: Text('Verify & Approve Broker', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    );
                  }
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showRejectionDialog(context, primaryBlue),
                icon: const Icon(Icons.block, color: Colors.red),
                label: Text('Reject Application', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                style: TextButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}