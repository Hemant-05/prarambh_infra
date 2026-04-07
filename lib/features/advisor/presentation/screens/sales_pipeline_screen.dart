import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _selectedMonth = 'All';
  String _selectedAttempts = 'All';

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: primaryBlue,
            indicatorWeight: 3,
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
              Tab(text: 'Closed'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: primaryBlue),
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                final advisorCode = authProvider.currentUser?.advisorCode ?? '';
                context.read<AdvisorLeadProvider>().fetchLeads(
                  advisorCode: advisorCode,
                );
              },
              tooltip: 'Refresh Leads',
            ),
          ],
          shape: Border(
            bottom: BorderSide(color: AppColors.getBorderColor(context)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
                               month: _selectedMonth,
                              attempts: _selectedAttempts,
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
                               month: _selectedMonth,
                              attempts: _selectedAttempts,
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
                              month: _selectedMonth,
                              attempts: _selectedAttempts,
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
                              month: _selectedMonth,
                              attempts: _selectedAttempts,
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
                              month: _selectedMonth,
                              attempts: _selectedAttempts,
                            )
                            .where((l) => l.stage.toLowerCase() == 'closed')
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
                              month: _selectedMonth,
                              attempts: _selectedAttempts,
                            )
                            .where((l) => l.stage.toLowerCase() == 'completed')
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
          const SizedBox(height: 10),

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
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  'Attempts',
                  LeadFilterHelper.attemptOptions,
                  _selectedAttempts,
                  (v) => setState(() => _selectedAttempts = v!),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 34,
      decoration: BoxDecoration(
        color: selectedValue != 'All'
            ? primaryBlue.withOpacity(0.1)
            : (isDark ? Colors.grey[900] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selectedValue != 'All'
              ? primaryBlue.withOpacity(0.3)
              : Colors.transparent,
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
                  fontSize: 10,
                  fontWeight: selectedValue == e
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: selectedValue == e
                      ? primaryBlue
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            );
          }).toList(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 12),
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
        ),
      ),
    );
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
    final isClosed = lead.stage.toLowerCase() == 'closed';
    final isCompleted = lead.stage.toLowerCase() == 'completed';
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    // Choose accent and background based on stage
    Color accentColor = isCompleted
        ? (isDark ? Colors.greenAccent : Colors.green[700]!)
        : (isBooking
              ? (isDark ? Colors.orangeAccent : Colors.orange[800]!)
              : (isClosed ? Colors.redAccent : primaryBlue));

    Color backgroundColor = isCompleted
        ? (isDark
              ? Colors.green.withOpacity(0.1)
              : Colors.green.withOpacity(0.05))
        : (isBooking
              ? (isDark
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.05))
              : (isClosed
                    ? (isDark
                          ? Colors.red.withOpacity(0.1)
                          : Colors.red.withOpacity(0.05))
                    : cardColor));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBooking || isClosed || isCompleted
              ? accentColor.withOpacity(isDark ? 0.4 : 0.2)
              : AppColors.getBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeadDetailsScreen(lead: lead, isAdmin: false),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lead.source.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                        if (lead.isPriority) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: isDark
                                      ? Colors.amberAccent
                                      : Colors.amber[700],
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "PRIORITY",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.amberAccent
                                        : Colors.amber[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isClosed)
                      Icon(
                        Icons.do_disturb_alt_rounded,
                        color: isDark ? Colors.redAccent : Colors.red,
                        size: 18,
                      ),
                    if (isCompleted)
                      Icon(
                        Icons.verified_rounded,
                        color: isDark ? Colors.greenAccent : Colors.green,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  lead.clientName,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: secondaryTextColor),
                    const SizedBox(width: 6),
                    Text(
                      lead.clientNumber,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    height: 1,
                    color: AppColors.getBorderColor(context),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_edu, size: 14, color: accentColor),
                        const SizedBox(width: 6),
                        Text(
                          '${lead.communicationAttempt} Attempts',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      lead.createdAt,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
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
}
