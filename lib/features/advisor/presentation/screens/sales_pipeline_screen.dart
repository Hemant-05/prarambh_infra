import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/core/utils/validators.dart';
import 'package:flutter/services.dart';
import 'package:prarambh_infra/features/admin/data/models/lead_models.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_lead_provider.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../advisor/presentation/screens/lead_details_screen.dart';
import '../../../../core/utils/access_helper.dart';
import '../../../../core/utils/lead_filter_helper.dart'; // NEW

class SalesPipelineScreen extends StatefulWidget {
  const SalesPipelineScreen({super.key});

  @override
  State<SalesPipelineScreen> createState() => _SalesPipelineScreenState();
}

class _SalesPipelineScreenState extends State<SalesPipelineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPotential = 'All';
  String _selectedAttempts = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _onlyPriority = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final advisorCode = authProvider.currentUser?.advisorCode ?? '';
      context.read<AdvisorLeadProvider>().fetchLeads(advisorCode: advisorCode);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddLeadDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Add New Lead',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Client Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        Validators.validateRequired(v, 'Client Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validatePhone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              if (!isSubmitting)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimaryBlue(context),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setDialogState(() => isSubmitting = true);
                        final advisorCode =
                            context
                                .read<AuthProvider>()
                                .currentUser
                                ?.advisorCode ??
                            '';

                        final provider = context.read<AdvisorLeadProvider>();
                        final success = await provider.addLead({
                          "client_name": nameCtrl.text,
                          "client_number": phoneCtrl.text,
                          "advisor_code": advisorCode,
                          "source": "Generated",
                          "stage": "suspecting",
                        }, advisorCode);

                        if (success && mounted) {
                          Navigator.pop(context);
                          _tabController.animateTo(0);
                        } else {
                          setDialogState(() => isSubmitting = false);
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add Lead',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdvisorLeadProvider>();

    // Handle redirection from dashboard if the screen is already alive in IndexedStack
    if (provider.initialPipelineTabIndex != null) {
      final targetIndex = provider.initialPipelineTabIndex!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController.index != targetIndex) {
          _tabController.animateTo(targetIndex);
        }
        provider.clearInitialPipelineTab();
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: primaryBlue,
          indicatorWeight: 1,
          labelColor: primaryBlue,
          unselectedLabelColor: isDark ? Colors.white38 : Colors.grey[600],
          labelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Suspecting'),
            Tab(text: 'Prospecting'),
            Tab(text: 'Site Visit'),
            Tab(text: 'Booking'),
            Tab(text: 'Completed'),
            Tab(text: 'Dead Lead'),
          ],
        ),
        shape: Border(
          bottom: BorderSide(color: AppColors.getBorderColor(context)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sales_pipeline_add_lead_fab',
        onPressed: () {
          if (AdvisorAccessHelper.check(context, feature: 'lead generation')) {
            _showAddLeadDialog();
          }
        },
        backgroundColor: primaryBlue,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Lead',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : Column(
              children: [
                _buildDiscoveryBar(isDark, primaryBlue),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStageList(
                        LeadFilterHelper.filterLeads(
                              leads: provider.leads,
                              query: _searchController.text,
                              category: _selectedCategory,
                              potential: _selectedPotential,
                              startDate: _startDate,
                              endDate: _endDate,
                              attempts: _selectedAttempts,
                              isPriority: _onlyPriority,
                            )
                            .where((l) => l.stage.toLowerCase() == 'suspecting')
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
                              isPriority: _onlyPriority,
                            )
                            .where(
                              (l) => l.stage.toLowerCase() == 'prospecting',
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
                              isPriority: _onlyPriority,
                            )
                            .where((l) => l.stage.toLowerCase() == 'site visit')
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
                              isPriority: _onlyPriority,
                            )
                            .where(
                              (l) =>
                                  l.stage.toLowerCase() == 'booking' ||
                                  l.stage.toLowerCase() ==
                                      'pending_verification',
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
                              isPriority: _onlyPriority,
                            )
                            .where((l) => l.stage.toLowerCase() == 'completed')
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
                              isPriority: _onlyPriority,
                            )
                            .where((l) => l.stage.toLowerCase() == 'dead')
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
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
                      hintText: 'Search Name or Address...',
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
              ),
            ],
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _onlyPriority = !_onlyPriority),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _onlyPriority
                          ? Colors.amber.withOpacity(0.1)
                          : (isDark ? Colors.grey[900] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _onlyPriority
                            ? Colors.amber
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: _onlyPriority
                              ? Colors.amber[700]
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Priority',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: _onlyPriority
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: _onlyPriority
                                ? (isDark
                                      ? Colors.amberAccent
                                      : Colors.amber[900])
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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

  Widget _buildStageList(
    List<LeadModel> leads,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    final hintColor = Theme.of(context).hintColor;

    return RefreshIndicator(
      onRefresh: () {
        final advisorCode =
            context.read<AuthProvider>().currentUser?.advisorCode ?? '';
        return context.read<AdvisorLeadProvider>().fetchLeads(
          advisorCode: advisorCode,
        );
      },
      child: leads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 48,
                    color: hintColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No leads in this stage.",
                    style: GoogleFonts.montserrat(
                      color: hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                return _buildPipelineCard(
                  leads[index],
                  cardColor,
                  primaryBlue,
                  isDark,
                );
              },
            ),
    );
  }

  Widget _buildPipelineCard(
    LeadModel lead,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    // Stage-specific styling
    final isBooking =
        lead.stage.toLowerCase() == 'booking' ||
        lead.stage.toLowerCase() == 'pending_verification';
    final isDead = lead.stage.toLowerCase() == 'dead';
    final isCompleted = lead.stage.toLowerCase() == 'completed';
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    // Choose accent and background based on stage
    Color accentColor = isCompleted
        ? (isDark ? Colors.greenAccent : Colors.green[700]!)
        : (isBooking
              ? (isDark ? Colors.orangeAccent : Colors.orange[800]!)
              : (isDead ? Colors.redAccent : primaryBlue));

    Color backgroundColor = isCompleted
        ? (isDark
              ? Colors.green.withOpacity(0.1)
              : Colors.green.withOpacity(0.05))
        : (isBooking
              ? (isDark
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.05))
              : (isDead
                    ? (isDark
                          ? Colors.red.withOpacity(0.1)
                          : Colors.red.withOpacity(0.05))
                    : cardColor));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lead.isPriority
              ? Colors.amber.withOpacity(0.3)
              : AppColors.getBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeadDetailsScreen(lead: lead, isAdmin: false),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Client Name & Priority Indicator
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      if (lead.isPriority)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.amber[700],
                            size: 16,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          lead.clientName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Data Details
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Attempts
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${lead.communicationAttempt} At.',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Date
                      Text(
                        lead.createdAt.split(' ')[0],
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Call Icon
                      GestureDetector(
                        onTap: () {
                          // Note: lead.clientNumber is the phone
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.call,
                            size: 16,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
