import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/core/utils/validators.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:prarambh_infra/features/client/presentation/screens/client_dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/auth_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        // Navigate to Client Dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ClientDashboardScreen()),
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AuthBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(logo, height: 100),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.getBorderColor(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextFieldLabel('Full Name', textColor),
                            const SizedBox(height: 8),
                            _buildTextField(
                              context: context,
                              hint: 'Enter your full name',
                              icon: Icons.person_outline,
                              controller: _fullNameController,
                              validator: (v) => Validators.validateRequired(v, 'Full Name'),
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldLabel('Email Address', textColor),
                            const SizedBox(height: 8),
                            _buildTextField(
                              context: context,
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldLabel('Phone Number', textColor),
                            const SizedBox(height: 8),
                            _buildTextField(
                              context: context,
                              hint: 'Enter your phone number',
                              icon: Icons.phone_outlined,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validatePhone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldLabel('Password', textColor),
                            const SizedBox(height: 8),
                            _buildTextField(
                              context: context,
                              hint: 'Enter your password',
                              icon: Icons.lock_outline,
                              controller: _passwordController,
                              obscureText: true,
                              validator: (v) => Validators.validateRequired(v, 'Password'),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Register',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account ? ",
                                  style: GoogleFonts.montserrat(fontSize: 12, color: textColor),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Log in',
                                    style: GoogleFonts.montserrat(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFieldLabel(String label, Color? color) {
    return Text(
      label,
      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final mutedText = AppColors.getSecondaryTextColor(context);
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: mutedText, fontSize: 14),
        prefixIcon: Icon(icon, color: mutedText, size: 20),
        errorStyle: GoogleFonts.montserrat(fontSize: 10),
      ),
    );
  }
}
