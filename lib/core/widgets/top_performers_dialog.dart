import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prarambh_infra/core/globals.dart';
import 'package:prarambh_infra/core/shared/models/top_performer_model.dart';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import 'package:intl/intl.dart';

class TopPerformersDialog extends StatefulWidget {
  final String userId;
  final VoidCallback onViewTeam;

  const TopPerformersDialog({
    super.key,
    required this.userId,
    required this.onViewTeam,
  });

  static Future<void> show(BuildContext context, {required String userId, required VoidCallback onViewTeam}) async {
    if (AppGlobals.hasShownTopPerformersBanner) return;

    const storage = FlutterSecureStorage();
    final String today = DateTime.now().toIso8601String().split('T').first;
    
    final String? lastShownDate = await storage.read(key: 'top_performers_last_shown_date');
    if (lastShownDate == today) {
      AppGlobals.hasShownTopPerformersBanner = true;
      return;
    }

    await storage.write(key: 'top_performers_last_shown_date', value: today);
    AppGlobals.hasShownTopPerformersBanner = true;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TopPerformersDialog(userId: userId, onViewTeam: onViewTeam),
    );
  }

  @override
  State<TopPerformersDialog> createState() => _TopPerformersDialogState();
}

class _TopPerformersDialogState extends State<TopPerformersDialog> {
  bool _isLoading = true;
  List<TopPerformerModel> _performers = [];

  @override
  void initState() {
    super.initState();
    _fetchPerformers();
  }

  Future<void> _fetchPerformers() async {
    try {
      final apiClient = GetIt.instance<ApiClient>();
      final response = await apiClient.getTopPerformers(widget.userId);
      if (response['status'] == true && response['data'] != null) {
        final List data = response['data'];
        setState(() {
          _performers = data.map((e) => TopPerformerModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        _closeDialog();
      }
    } catch (_) {
      _closeDialog();
    }
  }

  void _closeDialog() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹ ${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      return '₹ ${(amount / 100000).toStringAsFixed(1)} L';
    }
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xff064f8e);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'PRARAMBH INFRA',
                        style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TOP PERFORMERS',
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'OF THE MONTH',
                        style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_performers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text('No performers to show right now.', style: GoogleFonts.montserrat(color: Colors.grey)),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ..._performers.asMap().entries.map((entry) {
                      int rank = entry.key + 1;
                      TopPerformerModel performer = entry.value;

                      Color badgeColor;
                      if (rank == 1) badgeColor = Colors.amber;
                      else if (rank == 2) badgeColor = Colors.blueGrey.shade400;
                      else if (rank == 3) badgeColor = Colors.deepOrange.shade600;
                      else badgeColor = Colors.grey;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(rank <= 3 ? 2 : 0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: rank <= 3 ? Border.all(color: badgeColor, width: 2) : null,
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: performer.profilePhoto.isNotEmpty
                                        ? NetworkImage(performer.profilePhoto)
                                        : null,
                                    child: performer.profilePhoto.isEmpty
                                        ? const Icon(Icons.person, color: Colors.grey)
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$rank',
                                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    performer.fullName,
                                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                  ),
                                  Text(
                                    performer.designation.toUpperCase(),
                                    style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(performer.totalRevenue),
                                  style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Sales',
                                  style: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onViewTeam();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'VIEW MY TEAM',
                              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Check full leaderboard for details',
                      style: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 10),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
