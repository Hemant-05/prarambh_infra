import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/profile_image.dart';
import '../../data/models/lead_models.dart';

class AssignLeadScreen extends StatefulWidget {
  final LeadModel lead;
  const AssignLeadScreen({super.key, required this.lead});

  @override
  State<AssignLeadScreen> createState() => _AssignLeadScreenState();
}

class _AssignLeadScreenState extends State<AssignLeadScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeadProvider>().fetchAdvisorsForAssignment();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    // No dynamic tags needed

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Assign Lead',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Lead Info Header ---
          Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lead.clientName,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '+91 ${widget.lead.clientNumber}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.lead.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.lead.description,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: primaryBlue.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.montserrat(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search advisor name and code',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AVAILABLE ADVISORS',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // --- Advisors List ---
          Expanded(
            child:
                Selector<
                  AdminLeadProvider,
                  ({bool isLoading, List<AdvisorAssignModel> advisors})
                >(
                  selector: (_, p) =>
                      (isLoading: p.isLoading, advisors: p.availableAdvisors),
                  builder: (context, data, _) {
                    if (data.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Filter advisors based on search query AND exclude Admin
                    final filteredAdvisors = data.advisors.where((a) {
                      final matchesSearch =
                          _searchQuery.isEmpty ||
                          a.name.toLowerCase().contains(_searchQuery) ||
                          a.advisorCode.toLowerCase().contains(_searchQuery);
                      return matchesSearch &&
                          a.advisorCode.toLowerCase() != 'admin001';
                    }).toList();

                    if (filteredAdvisors.isEmpty) {
                      return Center(
                        child: Text(
                          "No advisors match your search.",
                          style: GoogleFonts.montserrat(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredAdvisors.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final advisor = filteredAdvisors[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              ProfileImage(
                                imageUrl: _isValidImage(advisor.profile) ? _getImageUrl(advisor.profile) : null,
                                initials: advisor.name.isNotEmpty 
                                    ? advisor.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                    : '?',
                                heroTag: 'assign_lead_advisor_${advisor.advisorCode}',
                                radius: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      advisor.name,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      advisor.advisorCode,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 11,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${advisor.activeLeads} Active Leads',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Selector<AdminLeadProvider, bool>(
                                selector: (_, p) => p.isSaving,
                                builder: (context, isSaving, _) {
                                  return ElevatedButton(
                                    onPressed: isSaving
                                        ? null
                                        : () async {
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            final navigator =
                                                Navigator.of(context);
                                            final provider = context
                                                .read<AdminLeadProvider>();
                                            final success = await provider
                                                .assignLeadToAdvisor(
                                              widget.lead.id,
                                              advisor.advisorCode,
                                            );
                                            if (success) {
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Lead assigned to ${advisor.name}',
                                                  ),
                                                ),
                                              );
                                              navigator.pop();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: isSaving
                                        ? const SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Assign',
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  bool _isValidImage(String profile) {
    if (profile.isEmpty) return false;
    final lower = profile.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  String _getImageUrl(String profile) {
    if (profile.startsWith('http')) return profile;
    return "https://workiees.com/${profile.startsWith('/') ? profile.substring(1) : profile}";
  }
}
