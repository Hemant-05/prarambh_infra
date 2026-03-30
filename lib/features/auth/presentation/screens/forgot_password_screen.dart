import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:provider/provider.dart';
import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/auth_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Ensure we start at the email step when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearForgotPasswordState();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleAction() async {
    final authProvider = context.read<AuthProvider>();
    final step = authProvider.forgotPasswordStep;

    if (step == ForgotPasswordStep.email) {
      final email = _emailController.text.trim();
      if (email.isEmpty) return _showError('Please enter your email');

      final success = await authProvider.requestOtp(email);
      if (!success && mounted) _showError(authProvider.errorMessage ?? 'Error');
    } else if (step == ForgotPasswordStep.otp) {
      final otp = _otpController.text.trim();
      if (otp.isEmpty) return _showError('Please enter the OTP');

      final success = await authProvider.verifyOtp(otp);
      if (!success && mounted) {
        _showError(authProvider.errorMessage ?? 'Invalid OTP');
      }
    } else if (step == ForgotPasswordStep.reset) {
      final password = _passwordController.text.trim();
      final confirm = _confirmPasswordController.text.trim();

      if (password.isEmpty || confirm.isEmpty) {
        return _showError('Please fill all fields');
      }
      if (password != confirm) return _showError('Passwords do not match');
      if (password.length < 6) {
        return _showError('Password must be at least 6 characters');
      }

      final success = await authProvider.setNewPassword(
        password,
        _otpController.text.trim(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully. Please login.'),
          ),
        );
        Navigator.pop(context); // Go back to Login Screen
      } else if (mounted) {
        _showError(authProvider.errorMessage ?? 'Failed to reset password');
      }
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

    // Watch the provider to rebuild UI when step changes
    final authState = context.watch<AuthProvider>();
    final step = authState.forgotPasswordStep;

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
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          Text(
                            step == ForgotPasswordStep.email
                                ? 'Reset Password'
                                : step == ForgotPasswordStep.otp
                                ? 'Enter Verification Code'
                                : 'Create New Password',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step == ForgotPasswordStep.email
                                ? 'Enter your email to receive an OTP.'
                                : step == ForgotPasswordStep.otp
                                ? 'We sent a code to your email.'
                                : 'Your new password must be different from previous used passwords.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: mutedText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // DYNAMIC FIELDS BASED ON STEP
                          if (step == ForgotPasswordStep.email) ...[
                            _buildTextFieldLabel('Email Address'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                            ),
                          ] else if (step == ForgotPasswordStep.otp) ...[
                            _buildTextFieldLabel('6-Digit OTP'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _otpController,
                              hint: 'Enter OTP',
                              icon: Icons.security_outlined,
                              isNumber: true,
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                            ),
                          ] else ...[
                            _buildTextFieldLabel('New Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Enter new password',
                              icon: Icons.lock_outline,
                              isPassword: !_isPasswordVisible,
                              onTogglePassword: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hint: 'Re-enter password',
                              icon: Icons.lock_outline,
                              isPassword: !_isConfirmPasswordVisible,
                              onTogglePassword: () => setState(
                                () => _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible,
                              ),
                              primaryBlue: primaryBlue,
                              borderColor: borderColor,
                              mutedText: mutedText,
                            ),
                          ],

                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    step == ForgotPasswordStep.email
                                        ? 'Send OTP'
                                        : step == ForgotPasswordStep.otp
                                        ? 'Verify OTP'
                                        : 'Reset Password',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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
    bool isNumber = false,
    required TextEditingController controller,
    required Color primaryBlue,
    required Color borderColor,
    required Color mutedText,
    VoidCallback? onTogglePassword,
  }) {
    return TextFormField(
      obscureText: isPassword,
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: mutedText, fontSize: 14),
        prefixIcon: Icon(icon, color: mutedText),
        suffixIcon: isPassword || onTogglePassword != null
            ? IconButton(
                icon: Icon(
                  isPassword ? Icons.visibility_off : Icons.visibility,
                  color: mutedText,
                ),
                onPressed: onTogglePassword,
              )
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
