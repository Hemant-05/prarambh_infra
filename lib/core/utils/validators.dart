class Validators {
  /// Validates that a field is not empty.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates Indian Phone Number: Should be exactly 10 digits and start with 6-9.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  /// Validates standard Email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates Aadhar Number: Should be exactly 12 digits.
  static String? validateAadhar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhar number is required';
    }
    final aadharRegex = RegExp(r'^\d{12}$');
    if (!aadharRegex.hasMatch(value.trim())) {
      return 'Aadhar number must be exactly 12 digits';
    }
    return null;
  }

  /// Validates PAN Number: 5 letters, 4 digits, 1 letter (e.g., ABCDE1234F).
  static String? validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid PAN (e.g., ABCDE1234F)';
    }
    return null;
  }

  /// Validates that a field contains only positive integers.
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }
    if (int.parse(value.trim()) < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validates a 6-digit Pincode.
  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    final pinRegex = RegExp(r'^\d{6}$');
    if (!pinRegex.hasMatch(value.trim())) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }
}
