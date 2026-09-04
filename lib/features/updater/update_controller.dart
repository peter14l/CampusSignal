import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_update_service.dart';
import '../../models/app_update_info.dart';

class UpdateState {
  final bool isChecking;
  final bool isDownloading;
  final bool isInstalling;
  final double downloadProgress;
  final int receivedBytes;
  final int totalBytes;
  final CheckUpdateResult? updateResult;
  final String? errorMessage;
  final bool isPopupDismissed;

  const UpdateState({
    this.isChecking = false,
    this.isDownloading = false,
    this.isInstalling = false,
    this.downloadProgress = 0.0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.updateResult,
    this.errorMessage,
    this.isPopupDismissed = false,
  });

  UpdateState copyWith({
    bool? isChecking,
    bool? isDownloading,
    bool? isInstalling,
    double? downloadProgress,
    int? receivedBytes,
    int? totalBytes,
    CheckUpdateResult? updateResult,
    String? errorMessage,
    bool? isPopupDismissed,
    bool clearError = false,
  }) {
    return UpdateState(
      isChecking: isChecking ?? this.isChecking,
      isDownloading: isDownloading ?? this.isDownloading,
      isInstalling: isInstalling ?? this.isInstalling,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      updateResult: updateResult ?? this.updateResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPopupDismissed: isPopupDismissed ?? this.isPopupDismissed,
    );
  }
}

class UpdateController extends Notifier<UpdateState> {
  late final AppUpdateService _service;

  @override
  UpdateState build() {
    _service = ref.watch(appUpdateServiceProvider);
    return const UpdateState();
  }

  /// Check for new APK release from R2
  Future<CheckUpdateResult> checkForUpdates({bool isSilent = false}) async {
    if (!isSilent) {
      state = state.copyWith(isChecking: true, clearError: true);
    }

    try {
      final result = await _service.checkForUpdate();
      state = state.copyWith(
        isChecking: false,
        updateResult: result,
        errorMessage: result.errorMessage,
      );
      return result;
    } catch (e) {
      final fallback = CheckUpdateResult(
        hasUpdate: false,
        currentVersion: '1.0.1',
        currentVersionCode: 2,
        errorMessage: e.toString(),
      );
      state = state.copyWith(
        isChecking: false,
        updateResult: fallback,
        errorMessage: e.toString(),
      );
      return fallback;
    }
  }

  /// Download APK with stream progress & launch system installer
  Future<void> startDownloadAndInstall(AppUpdateInfo update) async {
    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0.0,
      receivedBytes: 0,
      totalBytes: update.fileSizeBytes,
      clearError: true,
    );

    try {
      final filePath = await _service.downloadApk(
        update: update,
        onProgress: (progress, received, total) {
          state = state.copyWith(
            downloadProgress: progress,
            receivedBytes: received,
            totalBytes: total,
          );
        },
      );

      state = state.copyWith(
        isDownloading: false,
        isInstalling: true,
      );

      await _service.installApkAndExit(filePath);
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        isInstalling: false,
        errorMessage: 'Update failed: ${e.toString()}',
      );
    }
  }

  void dismissPopup() {
    state = state.copyWith(isPopupDismissed: true);
  }
}

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
