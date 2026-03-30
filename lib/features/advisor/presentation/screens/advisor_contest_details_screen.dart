import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/contest_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_contest_provider.dart';

class AdvisorContestDetailsScreen extends StatefulWidget {
  final ContestModel contest;
  const AdvisorContestDetailsScreen({super.key, required this.contest});

  @override
  State<AdvisorContestDetailsScreen> createState() => _AdvisorContestDetailsScreenState();
}

class _AdvisorContestDetailsScreenState extends State<AdvisorContestDetailsScreen> {
  DateTime? _targetDate;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    if ((widget.contest.status.toUpperCase() == 'ACTIVE' || widget.contest.status.toUpperCase() == 'LIVE') && widget.contest.endDate != null) {
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

  String _formatPad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLive = widget.contest.status.toUpperCase() == 'ACTIVE' || widget.contest.status.toUpperCase() == 'LIVE';

    // Auth & Contest Providers
    final authProvider = context.read<AuthProvider>();
    final advisorCode = authProvider.currentUser?.advisorCode ?? '';
    final contestProvider = context.watch<AdvisorContestProvider>();

    // Participant state mapping
    final isJoined = widget.contest.participants.any((p) => p.advisorCode == advisorCode);
    final myData = isJoined ? widget.contest.participants.firstWhere((p) => p.advisorCode == advisorCode) : null;
    int targetSales = 5; // Default Target
    int currentSales = myData?.units ?? 0;
    int progressPercent = (currentSales / targetSales * 100).clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: isJoined || contestProvider.isJoining ? null : () async {
              final success = await contestProvider.joinContest(widget.contest.id, advisorCode);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully joined the contest!'), backgroundColor: Colors.green));
                Navigator.pop(context); // Pop to refresh list
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to join. Please try again.'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isJoined ? Colors.green : primaryBlue,
              disabledBackgroundColor: Colors.green.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: contestProvider.isJoining
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
              isJoined ? 'Joined • Keep Going!' : 'Join Contest',
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: primaryBlue,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Contest Details', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {})],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.contest.imageUrl.isNotEmpty
                      ? Image.network(widget.contest.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.blueGrey, child: const Icon(Icons.image, size: 100, color: Colors.white24)))
                      : Container(color: Colors.blueGrey, child: const Icon(Icons.image, size: 100, color: Colors.white24)),
                  Container(
                    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black26, Colors.black.withOpacity(0.85)])),
                  ),
                  Positioned(
                    bottom: 30, left: 20, right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: isLive ? Colors.deepOrange : Colors.grey),
                            const SizedBox(width: 8),
                            Text(isLive ? 'LIVE NOW' : widget.contest.status.toUpperCase(), style: GoogleFonts.montserrat(color: isLive ? Colors.deepOrange : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.contest.title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text('Reward: ${widget.contest.rewardText}', style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

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
                  // --- Current Progress Section ---
                  if (isJoined) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Progress', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text('Active', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          // Circular Progress
                          SizedBox(
                            width: 80, height: 80,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: progressPercent / 100,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                                ),
                                Center(child: Text('$progressPercent%', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Stats & Warning
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL SALES', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('$currentSales', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                                      child: Text('/ $targetSales Units', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.blueGrey)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange.shade100)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.bolt, size: 14, color: Colors.deepOrange.shade400),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text('Sell ${targetSales - currentSales} more units to qualify!', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.deepOrange.shade800, fontWeight: FontWeight.w600))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Time Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TIME REMAINING', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                      Text(widget.contest.endDate != null ? 'Ends ${widget.contest.endDate!.split(' ')[0]}' : 'No End Date', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.blueGrey[600], fontWeight: FontWeight.w600)),
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

                  // Rules
                  Text('Contest Rules', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  if (widget.contest.rules != null && widget.contest.rules!.isNotEmpty)
                    ...widget.contest.rules!.map(
                          (rule) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2), padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.check, size: 14, color: primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(rule, style: GoogleFonts.montserrat(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.blueGrey[800], height: 1.5, fontWeight: FontWeight.w500))),
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
            Text(value, style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.blueGrey[600], fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}