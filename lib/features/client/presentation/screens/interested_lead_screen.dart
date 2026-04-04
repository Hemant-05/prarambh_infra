import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:prarambh_infra/core/utils/validators.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/enquiry_provider.dart';

class InterestedLeadScreen extends StatefulWidget {
  final String unitId;
  final String unitName;

  const InterestedLeadScreen({
    super.key,
    required this.unitId,
    required this.unitName,
  });

  @override
  State<InterestedLeadScreen> createState() => _InterestedLeadScreenState();
}

class _InterestedLeadScreenState extends State<InterestedLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<EnquiryProvider>().submitInterestedLead(
            clientName: _nameController.text,
            clientNumber: _phoneController.text,
            unitId: widget.unitId,
            description: _descriptionController.text.isNotEmpty 
                ? _descriptionController.text 
                : "Interested in ${widget.unitName}",
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
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Express Interest',
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
                  content: Text('Your interest has been recorded! We will contact you soon.'),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.apartment, color: primaryBlue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.unitName,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                "Unit ID: ${widget.unitId}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'I\'m Interested',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please provide your contact details so our property advisor can reach out to you.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildLabel('Your Name', textColor),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                    validator: (v) => Validators.validateRequired(v, 'Name'),
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
                  
                  _buildLabel('Special Requirements (Optional)', textColor),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Any specific questions or requirements?',
                    icon: Icons.note_add_outlined,
                    maxLines: 3,
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
                              'Express Interest',
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
