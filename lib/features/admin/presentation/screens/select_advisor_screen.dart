import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../../data/models/lead_models.dart';
import '../providers/admin_lead_provider.dart';

class SelectAdvisorScreen extends StatefulWidget {
  const SelectAdvisorScreen({super.key});

  @override
  State<SelectAdvisorScreen> createState() => _SelectAdvisorScreenState();
}

class _SelectAdvisorScreenState extends State<SelectAdvisorScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AdvisorAssignModel> _filteredAdvisors = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeadProvider>().fetchAdvisorsForAssignment();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAdvisors(String query, List<AdvisorAssignModel> allAdvisors) {
    if (query.isEmpty) {
      setState(() {
        _filteredAdvisors = allAdvisors;
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredAdvisors = allAdvisors.where((advisor) {
          return advisor.name.toLowerCase().contains(lowerQuery) ||
              advisor.advisorCode.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  String _formatImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://workiees.com/${url.startsWith('/') ? url.substring(1) : url}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final provider = context.watch<AdminLeadProvider>();
    final allAdvisors = provider.availableAdvisors;

    if (_searchController.text.isEmpty && _filteredAdvisors.length != allAdvisors.length) {
      _filteredAdvisors = allAdvisors;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: false),
        title: Text(
          'Select Advisor',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => _filterAdvisors(val, allAdvisors),
                style: GoogleFonts.montserrat(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search Name or Code...',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filterAdvisors('', allAdvisors);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAdvisors.isEmpty
                    ? Center(
                        child: Text(
                          'No advisors found',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredAdvisors.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final advisor = _filteredAdvisors[index];
                          final profileUrl = _formatImageUrl(advisor.profile);

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(context, advisor);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: primaryBlue.withOpacity(0.1),
                                      backgroundImage: profileUrl.isNotEmpty
                                          ? NetworkImage(profileUrl)
                                          : null,
                                      child: profileUrl.isEmpty
                                          ? Text(
                                              advisor.name.isNotEmpty
                                                  ? advisor.name[0].toUpperCase()
                                                  : '?',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: primaryBlue,
                                                fontSize: 18,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            advisor.name.isEmpty ? 'Unknown Advisor' : advisor.name,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            advisor.advisorCode,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
