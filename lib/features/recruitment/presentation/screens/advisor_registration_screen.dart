import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../providers/advisor_registration_provider.dart';

class AdvisorRegistrationScreen extends StatefulWidget {
  const AdvisorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<AdvisorRegistrationScreen> createState() => _AdvisorRegistrationScreenState();
}

class _AdvisorRegistrationScreenState extends State<AdvisorRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  void _nextStep() {
    final provider = context.read<AdvisorRegistrationProvider>();
    if (provider.validateStep1(context)) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep = 1);
    }
  }

  void _prevStep() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep = 0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final provider = context.watch<AdvisorRegistrationProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: _currentStep == 1 ? _prevStep : () => Navigator.pop(context)),
        title: Text('Advisor Registration', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Forms
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to force button clicks
              children: [
                _buildStepOne(provider),
                _buildStepTwo(provider, primaryBlue),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : (_currentStep == 0 ? _nextStep : () async {
              final success = await provider.submitRegistration(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful! Wait for Admin approval.')));
                Navigator.pop(context);
              }
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: provider.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_currentStep == 0 ? 'Next' : 'Submit Application', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 1 UI
  // ==========================================
  Widget _buildStepOne(AdvisorRegistrationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('1', 'Personal Details'),
          Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTextField('Full Name', 'Enter your full name', provider.nameCtrl),
                _buildTextField("Father's Name", "Enter father's name", provider.fatherNameCtrl),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Date of birth', 'MM/DD/YYYY', provider.dobCtrl, icon: Icons.calendar_today_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdown('Gender', provider.gender, ['Male', 'Female', 'Other'], (v) => setState(() => provider.gender = v!))),
                  ],
                ),
                _buildTextField('Aadhar Number', '12- digit UIDAI Number', provider.aadharCtrl, icon: Icons.badge_outlined, isNumber: true),
                _buildTextField('PAN Number', 'Permanent account number', provider.panCtrl, icon: Icons.credit_card_outlined),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('2', 'Contact Information'),
          Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTextField('Phone Number', '90998752146', provider.phoneCtrl, icon: Icons.phone_outlined, isNumber: true),
                _buildTextField('Email Address', 'email@gmail.com', provider.emailCtrl, icon: Icons.email_outlined),
                _buildTextField('Address', 'Full residential address', provider.addressCtrl, maxLines: 2),
                Row(
                  children: [
                    Expanded(child: _buildDropdown('State', provider.state, ['Madhya Pradesh', 'Maharashtra', 'Gujarat'], (v) => setState(() => provider.state = v!))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdown('City', provider.city, ['Hoshangabad', 'Indore', 'Bhopal'], (v) => setState(() => provider.city = v!))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Pincode', 'e.g. 452010', provider.pincodeCtrl, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Occupation', 'e.g. Agent', provider.occupationCtrl)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2 UI
  // ==========================================
  Widget _buildStepTwo(AdvisorRegistrationProvider provider, Color primaryBlue) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('3', 'Nominee Details'),
          Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTextField('Nominee Name', 'Enter Name of nominee', provider.nomineeNameCtrl),
                _buildTextField('Nominee Phone', 'Enter Phone number', provider.nomineePhoneCtrl, isNumber: true),
                _buildDropdown('Relationship', provider.relationship, ['Wife', 'Husband', 'Son', 'Daughter', 'Parent'], (v) => setState(() => provider.relationship = v!)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('4', 'Bank Details'),
          Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTextField('Bank Name', 'e.g. HDFC Bank', provider.bankNameCtrl),
                _buildTextField('Account Number', '**** **** **** 1234', provider.accNumberCtrl, icon: Icons.lock_outline, isNumber: true),
                Row(
                  children: [
                    Expanded(child: _buildTextField('IFSC Code', 'HDFC0001', provider.ifscCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Branch', 'Hoshangabad', provider.branchCtrl)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('5', 'KYC Documents'),
          Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildUploadBox('Aadhar Card (Front)', 'aadhar_front', provider.aadharFront, provider, primaryBlue),
                _buildUploadBox('Aadhar Card (Back)', 'aadhar_back', provider.aadharBack, provider, primaryBlue),
                _buildUploadBox('PAN Card', 'pan', provider.panPhoto, provider, primaryBlue),
                _buildUploadBox('Profile Photo (Selfie)', 'profile', provider.profilePhoto, provider, primaryBlue),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('6', 'Leader Code (mandatory)'),
          _buildTextField('', 'Referral code (mandatory)', provider.leaderCodeCtrl),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET HELPERS
  // ==========================================
  Widget _buildSectionHeader(String number, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24, height: 24, alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue[900]!, width: 2)),
            child: Text(number, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue[900])),
          ),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {IconData? icon, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black87)), const SizedBox(height: 8)],
          TextField(
            controller: controller, maxLines: maxLines, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.montserrat(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint, hintStyle: GoogleFonts.montserrat(color: Colors.grey[400], fontSize: 13),
              suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black87)), const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black87),
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(String title, String type, File? file, AdvisorRegistrationProvider provider, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black87)), const SizedBox(height: 8),
          GestureDetector(
            onTap: () => provider.pickFile(type),
            child: DottedBorder(
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: file != null ? Colors.blue.shade50 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Icon(file != null ? Icons.check_circle : Icons.upload_file, color: file != null ? primaryBlue : Colors.grey),
                    const SizedBox(height: 8),
                    Text(file != null ? 'File Attached' : 'Tap to Upload', style: GoogleFonts.montserrat(color: file != null ? primaryBlue : Colors.grey, fontSize: 12)),
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