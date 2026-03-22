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
  // 1. Controllers MUST be outside the build method
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. Dispose MUST be outside the build method
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. Logic methods MUST be outside the build method
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome ${authProvider.currentUser?.fullName}!')),
      );
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
    // Initialize colors dynamically based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppColors.getCardColor(context);
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final mutedText = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

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
                                Navigator.pushNamed(context, '/forgot_password');
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
                            onPressed: context.watch<AuthProvider>().isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: context.watch<AuthProvider>().isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Log in',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text looks best on dark blue buttons
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
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Notice I passed colors as arguments so we don't have to look up the theme again
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
        hintStyle: GoogleFonts.montserrat(
          color: mutedText,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: mutedText),
        suffixIcon: isPassword ? Icon(Icons.visibility_off, color: mutedText) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue), // Removed hardcoded hex here
        ),
      ),
    );
  }
}