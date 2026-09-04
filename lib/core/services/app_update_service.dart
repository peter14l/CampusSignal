import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/app_update_info.dart';

class CheckUpdateResult {
  final bool hasUpdate;
  final bool isMandatory;
  final AppUpdateInfo? updateInfo;
  final String currentVersion;
  final int currentVersionCode;
  final String? errorMessage;

  const CheckUpdateResult({
    required this.hasUpdate,
    this.isMandatory = false,
    this.updateInfo,
    required this.currentVersion,
    required this.currentVersionCode,
    this.errorMessage,
  });
}

/// Cloudflare R2 In-App Updater Service
class AppUpdateService {
  static const String r2VersionMetadataUrl =
      'https://pub-a56b2096b15c42f3b81606f43267e8c8.r2.dev/updates/version.json';

  final http.Client _client;

  AppUpdateService({http.Client? client}) : _client = client ?? http.Client();

  /// Gets current platform package information
  Future<PackageInfo> getPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint('Failed to fetch PackageInfo: $e');
      return PackageInfo(
        appName: 'CampusSignal',
        packageName: 'in.edu.sxuk.campussignal',
        version: '1.0.1',
        buildNumber: '2',
        buildSignature: '',
      );
    }
  }

  /// Checks Cloudflare R2 bucket updates/version.json for an available APK release
  Future<CheckUpdateResult> checkForUpdate() async {
    PackageInfo? packageInfo;
    try {
      packageInfo = await getPackageInfo();
      final currentVersion = packageInfo.version;
      final currentCode = int.tryParse(packageInfo.buildNumber) ?? 1;

      final uri = Uri.parse('$r2VersionMetadataUrl?t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return CheckUpdateResult(
          hasUpdate: false,
          currentVersion: currentVersion,
          currentVersionCode: currentCode,
          errorMessage: 'Unable to reach update server (HTTP ${response.statusCode})',
        );
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final updateInfo = AppUpdateInfo.fromJson(json);

      // Compare version codes or semantic version
      final isNewerCode = updateInfo.versionCode > currentCode;
      final isNewerSemantic = _isSemanticVersionGreater(updateInfo.version, currentVersion);
      final hasUpdate = isNewerCode || isNewerSemantic;

      final isMandatory = hasUpdate &&
          (updateInfo.mandatory || currentCode < updateInfo.minSupportedVersionCode);

      return CheckUpdateResult(
        hasUpdate: hasUpdate,
        isMandatory: isMandatory,
        updateInfo: updateInfo,
        currentVersion: currentVersion,
        currentVersionCode: currentCode,
      );
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return CheckUpdateResult(
        hasUpdate: false,
        currentVersion: packageInfo?.version ?? '1.0.1',
        currentVersionCode: int.tryParse(packageInfo?.buildNumber ?? '2') ?? 2,
        errorMessage: e.toString(),
      );
    }
  }

  /// Detects current device CPU architecture for downloading optimized split APKs
  String getDeviceArchitecture() {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final abi = Abi.current();
        if (abi == Abi.androidArm64) return 'arm64-v8a';
        if (abi == Abi.androidArm) return 'armeabi-v7a';
        if (abi == Abi.androidX64) return 'x86_64';
      }
    } catch (_) {}
    return 'universal';
  }

  /// Downloads APK from Cloudflare R2 and triggers Android Package Installer
  Future<String> downloadApk({
    required AppUpdateInfo update,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final arch = getDeviceArchitecture();
    final targetUrl = update.getApkUrlForArch(arch);
    final fileName = 'CampusSignal_v${update.version}_$arch.apk';
    final savePath = '${tempDir.path}/$fileName';
    final file = File(savePath);

    debugPrint('AppUpdater: Downloading APK for architecture [$arch] from: $targetUrl');

    if (await file.exists()) {
      await file.delete();
    }

    final request = http.Request('GET', Uri.parse(targetUrl));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download update package (HTTP ${response.statusCode})');
    }

    final totalBytes = response.contentLength ?? update.fileSizeBytes;
    int receivedBytes = 0;
    final sink = file.openWrite();

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
          onProgress(progress, receivedBytes, totalBytes);
        }
      }
      await sink.flush();
      await sink.close();
    } catch (e) {
      await sink.close();
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }

    return savePath;
  }

  /// Installs downloaded APK file using system PackageInstaller and terminates app
  Future<bool> installApkAndExit(String apkFilePath) async {
    try {
      if (!Platform.isAndroid) {
        debugPrint('APK installation is only supported on Android.');
        return false;
      }

      final file = File(apkFilePath);
      if (!await file.exists()) {
        throw Exception('APK file not found on device.');
      }

      // Open APK with system installer
      final result = await OpenFilex.open(
        apkFilePath,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type == ResultType.done) {
        // Wait briefly for package installer dialog to mount, then cleanly exit
        Future.delayed(const Duration(milliseconds: 1500), () {
          SystemNavigator.pop();
        });
        return true;
      } else {
        debugPrint('OpenFilex result: ${result.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Failed to install APK: $e');
      rethrow;
    }
  }

  bool _isSemanticVersionGreater(String remote, String current) {
    try {
      final rParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final r = i < rParts.length ? rParts[i] : 0;
        final c = i < cParts.length ? cParts[i] : 0;
        if (r > c) return true;
        if (r < c) return false;
      }
    } catch (_) {}
    return false;
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});
