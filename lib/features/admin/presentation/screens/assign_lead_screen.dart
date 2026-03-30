import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/lead_models.dart';

class AssignLeadScreen extends StatefulWidget {
  final LeadModel lead;
  const AssignLeadScreen({super.key, required this.lead});

  @override
  State<AssignLeadScreen> createState() => _AssignLeadScreenState();
}

class _AssignLeadScreenState extends State<AssignLeadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLeadProvider>().fetchAdvisorsForAssignment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final provider = context.watch<AdminLeadProvider>();

    // Generate dynamic tags based on the new database fields
    List<String> dynamicTags = [
      widget.lead.source.toUpperCase(),
      widget.lead.leadCategory.toUpperCase(),
      widget.lead.stage.toUpperCase()
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Assign Lead',
          style: GoogleFonts.montserrat(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Lead Info Header ---
          Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.person_outline, color: primaryBlue, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lead.clientName, // FIX: Using new Model field
                            style: GoogleFonts.montserrat(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+91 ${widget.lead.clientNumber} • ${widget.lead.isPriority ? "HOT LEAD" : "STANDARD"}', // FIX: Priority logic
                            style: GoogleFonts.montserrat(fontSize: 12, color: widget.lead.isPriority ? Colors.red : Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dynamic Tags
                Row(
                  children: dynamicTags.map((tag) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                    child: Text(tag, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  ),
                  ).toList(),
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search advisors by name or expertise...',
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true, fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AVAILABLE ADVISORS', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1)),
                Row(
                  children: [
                    Icon(Icons.filter_list, size: 14, color: primaryBlue), const SizedBox(width: 4),
                    Text('Filter', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                  ],
                ),
              ],
            ),
          ),

          // --- Advisors List ---
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.availableAdvisors.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final advisor = provider.availableAdvisors[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(advisor.name, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(width: 8),
                              Icon(Icons.circle, size: 8, color: true ? Colors.green : Colors.grey[400]),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.people_outline, size: 12, color: Colors.grey[500]), const SizedBox(width: 4),
                              Text('${advisor.activeLeads} Leads', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: provider.isSaving ? null : () async {
                          final success = await provider.assignLeadToAdvisor(widget.lead.id, advisor.advisorCode);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lead assigned to ${advisor.name}')));
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                        child: provider.isSaving
                            ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Assign', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}