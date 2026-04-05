import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/utils/ui_helper.dart';
import 'package:provider/provider.dart';
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
  String _selectedMonth = 'All';

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
    final allLeads = adminState.dashboardData?.priorityLeads ?? [];
    
    final filteredLeads = LeadFilterHelper.filterLeadMaps(
      leads: allLeads,
      query: _searchController.text,
      category: _selectedCategory,
      potential: _selectedPotential,
      month: _selectedMonth,
    );

    if (leadProvider.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UIHelper.showError(context, leadProvider.errorMessage!);
        leadProvider.clearError();
      });
    }

    Widget body;
    if (adminState.isLoading) {
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
            Icon(Icons.priority_high_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
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
                        Icon(Icons.search_off, size: 48, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No leads match your criteria',
                          style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredLeads.length,
                    itemBuilder: (context, index) {
                      final lead = Map<String, dynamic>.from(filteredLeads[index]);
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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text(
          'All Priority Leads',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (allLeads.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  final success = await ExcelHelper.exportLeadsToExcel(filteredLeads);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    if (success) {
                      UIHelper.showSuccess(context, 'Data exported successfully');
                    } else {
                      UIHelper.showError(context, 'Failed to export data');
                    }
                  }
                },
                icon: Icon(Icons.description_outlined, color: primaryBlue),
                tooltip: 'Export Current View as Excel',
              ),
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
                hintStyle: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
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
          
          // Quality Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterDropdown(
                  'Category',
                  ['All', 'A', 'B', 'C'],
                  _selectedCategory,
                  (v) => setState(() => _selectedCategory = v!),
                  isDark,
                  primaryBlue,
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  'Potential',
                  ['All', 'Hot', 'Warm', 'Cold'],
                  _selectedPotential,
                  (v) => setState(() => _selectedPotential = v!),
                  isDark,
                  primaryBlue,
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  'Month',
                  LeadFilterHelper.months,
                  _selectedMonth,
                  (v) => setState(() => _selectedMonth = v!),
                  isDark,
                  primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> items,
    String selectedValue,
    ValueChanged<String?> onChanged,
    bool isDark,
    Color primaryBlue,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: selectedValue != 'All'
            ? primaryBlue.withOpacity(0.1)
            : (isDark ? Colors.grey[900] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedValue != 'All' ? primaryBlue.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e == 'All' ? label : e,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: selectedValue == e ? FontWeight.bold : FontWeight.w500,
                  color: selectedValue == e ? primaryBlue : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            );
          }).toList(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 14),
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
        ),
      ),
    );
  }

  Widget _buildPriorityLeadListItem(
    BuildContext context,
    Map<String, dynamic> lead,
    Color cardColor,
    Color primaryBlue,
    Color? textColor,
    Color? secondaryTextColor,
    bool isDark,
  ) {
    final category = (lead['lead_category'] ?? '').toString();
    final potential = (lead['lead_potential'] ?? '').toString();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
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
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
            final fetchedLead = await context
                .read<AdminLeadProvider>()
                .getSingleLead(lead['id'].toString());
            if (context.mounted) {
              Navigator.pop(context);
              if (fetchedLead != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeadDetailsScreen(lead: fetchedLead, isAdmin: true),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(
                        (lead['stage'] ?? 'Pending').toString().toUpperCase().replaceAll('_', ' '),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (category.isNotEmpty) ...[
                          _buildMiniBadge('CAT $category', Colors.purple, isDark),
                          const SizedBox(width: 4),
                        ],
                        if (potential.isNotEmpty) ...[
                          _buildMiniBadge(potential.toUpperCase(), Colors.orange, isDark),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          (lead['created_at'] ?? '').toString().split(' ')[0],
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  lead['client_name']?.toString() ?? 'Unknown Client',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_android, size: 14, color: primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      lead['client_number']?.toString() ?? '',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.priority_high, size: 14, color: Colors.orange.shade800),
                        const SizedBox(width: 4),
                        Text(
                          'HIGH ATTENTION REQUIRED',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.orange.shade800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, size: 18, color: primaryBlue),
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
