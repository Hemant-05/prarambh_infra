import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getCardColor(context);
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final mutedText = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    
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
                          border: Border.all(color: borderColor),
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
                            _buildTextFieldLabel('Full Name'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hint: 'hemant sahu',
                              icon: Icons.person_outline,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                              controller: _fullNameController,
                              validator: (v) => v!.isEmpty ? 'Enter full name' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldLabel('Email Address'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hint: 'hemantsahu123@gmail.com',
                              icon: Icons.email_outlined,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => !v!.contains('@') ? 'Enter valid email' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldLabel('Phone Number'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hint: '90998752146',
                              icon: Icons.phone_outlined,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v!.length < 10 ? 'Enter valid phone' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldLabel('Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              hint: '***********',
                              icon: Icons.lock_outline,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                              controller: _passwordController,
                              obscureText: true,
                              validator: (v) => v!.length < 6 ? 'Password too short' : null,
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
                                  style: GoogleFonts.montserrat(fontSize: 12),
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

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required Color primaryBlue,
    required Color borderColor,
    required Color mutedText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: mutedText, fontSize: 14),
        prefixIcon: Icon(icon, color: mutedText, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
