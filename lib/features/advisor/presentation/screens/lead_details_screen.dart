import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math';

import '../../../../../core/theme/app_colors.dart';
import '../../../admin/data/models/lead_models.dart';
import '../../../admin/data/models/project_model.dart';
import '../../../admin/data/models/unit_model.dart';
import '../../../admin/data/models/deal_model.dart';
import '../../../admin/presentation/providers/admin_lead_provider.dart';
import '../../../admin/presentation/providers/admin_project_provider.dart';
import '../../../admin/presentation/providers/admin_deal_provider.dart';
import '../../../admin/presentation/screens/deal_management_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_lead_provider.dart';

class LeadDetailsScreen extends StatefulWidget {
  final LeadModel lead;
  final bool isAdmin;

  const LeadDetailsScreen({super.key, required this.lead, required this.isAdmin});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  late LeadModel _currentLead;
  late String currentStage;
  late int attemptCounter;
  String? rejectionReason;

  String? selectedProperty;
  int? selectedPropertyId;
  String? visitDate;
  String? meetingPoint;

  // Booking State Variables
  bool _isPendingVerification = false;
  bool _isDealVerified = false;
  String? _generatedTokenId;
  final TextEditingController _tokenAmountCtrl = TextEditingController();
  String _paymentMode = 'Online';

  final TextEditingController noteController = TextEditingController();
  final List<Map<String, String>> _noteHistory = [];

  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
    currentStage = _currentLead.stage.toLowerCase();
    attemptCounter = _currentLead.communicationAttempt;
    selectedProperty = _currentLead.propertyId > 0 ? "Property ID: ${_currentLead.propertyId}" : null;
    selectedPropertyId = _currentLead.propertyId > 0 ? _currentLead.propertyId : null;
    visitDate = _currentLead.reminder.isNotEmpty ? _currentLead.reminder : null;
    meetingPoint = _currentLead.meetingPoint.isNotEmpty ? _currentLead.meetingPoint : null;

    if (_currentLead.notes.isNotEmpty) {
      try {
        final decodedNotes = jsonDecode(_currentLead.notes);
        if (decodedNotes is List) {
          for (var item in decodedNotes) {
            _noteHistory.add({
              "date": item['date']?.toString() ?? '',
              "note": item['note']?.toString() ?? ''
            });
          }
        }
      } catch (e) {
        _noteHistory.add({"date": _currentLead.createdAt, "note": _currentLead.notes});
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProjectProvider>().fetchProjects();
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _emailController.dispose();
    _tokenAmountCtrl.dispose();
    super.dispose();
  }

  // ======================================================================
  // ACTIONS & CORE LOGIC
  // ======================================================================
  Future<void> _launchWhatsApp() async {
    String message = selectedProperty != null
        ? "Hello! Here are the details for $selectedProperty as discussed."
        : "Hello! Greetings from Prarambh Infra. How can we help you today?";

    final Uri url = Uri.parse("https://wa.me/91${_currentLead.clientNumber}?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _launchDialer() async {
    final Uri url = Uri.parse("tel:+91${_currentLead.clientNumber}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Dialer')));
    }
  }

  void _triggerLocalNotification(String title, String body) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.getPrimaryBlue(context), shape: BoxShape.circle),
                  child: const Icon(Icons.notifications, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(body, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                  onPressed: () => overlayEntry?.remove(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry?.mounted ?? false) overlayEntry?.remove();
    });
  }

