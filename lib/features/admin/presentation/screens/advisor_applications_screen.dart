import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:prarambh_infra/features/admin/data/models/advisor_application_model.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/review_application_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_advisor_provider.dart';
import 'package:prarambh_infra/features/admin/data/models/enquiry_model.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_enquiry_provider.dart';
import 'package:prarambh_infra/features/recruitment/presentation/providers/advisor_registration_provider.dart';
import 'package:prarambh_infra/features/recruitment/presentation/screens/advisor_registration_screen.dart';

class AdvisorApplicationsScreen extends StatefulWidget {
  const AdvisorApplicationsScreen({super.key});

  @override
  State<AdvisorApplicationsScreen> createState() =>
      _AdvisorApplicationsScreenState();
}

class _AdvisorApplicationsScreenState extends State<AdvisorApplicationsScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String _selectedWorkType = 'All'; // 'All', 'Full-time', 'Part-time'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAdvisorProvider>().fetchAdvisors(status: 'pending');
      context.read<AdminEnquiryProvider>().fetchCareerEnquiries();
    });
  }

  void _showFilterSheet(BuildContext context, Color primaryBlue) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Applications',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDateRange = null;
                            _selectedWorkType = 'All';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Reset', style: TextStyle(color: primaryBlue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Work Type',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['All', 'Full-time', 'Part-time'].map((type) {
                      final isSelected = _selectedWorkType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setSheetState(() => _selectedWorkType = type);
                              setState(() => _selectedWorkType = type);
                            }
                          },
                          selectedColor: primaryBlue.withOpacity(0.1),
                          labelStyle: GoogleFonts.montserrat(
                            color: isSelected ? primaryBlue : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Date Range',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _selectedDateRange,
                      );
                      if (picked != null) {
                        setSheetState(() => _selectedDateRange = picked);
                        setState(() => _selectedDateRange = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDateRange == null
                                ? 'Select Date Range'
                                : '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}',
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getCardColor(context);
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final advisorProvider = context.watch<AdminAdvisorProvider>();
    final enquiryProvider = context.watch<AdminEnquiryProvider>();

    // Common filter logic for advisors
    List<AdvisorApplicationModel> _filterAdvisors(List<AdvisorApplicationModel> advisors) {
      return advisors.where((advisor) {
        // Search Filter
        final matchesSearch = _searchQuery.isEmpty ||
            advisor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            advisor.displayId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            advisor.city.toLowerCase().contains(_searchQuery.toLowerCase());

        // Work Type Filter
        bool matchesType = true;
        if (_selectedWorkType != 'All') {
          matchesType = advisor.advisorType == _selectedWorkType;
        }

        // Date Filter
        bool matchesDate = true;
        if (_selectedDateRange != null) {
          try {
            final appliedDate = DateTime.parse(advisor.appliedDate);
            matchesDate = appliedDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                appliedDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
          } catch (e) {
            matchesDate = false;
          }
        }

        return matchesSearch && matchesType && matchesDate;
      }).toList();
    }

    final allAdvisors = advisorProvider.advisors;
    final byAdminAdvisors = _filterAdvisors(allAdvisors.where((a) => a.leaderId == 'admin001').toList());
    final byAdvisorAdvisors = _filterAdvisors(allAdvisors.where((a) => a.leaderId != 'admin001').toList());

    final filteredEnquiries = enquiryProvider.careerEnquiries.where((enquiry) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return enquiry.name.toLowerCase().contains(query) ||
          enquiry.email.toLowerCase().contains(query) ||
          enquiry.city.toLowerCase().contains(query);
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              // --- Custom Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 20, 10),
                child: Row(
                  children: [
                    backButton(isDark: isDark),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Advisor Applications',
                        style: GoogleFonts.montserrat(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Search and Filter Row ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                            hintText: 'Search advisors...',
                            hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showFilterSheet(context, primaryBlue),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: (_selectedDateRange != null || _selectedWorkType != 'All')
                              ? primaryBlue
                              : (isDark ? Colors.grey[850] : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: (_selectedDateRange != null || _selectedWorkType != 'All')
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Applied Filters Indicator ---
              if (_selectedDateRange != null || _selectedWorkType != 'All')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      if (_selectedWorkType != 'All')
                        _filterChip(_selectedWorkType, () => setState(() => _selectedWorkType = 'All')),
                      if (_selectedDateRange != null)
                        _filterChip(
                          '${_selectedDateRange!.start.toString().split(' ')[0]}...',
                          () => setState(() => _selectedDateRange = null),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // --- TabBar ---
              TabBar(
                indicatorColor: primaryBlue,
                labelColor: primaryBlue,
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'By Admin'),
                  Tab(text: 'By Advisor'),
                  Tab(text: 'App/Web'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildAdvisorList(byAdminAdvisors, advisorProvider.isLoading, cardColor, isDark),
                    _buildAdvisorList(byAdvisorAdvisors, advisorProvider.isLoading, cardColor, isDark),
                    _buildCareerEnquiryList(filteredEnquiries, enquiryProvider.isLoading, cardColor, isDark, primaryBlue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onClear) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 12, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorList(List<AdvisorApplicationModel> advisors, bool isLoading, Color cardColor, bool isDark) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (advisors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No applications found', style: GoogleFonts.montserrat(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      physics: const BouncingScrollPhysics(),
      itemCount: advisors.length,
      itemBuilder: (context, index) => _buildAdvisorCard(advisors[index], cardColor, isDark),
    );
  }

  Widget _buildCareerEnquiryList(List<AdminCareerEnquiryModel> enquiries, bool isLoading, Color cardColor, bool isDark, Color primaryBlue) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (enquiries.isEmpty) {
      return Center(child: Text('No web/app enquiries found', style: GoogleFonts.montserrat(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      physics: const BouncingScrollPhysics(),
      itemCount: enquiries.length,
      itemBuilder: (context, index) => _buildCareerInquiryCard(enquiries[index], isDark, primaryBlue),
    );
  }

  Widget _buildCareerInquiryCard(AdminCareerEnquiryModel enquiry, bool isDark, Color primaryBlue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryBlue.withOpacity(0.1),
                child: Icon(Icons.language, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enquiry.name,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      enquiry.createdAt,
                      style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  enquiry.city.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Icon(Icons.alternate_email, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(enquiry.email, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone_iphone, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(enquiry.phone, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'MESSAGE:',
            style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            enquiry.description,
            style: GoogleFonts.montserrat(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => context.read<AdminEnquiryProvider>().deleteCareerEnquiry(enquiry.id.toString()),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: Text('Remove', style: GoogleFonts.montserrat(color: Colors.red, fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.red)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdvisorRegistrationProvider>().preFillFromEnquiry(
                      name: enquiry.name,
                      email: enquiry.email,
                      phone: enquiry.phone,
                      city: enquiry.city,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvisorRegistrationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: Colors.white),
                  label: Text('Fill Form', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorCard(AdvisorApplicationModel app, Color cardColor, bool isDark) {
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
          ),
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      app.name.isNotEmpty && app.name.length >= 2
                          ? app.name.substring(0, 2).toUpperCase()
                          : 'U',
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            app.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            app.status,
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app.city} • ID: ${app.displayId}',
                      style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              app.appliedDate,
                              style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            app.advisorType,
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
