class Validators {
  // Email validation
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    // Basic email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and one number';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }

    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (name.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(name.trim())) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // College validation (optional field)
  static String? validateCollege(String? college) {
    if (college == null || college.isEmpty) {
      return null; // Optional field
    }

    if (college.trim().length < 2) {
      return 'College name must be at least 2 characters long';
    }

    if (college.trim().length > 100) {
      return 'College name cannot exceed 100 characters';
    }

    return null;
  }

  // Branch validation (optional field)
  static String? validateBranch(String? branch) {
    if (branch == null || branch.isEmpty) {
      return null; // Optional field
    }

    if (branch.trim().length < 2) {
      return 'Branch must be at least 2 characters long';
    }

    if (branch.trim().length > 50) {
      return 'Branch cannot exceed 50 characters';
    }

    return null;
  }

  // Year validation
  static String? validateYear(String? year) {
    if (year == null || year.isEmpty) {
      return null; // Optional field
    }

    final validYears = ['1st', '2nd', '3rd', '4th', 'Graduate', 'Post-Graduate'];
    if (!validYears.contains(year)) {
      return 'Please select a valid year';
    }

    return null;
  }

  // Phone number validation (optional field)
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null; // Optional field
    }

    // Remove all non-digits
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 10) {
      return 'Phone number must be 10 digits long';
    }

    // Check if it starts with a valid digit (not 0 or 1)
    if (digitsOnly[0] == '0' || digitsOnly[0] == '1') {
      return 'Phone number must start with a valid digit (2-9)';
    }

    return null;
  }

  // Generic text validation
  static String? validateText(String? text, {
    required String fieldName,
    int minLength = 1,
    int maxLength = 255,
    bool required = true,
  }) {
    if (text == null || text.isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    if (text.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (text.trim().length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  // URL validation (for profile pictures, etc.)
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
        r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$'
    );

    if (!urlRegex.hasMatch(url)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Study group name validation
  static String? validateGroupName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Group name is required';
    }

    if (name.trim().length < 3) {
      return 'Group name must be at least 3 characters long';
    }

    if (name.trim().length > 50) {
      return 'Group name cannot exceed 50 characters';
    }

    // Check for basic profanity or inappropriate content
    final inappropriateWords = ['spam', 'fake', 'test123'];
    final lowerName = name.toLowerCase();

    for (final word in inappropriateWords) {
      if (lowerName.contains(word)) {
        return 'Group name contains inappropriate content';
      }
    }

    return null;
  }

  // Study group description validation
  static String? validateGroupDescription(String? description) {
    if (description == null || description.isEmpty) {
      return null; // Optional field
    }

    if (description.trim().length > 500) {
      return 'Description cannot exceed 500 characters';
    }

    return null;
  }

  // Message validation
  static String? validateMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      return 'Message cannot be empty';
    }

    if (message.trim().length > 1000) {
      return 'Message cannot exceed 1000 characters';
    }

    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return 'Please enter a search term';
    }

    if (query.trim().length < 2) {
      return 'Search term must be at least 2 characters long';
    }

    if (query.trim().length > 100) {
      return 'Search term cannot exceed 100 characters';
    }

    return null;
  }
}