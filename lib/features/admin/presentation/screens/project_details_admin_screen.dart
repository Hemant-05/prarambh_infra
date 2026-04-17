import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/add_project_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart'; // NEW
import 'package:chewie/chewie.dart'; // NEW
import 'package:intl/intl.dart'; // NEW
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_helper.dart';
import '../../data/models/project_model.dart';
import 'package:prarambh_infra/core/widgets/pdf_viewer_screen.dart';
import 'project_inventory_screen.dart';

class ProjectDetailsAdminScreen extends StatefulWidget {
  final ProjectModel project;
  const ProjectDetailsAdminScreen({super.key, required this.project});

  @override
  State<ProjectDetailsAdminScreen> createState() =>
      _ProjectDetailsAdminScreenState();
}

class _ProjectDetailsAdminScreenState extends State<ProjectDetailsAdminScreen> {
  int _currentMediaIndex = 0;
  final List<Map<String, String>> _mediaItems = []; // Combines video and images

  @override
  void initState() {
    super.initState();
    _setupMediaList();
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

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                tooltip: 'Edit Project',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddProjectScreen(existingProject: project),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // MEDIA CAROUSEL
                  _mediaItems.isNotEmpty
                      ? PageView.builder(
                          itemCount: _mediaItems.length,
                          onPageChanged: (index) =>
                              setState(() => _currentMediaIndex = index),
                          itemBuilder: (context, index) {
                            final media = _mediaItems[index];
                            if (media['type'] == 'video') {
                              return _InlineVideoPlayer(
                                videoUrl: media['url']!,
                              );
                            } else {
                              return Image.network(
                                media['url']!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.domain,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                  // THE FIX: IgnorePointer prevents the gradient from blocking your swipes!
                  IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black87,
                          ],
                          stops: [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Dot Indicators
                  if (_mediaItems.length > 1)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_mediaItems.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentMediaIndex == index ? 12 : 8,
                            height: _currentMediaIndex == index ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentMediaIndex == index
                                  ? primaryBlue
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
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
              transform: Matrix4.translationValues(0, -20, 0),
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusBadge(
                          Icons.category,
                          project.projectType,
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(
                          Icons.construction,
                          project.constructionStatus,
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(
                          Icons.check_circle,
                          project.status,
                          Colors.green,
                        ),
                      ],
                    ),
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
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row 1: Size & Rate
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          'Total Area',
                          '${project.buildArea} sq.ft',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          'Market Value',
                          '₹${NumberFormat.compact().format(project.marketValue)}',
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
                          'Start Rate',
                          '₹${project.ratePerSqft}/sq.ft',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          'Budget Range',
                          project.budgetRange,
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

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                url: fullUrl,
                                title: '${project.projectName} Brochure',
                                fileName:
                                    "${project.projectName.replaceAll(' ', '_')}_Brochure.pdf",
                              ),
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
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProjectInventoryScreen(project: project),
                                ),
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

// =======================================================
// NEW COMPONENT: Interactive Inline Video Player
// =======================================================
class _InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _InlineVideoPlayer({required this.videoUrl});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      showControlsOnInitialize: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blueAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? Chewie(controller: _chewieController!)
        : const Center(child: CircularProgressIndicator(color: Colors.blue));
  }
}
