import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../../../../core/utils/ui_helper.dart';
import '../providers/advisor_profile_provider.dart';
import '../../data/models/advisor_profile_model.dart';

class AdvisorEditProfileScreen extends StatefulWidget {
  final AdvisorProfileModel profile;

  const AdvisorEditProfileScreen({super.key, required this.profile});

  @override
  State<AdvisorEditProfileScreen> createState() => _AdvisorEditProfileScreenState();
}

class _AdvisorEditProfileScreenState extends State<AdvisorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _fatherNameController;
  late TextEditingController _dobController;
  late TextEditingController _occupationController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _aadhaarController;
  late TextEditingController _panController;
  late TextEditingController _bankNameController;
  late TextEditingController _accNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _nomineeNameController;
  late TextEditingController _nomineePhoneController;
  late TextEditingController _relationshipController;

  String _selectedGender = 'Male';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _fatherNameController = TextEditingController(text: p.fatherName);
    _dobController = TextEditingController(text: p.dob);
    _occupationController = TextEditingController(text: p.occupation);
    _addressController = TextEditingController(text: p.address);
    _cityController = TextEditingController(text: p.city);
    _stateController = TextEditingController(text: p.state);
    _pincodeController = TextEditingController(text: p.pincode);
    _aadhaarController = TextEditingController(text: p.aadhaar);
    _panController = TextEditingController(text: p.pan);
    _bankNameController = TextEditingController(text: p.bankName);
    _accNumberController = TextEditingController(text: p.accNumber);
    _ifscController = TextEditingController(text: p.ifsc);
    _nomineeNameController = TextEditingController(text: p.nomineeName);
    _nomineePhoneController = TextEditingController(text: p.nomineePhone);
    _relationshipController = TextEditingController(text: p.relationship);
    _selectedGender = p.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fatherNameController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _bankNameController.dispose();
    _accNumberController.dispose();
    _ifscController.dispose();
    _nomineeNameController.dispose();
    _nomineePhoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdvisorProfileProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Theme.of(context).cardColor : AppColors.getPrimaryBlue(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(provider),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Photo Section
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_profileImage != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(
                              imageUrl: _profileImage!.path,
                              heroTag: 'edit_profile_photo',
                            ),
                          ),
                        );
                      } else if (widget.profile.profilePhoto.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(
                              imageUrl: widget.profile.profilePhoto,
                              heroTag: 'edit_profile_photo',
                            ),
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: 'edit_profile_photo',
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryBlue.withOpacity(0.1),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (widget.profile.profilePhoto.isNotEmpty
                                ? NetworkImage(widget.profile.profilePhoto)
                                : null) as ImageProvider?,
                        child: (_profileImage == null && widget.profile.profilePhoto.isEmpty)
                            ? Icon(Icons.person, size: 50, color: primaryBlue)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Read-only info (Quick indicator)
              _buildReadOnlyBanner(primaryBlue, isDark),
              const SizedBox(height: 24),

              // Fields grouped by section
              _buildSectionTitle("Personal Information"),
              _buildTextField(_nameController, "Full Name", Icons.person_outline),
              _buildTextField(_fatherNameController, "Father's Name", Icons.family_restroom),
              Row(
                children: [
                   Expanded(child: _buildTextField(_dobController, "Date of Birth", Icons.calendar_today, readOnly: true, onTap: _selectDate)),
                   const SizedBox(width: 12),
                   Expanded(child: _buildGenderDropdown()),
                ],
              ),
              _buildTextField(_occupationController, "Occupation", Icons.work_outline),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Contact Details"),
              _buildTextField(_emailController, "Email Address", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              _buildTextField(_phoneController, "Phone Number", Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildTextField(_addressController, "Full Address", Icons.home_outlined, maxLines: 2),
              Row(
                children: [
                   Expanded(child: _buildTextField(_cityController, "City", Icons.location_city_outlined)),
                   const SizedBox(width: 12),
                   Expanded(child: _buildTextField(_stateController, "State", Icons.map_outlined)),
                ],
              ),
              _buildTextField(_pincodeController, "Pincode", Icons.pin_drop_outlined, keyboardType: TextInputType.number),

              const SizedBox(height: 24),
              _buildSectionTitle("KYC Details"),
              _buildTextField(_aadhaarController, "Aadhaar Number", Icons.credit_card, keyboardType: TextInputType.number),
              _buildTextField(_panController, "PAN Number", Icons.credit_card_outlined),

              const SizedBox(height: 24),
              _buildSectionTitle("Bank Details"),
              _buildTextField(_bankNameController, "Bank Name", Icons.account_balance),
              _buildTextField(_accNumberController, "Account Number", Icons.numbers, keyboardType: TextInputType.number),
              _buildTextField(_ifscController, "IFSC Code", Icons.tag),

              const SizedBox(height: 24),
              _buildSectionTitle("Nominee Details"),
              _buildTextField(_nomineeNameController, "Nominee Name", Icons.person_add_outlined),
              _buildTextField(_relationshipController, "Relationship", Icons.handshake_outlined),
              _buildTextField(_nomineePhoneController, "Nominee Phone", Icons.phone, keyboardType: TextInputType.phone),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: "Gender",
          prefixIcon: const Icon(Icons.wc, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: ['Male', 'Female', 'Other'].map((String gender) {
          return DropdownMenuItem(value: gender, child: Text(gender, style: GoogleFonts.montserrat(fontSize: 14)));
        }).toList(),
        onChanged: (val) => setState(() => _selectedGender = val!),
      ),
    );
  }

  Widget _buildReadOnlyBanner(Color primaryBlue, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Administrative fields like Code, Type, and Lead Info are non-editable.",
              style: GoogleFonts.montserrat(fontSize: 11, color: primaryBlue, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(AdvisorProfileProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: provider.isSaving ? null : _handleUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: provider.isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Save Changes', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AdvisorProfileProvider>().updateProfile(
      id: widget.profile.id,
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      fatherName: _fatherNameController.text,
      dob: _dobController.text,
      gender: _selectedGender,
      occupation: _occupationController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
      aadhaar: _aadhaarController.text,
      pan: _panController.text,
      bankName: _bankNameController.text,
      accNumber: _accNumberController.text,
      ifsc: _ifscController.text,
      nomineeName: _nomineeNameController.text,
      nomineePhone: _nomineePhoneController.text,
      relationship: _relationshipController.text,
      profilePhoto: _profileImage,
    );

    if (success) {
      if (mounted) {
        UIHelper.showSuccess(context, "Profile updated successfully");
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        UIHelper.showError(context, "Update failed. Please try again.");
      }
    }
  }
}
