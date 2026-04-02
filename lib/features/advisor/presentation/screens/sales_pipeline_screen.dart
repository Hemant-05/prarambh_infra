import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/data/models/lead_models.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_lead_provider.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../advisor/presentation/screens/lead_details_screen.dart';

class SalesPipelineScreen extends StatefulWidget {
  const SalesPipelineScreen({super.key});

  @override
  State<SalesPipelineScreen> createState() => _SalesPipelineScreenState();
}

class _SalesPipelineScreenState extends State<SalesPipelineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  void _showAddLeadDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                        if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty)
                          return;

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
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Suspecting'),
              Tab(text: 'Prospecting'),
              Tab(text: 'Site Visit'),
              Tab(text: 'Booking'),
              Tab(text: 'Closed'),
              Tab(text: 'Completed'),
            ],
          ),
          shape: Border(bottom: BorderSide(color: AppColors.getBorderColor(context))),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLeadDialog,
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
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStageList(
                  provider.leads
                      .where((l) => l.stage.toLowerCase() == 'suspecting')
                      .toList(),
                  cardColor,
                  primaryBlue,
                  isDark,
                ),
                _buildStageList(
                  provider.leads
                      .where((l) => l.stage.toLowerCase() == 'prospecting')
                      .toList(),
                  cardColor,
                  primaryBlue,
                  isDark,
                ),
                _buildStageList(
                  provider.leads
                      .where((l) => l.stage.toLowerCase() == 'site visit')
                      .toList(),
                  cardColor,
                  primaryBlue,
                  isDark,
                ),
                _buildStageList(
                  provider.leads
                      .where((l) => l.stage.toLowerCase() == 'booking' || l.stage.toLowerCase() == 'pending_verification')
                      .toList(),
                  cardColor,
                  primaryBlue,
                  isDark,
                ),
                _buildStageList(
                  provider.leads
                      .where((l) => l.stage.toLowerCase() == 'closed')
                      .toList(),
                  cardColor,
                  primaryBlue,
                  isDark,
                ),
                _buildStageList(
                  provider.leads
                      .where((l) => l.stage.toLowerCase() == 'completed')
                      .toList(),
                  cardColor,
                  primaryBlue,
                  isDark,
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
    final hintColor = Theme.of(context).hintColor;

    if (leads.isEmpty)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 48, color: hintColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "No leads in this stage.",
              style: GoogleFonts.montserrat(color: hintColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    return RefreshIndicator(
      onRefresh: () {
        final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode ?? '';
        return context.read<AdvisorLeadProvider>().fetchLeads(advisorCode: advisorCode);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: leads.length,
        itemBuilder: (context, index) {
          return _buildPipelineCard(leads[index], cardColor, primaryBlue, isDark);
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
    final isBooking = lead.stage.toLowerCase() == 'booking' || lead.stage.toLowerCase() == 'pending_verification';
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
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: isDark ? Colors.amberAccent : Colors.amber[700], size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  "PRIORITY",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9, 
                                    fontWeight: FontWeight.bold, 
                                    color: isDark ? Colors.amberAccent : Colors.amber[700],
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
                  child: Divider(height: 1, color: AppColors.getBorderColor(context)),
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
