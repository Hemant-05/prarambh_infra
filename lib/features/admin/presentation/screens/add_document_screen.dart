import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_document_provider.dart';
import 'package:prarambh_infra/core/utils/validators.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _selectedCategory = 'Project Brochures';
  File? _selectedFile;

  final List<String> _categories = [
    'Project Brochures',
    'Project Site Maps',
    'RERA',
    'Company Legal Documents',
    'Business Plan',
    'Circulars',
    'Company Rules & Regulations',
    'Others'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final provider = context.watch<AdminDocumentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: backButton(isDark: false),
        title: Text('Add Document', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: provider.isSaving ? null : () async {
              if (!_formKey.currentState!.validate()) return;
              if (_selectedFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file.')));
                return;
              }

              final success = await provider.uploadDocument(
                name: _nameCtrl.text,
                category: _selectedCategory,
                documentFile: _selectedFile!,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document Uploaded Successfully')));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: provider.isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Upload Document', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Document Name', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  validator: (v) => Validators.validateRequired(v, 'Document Name'),
                  decoration: InputDecoration(
                    hintText: 'e.g. Phase 2 Brochure',
                    filled: true, fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                    errorStyle: GoogleFonts.montserrat(fontSize: 10, height: 0.8),
                  ),
                ),
                const SizedBox(height: 20),

                Text('Category', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text('File Upload', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDocument,
                  child: DottedBorder(
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Icon(_selectedFile != null ? Icons.check_circle : Icons.upload_file, color: primaryBlue, size: 40),
                          const SizedBox(height: 12),
                          Text(_selectedFile != null ? _selectedFile!.path.split('/').last : 'Tap to select PDF or Image', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}