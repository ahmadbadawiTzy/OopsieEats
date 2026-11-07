import 'package:flutter/foundation.dart';

/// Structured telemetry logger for profile photo pipeline diagnostics.
/// Outputs uniform logs for all 12 stages across the client-storage-database pipeline:
/// `[STAGE: <StageName>] status=<SUCCESS|FAILED> uid=<maskedUid> bucket=<bucket> path=<path> duration=<durationMs> error=<sanitizedError>`
class ProfilePhotoLogger {
  ProfilePhotoLogger._();

  static String maskUid(String? uid) {
    if (uid == null || uid.isEmpty) return '-';
    if (uid.length <= 6) return uid;
    return '${uid.substring(0, 3)}...${uid.substring(uid.length - 3)}';
  }

  static String sanitizeError(Object? error) {
    if (error == null) return 'none';
    final str = error.toString().replaceAll('\n', ' ');
    return str.replaceAll(
      RegExp(r'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'),
      '[JWT_REDACTED]',
    );
  }

  static void log({
    required String stage,
    required String status,
    String? uid,
    String? bucket,
    String? path,
    int? durationMs,
    Object? error,
  }) {
    final uidStr = maskUid(uid);
    final bucketStr = bucket ?? '-';
    final pathStr = path ?? '-';
    final durStr = durationMs != null ? '${durationMs}ms' : '-';
    final errStr = sanitizeError(error);

    debugPrint(
      '[STAGE: $stage] status=$status uid=$uidStr bucket=$bucketStr path=$pathStr duration=$durStr error=$errStr',
    );
  }
}
