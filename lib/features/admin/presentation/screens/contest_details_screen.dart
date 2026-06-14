import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_contest_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../data/models/contest_model.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'create_contest_screen.dart';

class ContestDetailsScreen extends StatefulWidget {
  final ContestModel contest;
  const ContestDetailsScreen({super.key, required this.contest});

  @override
  State<ContestDetailsScreen> createState() => _ContestDetailsScreenState();
}

class _ContestDetailsScreenState extends State<ContestDetailsScreen> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  final bool _isUploadingVideo = false;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimer(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTimer();
    });
  }

  void _updateTimer() {
    if (!mounted) return;

    final provider = context.read<AdminContestProvider>();
    final contest = provider.contests.firstWhere(
      (c) => c.id == widget.contest.id,
      orElse: () => widget.contest,
    );

    final DateTime? target;
    if (contest.isUpcoming && contest.startDate != null) {
      target = ContestModel.smartParse(contest.startDate);
    } else if (contest.isLive && contest.endDate != null) {
      target = ContestModel.smartParse(contest.endDate);
    } else {
      target = null;
    }

    if (target == null) {
      setState(() {
        _timeLeft = Duration.zero;
      });
      return;
    }

    final now = DateTime.now();
    if (contest.isUpcoming && now.isAfter(target)) {
      setState(() {});
      return;
    }

    if (target.isAfter(now)) {
      setState(() {
        _timeLeft = target!.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatPad(int value) => value.toString().padLeft(2, '0');

  Future<void> _shareContest(ContestModel contest) async {
    final bool isLive = contest.isLive;
    final bool isUpcoming = contest.isUpcoming;
    final bool isEnded = contest.isEnded;

    String statusText = 'ACTIVE';
    if (isLive) {
      statusText = '🟢 LIVE NOW';
    } else if (isUpcoming) {
      statusText = '🔵 UPCOMING';
    } else if (isEnded) {
      statusText = '⚪ ENDED';
    }

    final parsedStart = ContestModel.smartParse(contest.startDate);
    final parsedEnd = ContestModel.smartParse(contest.endDate);
    final String startDateFormatted = parsedStart != null 
        ? '${parsedStart.day.toString().padLeft(2, '0')}-${parsedStart.month.toString().padLeft(2, '0')}-${parsedStart.year}'
        : (contest.startDate?.split(' ')[0] ?? 'N/A');
    final String endDateFormatted = parsedEnd != null 
        ? '${parsedEnd.day.toString().padLeft(2, '0')}-${parsedEnd.month.toString().padLeft(2, '0')}-${parsedEnd.year}'
        : (contest.endDate?.split(' ')[0] ?? 'N/A');

    final StringBuffer sb = StringBuffer();
    sb.writeln('🏢 *PRARAMBH INFRA CONTEST* 🏢');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln('🏆 *Contest:* ${contest.title}');
    sb.writeln('📢 *Status:* $statusText');
    sb.writeln('🎁 *Reward:* ${contest.rewardText}');
    sb.writeln('🎯 *Target:* Sell 5 Units to qualify!');
    sb.writeln('📅 *Starts On:* $startDateFormatted');
    sb.writeln('📅 *Ends On:* $endDateFormatted');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (contest.rules != null && contest.rules!.isNotEmpty) {
      sb.writeln('\n📋 *CONTEST RULES & GUIDELINES:*');
      for (int i = 0; i < contest.rules!.length; i++) {
        sb.writeln('${i + 1}️⃣ ${contest.rules![i]}');
      }
      sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    sb.writeln('\n📲 Join the contest on *Prarambh Infra* app and participate now! 🚀');

    final String shareText = sb.toString();
    final String imageUrl = contest.imageUrl;

    if (imageUrl.isNotEmpty) {
      try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Text('Preparing contest content...'),
                ],
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }

        final dio = Dio();
        final tempDir = await getTemporaryDirectory();
        final String fileName = 'contest_reward_${contest.id}.jpg';
        final String filePath = '${tempDir.path}/$fileName';

        await dio.download(imageUrl, filePath);

        await Share.shareXFiles(
          [XFile(filePath)],
          text: shareText,
          subject: contest.title,
        );
        return;
      } catch (e) {
        debugPrint('Error downloading reward image for sharing: $e');
      }
    }

    // Fallback to text-only share if image URL is empty or download fails
    await Share.share(
      shareText,
      subject: contest.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final provider = context.watch<AdminContestProvider>();
    final contest = provider.contests.firstWhere(
      (c) => c.id == widget.contest.id,
      orElse: () => widget.contest,
    );

    // Functional Status Logic
    final bool isLive = contest.isLive;
    final bool isUpcoming = contest.isUpcoming;
    final bool isEnded = contest.isEnded;

    String timerLabel = 'TIME REMAINING';
    if (isUpcoming) timerLabel = 'STARTS IN';
    if (isEnded) timerLabel = 'CONTEST ENDED';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Image with transparent AppBar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Contest Details',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareContest(contest),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateContestScreen(existingContest: contest),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _MediaCarousel(
                videoUrl: contest.videoUrl,
                imageUrl: contest.imageUrl,
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF121212)
                    : const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Reward
                  Text(
                    contest.title,
                    style: GoogleFonts.montserrat(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reward: ${contest.rewardText}',
                          style: GoogleFonts.montserrat(
                            color: Colors.amber.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Time Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timerLabel,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        contest.endDate != null
                            ? 'Ends ${contest.endDate!.split(' ')[0]}'
                            : 'No End Date',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.blueGrey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeBox(
                        _formatPad(_timeLeft.inDays),
                        'DAYS',
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildTimeBox(
                        _formatPad(_timeLeft.inHours.remainder(24)),
                        'HRS',
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildTimeBox(
                        _formatPad(_timeLeft.inMinutes.remainder(60)),
                        'MINS',
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildTimeBox(
                        _formatPad(_timeLeft.inSeconds.remainder(60)),
                        'SECS',
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Top Performers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Performers',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (contest.topPerformers != null &&
                      contest.topPerformers!.isNotEmpty)
                    ...contest.topPerformers!.asMap().entries.map((
                      entry,
                    ) {
                      int rank = entry.key + 1;
                      Color rankColor = rank == 1
                          ? const Color(0xFFFFF9C4)
                          : rank == 2
                          ? const Color(0xFFF5F5F5)
                          : const Color(0xFFFFE0B2);
                      Color rankTextColor = rank == 1
                          ? const Color(0xFFF57F17)
                          : rank == 2
                          ? const Color(0xFF757575)
                          : const Color(0xFFE65100);
                      Color avatarBg = rank == 1
                          ? const Color(0xFFE8EAF6)
                          : rank == 2
                          ? const Color(0xFFE0F2F1)
                          : const Color(0xFFFCE4EC);
                      Color avatarText = rank == 1
                          ? const Color(0xFF3F51B5)
                          : rank == 2
                          ? const Color(0xFF00796B)
                          : const Color(0xFFC2185B);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: rankColor,
                              child: Text(
                                '$rank',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: rankTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: avatarBg,
                              child: Text(
                                entry.value.initials,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: avatarText,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value.name,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    entry.value.location,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: Colors.blueGrey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              entry.value.units,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "No performers listed yet.",
                          style: GoogleFonts.montserrat(color: Colors.grey),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Rules
                  Text(
                    'Contest Rules',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (contest.rules != null &&
                      contest.rules!.isNotEmpty)
                    ...contest.rules!.map(
                      (rule) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rule,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.blueGrey[800],
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      "No specific rules provided.",
                      style: GoogleFonts.montserrat(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(
    String value,
    String label,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: Colors.blueGrey[600],
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContestVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _ContestVideoPlayer({required this.videoUrl});

  @override
  State<_ContestVideoPlayer> createState() => _ContestVideoPlayerState();
}

class _ContestVideoPlayerState extends State<_ContestVideoPlayer> {
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

class _MediaCarousel extends StatefulWidget {
  final String videoUrl;
  final String imageUrl;

  const _MediaCarousel({required this.videoUrl, required this.imageUrl});

  @override
  State<_MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<_MediaCarousel> {
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
      mediaWidgets.add(_ContestVideoPlayer(videoUrl: widget.videoUrl));
    }
    if (widget.imageUrl.isNotEmpty) {
      mediaWidgets.add(
        Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: Colors.blueGrey[900],
                child: const Icon(Icons.image, size: 80, color: Colors.white24),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.black.withOpacity(0.85)],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (mediaWidgets.isEmpty) {
      return Container(
        color: Colors.blueGrey[900],
        child: const Icon(Icons.image, size: 80, color: Colors.white24),
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