  Future<void> _updateStageInDb(String newStage, {String? note}) async {
    if (note != null) {
      setState(() {
        _noteHistory.insert(0, {
          "date": DateTime.now().toString().split('.')[0],
          "note": note
        });
      });
    }

    final extraData = {
      "communication_attempt": attemptCounter,
      "property_id": selectedPropertyId,
      "reminder": visitDate ?? '',
      "meeting_point": meetingPoint ?? '',
      "notes": jsonEncode(_noteHistory),
    };

    bool success = false;

    // THE FIX: Switch between Admin and Advisor provider based on role
    if (widget.isAdmin) {
      final provider = context.read<AdminLeadProvider>();
      success = await provider.updateLeadStage(_currentLead.id, newStage, extraData: extraData);
    } else {
      final provider = context.read<AdvisorLeadProvider>();
      final authProvider = context.read<AuthProvider>();
      final advisorCode = authProvider.currentUser?.advisorCode ?? '';
      success = await provider.updateLeadStage(_currentLead.id, newStage, advisorCode, extraData: extraData);
    }

    if (success && mounted) {
      setState(() => currentStage = newStage.toLowerCase());
    }
  }

  void _incrementAttemptAndCheck(String reason) {
    int maxAttempts = currentStage == 'site visit' ? 10 : 5;
    setState(() => attemptCounter++);

    if (attemptCounter >= maxAttempts) {
      setState(() {
        currentStage = 'closed';
        rejectionReason = "Max attempts ($maxAttempts) reached. Last: $reason";
      });
      _updateStageInDb('closed', note: "System Auto-Closed: Max attempts reached.");
      _triggerLocalNotification("Lead Closed Automatically", "Maximum communication attempts ($maxAttempts) reached.");
    } else {
      _updateStageInDb(currentStage, note: "Call not connected: $reason");
    }
  }

  void _addNoteToHistory() {
    if (noteController.text.isNotEmpty) {
      String newNote = noteController.text;
      noteController.clear();
      _updateStageInDb(currentStage, note: newNote);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note added successfully")));
    }
  }

  void _showCascadedPropertySheet(Function(String, int) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Consumer<AdminProjectProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) return const Center(child: CircularProgressIndicator());

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Select Project", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.projects.length,
                      itemBuilder: (context, index) {
                        final project = provider.projects[index];
                        return ListTile(
                          leading: const Icon(Icons.business, color: Colors.blue),
                          title: Text(project.projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${project.city} • ${project.projectType}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () async {
                            await provider.fetchInventory(project.id.toString());
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              _showUnitSelectionSheet(project, provider.inventory, onSelect);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showUnitSelectionSheet(ProjectModel project, List<UnitModel> units, Function(String, int) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Select Unit in ${project.projectName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Expanded(
                child: units.isEmpty
                    ? const Center(child: Text("No units available in this project."))
                    : ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    bool isAvailable = unit.availabilityStatus.toLowerCase() == 'available';
                    return ListTile(
                      enabled: isAvailable,
                      leading: Icon(Icons.apartment, color: isAvailable ? Colors.green : Colors.red),
                      title: Text("${unit.towerName} - ${unit.unitNumber}", style: TextStyle(fontWeight: FontWeight.bold, color: isAvailable ? Colors.black : Colors.grey)),
                      subtitle: Text("₹${unit.calculatedPrice.toStringAsFixed(0)} • ${unit.availabilityStatus}"),
                      onTap: () {
                        onSelect("${project.projectName} (${unit.towerName}-${unit.unitNumber})", unit.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================================
  // BUILD METHOD
  // ======================================================================
  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6);
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    Color statusColor = primaryBlue;
    if (currentStage == "closed") statusColor = Colors.grey;
    if (currentStage == "site visit") statusColor = Colors.orange;
    if (currentStage == "booking") statusColor = Colors.green;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Text('Client Pipeline', style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: Icon(Icons.edit, color: primaryBlue), onPressed: _showEditLeadSheet),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(currentStage == 'closed' ? 'DEAD LEAD' : currentStage.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientInfoCard(cardColor, primaryBlue, textColor),
            const SizedBox(height: 24),

            if (['suspecting', 'prospecting', 'site visit'].contains(currentStage))
              _buildAttemptCounter(cardColor, primaryBlue),

            if (currentStage == "suspecting") _buildSuspectingActions(primaryBlue),
            if (currentStage == "closed") _buildRejectionInfo(),
            if (currentStage == "prospecting") _buildProspectingInfo(primaryBlue),
            if (currentStage == "site visit") _buildSiteVisitInfo(primaryBlue),
            if (currentStage == "booking") _buildBookingFlow(primaryBlue, cardColor),
          ],
        ),
      ),
    );
  }

  // ======================================================================
  // VISUAL COMPONENTS
  // ======================================================================
  Widget _buildClientInfoCard(Color cardColor, Color primaryBlue, Color textColor) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryBlue.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_currentLead.clientName, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 8),
                      Text('+91 ${_currentLead.clientNumber}', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.language, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('Source: ${_currentLead.source}', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(onTap: _launchDialer, child: _buildCircleAction(Icons.call, Colors.green)),
                    const SizedBox(width: 12),
                    GestureDetector(onTap: _launchWhatsApp, child: _buildCircleAction(Icons.message, const Color(0xFF25D366))),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text('PERSONAL INFORMATION', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1)),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem('Potential', _currentLead.leadPotential, textColor)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500])),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                  child: Text(_currentLead.leadCategory, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem('Age', _currentLead.clientAge != 'N/A' ? '${_currentLead.clientAge} Yrs' : 'N/A', textColor)),
                          Expanded(child: _buildInfoItem('Occupation', _currentLead.clientOccupation, textColor, icon: Icons.work)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem('Annual Income', _currentLead.annualIncome, textColor)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Decision Maker', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500])),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(_currentLead.keyDecisionMaker ? Icons.check_circle : Icons.cancel, size: 16, color: _currentLead.keyDecisionMaker ? Colors.green : Colors.red),
                                    const SizedBox(width: 6),
                                    Text(_currentLead.keyDecisionMaker ? 'Yes' : 'No', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Text('Residential Address', style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 18, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_currentLead.clientAddress, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: textColor, height: 1.4))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Icon(icon, color: Colors.white, size: 20),
  );

  Widget _buildInfoItem(String label, String value, Color textColor, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: Colors.grey[600]), const SizedBox(width: 6)],
            Expanded(child: Text(value.isEmpty ? 'N/A' : value, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ],
    );
  }

