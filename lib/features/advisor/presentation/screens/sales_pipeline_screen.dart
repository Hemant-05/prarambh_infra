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

class _SalesPipelineScreenState extends State<SalesPipelineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

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
              title: Text('Add New Lead', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Client Name', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
                ],
              ),
              actions: [
                if (!isSubmitting)
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.getPrimaryBlue(context)),
                  onPressed: isSubmitting ? null : () async {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;

                    setDialogState(() => isSubmitting = true);
                    final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode ?? '';

                    final provider = context.read<AdvisorLeadProvider>();
                    final success = await provider.addLead({
                      "client_name": nameCtrl.text,
                      "client_number": phoneCtrl.text,
                      "source": "Generated",
                      "stage": "suspecting"
                    }, advisorCode);

                    if (success && mounted) {
                      Navigator.pop(context);
                      _tabController.animateTo(0);
                    } else {
                      setDialogState(() => isSubmitting = false);
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add Lead', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
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
              Tab(text: 'Suspecting'), Tab(text: 'Prospecting'),
              Tab(text: 'Site Visit'), Tab(text: 'Booking'), Tab(text: 'Closed'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLeadDialog,
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Lead', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildStageList(provider.leads.where((l) => l.stage.toLowerCase() == 'suspecting').toList(), cardColor, primaryBlue, isDark),
          _buildStageList(provider.leads.where((l) => l.stage.toLowerCase() == 'prospecting').toList(), cardColor, primaryBlue, isDark),
          _buildStageList(provider.leads.where((l) => l.stage.toLowerCase() == 'site visit').toList(), cardColor, primaryBlue, isDark),
          _buildStageList(provider.leads.where((l) => l.stage.toLowerCase() == 'booking').toList(), cardColor, primaryBlue, isDark),
          _buildStageList(provider.leads.where((l) => l.stage.toLowerCase() == 'closed').toList(), cardColor, primaryBlue, isDark),
        ],
      ),
    );
  }

  Widget _buildStageList(List<LeadModel> leads, Color cardColor, Color primaryBlue, bool isDark) {
    if (leads.isEmpty) return Center(child: Text("No leads in this stage.", style: GoogleFonts.montserrat(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        return _buildPipelineCard(leads[index], cardColor, primaryBlue, isDark);
      },
    );
  }

  Widget _buildPipelineCard(LeadModel lead, Color cardColor, Color primaryBlue, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(lead.clientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          const Divider(height: 24),
          GestureDetector(
            onTap: () {
              // PASSING isAdmin: false since this is the Advisor
              Navigator.push(context, MaterialPageRoute(builder: (_) => LeadDetailsScreen(lead: lead, isAdmin: false)));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Created: ${lead.createdAt}'), Text('DETAILS >', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold))],
            ),
          ),
        ],
      ),
    );
  }
}