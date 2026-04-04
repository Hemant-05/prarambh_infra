import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:provider/provider.dart';
import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'package:prarambh_infra/core/utils/validators.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/auth_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleAction() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final step = authProvider.forgotPasswordStep;

    if (step == ForgotPasswordStep.email) {
      final email = _emailController.text.trim();
      final success = await authProvider.requestOtp(email);
      if (!success && mounted) _showError(authProvider.errorMessage ?? 'Error');
    } else if (step == ForgotPasswordStep.otp) {
      final otp = _otpController.text.trim();
      final success = await authProvider.verifyOtp(otp);
      if (!success && mounted) {
        _showError(authProvider.errorMessage ?? 'Invalid OTP');
      }
    } else if (step == ForgotPasswordStep.reset) {
      final password = _passwordController.text.trim();
      final confirm = _confirmPasswordController.text.trim();

      if (password != confirm) {
        _showError('Passwords do not match');
        return;
      }

      final success = await authProvider.setNewPassword(
        password,
        _otpController.text.trim(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully. Please login.')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        _showError(authProvider.errorMessage ?? 'Failed to reset password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final primaryBlue = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: textColor),
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
                        border: Border.all(color: AppColors.getBorderColor(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
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
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (step == ForgotPasswordStep.email) ...[
                              _buildTextFieldLabel('Email Address', textColor),
                              const SizedBox(height: 8),
                              _buildTextField(
                                context: context,
                                controller: _emailController,
                                hint: 'Enter your email',
                                icon: Icons.email_outlined,
                                validator: Validators.validateEmail,
                              ),
                            ] else if (step == ForgotPasswordStep.otp) ...[
                              _buildTextFieldLabel('6-Digit OTP', textColor),
                              const SizedBox(height: 8),
                              _buildTextField(
                                context: context,
                                controller: _otpController,
                                hint: 'Enter OTP',
                                icon: Icons.security_outlined,
                                isNumber: true,
                                validator: (v) => Validators.validateRequired(v, 'OTP'),
                              ),
                            ] else ...[
                              _buildTextFieldLabel('New Password', textColor),
                              const SizedBox(height: 8),
                              _buildTextField(
                                context: context,
                                controller: _passwordController,
                                hint: 'Enter new password',
                                icon: Icons.lock_outline,
                                isPassword: !_isPasswordVisible,
                                onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                validator: (v) => Validators.validateRequired(v, 'New Password'),
                              ),
                              const SizedBox(height: 16),
                              _buildTextFieldLabel('Confirm Password', textColor),
                              const SizedBox(height: 8),
                              _buildTextField(
                                context: context,
                                controller: _confirmPasswordController,
                                hint: 'Re-enter password',
                                icon: Icons.lock_outline,
                                isPassword: !_isConfirmPasswordVisible,
                                onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                validator: (v) {
                                  if (v != _passwordController.text) return 'Passwords do not match';
                                  return Validators.validateRequired(v, 'Confirm Password');
                                },
                              ),
                            ],
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: authState.isLoading ? null : _handleAction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
    bool isPassword = false,
    bool isNumber = false,
    required TextEditingController controller,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    final mutedText = AppColors.getSecondaryTextColor(context);
    return TextFormField(
      obscureText: isPassword,
      controller: controller,
      validator: validator,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.montserrat(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: mutedText, fontSize: 14),
        prefixIcon: Icon(icon, color: mutedText),
        suffixIcon: (isPassword || onTogglePassword != null)
            ? IconButton(
                icon: Icon(isPassword ? Icons.visibility_off : Icons.visibility, color: mutedText),
                onPressed: onTogglePassword,
              )
            : null,
      ),
    );
  }
}
