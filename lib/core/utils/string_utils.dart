import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility class for common string operations
/// Follows DRY principles with reusable string functions
class StringUtils {
  // Private constructor to prevent instantiation
  StringUtils._();

  /// Capitalizes first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Converts string to title case
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map(capitalize).join(' ');
  }

  /// Removes HTML tags from string
  static String stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Truncates string to specified length with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Generates MD5 hash of string
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Extracts YouTube video ID from URL
  static String? extractYouTubeId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }
}
