/// Centralized input validators for all forms in the app
class Validators {
  /// Validates that a field is not empty
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates phone number format (basic validation)
  static String? phone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }
    // Remove spaces, dashes, and parentheses for validation
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Check if it contains only digits and optional + at start
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Use required() separately if field is mandatory
    }
    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  /// Validates integer number
  static String? integer(String? value, {bool required = true, String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validates decimal number
  static String? decimal(String? value, {bool required = true, String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validates positive integer
  static String? positiveInteger(String? value, {bool required = true, String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    final num = int.tryParse(value.trim());
    if (num == null) {
      return 'Please enter a valid number';
    }
    if (num <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  /// Validates positive number (including 0)
  static String? nonNegativeInteger(String? value, {bool required = true, String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    final num = int.tryParse(value.trim());
    if (num == null) {
      return 'Please enter a valid number';
    }
    if (num < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validates number range
  static String? numberRange(String? value, {
    required int min,
    required int max,
    bool required = true,
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    final num = int.tryParse(value.trim());
    if (num == null) {
      return 'Please enter a valid number';
    }
    if (num < min || num > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  /// Validates decimal range
  static String? decimalRange(String? value, {
    required double min,
    required double max,
    bool required = true,
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return 'Please enter a valid number';
    }
    if (num < min || num > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  /// Validates URL format
  static String? url(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validates password strength (minimum 6 characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates password confirmation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Combines multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Validates date is not in the past
  static String? futureDate(DateTime? value, {bool required = true}) {
    if (value == null) {
      return required ? 'Date is required' : null;
    }
    if (value.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    return null;
  }

  /// Validates date is not in the future
  static String? pastDate(DateTime? value, {bool required = true}) {
    if (value == null) {
      return required ? 'Date is required' : null;
    }
    if (value.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  /// Validates that a string contains only letters and spaces
  static String? alphabetic(String? value, {bool required = true, String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName must contain only letters';
    }
    return null;
  }

  /// Validates that a string contains only alphanumeric characters
  static String? alphanumeric(String? value, {bool required = true, String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value.trim())) {
      return '$fieldName must contain only letters and numbers';
    }
    return null;
  }
}
