import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/lead_models.dart';
import 'lead_details_screen.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final stages = ['Suspecting', 'Prospecting', 'Site Visit', 'Booking'];
        context.read<AdminLeadProvider>().fetchPipelineLeads(
          stages[_tabController.index],
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeadProvider>().fetchPipelineLeads('Suspecting');
    });
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
            labelStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Suspecting'),
              Tab(text: 'Prospecting'),
              Tab(text: 'Site Visit'),
              Tab(text: 'Booking'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: provider.isLoadingPipeline
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.pipelineLeads.length,
              itemBuilder: (context, index) {
                final lead = provider.pipelineLeads[index];
                return _buildPipelineCard(lead, cardColor, primaryBlue, isDark);
              },
            ),
    );
  }

  Widget _buildPipelineCard(
    PipelineLeadModel lead,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue[50],
                child: Icon(Icons.person_outline, color: primaryBlue),
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
                            lead.name,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ADVISOR: ${lead.advisorName}',
                              style: GoogleFonts.montserrat(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lead.project,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Last: ${lead.lastActiveDate}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LeadDetailsScreen(leadId: lead.id, leadName: lead.name),
                  ),
                ),
                child: Text(
                  'DETAILS >',
                  style: GoogleFonts.montserrat(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
