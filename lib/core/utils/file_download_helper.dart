import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as p;
import 'ui_helper.dart';

class FileDownloadHelper {
  static final FileDownloadHelper _instance = FileDownloadHelper._internal();
  factory FileDownloadHelper() => _instance;
  FileDownloadHelper._internal();

  final Dio _dio = Dio();

  /// Main method to download a file from [url] and save it with [fileName].
  /// [context] is required for showing progress and notifications.
  Future<void> downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    try {
      // 1. Check Permissions
      bool hasPermission = await _requestPermissions();
      if (!hasPermission) {
        if (context.mounted) {
          UIHelper.showError(context, "Storage permission is required to download files.");
        }
        return;
      }

      // 2. Get Download Directory
      String? downloadPath = await _getDownloadDirectory();
      if (downloadPath == null) {
        if (context.mounted) {
          UIHelper.showError(context, "Could not find a valid download directory.");
        }
        return;
      }

      // 3. Prepare Final Path
      // Ensure the "Prarambh_Infra" folder exists inside Downloads
      final prarambhDir = Directory(p.join(downloadPath, "Prarambh_Infra"));
      if (!await prarambhDir.exists()) {
        await prarambhDir.create(recursive: true);
      }

      final savePath = p.join(prarambhDir.path, fileName);

      // 4. Start Download
      if (context.mounted) {
        UIHelper.showInfo(context, "Downloading $fileName...");
      }

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Future: Could implement a progress bar in notification
            // double progress = (received / total) * 100;
          }
        },
      );

      // 5. Success
      if (context.mounted) {
        UIHelper.showSuccess(context, "Downloaded to: Prarambh_Infra/$fileName");
      }
    } catch (e) {
      if (context.mounted) {
        UIHelper.showError(context, "Download failed: ${UIHelper.summarizeError(e.toString())}");
      }
    }
  }

  /// Handles platform-specific permission logic
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        // On Android 13+, apps don't need 'Permission.storage' to write to public directories like Downloads.
        // Requesting it will just return permanently denied, so we bypass it.
        return true;
      } else {
        // Android 12 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photosAddOnly.request().isGranted;
    }
    return true;
  }

  /// Finds the best path for saving downloads
  Future<String?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Direct access to secondary storage public Downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory.path;
      }
      // Fallback
      final externalDir = await getExternalStorageDirectory();
      return externalDir?.path;
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    return null;
  }
}
