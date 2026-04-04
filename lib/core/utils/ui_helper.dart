import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIHelper {
  static void showError(BuildContext context, String message) {
    if (message.isEmpty) return;
    
    // Check if the message is too long to be a toast, if so, summarize it
    final displayMessage = message.length > 100 ? summarizeError(message) : message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayMessage,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Builds a beautiful inline error widget with a retry button.
  /// Use this for sections of a page (like a dashboard stat card or a list) that fail to load.
  static Widget buildInlineError({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.withOpacity(0.05) : Colors.red.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 32),
          const SizedBox(height: 12),
          Text(
            summarizeError(message),
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.red.shade200 : Colors.red.shade800,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      Colors.blue.shade800,
      Icons.info_outline_rounded,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String summarizeError(String rawError) {
    debugPrint('RAW ERROR TO SUMMARIZE: $rawError');
    final error = rawError.toLowerCase();
    
    // 1. Connection & Timeouts
    if (error.contains('socketexception') || error.contains('connection failed') || error.contains('is not reachable')) {
      return 'Network connection lost. Please check your internet.';
    } else if (error.contains('timeout') || error.contains('deadline exceeded')) {
      return 'Request timed out. The server took too long to respond.';
    } 
    
    // 2. HTTP Status Codes
    else if (error.contains('401') || error.contains('unauthorized')) {
      if (error.contains('login') || error.contains('incorrect') || error.contains('invalid') || error.contains('credential') || error.contains('password')) {
        return 'Incorrect ID or password. Please try again.';
      }
      return 'Session expired. Please login again.';
    } else if (error.contains('403') || error.contains('forbidden')) {
      return 'You don\'t have permission to perform this action.';
    } else if (error.contains('404')) {
      return 'Requested resource not found.';
    } else if (error.contains('500')) {
      return 'Server error. Our team has been notified.';
    } else if (error.contains('502') || error.contains('503') || error.contains('504')) {
      return 'Server is currently unavailable. Please try again later.';
    }
    
    // 3. Data & Validation
    else if (error.contains('format_exception') || error.contains('invalid json')) {
      return 'Invalid data received from server.';
    } else if (error.contains('already exists') || error.contains('duplicate')) {
      return 'This record already exists in our system.';
    } else if (error.contains('validation failed') || error.contains('invalid input')) {
      return 'Please check your input data and try again.';
    } else if (error.contains('too large') || error.contains('file size')) {
      return 'File is too large to upload. Please use a smaller file.';
    }

    // 4. Generic Cleanup
    // Strip technical prefixes like "Exception:", "DioError:", etc.
    String cleanError = rawError
        .replaceAll('Exception:', '')
        .replaceAll('DioError:', '')
        .replaceAll('DioException:', '')
        .split(':')
        .last
        .trim();

    if (cleanError.isEmpty || cleanError.length < 3) {
      return 'An unexpected error occurred. Please try again.';
    }

    return cleanError;
  }
}
