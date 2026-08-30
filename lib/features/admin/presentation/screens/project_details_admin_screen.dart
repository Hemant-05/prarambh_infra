import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/add_project_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_helper.dart';
import '../../data/models/project_model.dart';
import 'package:prarambh_infra/core/widgets/pdf_viewer_screen.dart';
import 'package:prarambh_infra/core/widgets/media_carousel.dart';
import 'project_inventory_screen.dart';

class ProjectDetailsAdminScreen extends StatefulWidget {
  final ProjectModel project;
  const ProjectDetailsAdminScreen({super.key, required this.project});

  @override
  State<ProjectDetailsAdminScreen> createState() =>
      _ProjectDetailsAdminScreenState();
}

class _ProjectDetailsAdminScreenState extends State<ProjectDetailsAdminScreen> {
  final List<Map<String, String>> _mediaItems = []; // Combines video and images
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _setupMediaList();
  }

  Future<void> _navigateTo(Widget screen) async {
    setState(() {
      _isVisible = false;
    });
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  void _setupMediaList() {
    // 1. Add Video if it exists (Show it as the first item)
    if (widget.project.videoUrl.isNotEmpty) {
      String vidUrl = widget.project.videoUrl.startsWith('http')
          ? widget.project.videoUrl
          : 'https://workiees.com/${widget.project.videoUrl.startsWith('/') ? widget.project.videoUrl.substring(1) : widget.project.videoUrl}';
      _mediaItems.add({'type': 'video', 'url': vidUrl});
    }

    // 2. Add all Images
    for (String imgUrl in widget.project.images) {
      _mediaItems.add({'type': 'image', 'url': imgUrl});
    }
  }

  Future<void> _launchUrl(String path) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Link not available')));
      return;
    }

    String fullUrl = path.startsWith('http')
        ? path
        : 'https://workiees.com/${path.startsWith('/') ? path.substring(1) : path}';

    final Uri url = Uri.parse(fullUrl);

    try {
      // Platform default is the safest bet to avoid Android null component crashes
      await launchUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final project = widget.project;

    String formattedBudgetRange = project.budgetRange;
    if (project.budgetRange.contains('-')) {
      final parts = project.budgetRange.split('-');
      if (parts.length == 2) {
        String p1 = UIHelper.formatIndianCurrency(parts[0].trim());
        String p2 = UIHelper.formatIndianCurrency(parts[1].trim());
        formattedBudgetRange = '$p1 - $p2';
      }
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          project.projectName,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        centerTitle: true,
        leading: backButton(isDark: !isDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 24),
            tooltip: 'Edit Project',
            onPressed: () {
              _navigateTo(AddProjectScreen(existingProject: project));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // MEDIA CAROUSEL moved to top of body
          SliverToBoxAdapter(
            child: MediaCarousel(
              mediaItems: _mediaItems,
              isVisible: _isVisible,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project.projectName,
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (project.reraNumber.isNotEmpty)
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
                            'RERA Approved',
                            style: GoogleFonts.montserrat(
                              color: primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${project.city} • ${project.fullAddress.isNotEmpty ? project.fullAddress : project.locationMapUrl}',
                          style: GoogleFonts.montserrat(
                            color: primaryBlue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Project Status & Type Row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Type",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (project.projectType.isNotEmpty)
                              ...project.projectType
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .map(
                                    (type) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: _buildStatusBadge(
                                        Icons.category,
                                        type,
                                        Colors.orange,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Property Type",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (project.constructionStatus.isNotEmpty)
                              ...project.constructionStatus
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .map(
                                    (type) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: _buildStatusBadge(
                                        Icons.construction,
                                        type,
                                        Colors.blue,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Construction Status",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (project.status.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildStatusBadge(
                                  Icons.check_circle,
                                  project.status,
                                  Colors.green,
                                ),
                              ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Developer Row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DEVELOPER',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                project.developerName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RERA NO.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                project.reraNumber.isNotEmpty
                                    ? project.reraNumber
                                    : 'N/A',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LAND OWNER',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                project.landOwnerName.isNotEmpty
                                    ? project.landOwnerName
                                    : 'N/A',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fact_check,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TNCP NO.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                project.tncpNumber.isNotEmpty
                                    ? project.tncpNumber
                                    : 'N/A',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row 1: Size & Rate
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          'Total Area',
                          '${project.buildArea} sqft',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          'PRICE/SQFT',
                          '₹${project.ratePerSqft}/sq.ft',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats Row 2: Financials
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          'Budget Range',
                          formattedBudgetRange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Description
                  if (project.description.isNotEmpty) ...[
                    Text(
                      'Project Description',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      project.description,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Amenities
                  if (project.amenities.isNotEmpty) ...[
                    Text(
                      'Amenities',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: project.amenities
                          .map((a) => _buildChip(a, Colors.teal))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Specialties
                  if (project.specialties.isNotEmpty) ...[
                    Text(
                      'Features & Specialties',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: project.specialties
                          .map((s) => _buildChip(s, Colors.deepPurple))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(
                        Icons.map,
                        'Map',
                        'View',
                        primaryBlue,
                        () => _launchUrl(project.locationMapUrl),
                      ),
                      _buildQuickAction(
                        Icons.description,
                        'Brochure',
                        'View & Download',
                        primaryBlue,
                        () {
                          String path = project.brochureUrl.isNotEmpty
                              ? project.brochureUrl
                              : project.brochureFile;

                          if (path.isEmpty) {
                            UIHelper.showError(
                              context,
                              "Brochure not available",
                            );
                            return;
                          }

                          String fullUrl = path.startsWith('http')
                              ? path
                              : 'https://workiees.com/${path.startsWith('/') ? path.substring(1) : path}';

                          // Encode URL to handle spaces/special chars
                          fullUrl = Uri.encodeFull(fullUrl);

                          _navigateTo(
                            PdfViewerScreen(
                              url: fullUrl,
                              title: '${project.projectName} Brochure',
                              fileName:
                                  "${project.projectName.replaceAll(' ', '_')}_Brochure.pdf",
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Availability Card (Unchanged)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plot Availability',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _navigateTo(
                                ProjectInventoryScreen(project: project),
                              ),
                              child: Text(
                                'View All',
                                style: GoogleFonts.montserrat(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLegendItem(Colors.green, 'Available'),
                            _buildLegendItem(Colors.orange, 'Booked'),
                            _buildLegendItem(Colors.red, 'Sold Out'),
                            _buildLegendItem(Colors.amber, 'Resale'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Metadata Footer
                  Center(
                    child: Text(
                      'Listed on: ${DateFormat('dd MMM yyyy').format(project.createdAt)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String title,
    String subtitle,
    Color primaryBlue,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
