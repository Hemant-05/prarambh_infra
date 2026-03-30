import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/contest_model.dart';

class ContestDetailsScreen extends StatefulWidget {
  final ContestModel contest;
  const ContestDetailsScreen({super.key, required this.contest});

  @override
  State<ContestDetailsScreen> createState() => _ContestDetailsScreenState();
}

class _ContestDetailsScreenState extends State<ContestDetailsScreen> {
  DateTime? _targetDate;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    // If contest is live and has an end date, start ticking
    if (widget.contest.status.toUpperCase() == 'LIVE' && widget.contest.endDate != null) {
      _targetDate = DateTime.tryParse(widget.contest.endDate!);
      if (_targetDate != null) {
        _updateTimer();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
      }
    }
  }

  void _updateTimer() {
    if (_targetDate == null || !mounted) return;
    final now = DateTime.now();
    if (_targetDate!.isAfter(now)) {
      setState(() {
        _timeLeft = _targetDate!.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatPad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLive = widget.contest.status.toUpperCase() == 'LIVE';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_box_outlined, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            label: Text(
              'How to Qualify',
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
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
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Reward Image
                  widget.contest.imageUrl.isNotEmpty
                      ? Image.network(
                    widget.contest.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.blueGrey, child: const Icon(Icons.image, size: 100, color: Colors.white24)),
                  )
                      : Container(color: Colors.blueGrey, child: const Icon(Icons.image, size: 100, color: Colors.white24)),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.black.withOpacity(0.85)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: isLive ? Colors.deepOrange : Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              isLive ? 'LIVE NOW' : widget.contest.status.toUpperCase(),
                              style: GoogleFonts.montserrat(color: isLive ? Colors.deepOrange : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.contest.title,
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Reward: ${widget.contest.rewardText}',
                              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TIME REMAINING',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      ),
                      Text(
                        widget.contest.endDate != null ? 'Ends ${widget.contest.endDate!.split(' ')[0]}' : 'No End Date',
                        style: GoogleFonts.montserrat(fontSize: 13, color: Colors.blueGrey[600], fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeBox(_formatPad(_timeLeft.inDays), 'DAYS', cardColor, primaryBlue, isDark),
                      _buildTimeBox(_formatPad(_timeLeft.inHours.remainder(24)), 'HRS', cardColor, primaryBlue, isDark),
                      _buildTimeBox(_formatPad(_timeLeft.inMinutes.remainder(60)), 'MINS', cardColor, primaryBlue, isDark),
                      _buildTimeBox(_formatPad(_timeLeft.inSeconds.remainder(60)), 'SECS', cardColor, primaryBlue, isDark),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Top Performers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Performers',
                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                      Text(
                        'View Leaderboard >',
                        style: GoogleFonts.montserrat(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.contest.topPerformers != null && widget.contest.topPerformers!.isNotEmpty)
                    ...widget.contest.topPerformers!.asMap().entries.map((entry) {
                      int rank = entry.key + 1;
                      Color rankColor = rank == 1 ? const Color(0xFFFFF9C4) : rank == 2 ? const Color(0xFFF5F5F5) : const Color(0xFFFFE0B2);
                      Color rankTextColor = rank == 1 ? const Color(0xFFF57F17) : rank == 2 ? const Color(0xFF757575) : const Color(0xFFE65100);
                      Color avatarBg = rank == 1 ? const Color(0xFFE8EAF6) : rank == 2 ? const Color(0xFFE0F2F1) : const Color(0xFFFCE4EC);
                      Color avatarText = rank == 1 ? const Color(0xFF3F51B5) : rank == 2 ? const Color(0xFF00796B) : const Color(0xFFC2185B);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: rankColor,
                              child: Text('$rank', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: rankTextColor)),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: avatarBg,
                              child: Text(entry.value.initials, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: avatarText, fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.value.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                                  Text(entry.value.location, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.blueGrey[400], fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Text(entry.value.units, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: primaryBlue)),
                          ],
                        ),
                      );
                    })
                  else
                    Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("No performers listed yet.", style: GoogleFonts.montserrat(color: Colors.grey)),
                    )),

                  const SizedBox(height: 24),

                  // Rules
                  Text(
                    'Contest Rules',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  if (widget.contest.rules != null && widget.contest.rules!.isNotEmpty)
                    ...widget.contest.rules!.map(
                          (rule) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.check, size: 14, color: primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                rule,
                                style: GoogleFonts.montserrat(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.blueGrey[800], height: 1.5, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text("No specific rules provided.", style: GoogleFonts.montserrat(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String value, String label, Color cardColor, Color primaryBlue, bool isDark) {
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
              style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(fontSize: 10, color: Colors.blueGrey[600], fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}