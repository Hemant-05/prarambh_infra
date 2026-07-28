import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final profile = authProvider.currentUser;
              
              return Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: primaryBlue.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logos/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'PRARAMBH INFRA',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    profile?.role.toUpperCase() ?? 'ADMIN',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
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
                  icon: Icons.people_outline,
                  title: 'ADVISOR APPROVAL',
                  onTap: () {
                    Navigator.pushNamed(context, '/advisor_applications');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.campaign_outlined,
                  title: 'LEADS',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/lead_management');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'DOCS MANAGEMENT',
                  onTap: () {
                    Navigator.pushNamed(context, '/docs_management');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.campaign_outlined,
                  title: 'RECRUITMENT MANAGEMENT',
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
                  title: 'MEETING & ATTENDANCE',
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.pushNamed(context, '/meeting_management');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.analytics_outlined,
                  title: 'SALES ANALYTICS',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin_sales_analytics');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'UPCOMING INSTALLMENT',
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
                  icon: Icons.emoji_events_outlined,
                  title: 'CONTEST',
                  onTap: () {
                    Navigator.pushNamed(context, '/contests_list');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.leaderboard_outlined,
                  title: 'STARWALL',
                  onTap: () {
                    Navigator.pushNamed(context, '/leaderboard');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.contact_support_outlined,
                  title: 'CUSTOMER ENQUIRY',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin_enquiries');
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.newspaper_outlined,
                  title: 'BLOG MANAGEMENT',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin_blogs');
                  },
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'RESOURCES',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.gavel_outlined,
                  title: 'RERA COMPLIANCE',
                  onTap: () => launchUrl(Uri.parse('https://rera.mp.gov.in')),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.language_outlined,
                  title: 'COMPANY WEBSITE',
                  onTap: () => launchUrl(Uri.parse('https://prarambhinfra.com')),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.facebook,
                  title: 'FACEBOOK',
                  onTap: () => launchUrl(Uri.parse('https://www.facebook.com/prarambhinfra')),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  title: 'INSTAGRAM',
                  onTap: () => launchUrl(Uri.parse('https://www.instagram.com/prarambhinfra')),
                ),
              ],
            ),
          ),

          // Logout Button
          Divider(color: AppColors.getBorderColor(context), thickness: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'LOG OUT',
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
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
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
