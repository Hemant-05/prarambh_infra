import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/core/utils/file_download_helper.dart';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import 'package:prarambh_infra/core/widgets/pdf_viewer_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_document_provider.dart';
import 'add_document_screen.dart';

class DocsManagementScreen extends StatefulWidget {
  const DocsManagementScreen({super.key});

  @override
  State<DocsManagementScreen> createState() => _DocsManagementScreenState();
}

class _DocsManagementScreenState extends State<DocsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDocumentProvider>().fetchDocuments();
    });
  }

  // --- 1. VIEW DOCUMENT LOGIC ---
  Future<void> _viewDocument(DocumentModel doc) async {
    if (doc.type == 'IMAGE') {
      // Show Image in Full Screen Zoomable Dialog
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black87,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  doc.url,
                  fit: BoxFit.contain,
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (c, e, s) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            url: doc.url,
            title: 'View Document: ${doc.name}',
            fileName: "${doc.name.replaceAll(' ', '_')}.pdf",
          ),
        ),
      );
    }
  }

  // --- 2. UPDATE DOCUMENT LOGIC ---
  void _showUpdateBottomSheet(DocumentModel doc, Color primaryBlue) {
    final nameCtrl = TextEditingController(text: doc.name);
    File? newFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Document',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Document Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'png'],
                          );
                      if (result != null) {
                        setSheetState(
                          () => newFile = File(result.files.single.path!),
                        );
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    leading: Icon(
                      newFile != null ? Icons.check_circle : Icons.upload_file,
                      color: newFile != null ? Colors.green : primaryBlue,
                    ),
                    title: Text(
                      newFile != null
                          ? newFile!.path.split('/').last
                          : 'Replace File (Optional)',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(bottomSheetContext); // Close sheet
                        final success = await context
                            .read<AdminDocumentProvider>()
                            .updateDocument(
                              id: doc.id,
                              name: nameCtrl.text != doc.name
                                  ? nameCtrl.text
                                  : null,
                              documentFile: newFile,
                            );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Document Updated')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 3. DELETE DOCUMENT LOGIC ---
  Future<void> _deleteDocument(DocumentModel doc) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Delete Document?'),
            content: Text(
              'Are you sure you want to delete "${doc.name}"? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final success = await context
          .read<AdminDocumentProvider>()
          .deleteDocument(doc.id);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Document Deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final provider = context.watch<AdminDocumentProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: !isDark),
        title: Text(
          'DOCS MANAGEMENT',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: (){
            context.read<AdminDocumentProvider>().fetchDocuments();
          },)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddDocumentScreen()),
        ),
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryBlue),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'MANAGE COMPANY\nDOCUMENTS',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${provider.managedDocumentsCount}',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Active',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (provider.groupedDocuments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Text(
                          "No documents found.",
                          style: GoogleFonts.montserrat(color: Colors.grey),
                        ),
                      )
                    else
                      ...provider.groupedDocuments.entries.map((entry) {
                        return _buildExpandableSection(
                          entry.key,
                          entry.value,
                          primaryBlue,
                          textColor,
                          isDark,
                          initiallyExpanded: true,
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExpandableSection(
    String title,
    List<DocumentModel> documents,
    Color primaryBlue,
    Color textColor,
    bool isDark, {
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        iconColor: primaryBlue,
        collapsedIconColor: isDark ? Colors.white : Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: initiallyExpanded ? primaryBlue : textColor,
              ),
            ),
            if (documents.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text(
                      '${documents.length}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        children: documents
            .map((doc) => _buildDocItem(doc, primaryBlue, textColor))
            .toList(),
      ),
    );
  }

  Widget _buildDocItem(DocumentModel doc, Color primaryBlue, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  doc.type == 'PDF' ? Icons.picture_as_pdf : Icons.image,
                  color: doc.type == 'PDF' ? Colors.red : primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${doc.type} File',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // NEW: View Button
              IconButton(
                onPressed: () => _viewDocument(doc),
                icon: Icon(Icons.visibility, color: primaryBlue),
                tooltip: 'View Document',
              ),
              IconButton(
                onPressed: () {
                  FileDownloadHelper().downloadFile(
                    context: context,
                    url: doc.url,
                    fileName: "${doc.name.replaceAll(' ', '_')}.${doc.type.toLowerCase()}",
                  );
                },
                icon: Icon(Icons.download_rounded, color: primaryBlue),
                tooltip: 'Download Document',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showUpdateBottomSheet(doc, primaryBlue),
                  icon: Icon(Icons.sync_alt, color: primaryBlue, size: 16),
                  label: Text(
                    'Update',
                    style: GoogleFonts.montserrat(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _deleteDocument(doc),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.withOpacity(0.2)),
        ],
      ),
    );
  }
}
