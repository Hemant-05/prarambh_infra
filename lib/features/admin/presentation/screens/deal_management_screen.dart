import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prarambh_infra/core/widgets/back_button.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prarambh_infra/core/utils/file_download_helper.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/deal_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/models/project_model.dart';
import '../providers/admin_deal_provider.dart';
import '../providers/admin_project_provider.dart';
import '../providers/admin_lead_provider.dart';
import '../../../advisor/data/models/advisor_profile_model.dart';
import '../../../advisor/presentation/providers/advisor_profile_provider.dart';
import 'advisor_profile_screen.dart' as admin;
import 'package:url_launcher/url_launcher.dart';

class DealManagementScreen extends StatefulWidget {
  final DealModel deal;
  final bool isReraApproved;

  const DealManagementScreen({
    super.key,
    required this.deal,
    this.isReraApproved = false,
  });

  @override
  State<DealManagementScreen> createState() => _DealManagementScreenState();
}

class _DealManagementScreenState extends State<DealManagementScreen> {
  final _tokenAmountCtrl = TextEditingController();
  final _totalAmountCtrl = TextEditingController();
  final _docTitleCtrl = TextEditingController();
  File? _newPropertyDoc;

  String _selectedPlan = 'Select Plan';
  String _tokenPaymentMode = 'online';
  String _tokenDate = 'Select Date';
  List<Map<String, dynamic>> _installments = [];

  bool _isTokenAmountLocked = false;
  bool _isTokenDateLocked = false;
  bool _isTokenPaymentModeLocked = false;
  bool _isPaymentPlanLocked = false;
  bool _isTotalAmountLocked = false;

  UnitModel? _unit;
  bool _isLoadingUnit = false;

