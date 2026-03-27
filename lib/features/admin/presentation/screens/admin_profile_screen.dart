import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_profile_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id.toString() ?? '1';
      context.read<AdminProfileProvider>().fetchProfile(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final provider = context.watch<AdminProfileProvider>();

    if (provider.isLoading || provider.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = provider.profile!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Profile Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundImage: const AssetImage(
                          'assets/images/logos.png',
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.role,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT SETTINGS',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        Icons.person_outline,
                        'Edit Personal Info',
                        profile.email,
                        isDark,
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileItem(
                        Icons.lock_outline,
                        'Change Password',
                        'Update your security credentials',
                        isDark,
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileItem(
                        Icons.notifications_none,
                        'Notifications',
                        'Manage alerts and emails',
                        isDark,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'SYSTEM',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        Icons.privacy_tip_outlined,
                        'Privacy Policy',
                        'Read our terms and conditions',
                        isDark,
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileItem(
                        Icons.help_outline,
                        'Help & Support',
                        'Contact technical support',
                        isDark,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: Text(
                      'Log Out',
                      style: GoogleFonts.montserrat(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title,
    String subtitle,
    bool isDark, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue[800], size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
