import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';
import 'package:prarambh_infra/features/admin/data/models/lead_models.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_button.dart';
import '../providers/admin_provider.dart';
import '../providers/admin_lead_provider.dart';
import '../../../advisor/presentation/screens/lead_details_screen.dart';
import '../../../../core/utils/excel_helper.dart';
import '../../../../core/utils/lead_filter_helper.dart';

class PriorityLeadsScreen extends StatefulWidget {
  const PriorityLeadsScreen({super.key});

  @override
  State<PriorityLeadsScreen> createState() => _PriorityLeadsScreenState();
}

class _PriorityLeadsScreenState extends State<PriorityLeadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPotential = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    final adminState = context.watch<AdminProvider>();
    final leadProvider = context.watch<AdminLeadProvider>();
    
    // Use data from leadProvider if it has been refreshed, otherwise fallback to dashboard data
    // Convert dashboard maps to LeadModel for consistency
    final List<LeadModel> allLeads = leadProvider.priorityLeads.isNotEmpty 
        ? leadProvider.priorityLeads 
        : (adminState.dashboardData?.priorityLeads ?? [])
            .map((item) => LeadModel.fromJson(item as Map<String, dynamic>))
            .toList();

    final filteredLeads = LeadFilterHelper.filterLeads(
      leads: allLeads,
      query: _searchController.text,
      category: _selectedCategory,
      potential: _selectedPotential,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (leadProvider.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UIHelper.showError(context, leadProvider.errorMessage!);
        leadProvider.clearError();
      });
    }

    Widget body;
    if (adminState.isLoading || leadProvider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (adminState.hasError) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: UIHelper.buildInlineError(
            context: context,
            message: adminState.errorMessage!,
            onRetry: () => adminState.fetchDashboardData(),
          ),
        ),
      );
    } else if (allLeads.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.priority_high_rounded,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No priority leads found',
              style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      body = Column(
        children: [
          // Filter section
          _buildDiscoveryBar(isDark, primaryBlue),

          Expanded(
            child: filteredLeads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No leads match your criteria',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredLeads.length,
                    itemBuilder: (context, index) {
                      final lead = filteredLeads[index];
                      return _buildPriorityLeadListItem(
                        context,
                        lead,
                        cardColor,
                        primaryBlue,
                        textColor,
                        secondaryTextColor,
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).cardColor : primaryBlue,
        elevation: 0,
        leading: backButton(isDark: !isDark),
        title: Text(
          'All Priority Leads',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminLeadProvider>().fetchPriorityLeads(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              final success = await ExcelHelper.exportLeadsToExcel(
                filteredLeads,
              );

              if (context.mounted) {
                Navigator.pop(context); // Close loading dialog
                if (success) {
                  UIHelper.showSuccess(context, 'Data exported successfully');
                } else {
                  UIHelper.showError(context, 'Failed to export data');
                }
              }
            },
          ),
          
        ],
      ),
      body: body,
    );
  }

  Widget _buildDiscoveryBar(bool isDark, Color primaryBlue) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF121212) : Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Search Field
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.montserrat(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search Name, Stage, or Address...',
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 12,
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
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Category',
                  ['All', 'A', 'B', 'C'],
                  _selectedCategory,
                  (v) => setState(() => _selectedCategory = v),
                  isDark,
                  primaryBlue,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Potential',
                  ['All', 'Hot', 'Warm', 'Cold'],
                  _selectedPotential,
                  (v) => setState(() => _selectedPotential = v),
                  isDark,
                  primaryBlue,
                ),
                const SizedBox(width: 8),
                _buildDateRangeChip(isDark, primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    List<String> items,
    String selectedValue,
    Function(String) onSelect,
    bool isDark,
    Color primaryBlue,
  ) {
    final isActive = selectedValue != 'All';
    return GestureDetector(
      onTap: () => _showFilterPicker(label, items, selectedValue, onSelect),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? primaryBlue.withOpacity(0.1)
              : (isDark ? Colors.grey[900] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? primaryBlue.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedValue == 'All' ? label : selectedValue,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? primaryBlue
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isActive ? primaryBlue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeChip(bool isDark, Color primaryBlue) {
    final isActive = _startDate != null || _endDate != null;
    String label = 'Date Range';
    if (_startDate != null && _endDate != null) {
      label =
          '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}';
    } else if (_startDate != null) {
      label = 'From ${DateFormat('dd MMM').format(_startDate!)}';
    } else if (_endDate != null) {
      label = 'Until ${DateFormat('dd MMM').format(_endDate!)}';
    }

    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? primaryBlue.withOpacity(0.1)
              : (isDark ? Colors.grey[900] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? primaryBlue.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? primaryBlue
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive ? Icons.date_range : Icons.calendar_today_outlined,
              size: 14,
              color: isActive ? primaryBlue : Colors.grey,
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: Icon(Icons.close, size: 14, color: primaryBlue),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterPicker(
    String label,
    List<String> items,
    String selectedValue,
    Function(String) onSelect,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select $label',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;
                    return ListTile(
                      dense: true,
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(context);
                      },
                      leading: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: primaryBlue,
                              size: 20,
                            )
                          : const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                      title: Text(
                        item,
                        style: GoogleFonts.montserrat(
                          color: isSelected
                              ? primaryBlue
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Active',
                                style: GoogleFonts.montserrat(
                                  color: primaryBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).primaryColor,
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Widget _buildPriorityLeadListItem(
    BuildContext context,
    LeadModel lead,
    Color cardColor,
    Color primaryBlue,
    Color? textColor,
    Color? secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
            final fetchedLead = await context
                .read<AdminLeadProvider>()
                .getSingleLead(lead.id.toString());
            if (context.mounted) {
              Navigator.pop(context);
              if (fetchedLead != null) {
                context.read<AdvisorProfileProvider>().clearProfile();
                context.read<AdvisorProfileProvider>().fetchProfileByCode(
                  fetchedLead.advisorCode,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LeadDetailsScreen(lead: fetchedLead, isAdmin: true),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lead.createdAt.split(' ')[0],
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lead.clientName,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 12,
                            color: primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lead.clientNumber,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final number = lead.clientNumber;
                        if (number.isNotEmpty) {
                          final Uri url = Uri.parse('tel:$number');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: primaryBlue.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
