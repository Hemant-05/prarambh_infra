import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_recruitment_provider.dart';

class RecruiterDetailScreen extends StatefulWidget {
  final String recruiterName;
  final String advisorId;

  const RecruiterDetailScreen({Key? key, required this.recruiterName, required this.advisorId}) : super(key: key);

  @override
  State<RecruiterDetailScreen> createState() => _RecruiterDetailScreenState();
}

class _RecruiterDetailScreenState extends State<RecruiterDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminRecruitmentProvider>().fetchRecruitsForAdvisor(widget.advisorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final provider = context.watch<AdminRecruitmentProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Column(
          children: [
            Text('Recruited By', style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 12)),
            Text(widget.recruiterName, style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: provider.isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.currentRecruits.length,
        itemBuilder: (context, index) {
          final recruit = provider.currentRecruits[index];

          Color statusBg;
          Color statusText;
          if (recruit.status == 'Active') { statusBg = Colors.green.withOpacity(0.1); statusText = Colors.green; }
          else if (recruit.status == 'Pending') { statusBg = Colors.orange.withOpacity(0.1); statusText = Colors.orange; }
          else { statusBg = Colors.red.withOpacity(0.1); statusText = Colors.red; }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: Colors.grey[200], child: Text(recruit.initials, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black54))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recruit.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                      const SizedBox(height: 4),
                      Text(recruit.joinedDate, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                  child: Text(recruit.status, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: statusText)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}