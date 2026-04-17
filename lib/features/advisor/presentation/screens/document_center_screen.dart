import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prarambh_infra/core/widgets/pdf_viewer_screen.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_document_provider.dart';

class DocumentCenterScreen extends StatefulWidget {
  const DocumentCenterScreen({super.key});

  @override
  State<DocumentCenterScreen> createState() => _DocumentCenterScreenState();
}

class _DocumentCenterScreenState extends State<DocumentCenterScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<AdvisorDocumentProvider>().fetchDocuments(user.id.toString());
      }
    });
  }

  // --- VIEW DOCUMENT LOGIC ---
  Future<void> _viewDocument(DocumentModel doc) async {
    if (doc.type == 'IMAGE') {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black87,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true, minScale: 0.5, maxScale: 4.0,
                child: Image.network(
                  doc.url, fit: BoxFit.contain,
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                ),
              ),
              Positioned(
                top: 40, right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              )
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

  // --- UI HELPER FOR ICONS & COLORS ---
  Map<String, dynamic> _getIconStyle(String title, String category, bool isDark) {
    String t = title.toLowerCase();
    String c = category.toLowerCase();

    Color baseColor;
    Color bgColor;

    if (t.contains('welcome') || t.contains('rules')) {
      baseColor = isDark ? Colors.blueAccent : Colors.blue[700]!;
    } else if (t.contains('application') || t.contains('form')) {
      baseColor = isDark ? Colors.orangeAccent : Colors.orange[700]!;
    } else if (c.contains('brochure')) {
      baseColor = isDark ? Colors.purpleAccent : Colors.purple[600]!;
    } else if (c.contains('site map') || t.contains('map')) {
      baseColor = isDark ? Colors.tealAccent : Colors.teal[600]!;
    } else if (t.contains('plan') || c.contains('business')) {
      baseColor = isDark ? Colors.blueAccent : Colors.blue[600]!;
    } else if (t.contains('circular') || c.contains('marketing')) {
      baseColor = isDark ? Colors.redAccent : Colors.red[400]!;
    } else if (t.contains('rera') || c.contains('legal')) {
      baseColor = isDark ? Colors.amberAccent : Colors.amber[700]!;
    } else if (t.contains('id card') || c.contains('personal')) {
      baseColor = isDark ? Colors.cyanAccent : Colors.cyan[600]!;
    } else {
      baseColor = isDark ? Colors.white70 : Colors.grey[600]!;
    }

    bgColor = baseColor.withOpacity(isDark ? 0.15 : 0.1);

    return {
      'icon': _getIconFor(t, c),
      'color': baseColor,
      'bg': bgColor,
    };
  }

  IconData _getIconFor(String t, String c) {
    if (t.contains('welcome') || t.contains('rules')) return Icons.verified_user_outlined;
    if (t.contains('application') || t.contains('form')) return Icons.assignment_outlined;
    if (c.contains('brochure')) return Icons.folder_outlined;
    if (c.contains('site map') || t.contains('map')) return Icons.map_outlined;
    if (t.contains('plan') || c.contains('business')) return Icons.trending_up;
    if (t.contains('circular') || c.contains('marketing')) return Icons.campaign_outlined;
    if (t.contains('rera') || c.contains('legal')) return Icons.stars;
    if (t.contains('id card') || c.contains('personal')) return Icons.badge_outlined;
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final provider = context.watch<AdvisorDocumentProvider>();
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final hintColor = Theme.of(context).hintColor;

    // Generate dynamic categories from the fetched documents
    List<String> categories = ['All'];
    categories.addAll(provider.documents.map((d) => d.category).toSet().toList());

    // Filter logic
    final filteredDocs = provider.documents.where((doc) {
      final matchesSearch = doc.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || doc.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text(
          'Document Center', 
          style: GoogleFonts.montserrat(
            color: textColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.montserrat(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search for brochures, forms...',
                  hintStyle: GoogleFonts.montserrat(color: hintColor, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Categories List
          if (provider.documents.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryBlue : cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? primaryBlue : AppColors.getBorderColor(context)),
                      ),
                      child: Row(
                        children: [
                          if (cat == 'All') Icon(Icons.grid_view, size: 14, color: isSelected ? Colors.white : secondaryTextColor),
                          if (cat == 'All') const SizedBox(width: 6),
                          Text(
                            cat,
                            style: GoogleFonts.montserrat(
                              color: isSelected ? Colors.white : (isSelected ? Colors.white : secondaryTextColor),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Document List
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : filteredDocs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_outlined, size: 48, color: hintColor.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('No documents found.', style: GoogleFonts.montserrat(color: hintColor)),
                      ],
                    ),
                  )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredDocs.length + 1, // +1 for the "End of list" text
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == filteredDocs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('End of list', style: GoogleFonts.montserrat(color: hintColor, fontSize: 12))),
                  );
                }

                final doc = filteredDocs[index];
                final style = _getIconStyle(doc.name, doc.category, isDark);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.getBorderColor(context)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.02), 
                        blurRadius: 8, 
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: style['bg'], borderRadius: BorderRadius.circular(8)),
                        child: Icon(style['icon'], color: style['color'], size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.name,
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${doc.type} • 1.2 MB', // Mocking size as API currently lacks it
                              style: GoogleFonts.montserrat(fontSize: 12, color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.visibility, color: primaryBlue),
                        onPressed: () => _viewDocument(doc),
                      ),
                      IconButton(
                        icon: Icon(Icons.download_outlined, color: secondaryTextColor),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading...')));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}