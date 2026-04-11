import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/assign_lead_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/lead_models.dart';

// Import Lead Details from its Advisor location
import '../../../advisor/presentation/screens/lead_details_screen.dart';
import '../../../../core/utils/lead_filter_helper.dart'; // NEW

class LeadManagementScreen extends StatefulWidget {
  const LeadManagementScreen({super.key});

  @override
  State<LeadManagementScreen> createState() => _LeadManagementScreenState();
}

class _LeadManagementScreenState extends State<LeadManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPotential = 'All';
  String _selectedAttempts = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeadProvider>().fetchUnassignedLeads();
      context
          .read<AdminLeadProvider>()
          .fetchLeads(); // Fetches ALL pipeline leads
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminLeadProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).cardColor : primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Leads Management',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AdminLeadProvider>().fetchUnassignedLeads();
              context.read<AdminLeadProvider>().fetchLeads();
            },
            tooltip: 'Refresh Leads',
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDiscoveryBar(isDark, primaryBlue),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: primaryBlue,
                  labelColor: primaryBlue,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'New Leads'),
                    Tab(text: 'Suspecting'),
                    Tab(text: 'Prospecting'),
                    Tab(text: 'Site Visit'),
                    Tab(text: 'Booking'),
                    Tab(text: 'Closed'),
                    Tab(text: 'Completed'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 0: UNASSIGNED LEADS
                      _buildUnassignedSection(
                        LeadFilterHelper.filterLeads(
                          leads: provider.unassignedLeads,
                          query: _searchController.text,
                          category: _selectedCategory,
                          potential: _selectedPotential,
                          startDate: _startDate,
                          endDate: _endDate,
                          attempts: _selectedAttempts,
                        ),
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),

                      // STAGES
                      _buildStageList(
                        LeadFilterHelper.filterLeads(
                              leads: provider.leads,
                              query: _searchController.text,
                              category: _selectedCategory,
                              potential: _selectedPotential,
                              startDate: _startDate,
                              endDate: _endDate,
                              attempts: _selectedAttempts,
                            )
                            .where(
                              (l) =>
                                  l.stage.toLowerCase() == 'suspecting' &&
                                  l.advisorCode.isNotEmpty,
                            )
                            .toList(),
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildStageList(
                        LeadFilterHelper.filterLeads(
                              leads: provider.leads,
                              query: _searchController.text,
                              category: _selectedCategory,
                              potential: _selectedPotential,
                              startDate: _startDate,
                              endDate: _endDate,
                              attempts: _selectedAttempts,
                            )
                            .where(
                              (l) =>
                                  l.stage.toLowerCase() == 'prospecting' &&
                                  l.advisorCode.isNotEmpty,
                            )
                            .toList(),
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildStageList(
                        LeadFilterHelper.filterLeads(
                              leads: provider.leads,
                              query: _searchController.text,
                              category: _selectedCategory,
                              potential: _selectedPotential,
                              startDate: _startDate,
                              endDate: _endDate,
                              attempts: _selectedAttempts,
                            )
                            .where(
                              (l) =>
                                  l.stage.toLowerCase() == 'site visit' &&
                                  l.advisorCode.isNotEmpty,
                            )
                            .toList(),
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildStageList(
                        LeadFilterHelper.filterLeads(
                              leads: provider.leads,
                              query: _searchController.text,
                              category: _selectedCategory,
                              potential: _selectedPotential,
                              startDate: _startDate,
                              endDate: _endDate,
                              attempts: _selectedAttempts,
                            )
                            .where(
                              (l) =>
                                  l.stage.toLowerCase() == 'booking' &&
                                  l.advisorCode.isNotEmpty,
                            )
                            .toList(),
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildStageList(
                        LeadFilterHelper.filterLeads(
                              leads: provider.leads,
                              query: _searchController.text,
                              category: _selectedCategory,
                              potential: _selectedPotential,
                              startDate: _startDate,
                              endDate: _endDate,
                              attempts: _selectedAttempts,
                            )
                            .where(
                              (l) =>
                                  l.stage.toLowerCase() == 'closed' &&
                                  l.advisorCode.isNotEmpty,
                            )
                            .toList(),
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                      _buildStageList(
                        LeadFilterHelper.filterLeads(
                              leads: provider.leads,
                              query: _searchController.text,
                              category: _selectedCategory,
                              potential: _selectedPotential,
                              startDate: _startDate,
                              endDate: _endDate,
                              attempts: _selectedAttempts,
                            )
                            .where(
                              (l) =>
                                  l.stage.toLowerCase() == 'completed' &&
                                  l.advisorCode.isNotEmpty,
                            )
                            .toList(),
                        cardColor,
                        primaryBlue,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDiscoveryBar(bool isDark, Color primaryBlue) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF121212) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Search Field
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.montserrat(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search Name, Stage, or Address...',
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: Colors.grey,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),

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
                _buildFilterChip(
                  'Attempts',
                  LeadFilterHelper.attemptOptions,
                  _selectedAttempts,
                  (v) => setState(() => _selectedAttempts = v),
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
              seedColor: AppColors.getPrimaryBlue(context),
              primary: AppColors.getPrimaryBlue(context),
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

  void _showFilterPicker(
    String label,
    List<String> items,
    String selectedValue,
    Function(String) onSelect,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);

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

  Widget _buildUnassignedSection(
    List<LeadModel> leads,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    if (leads.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<AdminLeadProvider>().fetchUnassignedLeads();
          await context.read<AdminLeadProvider>().fetchLeads();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: Text(
                  "No new leads match your filters.",
                  style: GoogleFonts.montserrat(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminLeadProvider>().fetchUnassignedLeads();
        await context.read<AdminLeadProvider>().fetchLeads();
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UNASSIGNED LEADS',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${leads.length} Result',
                  style: GoogleFonts.montserrat(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...leads.map(
            (lead) =>
                _buildUnassignedLeadCard(lead, cardColor, primaryBlue, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStageList(
    List<LeadModel> leads,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    if (leads.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<AdminLeadProvider>().fetchUnassignedLeads();
          await context.read<AdminLeadProvider>().fetchLeads();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: Text(
                  "No leads in this stage match your filters.",
                  style: GoogleFonts.montserrat(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminLeadProvider>().fetchUnassignedLeads();
        await context.read<AdminLeadProvider>().fetchLeads();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: leads.length,
        itemBuilder: (context, index) {
          return _buildStageLeadCard(
            leads[index],
            cardColor,
            primaryBlue,
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildUnassignedLeadCard(
    LeadModel lead,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AssignLeadScreen(lead: lead)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.clientName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Source: ${lead.source.toUpperCase()}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (lead.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            lead.description,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: lead.clientNumber,
                        );
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        }
                      },
                      icon: Icon(
                        Icons.phone_outlined,
                        color: primaryBlue,
                        size: 18,
                      ),
                      tooltip: 'Call Lead',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AssignLeadScreen(lead: lead),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Assign Agent',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildLeadMetadataRow(lead, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStageLeadCard(
    LeadModel lead,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final isCompleted = lead.stage.toLowerCase() == 'completed';

    return InkWell(
      onTap: () {
        context.read<AdvisorProfileProvider>().clearProfile();
        context.read<AdvisorProfileProvider>().fetchProfileByCode(
          lead.advisorCode,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LeadDetailsScreen(lead: lead, isAdmin: true),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCompleted
              ? (isDark ? Colors.green.withOpacity(0.1) : Colors.green[50])
              : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.clientName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Source: ${lead.source.toUpperCase()}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (lead.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            lead.description,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: lead.clientNumber,
                        );
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        }
                      },
                      icon: Icon(
                        Icons.phone_outlined,
                        color: primaryBlue,
                        size: 18,
                      ),
                      tooltip: 'Call Lead',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LeadDetailsScreen(lead: lead, isAdmin: true),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Details',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            _buildLeadMetadataRow(lead, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadMetadataRow(LeadModel lead, bool isDark) {
    Color potentialColor = Colors.orange;
    if (lead.leadPotential.toLowerCase() == 'hot') {
      potentialColor = Colors.red;
    } else if (lead.leadPotential.toLowerCase() == 'cold') {
      potentialColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMetadataItem(
              Icons.local_fire_department_rounded,
              lead.leadPotential.toUpperCase(),
              potentialColor,
              isDark,
            ),
            const SizedBox(width: 8),
            _buildMetadataItem(
              Icons.category_outlined,
              'CAT ${lead.leadCategory.toUpperCase()}',
              Colors.purple,
              isDark,
            ),
            const SizedBox(width: 8),
            _buildMetadataItem(
              Icons.phone_callback_rounded,
              '${lead.communicationAttempt} Attempts',
              Colors.teal,
              isDark,
            ),
            const SizedBox(width: 8),
            _buildMetadataItem(
              Icons.calendar_today_rounded,
              lead.createdAt,
              Colors.grey[600]!,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(
    IconData icon,
    String label,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
