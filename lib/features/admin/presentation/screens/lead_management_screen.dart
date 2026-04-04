import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/assign_lead_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/lead_models.dart';

// Import Lead Details from its Advisor location
import '../../../advisor/presentation/screens/lead_details_screen.dart';

class LeadManagementScreen extends StatefulWidget {
  const LeadManagementScreen({super.key});

  @override
  State<LeadManagementScreen> createState() => _LeadManagementScreenState();
}

class _LeadManagementScreenState extends State<LeadManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Master Lead Pipeline',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
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
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 0: UNASSIGNED LEADS
                provider.unassignedLeads.isEmpty
                    ? Center(
                        child: Text(
                          "No new unassigned leads.",
                          style: GoogleFonts.montserrat(color: Colors.grey),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${provider.unassignedLeads.length} New',
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
                          ...provider.unassignedLeads.map(
                            (lead) => _buildUnassignedLeadCard(
                              lead,
                              cardColor,
                              primaryBlue,
                              isDark,
                            ),
                          ),
                        ],
                      ),

                // THE FIX: Locally filter the leads for each tab instantly!
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
                      .where((l) => l.stage.toLowerCase() == 'booking')
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
    if (leads.isEmpty) {
      return Center(
        child: Text(
          "No leads in this stage.",
          style: GoogleFonts.montserrat(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        return _buildStageLeadCard(
          leads[index],
          cardColor,
          primaryBlue,
          isDark,
        );
      },
    );
  }

  Widget _buildUnassignedLeadCard(
    LeadModel lead,
    Color cardColor,
    Color primaryBlue,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    // Determine source color
    Color sourceColor;
    IconData sourceIcon;
    switch (lead.source.toLowerCase()) {
      case 'website':
        sourceColor = Colors.blue;
        sourceIcon = Icons.language;
        break;
      case 'application':
        sourceColor = Colors.purple;
        sourceIcon = Icons.important_devices;
        break;
      default:
        sourceColor = Colors.orange;
        sourceIcon = Icons.campaign;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: sourceColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: sourceColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header with Source Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: sourceColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: sourceColor.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                    children: [
                      Icon(sourceIcon, size: 14, color: sourceColor),
                      const SizedBox(width: 6),
                      Text(
                        lead.source.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: sourceColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    lead.createdAt,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.clientName,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lead.clientNumber,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AssignLeadScreen(lead: lead),
                        ),
                      ),
                      icon: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Assign Agent Now',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    final isCompleted = lead.stage.toLowerCase() == 'completed';
    final accentColor = isCompleted ? Colors.green : primaryBlue;
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = isCompleted
        ? (isDark 
            ? Colors.green.withOpacity(0.05) 
            : Colors.green.withOpacity(0.02))
        : cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isCompleted ? Colors.green[50] : Colors.blue[50],
                child: Icon(
                  isCompleted ? Icons.verified_rounded : Icons.person_outline, 
                  color: isCompleted ? Colors.green : primaryBlue
                ),
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
                            lead.clientName,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green[50] : Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isCompleted ? 'COMPLETED' : 'SOURCE: ${lead.source.toUpperCase()}',
                            style: GoogleFonts.montserrat(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lead.clientNumber,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.support_agent,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lead.advisorCode.isNotEmpty
                              ? 'Advisor: ${lead.advisorCode}'
                              : 'Unassigned',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created : ${lead.createdAt}',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey[600],
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
                    'Update: ${lead.updatedAt}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignLeadScreen(lead: lead),
                      ),
                    ),
                    child: Text(
                      'REASSIGN',
                      style: GoogleFonts.montserrat(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LeadDetailsScreen(lead: lead, isAdmin: true),
                        ),
                      );
                    },
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
        ],
      ),
    );
  }
}
