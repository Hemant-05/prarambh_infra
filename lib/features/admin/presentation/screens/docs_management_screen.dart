import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_document_provider.dart';
import 'add_document_screen.dart';

class DocsManagementScreen extends StatefulWidget {
  const DocsManagementScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final provider = context.watch<AdminDocumentProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text('DOCS MANAGEMENT', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDocumentScreen())),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryBlue)),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('MANAGE PROJECT\nDOCUMENTS', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue, height: 1.2))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Text('${provider.documents.length}', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Active', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),

              // Expandable Sections
              _buildExpandableSection('Project Site Maps', provider.groupedDocuments['Project Site Maps'] ?? [], primaryBlue, textColor, isDark, initiallyExpanded: true),
              _buildExpandableSection('Project Brochures', [], primaryBlue, textColor, isDark),
              _buildExpandableSection('Business Plan', [], primaryBlue, textColor, isDark),
              _buildExpandableSection('Contest Circulars', [], primaryBlue, textColor, isDark),
              _buildExpandableSection('RERA Certification', provider.groupedDocuments['RERA Certification'] ?? [], primaryBlue, textColor, isDark, initiallyExpanded: true),
              _buildExpandableSection('Rules and Regulations', [], primaryBlue, textColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, List documents, Color primaryBlue, Color textColor, bool isDark, {bool initiallyExpanded = false}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        iconColor: primaryBlue,
        collapsedIconColor: isDark ? Colors.white : Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: initiallyExpanded ? primaryBlue : textColor)),
            if (documents.isEmpty)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)), child: Column(children: [Text('1', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)), Text('Active', style: GoogleFonts.montserrat(fontSize: 8))])),
          ],
        ),
        children: documents.map((doc) => _buildDocItem(doc, primaryBlue, textColor)).toList(),
      ),
    );
  }

  Widget _buildDocItem(var doc, Color primaryBlue, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)), child: Icon(doc.title.contains('RERA') ? Icons.verified : Icons.map, color: primaryBlue)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    Text('${doc.type} • ${doc.size}', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Last updated:', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
                  Text(doc.lastUpdated, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.sync_alt, color: primaryBlue, size: 16),
                  label: Text('Update', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: primaryBlue), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(side: BorderSide(color: primaryBlue), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Icon(Icons.delete, color: primaryBlue),
              )
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.withOpacity(0.2)),
        ],
      ),
    );
  }
}