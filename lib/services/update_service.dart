import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String? changelog;
  final bool isNewer;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.changelog,
    required this.isNewer,
  });
}

class UpdateService {
  static const _repoOwner = 'juancito8812';
  static const _repoName = 'arcanos-app';
  static final Dio _dio = Dio();

  /// Check the latest release from GitHub and compare with current version.
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _dio.get(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );

      if (response.statusCode == 404) return null;

      final data = response.data as Map<String, dynamic>;
      final latestVersion = (data['tag_name'] as String).replaceFirst('v', '');
      final changelog = data['body'] as String?;

      // Find APK asset
      final assets = data['assets'] as List<dynamic>? ?? [];
      String? downloadUrl;
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      if (downloadUrl == null) return null;

      final isNewer = _compareVersions(latestVersion, currentVersion) > 0;

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        changelog: changelog,
        isNewer: isNewer,
      );
    } catch (e) {
      debugPrint('UpdateService.checkForUpdate error: $e');
      return null;
    }
  }

  /// Download the APK to a local file.
  static Future<File?> downloadApk(String url, {void Function(double)? onProgress}) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/psicotarot_update.apk');

      await _dio.download(
        url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return file;
    } catch (e) {
      debugPrint('UpdateService.downloadApk error: $e');
      return null;
    }
  }

  /// Open the APK file with the system installer.
  static Future<void> installApk(String filePath) async {
    final result = await OpenFilex.open(filePath, type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      debugPrint('UpdateService.installApk error: ${result.message}');
    }
  }

  /// Compare two semver strings. Returns > 0 if a > b, < 0 if a < b, 0 if equal.
  static int _compareVersions(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final len = partsA.length > partsB.length ? partsA.length : partsB.length;
    for (int i = 0; i < len; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}
