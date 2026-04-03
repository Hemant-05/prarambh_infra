import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_enquiry_provider.dart';
import '../../data/models/enquiry_model.dart';

class AdminEnquiriesScreen extends StatefulWidget {
  const AdminEnquiriesScreen({super.key});

  @override
  State<AdminEnquiriesScreen> createState() => _AdminEnquiriesScreenState();
}

class _AdminEnquiriesScreenState extends State<AdminEnquiriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEnquiryProvider>().fetchContactEnquiries();
      context.read<AdminEnquiryProvider>().fetchCareerEnquiries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Enquiries',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryBlue,
          labelColor: primaryBlue,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'General Contact'),
            Tab(text: 'Career/Advisor'),
          ],
        ),
      ),
      body: Consumer<AdminEnquiryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildContactList(provider.contactEnquiries, isDark, primaryBlue),
              _buildCareerList(provider.careerEnquiries, isDark, primaryBlue),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContactList(List<AdminEnquiryModel> enquiries, bool isDark, Color primaryBlue) {
    if (enquiries.isEmpty) {
      return _buildEmptyState('No general enquiries found.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: enquiries.length,
      itemBuilder: (context, index) {
        final enquiry = enquiries[index];
        return _buildEnquiryCard(
          context: context,
          name: enquiry.fullName,
          phone: enquiry.phoneNumber,
          email: enquiry.email,
          intent: enquiry.iWantTo,
          message: enquiry.message,
          date: enquiry.createdAt,
          isDark: isDark,
          primaryBlue: primaryBlue,
          onDelete: () => context.read<AdminEnquiryProvider>().deleteContactEnquiry(enquiry.id.toString()),
        );
      },
    );
  }

  Widget _buildCareerList(List<AdminCareerEnquiryModel> enquiries, bool isDark, Color primaryBlue) {
    if (enquiries.isEmpty) {
      return _buildEmptyState('No career enquiries found.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: enquiries.length,
      itemBuilder: (context, index) {
        final enquiry = enquiries[index];
        return _buildEnquiryCard(
          context: context,
          name: enquiry.name,
          phone: enquiry.phone,
          email: enquiry.email,
          intent: enquiry.city,
          message: enquiry.description,
          date: enquiry.createdAt,
          isDark: isDark,
          primaryBlue: primaryBlue,
          isCareer: true,
          onDelete: () => context.read<AdminEnquiryProvider>().deleteCareerEnquiry(enquiry.id.toString()),
        );
      },
    );
  }

  Widget _buildEnquiryCard({
    required BuildContext context,
    required String name,
    required String phone,
    required String email,
    required String intent,
    required String message,
    required String date,
    required bool isDark,
    required Color primaryBlue,
    bool isCareer = false,
    required VoidCallback onDelete,
  }) {
    final cardColor = AppColors.getCardColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCareer ? 'LOCATION: $intent' : 'INTENT: $intent',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, phone, primaryBlue, () => _launchURL('tel:$phone')),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.email_outlined, email, primaryBlue, () => _launchURL('mailto:$email')),
          const SizedBox(height: 16),
          Text(
            'MESSAGE',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
               Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL('https://wa.me/91$phone'),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                  label: Text('WhatsApp', style: GoogleFonts.montserrat(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.montserrat(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
