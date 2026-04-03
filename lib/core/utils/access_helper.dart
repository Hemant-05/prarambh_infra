import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';

class AdvisorAccessHelper {
  /// Checks if the advisor is active.
  /// Returns `true` if active, otherwise shows a restriction dialog and returns `false`.
  static bool check(BuildContext context, {String feature = "this feature"}) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return false;

    final status = user.status.toLowerCase();
    final isRestricted = status == 'pending' || status == 'suspended' || status == 'inactive';

    if (isRestricted) {
      _showRestrictedDialog(context, user.status, feature);
      return false;
    }

    return true;
  }

  static void _showRestrictedDialog(BuildContext context, String currentStatus, String feature) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.lock_person_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 12),
            Text(
              'Access Restricted',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Your advisor account is currently '),
                  TextSpan(
                    text: currentStatus.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const TextSpan(text: '. '),
                  TextSpan(
                    text: 'You cannot access $feature at this time.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please contact your administrator to activate your account.',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Understood',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
