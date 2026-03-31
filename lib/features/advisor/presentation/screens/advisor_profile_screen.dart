import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_profile_provider.dart';
import '../../data/models/advisor_profile_model.dart';

class AdvisorProfileScreen extends StatefulWidget {
  const AdvisorProfileScreen({super.key});

  @override
  State<AdvisorProfileScreen> createState() => _AdvisorProfileScreenState();
}

class _AdvisorProfileScreenState extends State<AdvisorProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisorId = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      if (advisorId.isNotEmpty) {
        context.read<AdvisorProfileProvider>().fetchProfile(advisorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdvisorProfileProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: provider.isLoading || provider.profile == null
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : RefreshIndicator(
        onRefresh: () async {
          final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
          await provider.fetchProfile(id);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildProfileHeader(provider.profile!, primaryBlue, isDark),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildExpandableSection(
                    title: "Personal Information",
                    icon: Icons.person_outline,
                    primaryBlue: primaryBlue,
                    isDark: isDark,
                    isExpanded: true,
                    children: [
                      _buildInfoRow("Date of Birth", provider.profile!.dob, Icons.calendar_month_outlined, isDark),
                      _buildInfoRow("Gender", provider.profile!.gender, Icons.wc_outlined, isDark),
                      _buildInfoRow("Father's Name", provider.profile!.fatherName, Icons.family_restroom, isDark),
                      _buildInfoRow("Occupation", provider.profile!.occupation, Icons.work_outline, isDark, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    title: "Contact Details",
                    icon: Icons.contact_mail_outlined,
                    primaryBlue: primaryBlue,
                    isDark: isDark,
                    children: [
                      _buildInfoRow("Email", provider.profile!.email, Icons.email_outlined, isDark),
                      _buildInfoRow("Phone", "+91 ${provider.profile!.phone}", Icons.phone_outlined, isDark),
                      _buildInfoRow("City", provider.profile!.city, Icons.location_city_outlined, isDark),
                      _buildInfoRow("State", "${provider.profile!.state} - ${provider.profile!.pincode}", Icons.map_outlined, isDark),
                      _buildInfoRow("Address", provider.profile!.address, Icons.home_outlined, isDark, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    title: "Identity & KYC",
                    icon: Icons.fingerprint,
                    primaryBlue: primaryBlue,
                    isDark: isDark,
                    children: [
                      _buildInfoRow("Aadhaar No", provider.profile!.aadhaar, Icons.credit_card, isDark),
                      _buildInfoRow("PAN Number", provider.profile!.pan, Icons.credit_card_outlined, isDark, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    title: "Bank Details",
                    icon: Icons.account_balance_outlined,
                    primaryBlue: primaryBlue,
                    isDark: isDark,
                    children: [
                      _buildInfoRow("Bank Name", provider.profile!.bankName, Icons.account_balance, isDark),
                      _buildInfoRow("Account No", provider.profile!.accNumber, Icons.numbers, isDark),
                      _buildInfoRow("IFSC Code", provider.profile!.ifsc, Icons.tag, isDark, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    title: "Nominee Details",
                    icon: Icons.group_outlined,
                    primaryBlue: primaryBlue,
                    isDark: isDark,
                    children: [
                      _buildInfoRow("Nominee Name", provider.profile!.nomineeName, Icons.person, isDark),
                      _buildInfoRow("Relationship", provider.profile!.relationship, Icons.handshake_outlined, isDark),
                      _buildInfoRow("Nominee Phone", provider.profile!.nomineePhone, Icons.phone, isDark, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 40), // Bottom Padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER WIDGET ---
  Widget _buildProfileHeader(AdvisorProfileModel profile, Color primaryBlue, bool isDark) {
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Background Gradient Curve
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // Overlapping Profile Card
          Container(
            margin: const EdgeInsets.only(top: 80, left: 20, right: 20),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                Text(
                  profile.fullName,
                  style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.designation.toUpperCase(),
                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 14, color: primaryBlue),
                          const SizedBox(width: 6),
                          Text(profile.advisorCode, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 10, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(profile.status, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text("Joined on ${profile.joinedDate}", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          // Floating Avatar
          Positioned(
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: profile.profilePhoto.isNotEmpty ? NetworkImage(profile.profilePhoto) : null,
                child: profile.profilePhoto.isEmpty ? Icon(Icons.person, size: 50, color: primaryBlue) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- EXPANDABLE SECTION WIDGET ---
  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color primaryBlue,
    required bool isDark,
    required List<Widget> children,
    bool isExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          iconColor: primaryBlue,
          collapsedIconColor: Colors.grey[600],
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: children,
        ),
      ),
    );
  }

  // --- INFO ROW WIDGET ---
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not Provided',
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}