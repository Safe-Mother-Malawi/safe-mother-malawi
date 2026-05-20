/// Validation utilities for form inputs
class Validators {
  /// Email validation regex pattern
  /// Matches standard email format: user@domain.ext
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone validation regex pattern for Malawi
  /// Must be exactly 10 digits starting with 0
  static final RegExp _phoneRegex = RegExp(r'^0\d{9}$');

  /// Full name validation regex pattern
  /// Must contain at least first and last name separated by space
  /// Only letters, hyphens, apostrophes, and spaces allowed
  static final RegExp _fullNameRegex = RegExp(
    r"^[a-zA-Z]+[a-zA-Z\s'-]*[a-zA-Z]+$",
  );

  /// Common passwords that are not allowed
  static const Set<String> _commonPasswords = {
    'password', 'password123', '123456', '12345678', 'qwerty', 'abc123',
    'monkey', 'letmein', 'trustno1', 'dragon', 'baseball', 'iloveyou',
    'master', 'sunshine', 'ashley', 'bailey', 'passw0rd', 'shadow',
    '123123', '654321', 'superman', 'qazwsx', 'michael', 'football',
  };

  /// Validates email format
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }

    final email = value.trim();
    
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates phone number (Malawi format)
  /// Must be exactly 10 digits starting with 0
  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    final phone = value.trim();

    if (!phone.startsWith('0')) {
      return 'Phone number must start with 0';
    }

    if (phone.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }

    if (!_phoneRegex.hasMatch(phone)) {
      return 'Phone number must contain only digits';
    }

    return null;
  }

  /// Validates full name (first and last name)
  /// Must contain at least two words separated by space
  static String? validateFullName(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Full name is required' : null;
    }

    final name = value.trim();

    // Check if contains at least two words
    final words = name.split(RegExp(r'\s+'));
    if (words.length < 2) {
      return 'Please enter first and last name';
    }

    // Check if contains only valid characters
    if (!_fullNameRegex.hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Check if contains any digits
    if (name.contains(RegExp(r'\d'))) {
      return 'Name cannot contain numbers';
    }

    return null;
  }

  /// Validates password with enhanced security requirements
  /// Must be 6-24 characters with uppercase, lowercase, number, and special character
  /// Common passwords are not allowed
  static String? validatePassword(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Password is required' : null;
    }

    // Check length: 6-24 characters
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 24) {
      return 'Password must be a maximum of 24 characters';
    }

    // Check for uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)';
    }

    // Check for common passwords
    if (_commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a different password';
    }

    return null;
  }

  /// Calculate password strength score (0-100)
  /// Returns a score based on multiple factors
  static int calculatePasswordStrength(String? password) {
    if (password == null || password.isEmpty) return 0;

    int score = 0;

    // Length scoring (max 30 points)
    if (password.length >= 6) score += 10;
    if (password.length >= 8) score += 10;
    if (password.length >= 10) score += 10;

    // Character variety scoring (max 50 points)
    if (password.contains(RegExp(r'[a-z]'))) score += 10; // lowercase
    if (password.contains(RegExp(r'[A-Z]'))) score += 10; // uppercase
    if (password.contains(RegExp(r'[0-9]'))) score += 10; // numbers
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 10; // special
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]{2,}'))) score += 10; // multiple special

    // Pattern scoring (max 20 points)
    if (!_hasSequentialChars(password)) score += 10; // no sequential chars
    if (!_hasRepeatingChars(password)) score += 10; // no repeating chars

    return score.clamp(0, 100);
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int score) {
    if (score < 30) return 'Weak';
    if (score < 50) return 'Fair';
    if (score < 70) return 'Good';
    if (score < 85) return 'Strong';
    return 'Very Strong';
  }

  /// Get password strength color (for UI)
  static String getPasswordStrengthColor(int score) {
    if (score < 30) return '#FF5252'; // Red
    if (score < 50) return '#FFA726'; // Orange
    if (score < 70) return '#FFD54F'; // Yellow
    if (score < 85) return '#66BB6A'; // Light Green
    return '#2E7D32'; // Dark Green
  }

  /// Check for sequential characters (e.g., "abc", "123")
  static bool _hasSequentialChars(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      int char1 = password.codeUnitAt(i);
      int char2 = password.codeUnitAt(i + 1);
      int char3 = password.codeUnitAt(i + 2);
      if (char2 == char1 + 1 && char3 == char2 + 1) {
        return true;
      }
    }
    return false;
  }

  /// Check for repeating characters (e.g., "aaa", "111")
  static bool _hasRepeatingChars(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i + 1] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  /// Validates password with basic requirements (for backward compatibility)
  static String? validatePasswordBasic(String? value, {bool required = true, int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return required ? 'Password is required' : null;
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  /// Validates password confirmation
  /// Must match the original password
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email or phone (for login)
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone number is required';
    }

    final input = value.trim();

    // Check if it's a phone number (starts with 0 and contains only digits)
    if (input.startsWith('0') && RegExp(r'^\d+$').hasMatch(input)) {
      return validatePhone(input);
    }

    // Otherwise, validate as email
    return validateEmail(input);
  }

  /// Check if email is valid (returns bool instead of error message)
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    return _emailRegex.hasMatch(value.trim());
  }
}

