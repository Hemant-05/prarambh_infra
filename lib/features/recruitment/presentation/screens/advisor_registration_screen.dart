import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_registration_provider.dart';
import '../../../../../core/utils/ui_helper.dart';
import '../../../../../core/utils/validators.dart';
import 'package:flutter/services.dart';

class AdvisorRegistrationScreen extends StatefulWidget {
  const AdvisorRegistrationScreen({super.key});

  @override
  State<AdvisorRegistrationScreen> createState() =>
      _AdvisorRegistrationScreenState();
}

class _AdvisorRegistrationScreenState extends State<AdvisorRegistrationScreen> {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      final provider = context.read<AdvisorRegistrationProvider>();
      if (currentUser != null && currentUser.role.toLowerCase() == 'advisor') {
        provider.leaderCodeCtrl.text = currentUser.advisorCode ?? '';
      }
    });
  }

  void _nextStep() {
    if (_formKey1.currentState!.validate()) {
      final provider = context.read<AdvisorRegistrationProvider>();
      if (provider.validateStep1(context)) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep = 1);
      }
    }
  }

  void _prevStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final provider = context.watch<AdvisorRegistrationProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UIHelper.showError(
          context,
          UIHelper.summarizeError(provider.errorMessage!),
        );
        provider.clearError();
      });
    }

    // RULE: If logged-in user is 'Advisor' role and their designation is exactly 'advisor' (or null), block them.
    final isRoleAdvisor = currentUser?.role.toLowerCase() == 'advisor';
    final userDesignation = (currentUser?.designation ?? '').toLowerCase();
    
    if (isRoleAdvisor && (userDesignation == 'advisor' || userDesignation.isEmpty)) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'You do not have permission to recruit an Advisor.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: _currentStep == 1
              ? _prevStep
              : () => Navigator.pop(context),
        ),
        title: Text(
          'Advisor Recruitment',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Forms
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStepOne(provider, textColor, cardColor, isDark),
                _buildStepTwo(provider, primaryBlue, textColor, cardColor, isDark),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryBlue.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Uploading Documents...',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This process will take 2-3 minutes. Please be patient as large documents are being securely uploaded.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : (_currentStep == 0
                          ? _nextStep
                      : () async {
                              if (_formKey2.currentState!.validate()) {
                                final success = await provider.submitRegistration(
                                  context,
                                );
                                if (!context.mounted) return;
                                if (success) {
                                  UIHelper.showSuccess(
                                    context,
                                    'Registration Successful! Wait for Admin approval.',
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentStep == 0 ? 'Continue to Documents' : 'Submit Application',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  // ==========================================
  // STEP 1 UI
  // ==========================================
  Widget _buildStepOne(AdvisorRegistrationProvider provider, Color? textColor, Color cardColor, bool isDark) {
    final currentUser = context.read<AuthProvider>().currentUser;
    // Generate Designation Options
    List<String> designationOptions = ['Advisor'];
    
    final role = currentUser?.role.toLowerCase() ?? '';
    final designationStr = (currentUser?.designation ?? '').toLowerCase();

    if (role == 'admin' || role == 'superadmin') {
      designationOptions = [
        'Advisor',
        'Supervisor',
        'Manager',
        'Chief Manager',
        'Senior Manager',
        'Director'
      ];
    } else if (role == 'advisor' && designationStr == 'director') {
      designationOptions = ['Advisor', 'Supervisor'];
    }

    // Ensure state matches valid list initially
    if (!designationOptions.contains(provider.designation)) {
      provider.designation = designationOptions.first;
    }

    return Form(
      key: _formKey1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('1', 'Personal Details'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: AppColors.getBorderColor(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    'Full Name',
                    'As per Aadhar/PAN',
                    provider.nameCtrl,
                    icon: Icons.person_outline,
                    textColor: textColor,
                    validator: (v) => Validators.validateRequired(v, 'Full Name'),
                  ),
                  _buildTextField(
                    'Father Name',
                    'As per Aadhar/PAN',
                    provider.fatherNameCtrl,
                    textColor: textColor,
                    validator: (v) => Validators.validateRequired(v, 'Father\'s Name'),
                  ),
                  _buildDatePicker(
                    'Date of Birth',
                    'YYYY-MM-DD',
                    provider.dobCtrl,
                    provider,
                    textColor: textColor,
                  ),
                  _buildDropdown(
                    'Gender',
                    provider.gender,
                    ['Male', 'Female', 'Other'],
                    (v) => setState(() => provider.gender = v!),
                    textColor: textColor,
                  ),
                  _buildTextField(
                    'Aadhar Number',
                    '12- digit UIDAI Number',
                    provider.aadharCtrl,
                    icon: Icons.badge_outlined,
                    isNumber: true,
                    textColor: textColor,
                    validator: Validators.validateAadhar,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                  _buildTextField(
                    'PAN Number',
                    'Permanent account number',
                    provider.panCtrl,
                    icon: Icons.credit_card_outlined,
                    textColor: textColor,
                    validator: Validators.validatePan,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('2', 'Contact Information'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: AppColors.getBorderColor(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    'Phone Number',
                    '90998752146',
                    provider.phoneCtrl,
                    icon: Icons.phone_outlined,
                    isNumber: true,
                    textColor: textColor,
                    validator: Validators.validatePhone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  _buildTextField(
                    'Email ID',
                    'email@gmail.com',
                    provider.emailCtrl,
                    icon: Icons.email_outlined,
                    textColor: textColor,
                    validator: Validators.validateEmail,
                  ),
                  _buildTextField(
                    'Address',
                    'Full residential address',
                    provider.addressCtrl,
                    maxLines: 2,
                    textColor: textColor,
                    validator: (v) => Validators.validateRequired(v, 'Address'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'State',
                          'Madhya Pradesh',
                          provider.stateCtrl,
                          icon: Icons.map,
                          textColor: textColor,
                          validator: (v) => Validators.validateRequired(v, 'State'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'City',
                          'Ujjain',
                          provider.cityCtrl,
                          icon: Icons.location_city_outlined,
                          textColor: textColor,
                          validator: (v) => Validators.validateRequired(v, 'City'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Pincode',
                          'e.g. 452010',
                          provider.pincodeCtrl,
                          isNumber: true,
                          textColor: textColor,
                          validator: Validators.validatePincode,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Occupation',
                          'e.g. Agent',
                          provider.occupationCtrl,
                          textColor: textColor,
                          validator: (v) => Validators.validateRequired(v, 'Occupation'),
                        ),
                      ),
                    ],
                  ),
                  _buildDropdown(
                    'Designation',
                    provider.designation,
                    designationOptions,
                    (v) => setState(() => provider.designation = v!),
                    textColor: textColor,
                  ),
                  _buildDropdown(
                    'Advisor Type',
                    provider.advisorType,
                    ['Full time', 'Part time'],
                    (v) => setState(() => provider.advisorType = v!),
                    textColor: textColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2 UI
  // ==========================================
  Widget _buildStepTwo(
    AdvisorRegistrationProvider provider,
    Color primaryBlue,
    Color? textColor,
    Color cardColor,
    bool isDark,
  ) {
    final currentUser = context.read<AuthProvider>().currentUser;
    return Form(
      key: _formKey2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('3', 'Nominee Details'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: AppColors.getBorderColor(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    'Nominee Name',
                    'Enter Name of nominee',
                    provider.nomineeNameCtrl,
                    textColor: textColor,
                    validator: (v) => Validators.validateRequired(v, 'Nominee Name'),
                  ),
                  _buildDatePicker(
                    'Nominee Date of Birth',
                    'YYYY-MM-DD',
                    provider.nomineeDobCtrl,
                    provider,
                    textColor: textColor,
                  ),
                  _buildDropdown(
                    'Relationship',
                    provider.relationship,
                    ['Wife', 'Husband', 'Son', 'Daughter', 'Parent', 'Sibling', 'Cousin', 'Friends'],
                    (v) => setState(() => provider.relationship = v!),
                    textColor: textColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('4', 'Bank Details'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: AppColors.getBorderColor(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    'Bank Name',
                    'e.g. HDFC Bank',
                    provider.bankNameCtrl,
                    textColor: textColor,
                    validator: (v) => Validators.validateRequired(v, 'Bank Name'),
                  ),
                  _buildTextField(
                    'Account Number',
                    '**** **** **** 1234',
                    provider.accNumberCtrl,
                    icon: Icons.lock_outline,
                    isNumber: true,
                    textColor: textColor,
                    validator: (v) => Validators.validateInteger(v, 'Account Number'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'IFSC Code',
                          'HDFC0001',
                          provider.ifscCtrl,
                          textColor: textColor,
                          validator: (v) => Validators.validateRequired(v, 'IFSC Code'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Branch',
                          'Hoshangabad',
                          provider.branchCtrl,
                          textColor: textColor,
                          validator: (v) => Validators.validateRequired(v, 'Branch'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('5', 'KYC Documents'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: AppColors.getBorderColor(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildUploadBox(
                    'Aadhar Card (Front)',
                    'aadhar_front',
                    provider.aadharFront,
                    provider,
                    primaryBlue,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildUploadBox(
                    'Aadhar Card (Back)',
                    'aadhar_back',
                    provider.aadharBack,
                    provider,
                    primaryBlue,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildUploadBox(
                    'PAN Card (Front)',
                    'pan',
                    provider.panPhoto,
                    provider,
                    primaryBlue,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildUploadBox(
                    'PAN Card (Back)',
                    'pan_back',
                    provider.panBackPhoto,
                    provider,
                    primaryBlue,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _buildUploadBox(
                    'Profile Photo (Selfie)',
                    'profile',
                    provider.profilePhoto,
                    provider,
                    primaryBlue,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('6', 'Leader Code (mandatory)'),
            _buildTextField(
              '',
              'Referral code (mandatory)',
              provider.leaderCodeCtrl,
              textColor: textColor,
              readOnly: currentUser?.role.toLowerCase() == 'advisor',
              validator: (v) => Validators.validateRequired(v, 'Leader Code'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HELPERS
  // ==========================================

  // NEW: Custom Date Picker Field
  Widget _buildDatePicker(
    String label,
    String hint,
    TextEditingController controller,
    AdvisorRegistrationProvider provider, {
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 12, color: textColor?.withOpacity(0.8) ?? Colors.black87),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1), // Default start date
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                // Format directly to YYYY-MM-DD for the backend
                String formattedDate =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                controller.text = formattedDate;
              }
            },
            child: AbsorbPointer(
              // Prevents keyboard from popping up
              child: TextField(
                controller: controller,
                style: GoogleFonts.montserrat(fontSize: 14, color: textColor),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.montserrat(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title) {
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue, width: 2),
            ),
            child: Text(
              number,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    IconData? icon,
    bool isNumber = false,
    int maxLines = 1,
    Color? textColor,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: textColor?.withOpacity(0.8) ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.montserrat(fontSize: 14, color: textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(
                color: Colors.grey[400],
                fontSize: 13,
              ),
              suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.getBorderColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.getBorderColor(context)),
              ),
              errorStyle: GoogleFonts.montserrat(fontSize: 10, height: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 12, color: textColor?.withOpacity(0.8) ?? Colors.black87),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.getBorderColor(context)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: textColor,
                ),
                items: items
                    .map(
                      (item) =>
                           DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: textColor))),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(
    String title,
    String type,
    File? file,
    AdvisorRegistrationProvider provider,
    Color primaryBlue, {
    Color? textColor,
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(fontSize: 12, color: textColor?.withOpacity(0.8) ?? Colors.black87),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => provider.pickFile(type),
            child: DottedBorder(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: file != null
                      ? primaryBlue.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      file != null ? Icons.check_circle : Icons.upload_file,
                      color: file != null ? primaryBlue : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      file != null ? 'File Attached' : 'Tap to Upload',
                      style: GoogleFonts.montserrat(
                        color: file != null ? primaryBlue : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
