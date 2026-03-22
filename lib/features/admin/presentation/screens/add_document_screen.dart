import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import '../../../../core/theme/app_colors.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({Key? key}) : super(key: key);

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  String selectedCategory = 'Select Category';

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text('Admin: Add New Document', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Document Name', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Document Name',
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                ),
              ),
              const SizedBox(height: 20),

              Text('Select Category', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: primaryBlue), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: ['Select Category', 'Business plan', 'Circulars', 'Site Map', 'Brochures'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value, style: GoogleFonts.montserrat()));
                    }).toList(),
                    onChanged: (newValue) => setState(() => selectedCategory = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // File Picker Area
              GestureDetector(
                onTap: () async {
                  // Implement File Picker logic here using file_picker package
                  // FilePickerResult? result = await FilePicker.platform.pickFiles();
                },
                child: DottedBorder(
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Center(
                      child: Text('Choose File from Device', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: Text('Upload and Add to Center', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}