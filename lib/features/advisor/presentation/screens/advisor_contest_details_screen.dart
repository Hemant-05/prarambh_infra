import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/contest_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_contest_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AdvisorContestDetailsScreen extends StatefulWidget {
  final ContestModel contest;
  const AdvisorContestDetailsScreen({super.key, required this.contest});

  @override
  State<AdvisorContestDetailsScreen> createState() =>
      _AdvisorContestDetailsScreenState();
}

class _AdvisorContestDetailsScreenState
    extends State<AdvisorContestDetailsScreen> {
  DateTime? _targetDate;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    if (widget.contest.isUpcoming && widget.contest.startDate != null) {
      _targetDate = ContestModel.smartParse(widget.contest.startDate);
    } else if (widget.contest.isLive && widget.contest.endDate != null) {
      _targetDate = ContestModel.smartParse(widget.contest.endDate);
    }

    if (_targetDate != null) {
      _updateTimer();
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateTimer(),
      );
    }
  }

  void _updateTimer() {
    if (_targetDate == null || !mounted) return;
    final now = DateTime.now();

    // If the target date was the start date and we've reached it,
    // we should re-initialize to track the end date.
    if (widget.contest.isUpcoming && now.isAfter(_targetDate!)) {
      _timer?.cancel();
      _initializeTimer();
      return;
    }

    if (_targetDate!.isAfter(now)) {
      setState(() => _timeLeft = _targetDate!.difference(now));
    } else {
      setState(() => _timeLeft = Duration.zero);
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _shareContest() async {
    final bool isLive = widget.contest.isLive;
    final bool isUpcoming = widget.contest.isUpcoming;
    final bool isEnded = widget.contest.isEnded;

    String statusText = 'ACTIVE';
    if (isLive) {
      statusText = '🟢 LIVE NOW';
    } else if (isUpcoming) {
      statusText = '🔵 UPCOMING';
    } else if (isEnded) {
      statusText = '⚪ ENDED';
    }

    final parsedStart = ContestModel.smartParse(widget.contest.startDate);
    final parsedEnd = ContestModel.smartParse(widget.contest.endDate);
    final String startDateFormatted = parsedStart != null 
        ? '${parsedStart.day.toString().padLeft(2, '0')}-${parsedStart.month.toString().padLeft(2, '0')}-${parsedStart.year}'
        : (widget.contest.startDate?.split(' ')[0] ?? 'N/A');
    final String endDateFormatted = parsedEnd != null 
        ? '${parsedEnd.day.toString().padLeft(2, '0')}-${parsedEnd.month.toString().padLeft(2, '0')}-${parsedEnd.year}'
        : (widget.contest.endDate?.split(' ')[0] ?? 'N/A');

    final StringBuffer sb = StringBuffer();
    sb.writeln('🏢 *PRARAMBH INFRA CONTEST* 🏢');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln('🏆 *Contest:* ${widget.contest.title}');
    sb.writeln('📢 *Status:* $statusText');
    sb.writeln('🎁 *Reward:* ${widget.contest.rewardText}');
    sb.writeln('🎯 *Target:* Sell 5 Units to qualify!');
    sb.writeln('📅 *Starts On:* $startDateFormatted');
    sb.writeln('📅 *Ends On:* $endDateFormatted');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (widget.contest.rules != null && widget.contest.rules!.isNotEmpty) {
      sb.writeln('\n📋 *CONTEST RULES & GUIDELINES:*');
      for (int i = 0; i < widget.contest.rules!.length; i++) {
        sb.writeln('${i + 1}️⃣ ${widget.contest.rules![i]}');
      }
      sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    sb.writeln('\n📲 Join the contest on *Prarambh Infra* app and participate now! 🚀');

    final String shareText = sb.toString();
    final String imageUrl = widget.contest.imageUrl;

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
        final String fileName = 'contest_reward_${widget.contest.id}.jpg';
        final String filePath = '${tempDir.path}/$fileName';

        await dio.download(imageUrl, filePath);

        await Share.shareXFiles(
          [XFile(filePath)],
          text: shareText,
          subject: widget.contest.title,
        );
        return;
      } catch (e) {
        debugPrint('Error downloading reward image for sharing: $e');
      }
    }

    // Fallback to text-only share if image URL is empty or download fails
    await Share.share(
      shareText,
      subject: widget.contest.title,
    );
  }

  String _formatPad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isLive = widget.contest.isLive;
    final bool isUpcoming = widget.contest.isUpcoming;
    final bool isEnded = widget.contest.isEnded;

    String timerLabel = 'TIME REMAINING';
    if (isUpcoming) timerLabel = 'STARTS IN';
    if (isEnded) timerLabel = 'CONTEST ENDED';

    // Auth & Contest Providers
    final authProvider = context.read<AuthProvider>();
    final advisorCode = authProvider.currentUser?.advisorCode ?? '';
    final contestProvider = context.watch<AdvisorContestProvider>();

    // Participant state mapping
    final isJoined = widget.contest.participants.any(
      (p) => p.advisorCode == advisorCode,
    );
    final myData = isJoined
        ? widget.contest.participants.firstWhere(
            (p) => p.advisorCode == advisorCode,
          )
        : null;
    int targetSales = 5; // Default Target
    int currentSales = myData?.units ?? 0;
    int progressPercent = (currentSales / targetSales * 100)
        .clamp(0, 100)
        .toInt();

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
          'Contest Details',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareContest,
          ),
        ],
      ),
      bottomNavigationBar: isLive
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: isJoined || contestProvider.isJoining
                      ? null
                      : () async {
                          final success = await contestProvider.joinContest(
                            widget.contest.id,
                            advisorCode,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Successfully joined the contest!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context); // Pop to refresh list
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to join. Please try again.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined ? Colors.green : primaryBlue,
                    disabledBackgroundColor: Colors.green.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: contestProvider.isJoining
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isJoined ? 'Joined • Keep Going!' : 'Join Contest',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            )
          : null, // Don't show Join Contest button when not live (expired or upcoming)
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              child: _MediaCarousel(
                videoUrl: widget.contest.videoUrl,
                imageUrl: widget.contest.imageUrl,
              ),
            ),
            Container(
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: isLive
                                ? Colors.deepOrange
                                : (isUpcoming ? Colors.blue : Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLive
                                ? 'LIVE NOW'
                                : (isUpcoming ? 'UPCOMING' : 'ENDED'),
                            style: GoogleFonts.montserrat(
                              color: isLive
                                  ? Colors.deepOrange
                                  : (isUpcoming
                                        ? Colors.blue
                                        : Colors.grey),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.contest.endDate != null
                            ? 'Ends ${widget.contest.endDate!.split(' ')[0]}'
                            : 'No End Date',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.contest.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Reward Row
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reward: ${widget.contest.rewardText}',
                          style: GoogleFonts.montserrat(
                            color: isDark
                                ? Colors.white70
                                : Colors.blueGrey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Current Progress Section (only if joined) ---
                  if (isJoined) ...[
                    Text(
                      'Current Progress',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: progressPercent / 100,
                                  strokeWidth: 5,
                                  backgroundColor: Colors.grey[200],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.deepOrange,
                                      ),
                                ),
                                Center(
                                  child: Text(
                                    '$progressPercent%',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL SALES: $currentSales / $targetSales Units',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sell ${targetSales - currentSales} more units to qualify!',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Time Remaining
                  Text(
                    timerLabel,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 24),

                  // Rules
                  Text(
                    'Contest Rules',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.contest.rules != null &&
                      widget.contest.rules!.isNotEmpty)
                    ...widget.contest.rules!.map(
                      (rule) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                                size: 12,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                rule,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
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
                      style: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 8,
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
        Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            color: Colors.blueGrey[900],
            child: const Icon(Icons.image, size: 80, color: Colors.white24),
          ),
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