  final List<String> _plans = [
    'Select Plan',
    '100% Upfront (RERA Approved)',
    '50% - 50%',
    '25% - 75%',
    '33% - 33% - 34%',
    '25% - 25% - 50%',
    '25% - 25% - 25% - 25%',
    '20% - 20% - 20% - 20% - 20%',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _fetchUnitDetails();

    // Fetch advisor profile if code is available
    if (widget.deal.advisorCode.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AdvisorProfileProvider>().clearProfile();
        context.read<AdvisorProfileProvider>().fetchProfileByCode(
          widget.deal.advisorCode,
        );
      });
    }
  }

  Future<void> _fetchUnitDetails() async {
    if (widget.deal.unitId == 0) return;

    setState(() => _isLoadingUnit = true);
    try {
      final projectProvider = context.read<AdminProjectProvider>();

      // Fetch unit details
      final unit = await projectProvider.getUnitDetails(
        widget.deal.unitId.toString(),
      );

      // Ensure projects are fetched to find the project name
      if (projectProvider.projects.isEmpty) {
        await projectProvider.fetchProjects();
      }

      if (mounted) {
        setState(() {
          _unit = unit;
          _isLoadingUnit = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching unit: $e');
      if (mounted) setState(() => _isLoadingUnit = false);
    }
  }

  void _initData() {
    // Only lock fields if they have meaningful data AND the deal is somewhat finalized
    // For now, let's keep them editable if the deal is not verified
    bool isVerified = widget.deal.dealStatus.toLowerCase() == 'verified';

    _tokenAmountCtrl.text = widget.deal.tokenAmount ?? '';
    double tAmt = double.tryParse(_tokenAmountCtrl.text) ?? 0;
    if (tAmt > 0 && isVerified) {
      _isTokenAmountLocked = true;
    }

    _tokenPaymentMode = (widget.deal.tokenPaymentMode ?? 'online')
        .toLowerCase();
    if (_tokenPaymentMode != 'online' &&
        _tokenPaymentMode != 'cash' &&
        _tokenPaymentMode != 'cheque') {
      _tokenPaymentMode = 'online';
    }

    if (isVerified &&
        (widget.deal.tokenPaymentMode?.isNotEmpty ?? false) &&
        tAmt > 0) {
      _isTokenPaymentModeLocked = true;
    }

    if (widget.deal.tokenDate != null &&
        widget.deal.tokenDate!.isNotEmpty &&
        tAmt > 0 &&
        isVerified) {
      _tokenDate = widget.deal.tokenDate!;
      _isTokenDateLocked = true;
    }

    _totalAmountCtrl.text = widget.deal.paymentAmount ?? '';
    double pAmt = double.tryParse(_totalAmountCtrl.text) ?? 0;
    if (pAmt > 0 && isVerified) {
      _isTotalAmountLocked = true;
    }

    if (widget.deal.paymentPlan != null &&
        _plans.contains(widget.deal.paymentPlan)) {
      _selectedPlan = widget.deal.paymentPlan!;
      if (isVerified) _isPaymentPlanLocked = true;
    } else if (widget.isReraApproved) {
      _selectedPlan = '100% Upfront (RERA Approved)';
      _isPaymentPlanLocked = true;
    }

    if (widget.deal.installments.isNotEmpty) {
      _installments = widget.deal.installments
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  void _generateInstallments() {
    double total = double.tryParse(_totalAmountCtrl.text) ?? 0;
    if (total <= 0 || _selectedPlan == 'Select Plan') return;

    List<double> percentages = [];
    if (_selectedPlan.contains('100%')) {
      percentages = [1.0];
    } else if (_selectedPlan == '50% - 50%')
      percentages = [0.5, 0.5];
    else if (_selectedPlan == '25% - 75%')
      percentages = [0.25, 0.75];
    else if (_selectedPlan == '33% - 33% - 34%')
      percentages = [0.33, 0.33, 0.34];
    else if (_selectedPlan == '25% - 25% - 50%')
      percentages = [0.25, 0.25, 0.50];
    else if (_selectedPlan == '25% - 25% - 25% - 25%')
      percentages = [0.25, 0.25, 0.25, 0.25];
    else if (_selectedPlan.contains('20%'))
      percentages = [0.2, 0.2, 0.2, 0.2, 0.2];

    setState(() {
      _installments = percentages
          .map(
            (p) => {
              "amount": (total * p).toStringAsFixed(0),
              "date": "Select Date",
              "status": "Pending",
              "percent": "${(p * 100).toInt()}%",
            },
          )
          .toList();
    });
  }

  Future<void> _pickPropertyDoc() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _newPropertyDoc = File(image.path));
    }
  }

  Future<void> _pickDate(String type, int? index) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      String formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        if (type == 'token') {
          _tokenDate = formatted;
        } else if (type == 'installment' && index != null)
          _installments[index]['date'] = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final dealProvider = context.watch<AdminDealProvider>();
    final activeDeal = dealProvider.deals.firstWhere(
      (d) => d.id == widget.deal.id,
      orElse: () => widget.deal,
    );

    int paidCount = _installments.where((i) => i['status'] == 'Paid').length;
    bool isFullyPaid =
        _installments.isNotEmpty && paidCount == _installments.length;
    String overallStatus = isFullyPaid ? 'Complete' : 'Pending';

    bool isTokenTaken =
        (activeDeal.tokenAmount != null &&
            activeDeal.tokenAmount!.isNotEmpty &&
            (double.tryParse(activeDeal.tokenAmount!) ?? 0) > 0) ||
        (double.tryParse(_tokenAmountCtrl.text) ?? 0) > 0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: backButton(isDark: !isDark),
        title: Text(
          "Deal Configuration",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Consumer<AdminDealProvider>(
            builder: (context, provider, child) {
              return ElevatedButton(
                onPressed: provider.isSaving
                    ? null
                    : () async {
                        if (_installments.isNotEmpty &&
                            _installments.any(
                              (i) =>
                                  (i['date'] ?? 'Select Date') == 'Select Date',
                            )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select due dates for all installments.',
                              ),
                            ),
                          );
                          return;
                        }

                          bool success = await provider.savePaymentPlan(
                            dealId: activeDeal.id.toString(),
                            installmentsJson: jsonEncode(_installments),
                            totalAmount: _totalAmountCtrl.text,
                            status: overallStatus,
                            tokenAmount: _tokenAmountCtrl.text,
                            tokenPaymentMode: _tokenPaymentMode,
                            tokenDate: _tokenDate != 'Select Date'
                                ? _tokenDate
                                : null,
                            paymentPlan: _selectedPlan != 'Select Plan'
                                ? _selectedPlan
                                : null,
                            dealStatus: (isTokenTaken || isFullyPaid)
                                ? 'verified'
                                : activeDeal.dealStatus,
                            stage: isFullyPaid
                                ? 'close'
                                : (isTokenTaken ? 'ongoing' : activeDeal.stage),
                            docTitles: _newPropertyDoc != null
                                ? [
                                    _docTitleCtrl.text.isEmpty
                                        ? 'Property Document'
                                        : _docTitleCtrl.text,
                                  ]
                                : null,
                            docFiles: _newPropertyDoc != null
                                ? [_newPropertyDoc!]
                                : null,
                          );

                          if (success && mounted) {
                            if (mounted) {
                              if ((isTokenTaken || isFullyPaid) && activeDeal.dealStatus != 'verified') {
                                final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                                context.read<AdminLeadProvider>().addLeadNote(
                                  activeDeal.leadId.toString(),
                                  "Deal verified by admin. Token collected: ₹${_tokenAmountCtrl.text} via $_tokenPaymentMode.",
                                  now,
                                );
                                context.read<AdminLeadProvider>().removeLeadFromPriority(
                                  activeDeal.leadId.toString(),
                                );
                              }

                              if (isFullyPaid) {
                                context.read<AdminLeadProvider>().updateLeadStage(
                                  activeDeal.leadId.toString(),
                                  'completed',
                                );
                              } else {
                                context.read<AdminLeadProvider>().updateLeadStage(
                                  activeDeal.leadId.toString(),
                                  'completed',
                                );
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Deal Configuration Saved Successfully!',
                                ),
                              ),
                            );
                          }
                          Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: provider.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Confirm Configuration',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Action Plate
            _buildModernStatusPlate(primaryBlue, isFullyPaid, overallStatus),
            const SizedBox(height: 32),

            // 2. Client Profile & KYC
            _buildModernSectionHeader(
              "Client Profile",
              Icons.person_outline,
              primaryBlue,
            ),
            _buildUnifiedClientKYCCard(cardColor, primaryBlue, textColor, activeDeal),
            const SizedBox(height: 16),

            // 3. Advisor & Units Section
            if (activeDeal.advisorCode.isNotEmpty) ...[
              _buildModernSectionHeader(
                "Advisor Info",
                Icons.support_agent_outlined,
                primaryBlue,
              ),
              Consumer<AdvisorProfileProvider>(
                builder: (context, profileProvider, _) {
                  if (profileProvider.isLoading)
                    return _buildAdvisorSkeleton(cardColor);
                  if (profileProvider.profile != null) {
                    return _buildAdvisorInfoCard(
                      profileProvider.profile!,
                      cardColor,
                      primaryBlue,
                      textColor,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
            ],

            // 4. Property Documents
            if (activeDeal.propertyDocs.isNotEmpty) ...[
              _buildModernSectionHeader(
                "Archive Documents",
                Icons.folder_shared_outlined,
                primaryBlue,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: activeDeal.propertyDocs.length,
                  itemBuilder: (context, index) {
                    final doc = activeDeal.propertyDocs[index];
                    return _buildDocumentThumbnail(
                      doc['title'] ?? "Document",
                      doc['url'] ?? "",
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],

            // 5. Property Specification
            _buildModernSectionHeader(
              "Property Specification",
              Icons.apartment_outlined,
              primaryBlue,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPropertyDetailItem(
                    context,
                    Icons.business_center_outlined,
                    "Project",
                    activeDeal.projectName?.trim().isNotEmpty == true
                        ? activeDeal.projectName!
                        : (_unit?.projectId != null
                              ? "Project #${_unit!.projectId}"
                              : "Loading..."),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCompactDetail(
                            constraints,
                            Icons.tag,
                            "Unit",
                            activeDeal.unitNumber ??
                                _unit?.unitNumber ??
                                "N/A",
                          ),
                          _buildCompactDetail(
                            constraints,
                            Icons.layers_outlined,
                            "Tower",
                            activeDeal.towerName ?? _unit?.towerName ?? "N/A",
                          ),
                          _buildCompactDetail(
                            constraints,
                            Icons.explore_outlined,
                            "Facing",
                            _unit?.facing ?? "N/A",
                          ),
                          _buildCompactDetail(
                            constraints,
                            Icons.grid_3x3,
                            "Plot No",
                            _unit?.plotNumber ?? "N/A",
                          ),
                          _buildCompactDetail(
                            constraints,
                            Icons.square_foot_outlined,
                            "Area",
                            _unit != null ? "${_unit!.areaSqft} sqft" : "N/A",
                          ),
                          _buildCompactDetail(
                            constraints,
                            Icons.payments_outlined,
                            "Rate/sqft",
                            _unit != null ? "₹${_unit!.ratePerSqft}" : "N/A",
                          ),
                          _buildCompactDetail(
                            constraints,
                            Icons.account_balance_wallet_outlined,
                            "Total Value",
                            _unit != null
                                ? "₹${NumberFormat('#,##,###').format(_unit!.calculatedPrice)}"
                                : "N/A",
                          ),
                          _buildCompactDetail(
                            constraints,
                            Icons.info_outline,
                            "Category",
                            _unit?.propertyType ?? "N/A",
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 24),

            // Site Visit Photo if available
            Consumer<AdminLeadProvider>(
              builder: (context, leadProvider, _) {
                final matched = leadProvider.leads.where((l) => l.id == activeDeal.leadId.toString()).toList();
                if (matched.isNotEmpty && matched.first.siteVisitPhoto.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernSectionHeader(
                        "Site Visit Image",
                        Icons.image_outlined,
                        primaryBlue,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          image: DecorationImage(
                            image: NetworkImage(matched.first.siteVisitPhoto),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // 6. Booking Commitment
            _buildModernSectionHeader(
              "Booking Financials",
              Icons.security_outlined,
              primaryBlue,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "TOKEN DETAILS",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tokenAmountCtrl,
                    keyboardType: TextInputType.number,
                    enabled: !_isTokenAmountLocked,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "0.00",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MODE",
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _tokenPaymentMode,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                              ),
                              items: ["online", "cheque", "cash"]
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(
                                        m.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isTokenPaymentModeLocked
                                  ? null
                                  : (v) =>
                                        setState(() => _tokenPaymentMode = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DATE",
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: _isTokenDateLocked
                                  ? null
                                  : () => _pickDate('token', null),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _tokenDate,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _tokenDate == 'Select Date'
                                            ? Colors.red
                                            : textColor,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: primaryBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 7. Commercial Architecture
            if (isTokenTaken) ...[
              _buildModernSectionHeader(
                "Commercial Architecture",
                Icons.account_balance_outlined,
                primaryBlue,
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NET PAYABLE ASSET VALUE",
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _totalAmountCtrl,
                      keyboardType: TextInputType.number,
                      enabled: !_isTotalAmountLocked,
                      onChanged: (v) => _generateInstallments(),
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        prefixText: "₹ ",
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "STRATEGY PLAN",
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPlan,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _plans
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (widget.isReraApproved || _isPaymentPlanLocked)
                          ? null
                          : (val) {
                              setState(() => _selectedPlan = val!);
                              _generateInstallments();
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // 8. Installment Pulse
            if (isTokenTaken && _installments.isNotEmpty) ...[
              _buildModernSectionHeader(
                "Installment Pulse",
                Icons.analytics_outlined,
                primaryBlue,
              ),
              ..._installments.asMap().entries.map((entry) {
                int idx = entry.key;
                var inst = entry.value;
                bool isPaid = inst['status'] == 'Paid';
                final accentColor = isPaid
                    ? const Color(0xFF10B981)
                    : primaryBlue;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: accentColor.withOpacity(isPaid ? 0.3 : 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          inst['percent'] ?? '',
                          style: GoogleFonts.montserrat(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹ ${inst['amount'] ?? '0'}",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap:
                                  (isPaid ||
                                      (inst['date'] != null &&
                                          inst['date'] != 'Select Date'))
                                  ? null
                                  : () => _pickDate('installment', idx),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_note_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    inst['date'] ?? 'Set Due Date',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color:
                                          (inst['date'] == 'Select Date' ||
                                              inst['date'] == null)
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            isPaid ? "VERIFIED" : "PENDING",
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? Colors.green : Colors.orange,
                              letterSpacing: 1,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: isPaid,
                              activeColor: Colors.green,
                              onChanged: isPaid
                                  ? null
                                  : (val) {
                                      setState(
                                        () => _installments[idx]['status'] = val
                                            ? 'Paid'
                                            : 'Pending',
                                      );
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],

            // 9. Interactive Note History
            _buildModernSectionHeader(
              "Note History",
              Icons.history_edu_outlined,
              primaryBlue,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "NOTE HISTORY",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          letterSpacing: 1,
                        ),
                      ),
                      _buildCircleAction(
                        Icons.add,
                        primaryBlue,
                        onTap: () => _showAddNoteDialog(
                          primaryBlue,
                          textColor,
                          cardColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (activeDeal.notes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "No notes available",
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  else
                    ...activeDeal.notes.reversed.map((n) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['title'] ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n['time'] ?? '',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 10. Digital Vault
            _buildModernSectionHeader(
              "Digital Vault",
              Icons.cloud_upload_outlined,
              primaryBlue,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _docTitleCtrl,
                    decoration: InputDecoration(
                      hintText: "Document Title (e.g. Possession Letter)",
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickPropertyDoc,
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _newPropertyDoc != null
                            ? Colors.green.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _newPropertyDoc != null
                              ? Colors.green
                              : Colors.grey.shade200,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _newPropertyDoc != null
                                ? Icons.verified_outlined
                                : Icons.file_present_outlined,
                            color: _newPropertyDoc != null
                                ? Colors.green
                                : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _newPropertyDoc != null
                                ? "Ready for Upload"
                                : "Upload Verification Doc",
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _newPropertyDoc != null
                                  ? Colors.green
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(Color primaryBlue, Color textColor, Color cardColor) {
    final TextEditingController _noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Add Status Note",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              style: GoogleFonts.montserrat(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Enter operational details...",
                hintStyle: GoogleFonts.montserrat(fontSize: 12),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_noteCtrl.text.isEmpty) return;
                  final success = await context
                      .read<AdminDealProvider>()
                      .addDealNote(
                        widget.deal.id.toString(),
                        _noteCtrl.text,
                        DateTime.now().toString(),
                      );
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Note added successfully.")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save Note",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preservedLegacyFragment(int idx, bool isPaid, dynamic inst) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 14,
                color:
                    (isPaid ||
                        (inst['date'] != null && inst['date'] != 'Select Date'))
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                inst['date'] ?? 'Select Date',
                style: TextStyle(
                  fontSize: 12,
                  color: (inst['date'] ?? 'Select Date') == 'Select Date'
                      ? Colors.red
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  decoration:
                      (isPaid ||
                          (inst['date'] != null &&
                              inst['date'] != 'Select Date'))
                      ? null
                      : TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Text(
                isPaid ? "Paid" : "Pending",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
              Switch(
                value: isPaid,
                activeThumbColor: Colors.white,
                onChanged: isPaid
                    ? null
                    : (val) {
                        setState(() {
                          _installments[idx]['status'] = val
                              ? 'Paid'
                              : 'Pending';
                        });
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deprecated_buildPropertyDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.getPrimaryBlue(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deprecated_buildDocumentViewerTile(String title, String? imageUrl) {
    bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    String fullUrl = '';
    if (hasImage) {
      fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : 'https://workiees.com/$imageUrl';
    }

    return GestureDetector(
      onTap: hasImage ? () => _showFullScreenImage(title, fullUrl) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(11),
                          ),
                          child: Image.network(
                            fullUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Icon(
                          Icons.insert_drive_file,
                          color: Colors.grey[300],
                          size: 40,
                        ),
                  if (hasImage)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          FileDownloadHelper().downloadFile(
                            context: context,
                            url: fullUrl,
                            fileName: "${title.replaceAll(' ', '_')}_DOC.jpg",
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String title, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      FileDownloadHelper().downloadFile(
                        context: context,
                        url: url,
                        fileName: "${title.replaceAll(' ', '_')}.jpg",
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisorInfoCard(
    AdvisorProfileModel profile,
    Color cardColor,
    Color primaryBlue,
    Color textColor,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              admin.AdvisorProfileScreen(advisorId: profile.advisorCode),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    backgroundImage: profile.profilePhoto.isNotEmpty
                        ? NetworkImage(profile.profilePhoto)
                        : null,
                    child: profile.profilePhoto.isEmpty
                        ? Icon(Icons.person, color: primaryBlue, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                profile.advisorCode,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              profile.designation,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final Uri telUri = Uri.parse('tel:${profile.phone}');
                        if (await canLaunchUrl(telUri)) {
                          await launchUrl(telUri);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                title: Text(
                  "More Advisor Details",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Advisor Type',
                                profile.advisorType,
                                textColor,
                                icon: Icons.badge_outlined,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Slab Rate',
                                '₹ ${double.tryParse(profile.slab)?.toStringAsFixed(0) ?? profile.slab}',
                                textColor,
                                icon: Icons.percent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          'Contact Number',
                          '+91 ${profile.phone}',
                          textColor,
                          icon: Icons.phone_android,
                        ),
                      ],
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

  Widget _buildAdvisorSkeleton(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade100),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
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
              Icon(icon, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatusPlate(
    Color primaryBlue,
    bool isFullyPaid,
    String status,
  ) {
    final statusColor = isFullyPaid
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final statusBg = statusColor.withOpacity(0.12);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                isFullyPaid ? Icons.verified_user : Icons.pending_actions,
                size: 150,
                color: statusColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFullyPaid
                          ? Icons.check_circle
                          : Icons.query_builder_rounded,
                      color: statusColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ACTION PLATE",
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor.withOpacity(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFullyPaid
                              ? "All payments verified & deal complete"
                              : "Awaiting final documentation",
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: statusColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildUnifiedClientKYCCard(
    Color cardColor,
    Color primaryBlue,
    Color textColor,
    DealModel deal,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: primaryBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.clientName.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "+91 ${deal.clientNumber}",
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (deal.clientEmail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          deal.clientEmail,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildCircleAction(
                  Icons.call,
                  Colors.green,
                  onTap: () async {
                    final Uri telUri = Uri.parse(
                      'tel:${deal.clientNumber}',
                    );
                    if (await canLaunchUrl(telUri)) {
                      await launchUrl(telUri);
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "KYC DOCUMENTS",
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildDocumentThumbnail("Aadhaar Front", deal.clientAdharFront),
                    _buildDocumentThumbnail("Aadhaar Back", deal.clientAdharBack),
                    _buildDocumentThumbnail("PAN Front", deal.clientPanFront),
                    _buildDocumentThumbnail("PAN Back", deal.clientPanBack),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentThumbnail(String title, String url) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => url.isNotEmpty ? _showFullScreenImage(title, url) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isNotEmpty)
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 20),
              )
            else
              const Icon(
                Icons.description_outlined,
                color: Colors.grey,
                size: 24,
              ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetail(
    BoxConstraints constraints,
    IconData icon,
    String label,
    String value,
  ) {
    return SizedBox(
      width: (constraints.maxWidth - 8) / 2,
      child: _buildPropertyDetailItem(context, icon, label, value),
    );
  }

  Widget _buildPropertyDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: primaryBlue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewerTile(String title, String url) {
    return _buildDocumentThumbnail(title, url);
  }
}