  Widget _buildAttemptCounter(Color cardColor, Color primaryBlue) {
    int max = currentStage == 'site visit' ? 10 : 5;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Communication Attempts", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text("$attemptCounter / $max", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Broker Notes", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            const Icon(Icons.history, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _noteHistory.length > 3 ? 3 : _noteHistory.length,
          itemBuilder: (context, index) {
            final note = _noteHistory[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                      if (index != (_noteHistory.length > 3 ? 2 : _noteHistory.length - 1))
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note['note']!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(note['date']!, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: noteController,
                  decoration: const InputDecoration(hintText: "Add a new note...", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                ),
              ),
              IconButton(onPressed: _addNoteToHistory, icon: const Icon(Icons.send, color: Colors.blue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuspectingActions(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Call Outcome", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildActionTile(Icons.call_missed, Colors.orange, "Called, Not Connected", "Switch off / Busy / No Answer.", () => _showNotConnectedSheet()),
        _buildActionTile(Icons.thumb_down_off_alt, Colors.red, "Not Interested", "Client declined.", () => _showNotInterestedSheet()),
        _buildActionTile(Icons.psychology, primaryBlue, "Thinking / Interested", "Needs time or info.", () => _showInterestedSheet()),
        _buildActionTile(Icons.location_on, Colors.amber.shade700, "Schedule Site Visit", "Wants to see property.", () => _showSiteVisitSheet()),
      ],
    );
  }

  Widget _buildProspectingInfo(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (visitDate != null) _buildReminderBanner(),
        if (selectedProperty != null) _buildClickablePropertyCard(selectedProperty!),
        const SizedBox(height: 24),
        _buildNoteHistorySection(),
        const SizedBox(height: 24),
        Text("Update Status", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildActionTile(Icons.call_missed, Colors.orange, "Called, Not Connected", "Increment attempt & set reminder", () => _showNotConnectedSheet()),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showNotInterestedSheet(),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Dead Lead"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showSiteVisitSheet(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Schedule Visit", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSiteVisitInfo(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Meetup Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(visitDate ?? "Scheduled", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(meetingPoint ?? "Meeting Point Unset", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (selectedProperty != null) _buildClickablePropertyCard(selectedProperty!),
        const SizedBox(height: 16),
        _buildNoteHistorySection(),
        const SizedBox(height: 24),

        _buildActionTile(Icons.call_missed, Colors.orange, "Called, Not Connected", "Switch off / Busy / No Answer.", () => _showNotConnectedSheet()),
        const SizedBox(height: 10),
        _buildActionTile(Icons.refresh, Colors.blue, "Reschedule Visit", "Select new date and time.", () => _showSiteVisitSheet()),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _updateStageInDb("booking"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Visit Successful - Proceed to Booking", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: () => _showNotInterestedSheet(),
            child: const Text("Not Interested (Dead Lead)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ======================================================================
  // BOOKING FLOW
  // ======================================================================
  Widget _buildBookingFlow(Color primaryBlue, Color cardColor) {
    if (widget.isAdmin) {
      return _buildAdminTokenCollectionFlow();
    } else {
      return _buildAdvisorDocumentUploadFlow(primaryBlue);
    }
  }

  Widget _buildAdminTokenCollectionFlow() {
    if (_isDealVerified) return _buildVerifiedDealView();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
          child: const Row(children: [Icon(Icons.admin_panel_settings, color: Colors.orange), SizedBox(width: 12), Expanded(child: Text("Admin Action: Verify documents and collect initial token.", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))]),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: TextField(controller: _tokenAmountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Token Amount (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _paymentMode, decoration: InputDecoration(labelText: 'Mode', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                items: ['Online', 'Cash', 'Cheque'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _paymentMode = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Consumer<AdminDealProvider>(
            builder: (context, dealProvider, child) {
              return SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton.icon(
                  onPressed: dealProvider.isSaving ? null : () async {
                    if (_tokenAmountCtrl.text.isEmpty) return;
                    final success = await dealProvider.initiateDeal(
                      clientName: _currentLead.clientName, clientNumber: _currentLead.clientNumber,
                      advisorCode: _currentLead.advisorCode, tokenAmount: _tokenAmountCtrl.text, paymentMode: _paymentMode,
                    );
                    if (success) {
                      await _updateStageInDb('booking', note: "Admin verified. Token received via $_paymentMode.");
                      setState(() { _isDealVerified = true; _generatedTokenId = "TKN-${Random().nextInt(9999)}"; });
                    }
                  },
                  icon: dealProvider.isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.verified, color: Colors.white),
                  label: Text(dealProvider.isSaving ? "Processing..." : "Verify & Create Deal", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              );
            }
        ),
      ],
    );
  }

  Widget _buildAdvisorDocumentUploadFlow(Color primaryBlue) {
    if (_isPendingVerification) return _buildPendingVerificationView();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Client Documentation", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Collect documents and submit to the Admin for Token Verification & Deal Creation.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        TextField(controller: _aadhaarController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Aadhaar Number', prefixIcon: const Icon(Icons.badge), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
        const SizedBox(height: 16),
        TextField(controller: _panController, decoration: InputDecoration(labelText: 'PAN Number', prefixIcon: const Icon(Icons.credit_card), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (_aadhaarController.text.isEmpty || _panController.text.isEmpty) return;
              await _updateStageInDb('booking', note: "Documents submitted. Pending Admin verification.");
              setState(() => _isPendingVerification = true);
            },
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text("Submit to Admin", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedDealView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Deal Verified & Tokenized", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
            ],
          ),
          const Divider(height: 30),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Token ID", style: TextStyle(color: Colors.grey)),
                Text("#$_generatedTokenId", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Amount", style: TextStyle(color: Colors.grey)),
                Text("₹ ${_tokenAmountCtrl.text}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _triggerLocalNotification("Download Started", "Receipt $_generatedTokenId saving..."),
              icon: const Icon(Icons.download, size: 18),
              label: const Text("Download Receipt"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                DealModel newDeal = DealModel(
                    id: int.parse(_currentLead.id),
                    clientName: _currentLead.clientName,
                    clientNumber: _currentLead.clientNumber,
                    clientEmail: _emailController.text,
                    clientAdharFront: '',
                    propertyId: selectedPropertyId ?? 0,
                    isResale: false,
                    notes: '',
                    dealStatus: 'verified',
                    paymentMode: _paymentMode,
                    paymentStatus: 'Pending',
                    createdAt: DateTime.now().toString(),
                    propertyDocs: [],
                    installments: []
                );

                Navigator.push(context, MaterialPageRoute(builder: (_) => DealManagementScreen(deal: newDeal, isReraApproved: false)));
              },
              icon: const Icon(Icons.tune, color: Colors.white),
              label: const Text("Configure Payment Plan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVerificationView() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 1), borderRadius: BorderRadius.circular(12), color: Colors.orange.withOpacity(0.1)),
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.timer, color: Colors.orange, size: 40),
          SizedBox(height: 20),
          Text("Pending Verification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Manager is reviewing documents and collecting token...", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRejectionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.report, color: Colors.grey, size: 20), SizedBox(width: 8), Text("Lead Closed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))]),
          const SizedBox(height: 8),
          Text(rejectionReason ?? _currentLead.reason, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // ======================================================================
  // BOTTOM SHEETS
  // ======================================================================
  Widget _buildActionTile(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildClickablePropertyCard(String propName) {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), image: const DecorationImage(image: AssetImage("assets/images/logos.png"), fit: BoxFit.cover))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Interested Property", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(propName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))])),
        ],
      ),
    );
  }

  Widget _buildReminderBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12), width: double.infinity, decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
      child: Row(children: [const Icon(Icons.alarm, size: 16, color: Colors.amber), const SizedBox(width: 8), Expanded(child: Text("Follow-up: $visitDate", style: const TextStyle(fontSize: 12, color: Colors.brown)))]),
    );
  }

  Future<String?> _showDateTimePicker(BuildContext context) async {
    DateTime tempDate = DateTime.now();
    TimeOfDay tempTime = TimeOfDay.now();
    return showModalBottomSheet<String>(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: 550, padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close))]),
              Expanded(child: CalendarDatePicker(initialDate: tempDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), onDateChanged: (d) => setSheetState(() => tempDate = d))),
              InkWell(
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: tempTime);
                  if (t != null) setSheetState(() => tempTime = t);
                },
                child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Time:", style: TextStyle(fontWeight: FontWeight.bold)), Text(tempTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))])),
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { String f = "${tempDate.year}-${tempDate.month.toString().padLeft(2, '0')}-${tempDate.day.toString().padLeft(2, '0')} ${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}:00"; Navigator.pop(ctx, f); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text("Confirm", style: TextStyle(color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotConnectedSheet() {
    String? localReminder;
    String? selectedReason;
    final List<String> reasons = ["Switch Off", "Busy", "Not Answered", "Call Later", "Network Issue"];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle), child: const Icon(Icons.call_missed, color: Colors.orange)), const SizedBox(width: 12), const Text("Call Not Connected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              const Text("Select Reason", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: reasons.map((reason) {
                  bool isSelected = selectedReason == reason;
                  return ChoiceChip(label: Text(reason), selected: isSelected, onSelected: (val) => setSheetState(() => selectedReason = val ? reason : null), selectedColor: Colors.blue, backgroundColor: Colors.white, labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87));
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text("Follow-up Reminder (Optional)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async { String? r = await _showDateTimePicker(context); if (r != null) setSheetState(() => localReminder = r); },
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Row(children: [const Icon(Icons.alarm, size: 20, color: Colors.blue), const SizedBox(width: 12), Text(localReminder ?? "Set Date & Time", style: TextStyle(color: localReminder != null ? Colors.black87 : Colors.grey, fontWeight: localReminder != null ? FontWeight.bold : FontWeight.normal))])),
              ),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: () { if (selectedReason == null) return; visitDate = localReminder; _incrementAttemptAndCheck(selectedReason!); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Save & Update Counter", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  void _showSiteVisitSheet() {
    String? localSelectedProp = selectedProperty;
    String? localVisitDate;
    TextEditingController meetingPointCtrl = TextEditingController(text: meetingPoint);

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle), child: const Icon(Icons.location_on, color: Colors.orange)), const SizedBox(width: 12), const Text("Schedule Site Visit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              const Text("Select Property", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 8),
              InkWell(
                onTap: () => _showCascadedPropertySheet((prop, unitId) => setSheetState((){ localSelectedProp = prop; selectedPropertyId = unitId; })),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Row(children: [const Icon(Icons.apartment, color: Colors.blue, size: 20), const SizedBox(width: 12), Expanded(child: Text(localSelectedProp ?? "Select Project & Unit", style: TextStyle(fontWeight: localSelectedProp != null ? FontWeight.bold : FontWeight.normal, color: localSelectedProp != null ? Colors.black87 : Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)), const Icon(Icons.arrow_drop_down, color: Colors.grey)])),
              ),
              const SizedBox(height: 16),
              const Text("Date & Time", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 8),
              InkWell(
                onTap: () async { String? t = await _showDateTimePicker(context); if (t != null) setSheetState(() => localVisitDate = t); },
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Row(children: [const Icon(Icons.calendar_month, color: Colors.orange, size: 20), const SizedBox(width: 12), Text(localVisitDate ?? "Select Date & Time", style: TextStyle(fontWeight: localVisitDate != null ? FontWeight.bold : FontWeight.normal, color: localVisitDate != null ? Colors.black87 : Colors.grey)), const Spacer(), const Icon(Icons.arrow_drop_down, color: Colors.grey)])),
              ),
              const SizedBox(height: 16),
              TextField(controller: meetingPointCtrl, decoration: const InputDecoration(labelText: "Meeting Point (Optional)", border: OutlineInputBorder())),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (localSelectedProp == null || localVisitDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Property and Date.')));
                      return;
                    }

                    selectedProperty = localSelectedProp;
                    visitDate = localVisitDate;
                    meetingPoint = meetingPointCtrl.text;

                    bool isReschedule = (currentStage == 'site visit');

                    if (isReschedule) {
                      setState(() => attemptCounter++);
                      if (attemptCounter >= 10) {
                        setState(() { currentStage = 'closed'; rejectionReason = "Max attempts (10) reached during reschedule."; });
                        _updateStageInDb('closed', note: "System Auto-Closed: Max attempts (10) reached while rescheduling.");
                        Navigator.pop(ctx);
                        _triggerLocalNotification("Lead Closed Automatically", "Maximum communication attempts (10) reached.");
                        return;
                      }
                    } else {
                      setState(() => attemptCounter = 0);
                    }

                    String noteText = isReschedule
                        ? "Rescheduled visit for $visitDate at $selectedProperty. Meeting point: $meetingPoint"
                        : "Scheduled visit for $visitDate at $selectedProperty. Meeting point: $meetingPoint";

                    _updateStageInDb("site visit", note: noteText);
                    Navigator.pop(ctx);

                    _triggerLocalNotification(isReschedule ? "Visit Rescheduled" : "Visit Scheduled", "With client at $localSelectedProp");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Confirm Visit", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotInterestedSheet() {
    String? selectedReason;
    final List<String> reasons = ["Already bought", "Just browsing", "Budget Issue", "Location Issue", "Others"];
    TextEditingController notesCtrl = TextEditingController();
    showModalBottomSheet(
      backgroundColor: Colors.white, context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Mark as Not Interested", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedReason, items: reasons.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setSheetState(() => selectedReason = v), decoration: const InputDecoration(labelText: "Reason", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: "Notes", border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedReason == null) return;
                    rejectionReason = "$selectedReason - ${notesCtrl.text}";
                    _updateStageInDb("closed", note: "Not Interested: $rejectionReason");
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Confirm Dead Lead", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInterestedSheet() {
    String? localProp = selectedProperty;
    String? localReminder;
    TextEditingController localNoteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: const Icon(Icons.psychology, color: Colors.blue)), const SizedBox(width: 12), const Text("Mark as Interested", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _showCascadedPropertySheet((prop, unitId) => setSheetState(() { localProp = prop; selectedPropertyId = unitId; })),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Row(children: [const Icon(Icons.apartment, color: Colors.blue, size: 20), const SizedBox(width: 12), Expanded(child: Text(localProp ?? "Select Project & Unit", style: TextStyle(fontWeight: localProp != null ? FontWeight.bold : FontWeight.normal, color: localProp != null ? Colors.black87 : Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), const Icon(Icons.arrow_drop_down, color: Colors.grey)])),
              ),
              const SizedBox(height: 16),
              TextField(controller: localNoteCtrl, maxLines: 2, decoration: const InputDecoration(hintText: "Add Broker Note...", fillColor: Color(0xFFF8FAFC), filled: true, border: OutlineInputBorder(borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async { String? t = await _showDateTimePicker(context); if (t != null) setSheetState(() => localReminder = t); },
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.alarm, size: 18, color: Colors.blue), const SizedBox(width: 12), Text(localReminder ?? "Set Follow-up Reminder", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)), const Spacer(), if (localReminder == null) const Icon(Icons.add, size: 16, color: Colors.blue)])),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    attemptCounter = 0;
                    selectedProperty = localProp;
                    visitDate = localReminder;
                    noteController.text = localNoteCtrl.text;
                    _updateStageInDb("prospecting", note: "Marked Interested for $localProp. Note: ${localNoteCtrl.text}");
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Move to Prospecting", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditLeadSheet() {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => _EditLeadForm(
        lead: _currentLead, primaryBlue: primaryBlue, isAdmin: widget.isAdmin,
        onSuccess: (updatedLead) {
          setState(() { _currentLead = updatedLead; });
        },
      ),
    );
  }
}

// ======================================================================
// EDIT LEAD FORM (THE NEW BOTTOM SHEET)
// ======================================================================
class _EditLeadForm extends StatefulWidget {
  final LeadModel lead;
  final Color primaryBlue;
  final bool isAdmin;
  final Function(LeadModel) onSuccess;

  const _EditLeadForm({required this.lead, required this.primaryBlue, required this.isAdmin, required this.onSuccess});

  @override
  State<_EditLeadForm> createState() => _EditLeadFormState();
}

class _EditLeadFormState extends State<_EditLeadForm> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _occCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _category = 'A';
  String _potential = 'Warm';
  String _ownsHouse = 'No';
  String _decisionMaker = 'No';

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.lead.clientName;
    _phoneCtrl.text = widget.lead.clientNumber;
    _ageCtrl.text = widget.lead.clientAge == 'N/A' ? '' : widget.lead.clientAge;
    _occCtrl.text = widget.lead.clientOccupation == 'N/A' ? '' : widget.lead.clientOccupation;
    _incomeCtrl.text = widget.lead.annualIncome == 'N/A' ? '' : widget.lead.annualIncome;
    _addressCtrl.text = widget.lead.clientAddress == 'N/A' ? '' : widget.lead.clientAddress;

    if (['A', 'B', 'C'].contains(widget.lead.leadCategory.toUpperCase())) {
      _category = widget.lead.leadCategory.toUpperCase();
    }
    if (['Hot', 'Warm', 'Cold'].contains(widget.lead.leadPotential)) {
      _potential = widget.lead.leadPotential;
    }
    _ownsHouse = (widget.lead.ownsHouse == '1' || widget.lead.ownsHouse.toLowerCase() == 'yes') ? 'Yes' : 'No';
    _decisionMaker = widget.lead.keyDecisionMaker ? 'Yes' : 'No';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _ageCtrl.dispose();
    _occCtrl.dispose(); _incomeCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Update Client Details', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildTextField('Client Name', _nameCtrl)), const SizedBox(width: 16), Expanded(child: _buildTextField('Phone Number', _phoneCtrl, isNumber: true))]),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildTextField('Age', _ageCtrl, isNumber: true)), const SizedBox(width: 16), Expanded(child: _buildTextField('Occupation', _occCtrl))]),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildTextField('Annual Income', _incomeCtrl)), const SizedBox(width: 16), Expanded(child: _buildDropdown('Decision Maker?', _decisionMaker, ['Yes', 'No'], (v) => setState(() => _decisionMaker = v!)))]),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildDropdown('Category', _category, ['A', 'B', 'C'], (v) => setState(() => _category = v!))), const SizedBox(width: 16), Expanded(child: _buildDropdown('Potential', _potential, ['Hot', 'Warm', 'Cold'], (v) => setState(() => _potential = v!)))]),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildDropdown('Owns House?', _ownsHouse, ['Yes', 'No'], (v) => setState(() => _ownsHouse = v!))), const SizedBox(width: 16), const Expanded(child: SizedBox())]),
                  const SizedBox(height: 16),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _buildTextField('Full Address', _addressCtrl, maxLines: 2))]),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final data = {
                          "client_name": _nameCtrl.text,
                          "client_number": _phoneCtrl.text,
                          "source": widget.lead.source,
                          "client_age": _ageCtrl.text,
                          "client_occupation": _occCtrl.text,
                          "lead_category": _category,
                          "lead_potential": _potential,
                          "client_address": _addressCtrl.text,
                          "owns_house": _ownsHouse == 'Yes' ? 1 : 0,
                          "annual_income": _incomeCtrl.text,
                          "key_decision_maker": _decisionMaker == 'Yes' ? 1 : 0,
                        };

                        bool success = false;
                        if (widget.isAdmin) {
                          final provider = context.read<AdminLeadProvider>();
                          success = await provider.updateLeadStage(widget.lead.id, widget.lead.stage, extraData: data);
                        } else {
                          final provider = context.read<AdvisorLeadProvider>();
                          final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode ?? '';
                          success = await provider.updateLeadStage(widget.lead.id, widget.lead.stage, advisorCode, extraData: data);
                        }

                        if (success && mounted) {
                          LeadModel updatedLead = LeadModel(
                            id: widget.lead.id, clientName: _nameCtrl.text, clientNumber: _phoneCtrl.text, advisorCode: widget.lead.advisorCode, source: widget.lead.source, clientAge: _ageCtrl.text, clientOccupation: _occCtrl.text, leadCategory: _category, leadPotential: _potential, clientAddress: _addressCtrl.text, ownsHouse: _ownsHouse, annualIncome: _incomeCtrl.text, keyDecisionMaker: _decisionMaker == 'Yes', isPriority: widget.lead.isPriority, siteVisitPhoto: widget.lead.siteVisitPhoto, stage: widget.lead.stage, propertyId: widget.lead.propertyId, callOutCome: widget.lead.callOutCome, reason: widget.lead.reason, notes: widget.lead.notes, reminder: widget.lead.reminder, meetingPoint: widget.lead.meetingPoint, communicationAttempt: widget.lead.communicationAttempt, createdAt: widget.lead.createdAt, updatedAt: widget.lead.updatedAt,
                          );
                          widget.onSuccess(updatedLead);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client details updated successfully!')));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: widget.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text('Save Changes', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        const SizedBox(height: 6),
        TextField(
          controller: controller, maxLines: maxLines, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.montserrat(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), filled: true, fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey), style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}