import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../providers/admin_document_provider.dart';

const String _baseUrl = 'https://workiees.com/';

class AssignDocumentsScreen extends StatefulWidget {
  final String advisorId;
  final String advisorName;
  final String advisorCode;
  final String advisorProfile;

  const AssignDocumentsScreen({
    super.key,
    required this.advisorId,
    required this.advisorName,
    required this.advisorProfile,
    required this.advisorCode,
  });

  @override
  State<AssignDocumentsScreen> createState() => _AssignDocumentsScreenState();
}

class _AssignDocumentsScreenState extends State<AssignDocumentsScreen> {
  // Store the actual files the admin picks for this advisor
  File? welcomeLetter;
  File? applicationForm;
  File? idCard;

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (type == 'Welcome Letter') {
          welcomeLetter = File(result.files.single.path!);
        }
        if (type == 'Application Form') {
          applicationForm = File(result.files.single.path!);
        }
        if (type == 'ID Card') idCard = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitDocuments() async {
    final provider = context.read<AdminDocumentProvider>();
    int successCount = 0;

    // Helper to upload if a file was selected
    Future<void> uploadIfPresent(String name, File? file) async {
      if (file != null) {
        final success = await provider.uploadDocument(
          name: name,
          category:
              'Personal', // Backend uses 'Personal' for advisor-specific docs
          userId: widget.advisorId, // Attach it to this specific advisor!
          documentFile: file,
        );
        if (success) successCount++;
      }
    }

    await uploadIfPresent('Welcome Letter', welcomeLetter);
    await uploadIfPresent('Application Form', applicationForm);
    await uploadIfPresent('ID Card', idCard);

    if (mounted) {
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount documents assigned successfully!'),
          ),
        );
        Navigator.popUntil(context, ModalRoute.withName('/admin_dashboard'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one document to assign.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isSaving = context.watch<AdminDocumentProvider>().isSaving;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text(
          'Assign Documents',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: cardColor,
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : _submitDocuments,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text(
                    'Confirm and Send',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            icon: const Icon(Icons.send, color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Advisor Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryBlue.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (widget.advisorProfile.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(
                              imageUrl: Uri.encodeFull(
                                  "$_baseUrl${widget.advisorProfile}"),
                              heroTag:
                                  'admin_assign_profile_${widget.advisorId}',
                            ),
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: 'admin_assign_profile_${widget.advisorId}',
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: widget.advisorProfile.isNotEmpty
                            ? NetworkImage(
                                Uri.encodeFull(
                                    "$_baseUrl${widget.advisorProfile}"),
                              )
                            : null,
                        child: widget.advisorProfile.isEmpty
                            ? Text(
                                widget.advisorName
                                    .substring(
                                      0,
                                      widget.advisorName.length > 1 ? 2 : 1,
                                    )
                                    .toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.advisorName,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Advisor ID: ${widget.advisorCode}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Documents List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attach Custom Documents',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocRow(
                    'Welcome Letter',
                    welcomeLetter,
                    primaryBlue,
                    textColor,
                  ),
                  const Divider(),
                  _buildDocRow(
                    'Application Form',
                    applicationForm,
                    primaryBlue,
                    textColor,
                  ),
                  const Divider(),
                  _buildDocRow('ID Card', idCard, primaryBlue, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocRow(
    String title,
    File? selectedFile,
    Color primaryBlue,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              selectedFile != null ? Icons.check_circle : Icons.description,
              color: primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                if (selectedFile != null)
                  Text(
                    selectedFile.path.split('/').last,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Not Selected',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _pickFile(title),
            icon: Icon(
              selectedFile != null ? Icons.edit : Icons.upload,
              size: 14,
              color: Colors.white,
            ),
            label: Text(
              selectedFile != null ? 'Change' : 'Select',
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedFile != null
                  ? Colors.green
                  : primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
