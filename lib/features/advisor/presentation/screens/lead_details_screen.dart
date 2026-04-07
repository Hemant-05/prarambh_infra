import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:prarambh_infra/core/utils/file_download_helper.dart';

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
import 'advisor_unit_details_screen.dart';
import '../providers/advisor_lead_provider.dart';
import '../../../advisor/presentation/screens/lead_notes_full_screen.dart';

class LeadDetailsScreen extends StatefulWidget {
  final LeadModel lead;
  final bool isAdmin;

  const LeadDetailsScreen({
    super.key,
    required this.lead,
    required this.isAdmin,
  });

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  late LeadModel _currentLead;
  late String currentStage;
  late int attemptCounter;
  String? rejectionReason;

  // Priority toggle
  late bool _isPriorityToggle;

  // Selected property state (full objects for rich display)
  UnitModel? _selectedUnit;
  ProjectModel? _selectedProject;

  String? selectedProperty;
  int? selectedPropertyId; // Now specifically used as Project ID
  int? selectedUnitId; // New field for Unit ID
  String? visitDate;
  String? meetingPoint;

  // Booking State Variables
  final bool _isPendingVerification = false;
  final bool _isDealVerified = false;
  String? _generatedTokenId;
  final TextEditingController _tokenAmountCtrl = TextEditingController();
  final String _paymentMode = 'Online';

  final TextEditingController noteController = TextEditingController();
  final List<Map<String, String>> _noteHistory = [];

  File? _adharFront;
  File? _adharBack;
  File? _panFront;
  File? _panBack;

  final TextEditingController _emailController = TextEditingController();

  Future<void> _pickDocument(String type) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        if (type == 'AF') {
          _adharFront = File(image.path);
        } else if (type == 'AB')
          _adharBack = File(image.path);
        else if (type == 'PF')
          _panFront = File(image.path);
        else if (type == 'PB')
          _panBack = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
    currentStage = _currentLead.stage.toLowerCase();
    attemptCounter = _currentLead.communicationAttempt;
    _isPriorityToggle = _currentLead.isPriority;
    selectedProperty = _currentLead.unitId > 0
        ? "Unit ID: ${_currentLead.unitId}"
        : null;
    selectedPropertyId = _currentLead.propertyId > 0
        ? _currentLead.propertyId
        : null;
    selectedUnitId = _currentLead.unitId > 0 ? _currentLead.unitId : null;
    visitDate = _currentLead.reminder.isNotEmpty ? _currentLead.reminder : null;
    meetingPoint = _currentLead.meetingPoint.isNotEmpty
        ? _currentLead.meetingPoint
        : null;

