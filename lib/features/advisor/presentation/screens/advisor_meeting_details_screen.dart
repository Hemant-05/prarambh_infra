import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/advisor_meeting_model.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';

class AdvisorMeetingDetailsScreen extends StatefulWidget {
  final AdvisorMeetingModel meeting;
  const AdvisorMeetingDetailsScreen({super.key, required this.meeting});

  @override
  State<AdvisorMeetingDetailsScreen> createState() =>
      _AdvisorMeetingDetailsScreenState();
}

class _AdvisorMeetingDetailsScreenState
    extends State<AdvisorMeetingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Status text and color helper
    final status = widget.meeting.status.toUpperCase();
    Color statusColor = Colors.green;
    if (status == 'ONGOING') statusColor = Colors.orange;
    if (status == 'COMPLETED') statusColor = Colors.blue;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: !isDark),
        title: Text(
          'Meeting Details',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF121212) : primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: _MeetingMediaCarousel(
                videoUrl: widget.meeting.videoUrl,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Time Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.montserrat(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(widget.meeting.meetingDate),
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        widget.meeting.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Details Rows
                      _buildDetailRow(
                        Icons.access_time_outlined,
                        'Time',
                        '${_formatTime(widget.meeting.startTime)} - ${_formatTime(widget.meeting.endTime)}',
                        isDark,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Location',
                        widget.meeting.location,
                        isDark,
                      ),

                      // Attendance Info
                      if (widget.meeting.checkInTime != null) ...[
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          Icons.login,
                          'Checked In',
                          _formatTime(widget.meeting.checkInTime!),
                          isDark,
                          textColor: Colors.green,
                        ),
                      ],
                      if (widget.meeting.checkOutTime != null) ...[
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          Icons.logout,
                          'Checked Out',
                          _formatTime(widget.meeting.checkOutTime!),
                          isDark,
                          textColor: Colors.blue,
                        ),
                      ],
                      if (widget.meeting.checkInTime != null &&
                          widget.meeting.checkOutTime == null) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              ); // Go back to schedule screen to exit
                            },
                            icon: const Icon(Icons.exit_to_app),
                            label: Text(
                              'Exit Meeting',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    textColor ??
                    (isDark ? Colors.white70 : Colors.blueGrey[800]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty || timeStr == '--:--') return timeStr;
    try {
      final upper = timeStr.toUpperCase();
      if (upper.contains('AM') || upper.contains('PM')) return timeStr;
      
      String t = timeStr;
      if (t.contains('T')) {
        t = t.split('T').last;
      } else if (t.contains(' ')) {
        t = t.split(' ').last;
      }
      
      final parts = t.split(':');
      if (parts.isEmpty) return timeStr;
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }
}

class _MeetingVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _MeetingVideoPlayer({required this.videoUrl});

  @override
  State<_MeetingVideoPlayer> createState() => _MeetingVideoPlayerState();
}

class _MeetingVideoPlayerState extends State<_MeetingVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white,
        ),
      );
    } catch (e) {
      debugPrint("Error initializing video player: $e");
      _hasError = true;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Failed to load video',
            style: GoogleFonts.montserrat(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? Chewie(controller: _chewieController!)
        : const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}

class _MeetingMediaCarousel extends StatefulWidget {
  final String videoUrl;

  const _MeetingMediaCarousel({required this.videoUrl});

  @override
  State<_MeetingMediaCarousel> createState() => _MeetingMediaCarouselState();
}

class _MeetingMediaCarouselState extends State<_MeetingMediaCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mediaWidgets = [];
    if (widget.videoUrl.isNotEmpty) {
      mediaWidgets.add(_MeetingVideoPlayer(videoUrl: widget.videoUrl));
    }

    // As Meeting might not have a banner image unlike Contest, we skip it or add placeholder if both empty.
    if (mediaWidgets.isEmpty) {
      return Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_camera_front_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No meeting video available',
              style: GoogleFonts.montserrat(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (mediaWidgets.length == 1) {
      return mediaWidgets.first;
    }

    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (idx) => setState(() => _currentPage = idx),
          children: mediaWidgets,
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              mediaWidgets.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blue : Colors.white54,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
