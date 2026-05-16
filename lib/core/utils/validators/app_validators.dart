import 'package:flutter_pulse_app/core/utils/constants/app_constants.dart';

class AppValidators {
  /// Validates task title
  /// If everything is OK → returns null
  ///If there is an error → returns an error message (String)
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < AppConstants.minTitleLength) {
      return 'Title must be at least ${AppConstants.minTitleLength} characters';
    }
    if (value.trim().length > AppConstants.maxTitleLength) {
      return 'Title must not exceed ${AppConstants.maxTitleLength} characters';
    }
    return null;
  }

  /// Validates task description
  static String? validateDescription(String? value) {
    if (value != null &&
        value.trim().length > AppConstants.maxDescriptionLength) {
      return 'Description must not exceed ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }
}
