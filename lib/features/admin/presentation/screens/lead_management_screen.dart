import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/assign_lead_screen.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/lead_models.dart';

class LeadManagementScreen extends StatefulWidget {
  const LeadManagementScreen({Key? key}) : super(key: key);

  @override
  State<LeadManagementScreen> createState() => _LeadManagementScreenState();
}

class _LeadManagementScreenState extends State<LeadManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeadProvider>().fetchNewLeads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final cardColor = AppColors.getCardColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminLeadProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('Lead Management', style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87), onPressed: () {}),
          IconButton(icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black87), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: primaryBlue, labelColor: primaryBlue, unselectedLabelColor: Colors.grey[600],
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [Tab(text: 'New Leads'), Tab(text: 'Assigned'), Tab(text: 'Follow-up'), Tab(text: 'Closed')],
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // 1. New Leads Tab
          ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECENT ARRIVALS', style: GoogleFonts.montserrat(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text('${provider.newLeads.length} New', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 10))),
                ],
              ),
              const SizedBox(height: 16),
              ...provider.newLeads.map((lead) => _buildLeadCard(lead, cardColor, primaryBlue, isDark)).toList(),
            ],
          ),
          const Center(child: Text("Assigned Leads View")),
          const Center(child: Text("Follow-up Leads View")),
          const Center(child: Text("Closed Leads View")),
        ],
      ),
    );
  }

  Widget _buildLeadCard(LeadModel lead, Color cardColor, Color primaryBlue, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${lead.source} • ${lead.timeAgo}', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(height: 6),
                    Text(lead.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                    const SizedBox(height: 4),
                    Text('${lead.email} • ${lead.phone}', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8), image: const DecorationImage(image: AssetImage('assets/images/logos.png'), fit: BoxFit.cover)))
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(children: [Icon(Icons.business, size: 14, color: Colors.grey[500]), const SizedBox(width: 8), Text(lead.projectName, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]))]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssignLeadScreen(lead: lead))),
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
              label: Text('Assign Agent', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          )
        ],
      ),
    );
  }
}