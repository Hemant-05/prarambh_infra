// lib/features/client/presentation/screens/career_enquiry_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:prarambh_infra/core/utils/validators.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/enquiry_provider.dart';

class CareerEnquiryScreen extends StatefulWidget {
  const CareerEnquiryScreen({super.key});

  @override
  State<CareerEnquiryScreen> createState() => _CareerEnquiryScreenState();
}

class _CareerEnquiryScreenState extends State<CareerEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<EnquiryProvider>().submitCareerEnquiry(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            city: _cityController.text,
            description: _messageController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextColor(context);
    final primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppColors.getScaffoldColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Join as Advisor',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<EnquiryProvider>(
        builder: (context, provider, child) {
          if (provider.isSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Application submitted! Our recruitment team will contact you.'),
                  backgroundColor: Colors.green,
                ),
              );
              provider.resetState();
              Navigator.pop(context);
            });
          }

          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error!),
                  backgroundColor: Colors.red,
                ),
              );
              provider.resetState();
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grow Your Career with Us',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join our network of professional advisors and start earning premium commissions on real estate deals.',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel('Full Name', textColor),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter your name',
                    icon: Icons.person_outline,
                    validator: (v) => Validators.validateRequired(v, 'Full Name'),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel('Email Address', textColor),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel('Phone Number', textColor),
                  _buildTextField(
                    controller: _phoneController,
                    hint: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel('City', textColor),
                  _buildTextField(
                    controller: _cityController,
                    hint: 'Enter your city',
                    icon: Icons.location_city_outlined,
                    validator: (v) => v!.isEmpty ? 'Please enter your city' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel('Tell us about your experience', textColor),
                  _buildTextField(
                    controller: _messageController,
                    hint: 'Your background, current occupation...',
                    icon: Icons.work_outline,
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? 'Please enter a message' : null,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Apply Now',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String label, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey),
        prefixIcon: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: AppColors.getCardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
