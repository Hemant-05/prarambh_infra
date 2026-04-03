import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/enquiry_provider.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedIntent = 'Buy a property';

  final List<String> _intents = [
    'Buy a property',
    'Sell a property',
    'Rent a property',
    'Invest',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<EnquiryProvider>().submitContactEnquiry(
            fullName: _nameController.text,
            email: _emailController.text,
            phoneNumber: _phoneController.text,
            iWantTo: _selectedIntent,
            message: _messageController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextColor(context);
    final secondaryTextColor = AppColors.getSecondaryTextColor(context);
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
          'Contact Us',
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
                  content: Text('Message sent successfully! We will contact you soon.'),
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
                  Text(
                    'Get in Touch',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill out the form below and our team will get back to you with all the details.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel('Full Name', textColor),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter your name',
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel('Email Address', textColor),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                       if (v!.isEmpty) return 'Please enter your email';
                       if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter a valid email';
                       return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildLabel('Phone Number', textColor),
                  _buildTextField(
                    controller: _phoneController,
                    hint: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Please enter your phone number' : null,
                  ),
                  
                  const SizedBox(height: 20),

                  _buildLabel('I want to...', textColor),
                  _buildDropdownField(primaryBlue),

                  const SizedBox(height: 20),
                  
                  _buildLabel('Message', textColor),
                  _buildTextField(
                    controller: _messageController,
                    hint: 'Tell us how we can help you...',
                    icon: Icons.message_outlined,
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? 'Please enter a message' : null,
                  ),
                  
                  const SizedBox(height: 40),
                  
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
                              'Send Message',
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

  Widget _buildDropdownField(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedIntent,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
          dropdownColor: AppColors.getCardColor(context),
          style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.getTextColor(context)),
          items: _intents.map((String intent) {
            return DropdownMenuItem<String>(
              value: intent,
              child: Text(intent),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedIntent = newValue);
            }
          },
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
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
