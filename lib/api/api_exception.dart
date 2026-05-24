/// Raised for any non-success API outcome (network error, timeout, 4xx/5xx).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  bool get isNetwork => statusCode == null;
  bool get isUnauthorized => statusCode == 401;

  /// First validation message Laravel returned, if any.
  String? get firstError {
    if (errors == null) return null;
    for (final v in errors!.values) {
      if (v is List && v.isNotEmpty) return v.first.toString();
      if (v is String) return v;
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
