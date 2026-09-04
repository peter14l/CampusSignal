import 'dart:convert';

/// Represents metadata for an app version update stored in Cloudflare R2
class AppUpdateInfo {
  final String version;
  final int versionCode;
  final int minSupportedVersionCode;
  final String apkUrl;
  final int fileSizeBytes;
  final String releaseNotes;
  final DateTime publishedAt;
  final bool mandatory;

  const AppUpdateInfo({
    required this.version,
    required this.versionCode,
    this.minSupportedVersionCode = 1,
    required this.apkUrl,
    this.fileSizeBytes = 0,
    required this.releaseNotes,
    required this.publishedAt,
    this.mandatory = false,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] as String? ?? '1.0.0',
      versionCode: json['versionCode'] as int? ?? 1,
      minSupportedVersionCode: json['minSupportedVersionCode'] as int? ?? 1,
      apkUrl: json['apkUrl'] as String? ?? '',
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      releaseNotes: json['releaseNotes'] as String? ?? 'New improvements and bug fixes.',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      mandatory: json['mandatory'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'versionCode': versionCode,
      'minSupportedVersionCode': minSupportedVersionCode,
      'apkUrl': apkUrl,
      'fileSizeBytes': fileSizeBytes,
      'releaseNotes': releaseNotes,
      'publishedAt': publishedAt.toIso8601String(),
      'mandatory': mandatory,
    };
  }

  String get formattedFileSize {
    if (fileSizeBytes <= 0) return 'Approx. 28 MB';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  List<String> get changelogItems {
    return releaseNotes
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          if (line.startsWith('•') || line.startsWith('-') || line.startsWith('*')) {
            return line.substring(1).trim();
          }
          return line;
        })
        .toList();
  }
}
