import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/data/models/document_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
      final Uri url = Uri.parse(doc.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open PDF.')));
      }
    }
  }

  // --- UI HELPER FOR ICONS & COLORS ---
  Map<String, dynamic> _getIconStyle(String title, String category) {
    String t = title.toLowerCase();
    String c = category.toLowerCase();

    if (t.contains('welcome') || t.contains('rules')) return {'icon': Icons.verified_user_outlined, 'color': Colors.blue[700], 'bg': Colors.blue[50]};
    if (t.contains('application') || t.contains('form')) return {'icon': Icons.assignment_outlined, 'color': Colors.orange[700], 'bg': Colors.orange[50]};
    if (c.contains('brochure')) return {'icon': Icons.folder_outlined, 'color': Colors.purple[600], 'bg': Colors.purple[50]};
    if (c.contains('site map') || t.contains('map')) return {'icon': Icons.map_outlined, 'color': Colors.teal[600], 'bg': Colors.teal[50]};
    if (t.contains('plan') || c.contains('business')) return {'icon': Icons.trending_up, 'color': Colors.blue[600], 'bg': Colors.blue[50]};
    if (t.contains('circular') || c.contains('marketing')) return {'icon': Icons.campaign_outlined, 'color': Colors.red[400], 'bg': Colors.red[50]};
    if (t.contains('rera') || c.contains('legal')) return {'icon': Icons.stars, 'color': Colors.amber[700], 'bg': Colors.amber[50]};
    if (t.contains('id card') || c.contains('personal')) return {'icon': Icons.badge_outlined, 'color': Colors.cyan[600], 'bg': Colors.cyan[50]};

    return {'icon': Icons.description_outlined, 'color': Colors.grey[600], 'bg': Colors.grey[100]};
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final provider = context.watch<AdvisorDocumentProvider>();

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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: backButton(isDark: isDark),
        title: Text('Document Center', style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search for brochures, forms...',
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                        color: isSelected ? primaryBlue : (isDark ? Colors.grey[800] : Colors.white),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? primaryBlue : Colors.grey.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          if (cat == 'All') Icon(Icons.grid_view, size: 14, color: isSelected ? Colors.white : Colors.grey[600]),
                          if (cat == 'All') const SizedBox(width: 6),
                          Text(
                            cat,
                            style: GoogleFonts.montserrat(
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
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
                ? Center(child: Text('No documents found.', style: GoogleFonts.montserrat(color: Colors.grey)))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredDocs.length + 1, // +1 for the "End of list" text
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == filteredDocs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('End of list', style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 12))),
                  );
                }

                final doc = filteredDocs[index];
                final style = _getIconStyle(doc.name, doc.category);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
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
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${doc.type} • 1.2 MB', // Mocking size as API currently lacks it
                              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Color(0xFF0056A4)), // Dark blue eye icon
                        onPressed: () => _viewDocument(doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_outlined, color: Colors.grey),
                        onPressed: () {
                          // Download logic can go here
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