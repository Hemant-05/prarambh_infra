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
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdvisorLeadProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          elevation: 1,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: primaryBlue,
            labelColor: primaryBlue,
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(text: 'Suspecting'),
              Tab(text: 'Prospecting'),
              Tab(text: 'Site Visit'),
              Tab(text: 'Booking'),
              Tab(text: 'Closed'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLeadDialog,
        backgroundColor: primaryBlue,
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
          ? const Center(child: CircularProgressIndicator())
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
    if (leads.isEmpty)
      return Center(
        child: Text(
          "No leads in this stage.",
          style: GoogleFonts.montserrat(color: Colors.grey),
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        return _buildPipelineCard(leads[index], cardColor, primaryBlue, isDark);
      },
    );
  }

  Widget _buildPipelineCard(
    LeadModel lead,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    // Stage-specific styling
    final isBooking = lead.stage.toLowerCase() == 'booking';
    final isClosed = lead.stage.toLowerCase() == 'closed';
    final isCompleted = lead.stage.toLowerCase() == 'completed';

    // Choose accent and background based on stage
    Color accentColor = isCompleted
        ? Colors.green
        : (isBooking ? Colors.orange : (isClosed ? Colors.red : primaryBlue));
        
    Color? backgroundColor = isCompleted
        ? (isDark 
            ? Colors.green.withOpacity(0.05) 
            : Colors.green.withOpacity(0.02))
        : (isBooking
            ? (isDark
                  ? Colors.orange.withOpacity(0.05)
                  : Colors.orange.withOpacity(0.02))
            : (isClosed
                  ? (isDark
                        ? Colors.red.withOpacity(0.05)
                        : Colors.red.withOpacity(0.02))
                  : cardColor));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBooking || isClosed
              ? accentColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                // Top Row: Source Tag & Stage Icon
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
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber.shade700, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  "PRIORITY",
                                  style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isClosed)
                      const Icon(
                        Icons.do_disturb_alt_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                    if (isCompleted)
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.green,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Name and Phone
                Text(
                  lead.clientName,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      lead.clientNumber,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),

                // Footer Row: Attempts & Created Date
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
                        color: Colors.grey[500],
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
