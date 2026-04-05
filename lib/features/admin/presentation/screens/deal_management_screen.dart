import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  }

  Future<void> _fetchUnitDetails() async {
    if (widget.deal.propertyId == 0) return;
    
    setState(() => _isLoadingUnit = true);
    try {
      final projectProvider = context.read<AdminProjectProvider>();
      
      // Fetch unit details
      final unit = await projectProvider.getUnitDetails(widget.deal.propertyId.toString());
      
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

    _tokenPaymentMode = (widget.deal.tokenPaymentMode ?? 'online').toLowerCase();
    if (_tokenPaymentMode != 'online' &&
        _tokenPaymentMode != 'cash' &&
        _tokenPaymentMode != 'cheque') {
      _tokenPaymentMode = 'online'; 
    } 

    if (isVerified && (widget.deal.tokenPaymentMode?.isNotEmpty ?? false) && tAmt > 0) {
      _isTokenPaymentModeLocked = true;
    }

    if (widget.deal.tokenDate != null && widget.deal.tokenDate!.isNotEmpty && tAmt > 0 && isVerified) {
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
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

    int paidCount = _installments.where((i) => i['status'] == 'Paid').length;
    bool isFullyPaid =
        _installments.isNotEmpty && paidCount == _installments.length;
    String overallStatus = isFullyPaid ? 'Complete' : 'Pending';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.grey),
        title: Text(
          'Deal Configuration',
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                            const SnackBar(
                              content: Text(
                                'Please select due dates for all installments.',
                              ),
                            ),
                          );
                          return;
                        }

                        // Save entirely via the provider
                        bool success = await provider.savePaymentPlan(
                          dealId: widget.deal.id.toString(),
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
                          docTitles: _newPropertyDoc != null 
                              ? [_docTitleCtrl.text.isEmpty ? 'Property Document' : _docTitleCtrl.text] 
                              : null,
                          docFiles: _newPropertyDoc != null ? [_newPropertyDoc!] : null,
                        );

                        if (success && mounted) {
                          // AUTOMATION: Update Lead status to 'completed'
                          if (mounted) {
                            context.read<AdminLeadProvider>().updateLeadStage(
                              widget.deal.leadId.toString(),
                              'completed',
                            );
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Deal Configuration Saved & Lead Completed!',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Configuration',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Status Indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFullyPaid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFullyPaid ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isFullyPaid ? Icons.check_circle : Icons.pending_actions,
                    color: isFullyPaid ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Overall Deal Status: ${overallStatus.toUpperCase()}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFullyPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            // Client Documents Gallery
            Text(
              "Client KYC Documents",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildDocumentViewerTile("Aadhaar Front", widget.deal.clientAdharFront),
                  _buildDocumentViewerTile("Aadhaar Back", widget.deal.clientAdharBack),
                  _buildDocumentViewerTile("PAN Front", widget.deal.clientPanFront),
                  _buildDocumentViewerTile("PAN Back", widget.deal.clientPanBack),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Property Documents Section
            if (widget.deal.propertyDocs.isNotEmpty) ...[
              Text(
                "Property Documents",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: widget.deal.propertyDocs.length,
                  itemBuilder: (context, index) {
                    return _buildDocumentViewerTile(
                      "Property Doc ${index + 1}", 
                      widget.deal.propertyDocs[index]
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Property Details Section
            Text(
              "Property Details",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoadingUnit 
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ))
                : _unit == null
                  ? Center(child: Text("Property information not available", style: TextStyle(color: Colors.grey[600])))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPropertyDetailItem(
                          context, 
                          Icons.business, 
                          "Project", 
                          context.read<AdminProjectProvider>().projects.firstWhere(
                            (p) => p.id == _unit!.projectId, 
                            orElse: () => ProjectModel(
                              id: 0, projectName: 'Project #${_unit!.projectId}', 
                              description: '', developerName: '', reraNumber: '', 
                              projectType: '', constructionStatus: '', status: '', 
                              fullAddress: '', locationMapUrl: '', city: '', 
                              marketValue: 0, totalPlots: 0, buildArea: '', 
                              budgetRange: '', ratePerSqft: 0, videoUrl: '', 
                              brochureUrl: '', brochureFile: '', images: [], 
                              amenities: [], specialties: [], createdAt: DateTime.now()
                            )
                          ).projectName
                        ),
                        const Divider(height: 24),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          children: [
                            _buildPropertyDetailItem(context, Icons.confirmation_number_outlined, "Unit #", _unit!.unitNumber),
                            _buildPropertyDetailItem(context, Icons.layers_outlined, "Tower/Floor", "${_unit!.towerName} / ${_unit!.floorNumber}"),
                            _buildPropertyDetailItem(context, Icons.home_work_outlined, "Type", _unit!.propertyType),
                            _buildPropertyDetailItem(context, Icons.king_bed_outlined, "Config", _unit!.configuration),
                            _buildPropertyDetailItem(context, Icons.square_foot_outlined, "Area", "${_unit!.areaSqft} sqft"),
                            _buildPropertyDetailItem(context, Icons.explore_outlined, "Facing", _unit!.facing),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Token Details Card
            Text(
              "Token / Booking Information",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                  Text(
                    "Received Token Amount (₹)",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tokenAmountCtrl,
                    keyboardType: TextInputType.number,
                    enabled: !_isTokenAmountLocked,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Payment Mode",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _tokenPaymentMode,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              items: ['online', 'cash', 'cheque']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isTokenPaymentModeLocked
                                  ? null
                                  : (val) => setState(() => _tokenPaymentMode = val!),
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
                              "Receiving Date",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _isTokenDateLocked ? null : () => _pickDate('token', null),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _tokenDate,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _tokenDate == 'Select Date'
                                            ? Colors.red
                                            : Colors.grey[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: _isTokenDateLocked ? Colors.grey[400] : Colors.grey[600],
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

            Text(
              "Payment Configuration",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryBlue.withOpacity(0.5)),
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
                  Text(
                    "Total Payable Amount (₹)",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _totalAmountCtrl,
                    keyboardType: TextInputType.number,
                    enabled: !_isTotalAmountLocked,
                    onChanged: (v) => _generateInstallments(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Installment Plan",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPlan,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    items: _plans
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: GoogleFonts.montserrat(fontSize: 13),
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
                  if (widget.isReraApproved || _isPaymentPlanLocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        widget.isReraApproved 
                            ? "Locked to 100% Upfront due to RERA compliance."
                            : "Payment Plan is locked after initial configuration.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Additional Documents Upload (Property Docs)
            Text(
              "Upload Additional Property Documents",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                  Text(
                    "Document Title",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _docTitleCtrl,
                    decoration: InputDecoration(
                      hintText: "e.g. Layout Plan, Agreement",
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickPropertyDoc,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _newPropertyDoc != null ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                        border: Border.all(
                          color: _newPropertyDoc != null ? Colors.green : Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _newPropertyDoc != null ? Icons.check_circle : Icons.upload_file,
                            color: _newPropertyDoc != null ? Colors.green : Colors.grey[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _newPropertyDoc != null ? "Document Selected" : "Tap to browse files",
                            style: TextStyle(
                              color: _newPropertyDoc != null ? Colors.green : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Installments Tracker
            if (_installments.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Installment Tracker",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isFullyPaid
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isFullyPaid
                          ? "ALL PAID"
                          : "$paidCount / ${_installments.length} PAID",
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isFullyPaid ? Colors.green : primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ..._installments.asMap().entries.map((entry) {
                int idx = entry.key;
                var inst = entry.value;
                bool isPaid = inst['status'] == 'Paid';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.withOpacity(0.05) : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPaid ? Colors.green : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green : primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          inst['percent'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹ ${inst['amount'] ?? '0'}",
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? Colors.green : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: (isPaid || (inst['date'] != null && inst['date'] != 'Select Date'))
                                  ? null
                                  : () => _pickDate('installment', idx),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: (isPaid || (inst['date'] != null && inst['date'] != 'Select Date')) ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    inst['date'] ?? 'Select Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          (inst['date'] ?? 'Select Date') ==
                                              'Select Date'
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      decoration: (isPaid || (inst['date'] != null && inst['date'] != 'Select Date'))
                                          ? null
                                          : TextDecoration.underline,
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
                            onChanged: (val) {
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
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetailItem(BuildContext context, IconData icon, String label, String value) {
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
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentViewerTile(String title, String? imageUrl) {
    bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    String fullUrl = '';
    if (hasImage) {
      fullUrl = imageUrl.startsWith('http') ? imageUrl : 'https://workiees.com/$imageUrl';
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
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                          child: Image.network(
                            fullUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey[400]),
                          ),
                        )
                      : Icon(Icons.insert_drive_file, color: Colors.grey[300], size: 40),
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
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
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
            InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 30),
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
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
