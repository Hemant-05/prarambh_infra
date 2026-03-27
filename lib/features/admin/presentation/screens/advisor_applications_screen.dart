import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/review_application_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_advisor_provider.dart';

class AdvisorApplicationsScreen extends StatefulWidget {
  const AdvisorApplicationsScreen({super.key});

  @override
  State<AdvisorApplicationsScreen> createState() =>
      _AdvisorApplicationsScreenState();
}

class _AdvisorApplicationsScreenState extends State<AdvisorApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAdvisorProvider>().fetchAdvisors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getCardColor(context);
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final provider = context.watch<AdminAdvisorProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text(
          'Advisor Applications',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search by name, ID...',
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Pending',
                        isActive: true,
                        onClear: () {},
                        primaryBlue: primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Date',
                        isDropdown: true,
                        primaryBlue: primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Region',
                        isDropdown: true,
                        primaryBlue: primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PENDING REVIEW (${provider.advisors.length})',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.advisors.length,
                    itemBuilder: (context, index) {
                      final app = provider.advisors[index];
                      return _buildAdvisorCard(app, cardColor, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isActive = false,
    bool isDropdown = false,
    VoidCallback? onClear,
    required Color primaryBlue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : Colors.transparent,
        border: Border.all(
          color: isActive ? primaryBlue : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ],
          if (isDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[700]),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvisorCard(var app, Color cardColor, bool isDark) {
    Color statusColor;
    Color statusBgColor;
    if (app.status == 'Pending') {
      statusColor = const Color(0xFFE65100);
      statusBgColor = const Color(0xFFFFF3E0);
    } else if (app.status == 'Docs Review') {
      statusColor = const Color(0xFFC62828);
      statusBgColor = const Color(0xFFFFEBEE);
    } else {
      statusColor = Colors.grey[700]!;
      statusBgColor = Colors.grey[200]!;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewApplicationScreen(advisor: app),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ), // The left colored bar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with Shield Badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      app.name.substring(0, 2).toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Colors.blue,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          app.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            app.status,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app.zone} • ID: ${app.displayId}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Applied: ${app.appliedDate}',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