    if (_currentLead.notes.isNotEmpty) {
      _parseLeadNotes(_currentLead.notes);
      // Sort history to ensure latest is always on top
      _noteHistory.sort((a, b) {
        final d1 = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final d2 = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return d2.compareTo(d1);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (selectedUnitId != null && selectedUnitId! > 0) {
        try {
          final provider = context.read<AdminProjectProvider>();
          final unit = await provider.getUnitDetails(selectedUnitId.toString());

          ProjectModel? proj;
          try {
            proj = await provider.getProjectDetails(unit.projectId.toString());
          } catch (_) {
            // Fallback to searching in list if single fetch fails
            if (provider.projects.isEmpty) {
              await provider.fetchProjects();
            }
            try {
              proj = provider.projects.firstWhere(
                (p) => p.id == unit.projectId,
              );
            } catch (_) {}
          }

          if (mounted) {
            setState(() {
              _selectedUnit = unit;
              if (proj != null) {
                _selectedProject = proj;
                selectedProperty =
                    "${proj.projectName} (${unit.towerName} - ${unit.unitNumber})";
              } else {
                selectedProperty = "Unit ID: ${unit.id}";
              }
            });
          }
        } catch (e) {
          debugPrint('Error fetching property data: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    _emailController.dispose();
    _tokenAmountCtrl.dispose();
    super.dispose();
  }

  // ======================================================================
  // ACTIONS & CORE LOGIC
  // ======================================================================
  Future<void> _launchWhatsApp() async {
    String message;
    if (_selectedUnit != null && _selectedProject != null) {
      final unit = _selectedUnit!;
      final project = _selectedProject!;
      final price = unit.calculatedPrice;
      final priceStr = price >= 10000000
          ? '₹${(price / 10000000).toStringAsFixed(2)} Cr'
          : price >= 100000
          ? '₹${(price / 100000).toStringAsFixed(2)} L'
          : '₹${price.toStringAsFixed(0)}';
      message =
          """🏠 *Property Detail from Prarambh Infra*

Project: ${project.projectName}
Unit: ${unit.towerName} - ${unit.unitNumber}
Configuration: ${unit.configuration}
Floor: ${unit.floorNumber}
Facing: ${unit.facing}
Area: ${unit.areaSqft.toStringAsFixed(0)} sq.ft
💰 Price: $priceStr

Please feel free to contact us for more information.""";
    } else if (selectedProperty != null) {
      message =
          "Hello! Here are the details for $selectedProperty as discussed.";
    } else {
      message =
          "Hello! Greetings from Prarambh Infra. How can we help you today?";
    }

    final Uri url = Uri.parse(
      "https://wa.me/91${_currentLead.clientNumber}?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _togglePriority() async {
    final newPriority = !_isPriorityToggle;
    setState(() => _isPriorityToggle = newPriority);
    final extraData = {
      'is_priority': newPriority ? 1 : 0,
      'communication_attempt': attemptCounter,
      'property_id':
          _selectedProject?.id.toString() ??
          selectedPropertyId?.toString() ??
          '0',
      'unit_id':
          _selectedUnit?.id.toString() ?? selectedUnitId?.toString() ?? '0',
      'reminder': visitDate ?? '',
      'meeting_point': meetingPoint ?? '',
    };
    bool success = false;
    if (widget.isAdmin) {
      success = await context.read<AdminLeadProvider>().updateLeadStage(
        _currentLead.id,
        currentStage,
        extraData: extraData,
      );
    } else {
      final advisorCode =
          context.read<AuthProvider>().currentUser?.advisorCode ?? '';
      success = await context.read<AdvisorLeadProvider>().updateLeadStage(
        _currentLead.id,
        currentStage,
        advisorCode,
        extraData: extraData,
      );
    }
    if (!success && mounted) setState(() => _isPriorityToggle = !newPriority);
  }

  Future<void> _launchDialer() async {
    final Uri url = Uri.parse("tel:+91${_currentLead.clientNumber}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open Dialer')));
      }
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryBlue(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 18,
                  ),
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

  Future<void> _updateStageInDb(
    String newStage, {
    String? note,
    String? reason,
  }) async {
    if (note != null) {
      setState(() {
        _noteHistory.insert(0, {
          "date": DateTime.now().toString().split('.')[0],
          "note": note,
        });
      });
    }

    final extraData = {
      "communication_attempt": attemptCounter,
      "property_id":
          _selectedProject?.id.toString() ??
          selectedPropertyId?.toString() ??
          '0',
      "unit_id":
          _selectedUnit?.id.toString() ?? selectedUnitId?.toString() ?? '0',
      "reminder": visitDate ?? '',
      "meeting_point": meetingPoint ?? '',
      "reason": reason ?? rejectionReason ?? '',
    };

    if (note != null && note.isNotEmpty) {
      extraData["notes"] = jsonEncode(_noteHistory);
    }

    bool success = false;

    // THE FIX: Switch between Admin and Advisor provider based on role
    if (widget.isAdmin) {
      final provider = context.read<AdminLeadProvider>();
      success = await provider.updateLeadStage(
        _currentLead.id,
        newStage,
        extraData: extraData,
      );
    } else {
      final provider = context.read<AdvisorLeadProvider>();
      final authProvider = context.read<AuthProvider>();
      final advisorCode = authProvider.currentUser?.advisorCode ?? '';
      success = await provider.updateLeadStage(
        _currentLead.id,
        newStage,
        advisorCode,
        extraData: extraData,
      );
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
      _updateStageInDb(
        'closed',
        reason:
            "System Auto-Closed: Max attempts reached ($maxAttempts). Last Reason: $reason",
        note: "System Auto-Closed: Max attempts reached.",
      );
      _triggerLocalNotification(
        "Lead Closed Automatically",
        "Maximum communication attempts ($maxAttempts) reached.",
      );
    } else {
      _updateStageInDb(currentStage, note: "Call not connected: $reason");
    }
  }

  Future<void> _addNoteToHistory() async {
    if (noteController.text.isNotEmpty) {
      String newNote = noteController.text;
      noteController.clear();

      setState(() {
        _noteHistory.insert(0, {
          "date": DateTime.now().toString().split('.')[0],
          "note": newNote,
        });
      });

      bool success = false;
      if (widget.isAdmin) {
        success = await context.read<AdminLeadProvider>().addLeadNote(
          _currentLead.id,
          newNote,
          DateTime.now().toString(),
        );
      } else {
        final advisorCode =
            context.read<AuthProvider>().currentUser?.advisorCode ?? '';
        success = await context.read<AdvisorLeadProvider>().addLeadNote(
          _currentLead.id,
          newNote,
          DateTime.now().toString(),
          advisorCode,
          currentStage,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? "Note added successfully"
                  : "Failed to add note on server",
            ),
          ),
        );
      }
    }
  }

  void _showCascadedPropertySheet(
    Function(String, int, UnitModel, ProjectModel) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PropertyBrowserSheet(onSelect: onSelect),
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
    if (currentStage == "booking" || currentStage == "pending_verification") {
      statusColor = Colors.green;
    }
    if (currentStage == "completed") {
      statusColor = Colors.green.shade700;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: backButton(isDark: isDark),
        title: Text(
          'Client Pipeline',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentStage == 'closed'
                  ? 'DEAD LEAD'
                  : currentStage == 'completed'
                  ? 'COMPLETED'
                  : currentStage.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClientInfoCard(cardColor, primaryBlue, textColor),
                const SizedBox(height: 24),

                if ([
                  'suspecting',
                  'prospecting',
                  'site visit',
                ].contains(currentStage))
                  _buildAttemptCounter(cardColor, primaryBlue),

                if (currentStage == "suspecting")
                  _buildSuspectingActions(primaryBlue),
                if (currentStage == "closed") _buildRejectionInfo(),

                // Unified Sections: Property & Notes (Shown if property exists or for all stages)
                if (selectedPropertyId != null)
                _buildClickablePropertyCard(selectedProperty!),

                _buildNoteHistorySection(),
                const SizedBox(height: 24),

                if (currentStage == "prospecting")
                  _buildProspectingInfo(primaryBlue),
                if (currentStage == "site visit")
                  _buildSiteVisitInfo(primaryBlue),
                if (currentStage == "booking" ||
                    currentStage == "pending_verification")
                  _buildBookingFlow(primaryBlue, cardColor),
                if (currentStage == "completed") _buildCompletedView(isDark),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ======================================================================
  // Robust Recursive Note Parsing
  // ======================================================================
  void _parseLeadNotes(String raw) {
    if (raw.isEmpty || raw == '[]' || raw == 'null') return;

    // Clean up basic string artifacts if any
    String cleaned = raw.trim();
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).replaceAll(r'\"', '"');
    }

    try {
      // 1. Try Standard JSON Decoding
      final decoded = jsonDecode(cleaned);
      if (decoded is List) {
        for (var item in decoded) {
          if (item is Map) {
            String note = (item['note'] ?? item['title'] ?? '').toString();
            String date = (item['date'] ?? item['time'] ?? '').toString();

            // If the note itself looks like trapped JSON, parse it recursively
            if (note.contains('{') &&
                (note.contains('note:') || note.contains('title:'))) {
              _parseLeadNotes(note);
            } else if (note.isNotEmpty) {
              _addUniqueNote(note, date);
            }
          }
        }
        return;
      }
    } catch (_) {
      // 2. Fallback to Regex for malformed unquoted strings
      final regex = RegExp(
        r'\{(?:note|title|date|time):\s*(.*?)\s*,\s*(?:note|title|date|time):\s*(.*?)\s*\}',
      );
      final matches = regex.allMatches(cleaned);

      if (matches.isNotEmpty) {
        for (var match in matches) {
          String val1 = match.group(1)?.trim() ?? '';
          String val2 = match.group(2)?.trim() ?? '';
          String matchText = match.group(0)!;

          String note = '';
          String date = '';

          if (matchText.contains('note:')) {
            if (matchText.indexOf('note:') < matchText.indexOf('date:')) {
              note = val1;
              date = val2;
            } else {
              note = val2;
              date = val1;
            }
          } else if (matchText.contains('title:')) {
            if (matchText.indexOf('title:') < matchText.indexOf('time:')) {
              note = val1;
              date = val2;
            } else {
              note = val2;
              date = val1;
            }
          }

          if (note.contains('{')) {
            _parseLeadNotes(note);
          } else if (note.isNotEmpty) {
            _addUniqueNote(note, date);
          }
        }
        return;
      }
    }

    if (cleaned.isNotEmpty && cleaned != '[]') {
      _addUniqueNote(cleaned, _currentLead.createdAt);
    }
  }

  void _addUniqueNote(String note, String date) {
    if (note.trim().isEmpty) return;
    // Basic de-duplication
    final alreadyExists = _noteHistory.any(
      (n) => n['note'] == note && n['date'] == date,
    );
    if (!alreadyExists) {
      _noteHistory.add({"note": note, "date": date});
    }
  }

  String _formatNoteDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Recent';
      final parts = dateStr.split(' ');
      if (parts.length >= 2) {
        // Handle YYYY-MM-DD HH:MM:SS
        final dateObj = DateTime.tryParse(dateStr);
        if (dateObj != null) {
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          String hour = dateObj.hour > 12
              ? (dateObj.hour - 12).toString()
              : dateObj.hour.toString();
          if (hour == '0') hour = '12';
          final ampm = dateObj.hour >= 12 ? 'PM' : 'AM';
          final minute = dateObj.minute.toString().padLeft(2, '0');
          return '${months[dateObj.month - 1]} ${dateObj.day}, $hour:$minute $ampm';
        }
      }
      return dateStr; // Fallback to raw string
    } catch (_) {
      return dateStr;
    }
  }


  // ======================================================================
  // NEW SITE VISIT FEATURES: PHOTO & LOCATION
  // ======================================================================
  Future<void> _pickAndUploadSiteVisitPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final file = File(image.path);
        bool success = false;

        final data = {
          'site_visit_photo': await MultipartFile.fromFile(file.path),
        };

        if (widget.isAdmin) {
          success = await context.read<AdminLeadProvider>().updateLeadStage(
            _currentLead.id,
            currentStage,
            extraData: data,
          );
        } else {
          final advisorCode =
              context.read<AuthProvider>().currentUser?.advisorCode ?? '';
          success = await context.read<AdvisorLeadProvider>().updateLeadStage(
            _currentLead.id,
            currentStage,
            advisorCode,
            extraData: data,
          );
        }

        if (success) {
          // Sync with updated provider state to get the new photo URL
          final updatedLeads = context.read<AdvisorLeadProvider>().leads;
          final freshLead = updatedLeads.firstWhere(
            (l) => l.id == _currentLead.id,
            orElse: () => _currentLead,
          );

          setState(() {
            _currentLead = freshLead;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo uploaded successfully!')),
            );
          }
        }
      } catch (e) {
        debugPrint('Upload Photo Error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showEditLocationDialog() {
    final ctrl = TextEditingController(text: meetingPoint);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Meeting Point"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: "Enter meetup location"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newLoc = ctrl.text.trim();
              if (newLoc.isEmpty) return;

              Navigator.pop(ctx);
              setState(() => meetingPoint = newLoc);
              await _updateStageInDb(
                currentStage,
                note: "Updated location to: $newLoc",
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  bool _isLoading = false;

  // ======================================================================
  // VISUAL COMPONENTS
  // ======================================================================
  Widget _buildClientInfoCard(
    Color cardColor,
    Color primaryBlue,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.5)),
      ),
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
                      Text(
                        _currentLead.clientName,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+91 ${_currentLead.clientNumber}',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Source: ${_currentLead.source}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _togglePriority,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _isPriorityToggle
                                    ? Colors.amber.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: _isPriorityToggle
                                    ? Border.all(color: Colors.amber.shade300)
                                    : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isPriorityToggle
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: _isPriorityToggle
                                        ? Colors.amber
                                        : Colors.grey.shade600,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Priority",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _isPriorityToggle
                                          ? Colors.amber.shade700
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _showEditLeadSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryBlue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: primaryBlue,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Edit Details",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _launchDialer,
                      child: _buildCircleAction(Icons.call, Colors.green),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _launchWhatsApp,
                      child: _buildCircleAction(
                        Icons.message,
                        const Color(0xFF25D366),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              title: Text(
                'PERSONAL INFORMATION',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              'Potential',
                              _currentLead.leadPotential,
                              textColor,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _currentLead.leadCategory,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              'Age',
                              _currentLead.clientAge != 'N/A'
                                  ? '${_currentLead.clientAge} Yrs'
                                  : 'N/A',
                              textColor,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              'Occupation',
                              _currentLead.clientOccupation,
                              textColor,
                              icon: Icons.work,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              'Annual Income',
                              _currentLead.annualIncome,
                              textColor,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              'Owns House',
                              _currentLead.ownsHouse == '1' ? 'Yes' : 'No',
                              textColor,
                              icon: Icons.home,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Decision Maker',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      _currentLead.keyDecisionMaker
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: _currentLead.keyDecisionMaker
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _currentLead.keyDecisionMaker
                                          ? 'Yes'
                                          : 'No',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (selectedUnitId != null && selectedUnitId! > 0) ...[
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Project',
                                _selectedProject?.projectName ?? 'Loading...',
                                textColor,
                                icon: Icons.apartment,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Unit (Block - No)',
                                _selectedUnit != null
                                    ? "${_selectedUnit!.towerName} - ${_selectedUnit!.unitNumber}"
                                    : 'Loading...',
                                textColor,
                                icon: Icons.grid_view_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Text(
                        'Residential Address',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 18, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentLead.clientAddress,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
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

  Widget _buildInfoItem(
    String label,
    String value,
    Color textColor, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                value.isEmpty ? 'N/A' : value,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Communication Attempts",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$attemptCounter / $max",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteHistorySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final notesToShow = _noteHistory.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sticky_note_2_outlined,
                color: primaryBlue,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Broker Notes',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (_noteHistory.length > 2)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeadNotesFullScreen(
                      lead: _currentLead,
                      noteHistory: _noteHistory,
                    ),
                  ),
                ),
                child: Text(
                  'View All (${_noteHistory.length})',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_noteHistory.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.notes, color: Colors.grey.shade400, size: 28),
                const SizedBox(height: 8),
                Text(
                  'No notes yet. Add your first note below.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...notesToShow.map((note) {
            final index = _noteHistory.indexOf(note);
            final noteColors = [
              Colors.blue,
              Colors.purple,
              Colors.teal,
              Colors.orange,
              Colors.green,
            ];
            final accent = noteColors[index % noteColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey.shade100,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_note, color: accent, size: 20),
                ),
                title: Text(
                  note['note'] ?? '',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatNoteDate(note['date'] ?? ''),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primaryBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: noteController,
                  style: GoogleFonts.montserrat(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Write a note...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: _addNoteToHistory,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                ),
              ),
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
        Text(
          "Call Outcome",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          Icons.call_missed,
          Colors.orange,
          "Called, Not Connected",
          "Switch off / Busy / No Answer.",
          () => _showNotConnectedSheet(),
        ),
        _buildActionTile(
          Icons.thumb_down_off_alt,
          Colors.red,
          "Not Interested",
          "Client declined.",
          () => _showNotInterestedSheet(),
        ),
        _buildActionTile(
          Icons.psychology,
          primaryBlue,
          "Thinking / Interested",
          "Needs time or info.",
          () => _showInterestedSheet(),
        ),
        _buildActionTile(
          Icons.location_on,
          Colors.amber.shade700,
          "Schedule Site Visit",
          "Wants to see property.",
          () => _showSiteVisitSheet(),
        ),
      ],
    );
  }

  Widget _buildCompletedView(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            "Lead Successfully Completed",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.green.shade300 : Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "This lead has successfully transitioned through all stages and is now marked as completed.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProspectingInfo(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (visitDate != null) _buildReminderBanner(),
        const SizedBox(height: 12),
        Text(
          "Update Status",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          Icons.call_missed,
          Colors.orange,
          "Called, Not Connected",
          "Increment attempt & set reminder",
          () => _showNotConnectedSheet(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showNotInterestedSheet(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Dead Lead"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showSiteVisitSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Schedule Visit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSiteVisitInfo(Color primaryBlue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Meetup Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (!widget.isAdmin)
                    GestureDetector(
                      onTap: _showEditLocationDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: primaryBlue, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.alarm, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    visitDate ?? "Scheduled",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meetingPoint ?? "Meeting Point Unset",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Site Visit Photo Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Site Visit Photo",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      if (_currentLead.siteVisitPhoto.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            FileDownloadHelper().downloadFile(
                              context: context,
                              url: _currentLead.siteVisitPhoto,
                              fileName:
                                  "SiteVisit_${_currentLead.clientName.replaceAll(' ', '_')}.jpg",
                            );
                          },
                          icon: Icon(
                            Icons.download_rounded,
                            color: primaryBlue,
                            size: 20,
                          ),
                          tooltip: 'Download Photo',
                        ),
                      if (!widget.isAdmin)
                        IconButton(
                          onPressed: _pickAndUploadSiteVisitPhoto,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: primaryBlue,
                            size: 20,
                          ),
                          tooltip: 'Upload/Change Photo',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_currentLead.siteVisitPhoto.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _currentLead.siteVisitPhoto,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                )
              else if (!widget.isAdmin)
                InkWell(
                  onTap: _pickAndUploadSiteVisitPhoto,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Upload Photo with Client",
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  "No photo uploaded.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildActionTile(
          Icons.call_missed,
          Colors.orange,
          "Called, Not Connected",
          "Switch off / Busy / No Answer.",
          () => _showNotConnectedSheet(),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          Icons.refresh,
          Colors.blue,
          "Reschedule Visit",
          "Select new date and time.",
          () => _showSiteVisitSheet(),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _updateStageInDb("booking"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              "Visit Successful - Proceed to Booking",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: () => _showNotInterestedSheet(),
            child: const Text(
              "Not Interested (Dead Lead)",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.timer, color: Colors.orange, size: 40),
          const SizedBox(height: 20),
          const Text(
            "Deal Verification Pending",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Verify deal & review documents and collecting token...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Text(
              "Go to Deal Section...\nDo the token process",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorDocumentUploadFlow(Color primaryBlue) {
    if (currentStage == 'pending_verification' || _isPendingVerification) {
      return _buildPendingVerificationView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Client Documentation",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Client Email",
            hintText: "Enter client's email address",
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 8),
        const Text(
          "Collect documents and submit to the Admin for Token Verification & Deal Creation.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildDocPickerTile('Aadhar Front', 'AF', _adharFront, primaryBlue),
            _buildDocPickerTile('Aadhar Back', 'AB', _adharBack, primaryBlue),
            _buildDocPickerTile('PAN Front', 'PF', _panFront, primaryBlue),
            _buildDocPickerTile('PAN Back', 'PB', _panBack, primaryBlue),
          ],
        ),
        const SizedBox(height: 30),
        Consumer<AdminDealProvider>(
          builder: (context, dealProvider, child) {
            return SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: dealProvider.isSaving
                    ? null
                    : () async {
                        if (_adharFront == null ||
                            _adharBack == null ||
                            _panFront == null ||
                            _panBack == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload all 4 documents'),
                            ),
                          );
                          return;
                        }

                        // Create the unverified deal with 0 tokens and the 4 docs
                        bool success = await dealProvider.initiateDeal(
                          clientName: _currentLead.clientName,
                          clientNumber: _currentLead.clientNumber,
                          clientEmail: _emailController.text.trim(),
                          advisorCode: _currentLead.advisorCode,
                          leadId: _currentLead.id,
                          propertyId:
                              _selectedProject?.id.toString() ??
                              selectedPropertyId?.toString() ??
                              '0',
                          unitId:
                              _selectedUnit?.id.toString() ??
                              selectedUnitId?.toString() ??
                              '0',
                          tokenAmount: '0',
                          paymentAmount: '0',
                          tokenPaymentMode: '',
                          tokenDate: '',
                          aadhaarPhotoFront: _adharFront,
                          aadhaarPhotoBack: _adharBack,
                          panPhotoFront: _panFront,
                          panPhotoBack: _panBack,
                        );

                        if (success) {
                          await _updateStageInDb(
                            'pending_verification',
                            note:
                                "Documents submitted. Deal created (Not Verified). Pending Admin verification.",
                          );
                          if (mounted) {
                            setState(
                              () => currentStage = 'pending_verification',
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to submit documents'),
                            ),
                          );
                        }
                      },
                icon: dealProvider.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  dealProvider.isSaving ? "Uploading..." : "Submit to Admin",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocPickerTile(
    String title,
    String type,
    File? file,
    Color primaryBlue,
  ) {
    return GestureDetector(
      onTap: () => _pickDocument(type),
      child: Container(
        decoration: BoxDecoration(
          color: file != null
              ? primaryBlue.withOpacity(0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? primaryBlue : Colors.grey.shade300,
            width: file != null ? 2 : 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (file != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Image.file(
                    file,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Expanded(
                child: Icon(
                  Icons.upload_file,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: file != null ? primaryBlue : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Text(
                file != null ? 'Selected' : title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: file != null ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedDealView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "Deal Verified & Tokenized",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Token ID", style: TextStyle(color: Colors.grey)),
                Text(
                  "#$_generatedTokenId",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Amount", style: TextStyle(color: Colors.grey)),
                Text(
                  "₹ ${_tokenAmountCtrl.text}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _triggerLocalNotification(
                "Download Started",
                "Receipt $_generatedTokenId saving...",
              ),
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
                  advisorCode: _currentLead.advisorCode,
                  clientEmail: _emailController.text,
                  clientAdharFront: '',
                  clientAdharBack: '',
                  clientPanFront: '',
                  clientPanBack: '',
                  propertyId: _selectedProject?.id ?? selectedPropertyId ?? 0,
                  unitId: _selectedUnit?.id ?? selectedUnitId ?? 0,
                  stage: 'booking',
                  leadId: int.parse(_currentLead.id),
                  isResale: false,
                  notes: [],
                  dealStatus: 'verified',
                  tokenPaymentMode: _paymentMode,
                  paymentStatus: 'Pending',
                  createdAt: DateTime.now().toString(),
                  updatedAt: DateTime.now().toString(),
                  propertyDocs: [],
                  installments: [],
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DealManagementScreen(
                      deal: newDeal,
                      isReraApproved: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.tune, color: Colors.white),
              label: const Text(
                "Configure Payment Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVerificationView() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.timer, color: Colors.orange, size: 40),
          SizedBox(height: 20),
          Text(
            "Pending Verification",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Manager is reviewing documents and collecting token...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.report, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text(
                "Lead Closed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rejectionReason ?? _currentLead.reason,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // BOTTOM SHEETS
  // ======================================================================
  Widget _buildActionTile(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[850] : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white38 : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildClickablePropertyCard(String propName) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _selectedUnit != null && _selectedProject != null
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdvisorUnitDetailsScreen(
                  unit: _selectedUnit!,
                  project: _selectedProject!,
                ),
              ),
            )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryBlue.withOpacity(0.08),
              primaryBlue.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryBlue.withOpacity(0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'INTERESTED PROPERTY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedUnit != null)
                    Icon(Icons.open_in_new, size: 14, color: primaryBlue),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                propName,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (_selectedUnit != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _unitChip(
                      Icons.apartment,
                      _selectedUnit!.configuration,
                      Colors.blue,
                    ),
                    _unitChip(
                      Icons.layers,
                      _selectedUnit!.floorNumber,
                      Colors.purple,
                    ),
                    _unitChip(
                      Icons.explore,
                      _selectedUnit!.facing,
                      Colors.teal,
                    ),
                    _unitChip(
                      Icons.square_foot,
                      '${_selectedUnit!.areaSqft.toStringAsFixed(0)} sqft',
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      () {
                        final price = _selectedUnit!.calculatedPrice;
                        return price >= 10000000
                            ? '₹${(price / 10000000).toStringAsFixed(2)} Cr'
                            : '₹${(price / 100000).toStringAsFixed(2)} L';
                      }(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _selectedUnit!.availabilityStatus.toLowerCase() ==
                                'available'
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              _selectedUnit!.availabilityStatus.toLowerCase() ==
                                  'available'
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Text(
                        _selectedUnit!.availabilityStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              _selectedUnit!.availabilityStatus.toLowerCase() ==
                                  'available'
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label.isEmpty ? 'N/A' : label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Follow-up: $visitDate",
              style: const TextStyle(fontSize: 12, color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showDateTimePicker(BuildContext context) async {
    DateTime tempDate = DateTime.now();
    TimeOfDay tempTime = TimeOfDay.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: 550,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Date",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.blue,
                      brightness: isDark ? Brightness.dark : Brightness.light,
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (d) => setSheetState(() => tempDate = d),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: tempTime,
                  );
                  if (t != null) setSheetState(() => tempTime = t);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Time:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Text(
                        tempTime.format(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String f =
                        "${tempDate.year}-${tempDate.month.toString().padLeft(2, '0')}-${tempDate.day.toString().padLeft(2, '0')} ${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}:00";
                    Navigator.pop(ctx, f);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotConnectedSheet() {
    String? localReminder;
    String? selectedReason;
    final List<String> reasons = [
      "Switch Off",
      "Busy",
      "Not Answered",
      "Call Later",
      "Network Issue",
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_missed, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Call Not Connected",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Select Reason",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: reasons.map((reason) {
                  bool isSelected = selectedReason == reason;
                  return ChoiceChip(
                    label: Text(reason),
                    selected: isSelected,
                    onSelected: (val) => setSheetState(
                      () => selectedReason = val ? reason : null,
                    ),
                    selectedColor: Colors.blue,
                    backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                "Follow-up Reminder (Optional)",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  String? r = await _showDateTimePicker(context);
                  if (r != null) setSheetState(() => localReminder = r);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm, size: 20, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        localReminder ?? "Set Date & Time",
                        style: TextStyle(
                          color: localReminder != null
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey,
                          fontWeight: localReminder != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedReason == null) return;
                    visitDate = localReminder;
                    _incrementAttemptAndCheck(selectedReason!);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save & Update Counter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSiteVisitSheet() {
    String? localSelectedProp = selectedProperty;
    String? localVisitDate;
    TextEditingController meetingPointCtrl = TextEditingController(
      text: meetingPoint,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Schedule Site Visit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Select Property",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showCascadedPropertySheet(
                  (prop, unitId, unit, project) => setSheetState(() {
                    localSelectedProp = prop;
                    selectedPropertyId = project.id;
                    selectedUnitId = unit.id;
                    _selectedUnit = unit;
                    _selectedProject = project;
                  }),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localSelectedProp ?? "Select Project & Unit",
                          style: TextStyle(
                            fontWeight: localSelectedProp != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: localSelectedProp != null
                                ? (isDark ? Colors.white70 : Colors.black87)
                                : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Date & Time",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  String? t = await _showDateTimePicker(context);
                  if (t != null) setSheetState(() => localVisitDate = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localVisitDate ?? "Select Date & Time",
                        style: TextStyle(
                          fontWeight: localVisitDate != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: localVisitDate != null
                              ? (isDark ? Colors.white70 : Colors.black87)
                              : Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: meetingPointCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Meeting Point (Optional)",
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (localSelectedProp == null || localVisitDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select Property and Date.'),
                        ),
                      );
                      return;
                    }

                    selectedProperty = localSelectedProp;
                    visitDate = localVisitDate;
                    meetingPoint = meetingPointCtrl.text;

                    bool isReschedule = (currentStage == 'site visit');

                    if (isReschedule) {
                      setState(() => attemptCounter++);
                      if (attemptCounter >= 10) {
                        setState(() {
                          currentStage = 'closed';
                          rejectionReason =
                              "Max attempts (10) reached during reschedule.";
                        });
                        _updateStageInDb(
                          'closed',
                          note:
                              "System Auto-Closed: Max attempts (10) reached while rescheduling.",
                        );
                        Navigator.pop(ctx);
                        _triggerLocalNotification(
                          "Lead Closed Automatically",
                          "Maximum communication attempts (10) reached.",
                        );
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

                    _triggerLocalNotification(
                      isReschedule ? "Visit Rescheduled" : "Visit Scheduled",
                      "With client at $localSelectedProp",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm Visit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    final List<String> reasons = [
      "Already bought",
      "Just browsing",
      "Budget Issue",
      "Location Issue",
      "Others",
    ];
    TextEditingController notesCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Mark as Not Interested",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: isDark ? Colors.grey[850] : Colors.white,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  items: reasons
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setSheetState(() => selectedReason = v),
                  decoration: InputDecoration(
                    labelText: "Reason",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.grey[800]!
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Notes",
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedReason == null) return;
                    rejectionReason = "$selectedReason - ${notesCtrl.text}";
                    _updateStageInDb(
                      "closed",
                      reason: rejectionReason,
                      note: "Not Interested: $rejectionReason",
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Confirm Dead Lead",
                    style: TextStyle(color: Colors.white),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Mark as Interested",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _showCascadedPropertySheet(
                  (prop, unitId, unit, project) => setSheetState(() {
                    localProp = prop;
                    selectedPropertyId = project.id;
                    selectedUnitId = unit.id;
                    _selectedUnit = unit;
                    _selectedProject = project;
                  }),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localProp ?? "Select Project & Unit",
                          style: TextStyle(
                            fontWeight: localProp != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: localProp != null
                                ? (isDark ? Colors.white70 : Colors.black87)
                                : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: localNoteCtrl,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Add Broker Note...",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  fillColor: isDark
                      ? Colors.grey[850]
                      : const Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  String? t = await _showDateTimePicker(context);
                  if (t != null) setSheetState(() => localReminder = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue.withOpacity(0.15)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm, size: 18, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        localReminder ?? "Set Follow-up Reminder",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      if (localReminder == null)
                        const Icon(Icons.add, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    attemptCounter = 0;
                    selectedProperty = localProp;
                    visitDate = localReminder;
                    noteController.text = localNoteCtrl.text;
                    _updateStageInDb(
                      "prospecting",
                      note:
                          "Marked Interested for $localProp. Note: ${localNoteCtrl.text}",
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Move to Prospecting",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditLeadForm(
        lead: _currentLead,
        primaryBlue: primaryBlue,
        isAdmin: widget.isAdmin,
        onSuccess: (updatedLead) {
          setState(() {
            _currentLead = updatedLead;
          });
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

  const _EditLeadForm({
    required this.lead,
    required this.primaryBlue,
    required this.isAdmin,
    required this.onSuccess,
  });

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.lead.clientName;
    _phoneCtrl.text = widget.lead.clientNumber;
    _ageCtrl.text = widget.lead.clientAge == 'N/A' ? '' : widget.lead.clientAge;
    _occCtrl.text = widget.lead.clientOccupation == 'N/A'
        ? ''
        : widget.lead.clientOccupation;
    _incomeCtrl.text = widget.lead.annualIncome == 'N/A'
        ? ''
        : widget.lead.annualIncome;
    _addressCtrl.text = widget.lead.clientAddress == 'N/A'
        ? ''
        : widget.lead.clientAddress;

    if (['A', 'B', 'C'].contains(widget.lead.leadCategory.toUpperCase())) {
      _category = widget.lead.leadCategory.toUpperCase();
    }
    if (['Hot', 'Warm', 'Cold'].contains(widget.lead.leadPotential)) {
      _potential = widget.lead.leadPotential;
    }
    _ownsHouse =
        (widget.lead.ownsHouse == '1' ||
            widget.lead.ownsHouse.toLowerCase() == 'yes')
        ? 'Yes'
        : 'No';
    _decisionMaker = widget.lead.keyDecisionMaker ? 'Yes' : 'No';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _occCtrl.dispose();
    _incomeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update Client Details',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Client Name', _nameCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Phone Number',
                          _phoneCtrl,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Age', _ageCtrl, isNumber: true),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Occupation', _occCtrl)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Annual Income', _incomeCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Decision Maker?',
                          _decisionMaker,
                          ['Yes', 'No'],
                          (v) => setState(() => _decisionMaker = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown('Category', _category, [
                          'A',
                          'B',
                          'C',
                        ], (v) => setState(() => _category = v!)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Potential',
                          _potential,
                          ['Hot', 'Warm', 'Cold'],
                          (v) => setState(() => _potential = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          'Owns House?',
                          _ownsHouse,
                          ['Yes', 'No'],
                          (v) => setState(() => _ownsHouse = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Full Address',
                          _addressCtrl,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              setState(() => _isSaving = true);

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
                                "key_decision_maker":
                                    _decisionMaker == 'Yes' ? 1 : 0,
                              };

                              bool success = false;
                              try {
                                if (widget.isAdmin) {
                                  final provider =
                                      context.read<AdminLeadProvider>();
                                  success = await provider.updateLeadStage(
                                    widget.lead.id,
                                    widget.lead.stage,
                                    extraData: data,
                                  );
                                } else {
                                  final provider =
                                      context.read<AdvisorLeadProvider>();
                                  final advisorCode =
                                      context
                                          .read<AuthProvider>()
                                          .currentUser
                                          ?.advisorCode ??
                                      '';
                                  success = await provider.updateLeadStage(
                                    widget.lead.id,
                                    widget.lead.stage,
                                    advisorCode,
                                    extraData: data,
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isSaving = false);
                              }

                              if (success && mounted) {
                                LeadModel updatedLead = LeadModel(
                                  id: widget.lead.id,
                                  clientName: _nameCtrl.text,
                                  clientNumber: _phoneCtrl.text,
                                  advisorCode: widget.lead.advisorCode,
                                  source: widget.lead.source,
                                  clientAge: _ageCtrl.text,
                                  clientOccupation: _occCtrl.text,
                                  leadCategory: _category,
                                  leadPotential: _potential,
                                  clientAddress: _addressCtrl.text,
                                  ownsHouse: _ownsHouse,
                                  annualIncome: _incomeCtrl.text,
                                  keyDecisionMaker: _decisionMaker == 'Yes',
                                  isPriority: widget.lead.isPriority,
                                  siteVisitPhoto: widget.lead.siteVisitPhoto,
                                  stage: widget.lead.stage,
                                  propertyId: widget.lead.propertyId,
                                  callOutCome: widget.lead.callOutCome,
                                  reason: widget.lead.reason,
                                  notes: widget.lead.notes,
                                  reminder: widget.lead.reminder,
                                  meetingPoint: widget.lead.meetingPoint,
                                  communicationAttempt:
                                      widget.lead.communicationAttempt,
                                  createdAt: widget.lead.createdAt,
                                  updatedAt: widget.lead.updatedAt,
                                  unitId: widget.lead.unitId,
                                );
                                widget.onSuccess(updatedLead);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Client details updated successfully!',
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.grey[850]
                : Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? Colors.grey[850] : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// PROPERTY BROWSER SHEET (Full-featured search & filter property selector)
// ======================================================================
class _PropertyBrowserSheet extends StatefulWidget {
  final Function(String, int, UnitModel, ProjectModel) onSelect;
  const _PropertyBrowserSheet({required this.onSelect});
  @override
  State<_PropertyBrowserSheet> createState() => _PropertyBrowserSheetState();
}

class _PropertyBrowserSheetState extends State<_PropertyBrowserSheet> {
  String _searchQuery = '';
  String? _selectedConfig;
  String? _selectedType;
  String? _selectedCategory;
  String? _selectedFacing;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  RangeValues _areaRange = const RangeValues(0, 10000);
  bool _isHighValueOnly = false;
  bool _filtersExpanded = false;

  final List<String> _configs = ['1BHK', '2BHK', '3BHK', '4BHK'];
  final List<String> _types = ['Apartment', 'Plot', 'Villa', 'Flat'];
  final List<String> _categories = ['Buy', 'Rent', 'Resell'];
  final List<String> _facings = ['East', 'West', 'North', 'South'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProjectProvider>().fetchProjects();
    });
  }

  bool _unitMatchesFilters(UnitModel u) {
    if (_selectedConfig != null && u.configuration != _selectedConfig) {
      return false;
    }
    if (_selectedType != null && u.propertyType != _selectedType) return false;
    if (_selectedCategory != null && u.saleCategory != _selectedCategory) {
      return false;
    }
    if (_selectedFacing != null && u.facing != _selectedFacing) return false;

    if (_isHighValueOnly) {
      if (u.calculatedPrice < 10000000) return false;
    } else {
      if (u.calculatedPrice < _priceRange.start ||
          u.calculatedPrice > _priceRange.end) {
        return false;
      }
    }

    if (u.areaSqft < _areaRange.start || u.areaSqft > _areaRange.end) {
      return false;
    }
    return true;
  }

  Widget _filterChip(String label, String? selected, VoidCallback onTap) {
    final isSelected = selected == label;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryBlue
              : (isDark ? Colors.grey[850] : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryBlue
                : (isDark ? Colors.grey[800]! : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String? selected,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.start,
          children: options
              .map((o) => _filterChip(o, selected, () => onSelect(o)))
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AdminProjectProvider>(
      builder: (context, provider, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Browse Properties',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search projects or units...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _filtersExpanded = !_filtersExpanded),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _filtersExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: primaryBlue,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    if (_filtersExpanded) ...[
                      const SizedBox(height: 12),
                      _buildFilterSection(
                        'Configuration',
                        _configs,
                        _selectedConfig,
                        (v) => setState(
                          () =>
                              _selectedConfig = _selectedConfig == v ? null : v,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFilterSection(
                        'Property Type',
                        _types,
                        _selectedType,
                        (v) => setState(
                          () => _selectedType = _selectedType == v ? null : v,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFilterSection(
                        'Sale Category',
                        _categories,
                        _selectedCategory,
                        (v) => setState(
                          () => _selectedCategory = _selectedCategory == v
                              ? null
                              : v,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFilterSection(
                        'Facing',
                        _facings,
                        _selectedFacing,
                        (v) => setState(
                          () =>
                              _selectedFacing = _selectedFacing == v ? null : v,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Price:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isHighValueOnly
                                ? '1Cr+'
                                : '\u20b9${(_priceRange.start / 100000).toStringAsFixed(0)}L - \u20b9${(_priceRange.end / 100000).toStringAsFixed(0)}L',
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Opacity(
                        opacity: _isHighValueOnly ? 0.5 : 1.0,
                        child: IgnorePointer(
                          ignoring: _isHighValueOnly,
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 10000000,
                            divisions: 100,
                            activeColor: primaryBlue,
                            onChanged: (v) => setState(() => _priceRange = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => setState(
                          () => _isHighValueOnly = !_isHighValueOnly,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _isHighValueOnly,
                                activeColor: primaryBlue,
                                onChanged: (v) => setState(
                                  () => _isHighValueOnly = v ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Show 1Cr+ Properties Only',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Area (Sqft):',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_areaRange.start.toStringAsFixed(0)} - ${_areaRange.end.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _areaRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        activeColor: primaryBlue,
                        onChanged: (v) => setState(() => _areaRange = v),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.projects.length,
                        itemBuilder: (context, i) {
                          final project = provider.projects[i];
                          if (_searchQuery.isNotEmpty &&
                              !project.projectName.toLowerCase().contains(
                                _searchQuery,
                              ) &&
                              !project.city.toLowerCase().contains(
                                _searchQuery,
                              )) {
                            return const SizedBox.shrink();
                          }
                          return _ProjectCard(
                            project: project,
                            primaryBlue: primaryBlue,
                            isDark: isDark,
                            searchQuery: _searchQuery,
                            unitFilter: _unitMatchesFilters,
                            onSelectUnit: (unit) {
                              widget.onSelect(
                                '${project.projectName} (${unit.towerName}-${unit.unitNumber})',
                                unit.id,
                                unit,
                                project,
                              );
                              Navigator.pop(context);
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
}

class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final Color primaryBlue;
  final bool isDark;
  final String searchQuery;
  final bool Function(UnitModel) unitFilter;
  final Function(UnitModel) onSelectUnit;

  const _ProjectCard({
    required this.project,
    required this.primaryBlue,
    required this.isDark,
    required this.searchQuery,
    required this.unitFilter,
    required this.onSelectUnit,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) async {
            setState(() => _expanded = val);
            if (val) {
              await context.read<AdminProjectProvider>().fetchInventory(
                project.id.toString(),
              );
            }
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.apartment, color: widget.primaryBlue, size: 22),
          ),
          title: Text(
            project.projectName,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            '${project.city} \u2022 ${project.projectType}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            color: widget.primaryBlue,
          ),
          children: [
            Consumer<AdminProjectProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final units = provider.inventory.where((u) {
                  if (u.projectId != project.id) return false;
                  if (!widget.unitFilter(u)) return false;
                  if (widget.searchQuery.isNotEmpty) {
                    final q = widget.searchQuery;
                    return u.unitNumber.toLowerCase().contains(q) ||
                        u.towerName.toLowerCase().contains(q) ||
                        u.configuration.toLowerCase().contains(q) ||
                        u.location.toLowerCase().contains(q);
                  }
                  return true;
                }).toList();

                if (units.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No matching units',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: units.map((unit) {
                    final isAvailable =
                        unit.availabilityStatus.toLowerCase() == 'available';
                    final price = unit.calculatedPrice;
                    final priceStr = price >= 10000000
                        ? '\u20b9${(price / 10000000).toStringAsFixed(2)} Cr'
                        : '\u20b9${(price / 100000).toStringAsFixed(2)} L';

                    return GestureDetector(
                      onTap: isAvailable
                          ? () => widget.onSelectUnit(unit)
                          : null,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? widget.primaryBlue.withOpacity(0.04)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAvailable
                                ? widget.primaryBlue.withOpacity(0.2)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${unit.towerName} - ${unit.unitNumber}',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isAvailable
                                              ? null
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          unit.configuration,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: widget.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Floor: ${unit.floorNumber} \u2022 ${unit.facing} \u2022 ${unit.areaSqft.toStringAsFixed(0)} sqft',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  priceStr,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable
                                        ? widget.primaryBlue
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    unit.availabilityStatus,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isAvailable
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
