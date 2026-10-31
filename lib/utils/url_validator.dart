class UrlValidator {
  static String? validateHttpUrl(
    String? value, {
    required String fieldName,
    bool required = true,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return required ? '$fieldName is required.' : null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        !RegExp(r'^[A-Za-z0-9.-]+$').hasMatch(uri.host) ||
        trimmed.contains(RegExp(r'[\s<>"{}|\\^`]'))) {
      return 'Please enter a valid HTTP/HTTPS URL.';
    }
    return null;
  }

  static String normalize(String value) => value.trim();
}
