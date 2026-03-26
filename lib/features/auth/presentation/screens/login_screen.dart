import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:provider/provider.dart';

import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/auth_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _advisorCodeController =
      TextEditingController(); // NEW: Advisor Code Controller

  String _loginType = 'User'; // NEW: Radio button state ('User' or 'Advisor')

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _advisorCodeController.dispose(); // Dispose the new controller
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final advisorCode = _advisorCodeController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill email and password')),
      );
      return;
    }

    // Validation specifically for Advisor
    if (_loginType == 'Advisor' && advisorCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Advisor Code is required')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    bool success;

    // Call the correct API method based on the radio selection
    if (_loginType == 'Advisor') {
      success = await authProvider.loginAdvisor(password, advisorCode);
    } else {
      success = await authProvider.login(email, password);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Welcome back')));
      final userRole = authProvider.currentUser?.role;

      if (userRole == 'Admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if (userRole == 'Advisor') {
        Navigator.pushReplacementNamed(context, '/advisor_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/client_dashboard');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getCardColor(context);
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final mutedText = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return AuthBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(logo, height: 120),
                    const SizedBox(height: 40),
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
                          // NEW: Radio Buttons for Login Type
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio<String>(
                                value: 'User',
                                groupValue: _loginType,
                                activeColor: primaryBlue,
                                onChanged: (value) =>
                                    setState(() => _loginType = value!),
                              ),
                              Text(
                                'User',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Radio<String>(
                                value: 'Advisor',
                                groupValue: _loginType,
                                activeColor: primaryBlue,
                                onChanged: (value) =>
                                    setState(() => _loginType = value!),
                              ),
                              Text(
                                'Advisor',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // NEW: Conditional Advisor Code Field
                          if (_loginType == 'Advisor') ...[
                            _buildTextFieldLabel('Advisor Code'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _advisorCodeController,
                              hint: 'e.g. ADV-9082',
                              icon: Icons.badge_outlined,
                              isDark: isDark,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (_loginType == 'User') ...[
                            _buildTextFieldLabel('Email Address'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'hemantsahu123@gmail.com',
                              icon: Icons.email_outlined,
                              isDark: isDark,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                            ),
                            const SizedBox(height: 20),
                          ],

                          _buildTextFieldLabel('Password'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'hemant0312',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isDark: isDark,
                            primaryBlue: primaryBlue,
                            borderColor: borderColor,
                            mutedText: mutedText,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot_password',
                                );
                              },
                              child: Text(
                                'Forgot password ?',
                                style: GoogleFonts.montserrat(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: context.watch<AuthProvider>().isLoading
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: context.watch<AuthProvider>().isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Log in',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account ? ",
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Create account',
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
    bool isPassword = false,
    required bool isDark,
    required TextEditingController controller,
    required Color primaryBlue,
    required Color borderColor,
    required Color mutedText,
  }) {
    return TextFormField(
      obscureText: isPassword,
      controller: controller,
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: mutedText, fontSize: 14),
        prefixIcon: Icon(icon, color: mutedText),
        suffixIcon: isPassword
            ? Icon(Icons.visibility_off, color: mutedText)
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue),
        ),
      ),
    );
  }
}
