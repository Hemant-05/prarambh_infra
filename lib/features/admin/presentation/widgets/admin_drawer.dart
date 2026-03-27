import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Profile Section
          CircleAvatar(
            radius: 40,
            backgroundImage: const AssetImage(
              logo,
            ), // Replace with actual profile image
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 12),
          Text(
            'Amit Jadhav', // You can replace this with Provider data later
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            'Admin',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(
                  icon: Icons.description_outlined,
                  title: 'Document Management',
                  textColor: textColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/docs_management');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'Contests',
                  textColor: textColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/contests_list');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.leaderboard_outlined,
                  title: 'Leader board',
                  textColor: textColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/leaderboard');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.co_present_outlined,
                  title: 'Meeting & Attendance',
                  textColor: textColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/attendance_report');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Leads',
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/lead_management');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people_outline,
                  title: 'Advisor Application',
                  textColor: textColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/advisor_applications');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Recruitment by Broker',
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.pushNamed(context, '/recruitment_dashboard');
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Log Out',
              style: GoogleFonts.montserrat(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData? icon,
    required String title,
    required Color textColor,
    bool isSubItem = false,
    VoidCallback? onTap, // Add this parameter
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: isSubItem ? 56.0 : 24.0,
        right: 24.0,
      ),
      leading: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: textColor,
          fontWeight: isSubItem ? FontWeight.w500 : FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
