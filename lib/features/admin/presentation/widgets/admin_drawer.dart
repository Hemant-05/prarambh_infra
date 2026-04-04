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
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Profile Section
          CircleAvatar(
            radius: 40,
            backgroundImage: const AssetImage(logo),
            backgroundColor: AppColors.getBorderColor(context),
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
          Divider(color: AppColors.getBorderColor(context), thickness: 1),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.analytics_outlined,
                  title: 'Sales Analytics',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin_sales_analytics');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'Document Management',
                  onTap: () {
                    Navigator.pushNamed(context, '/docs_management');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Upcoming Installments',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/admin_upcoming_installments',
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.campaign_outlined,
                  title: 'Recruitment Dashboard',
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.pushNamed(
                      context,
                      '/admin_recruitment_dashboard',
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.co_present_outlined,
                  title: 'Meeting & Attendance',
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.pushNamed(context, '/meeting_management');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.people_outline,
                  title: 'Advisor Application',
                  onTap: () {
                    Navigator.pushNamed(context, '/advisor_applications');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.emoji_events_outlined,
                  title: 'Contests',
                  onTap: () {
                    Navigator.pushNamed(context, '/contests_list');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.leaderboard_outlined,
                  title: 'Leader board',
                  onTap: () {
                    Navigator.pushNamed(context, '/leaderboard');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.campaign_outlined,
                  title: 'Leads',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/lead_management');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.newspaper_outlined,
                  title: 'Blog Management',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin_blogs');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.contact_support_outlined,
                  title: 'User Enquiries',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin_enquiries');
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Divider(color: AppColors.getBorderColor(context), thickness: 1),
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
            onTap: () async {
              // 1. Close drawer
              Navigator.pop(context);
              // 2. Clear state
              await context.read<AuthProvider>().logout();
              // 3. Navigate away
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData? icon,
    required String title,
    bool isSubItem = false,
    VoidCallback? onTap,
  }) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return ListTile(
      contentPadding: EdgeInsets.only(
        left: isSubItem ? 56.0 : 24.0,
        right: 24.0,
      ),
      leading: icon != null ? Icon(icon, color: secondaryTextColor) : null,
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
