import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrack/utils/url_validator.dart';

void main() {
  test('accepts HTTP and HTTPS URLs and trims whitespace', () {
    expect(
      UrlValidator.validateHttpUrl(
        ' https://ssc.gov.in/ ',
        fieldName: 'Notification',
      ),
      isNull,
    );
  });

  test('rejects unsafe, incomplete, and malformed URLs', () {
    for (final value in [
      'ssc.gov.in',
      'hello',
      'javascript:alert(1)',
      'data:text/plain,unsafe',
      'file:///tmp/job.pdf',
      'https://bad host.example',
    ]) {
      expect(
        UrlValidator.validateHttpUrl(value, fieldName: 'Notification'),
        isNotNull,
      );
    }
  });

  test('supports optional legacy links without showing a validation error', () {
    expect(
      UrlValidator.validateHttpUrl(
        '',
        fieldName: 'Notification',
        required: false,
      ),
      isNull,
    );
  });
}
