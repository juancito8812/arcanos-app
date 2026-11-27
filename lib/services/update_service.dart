import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String? sha256Url;
  final String? changelog;
  final bool isNewer;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.sha256Url,
    this.changelog,
    required this.isNewer,
  });
}

class UpdateService {
  static const _repoOwner = 'juancito8812';
  static const _repoName = 'arcanos-app';
  static final Dio _dio = Dio();

  /// Un APK real de esta app nunca baja de 5 MB; sirve como freno barato
  /// contra HTML de error o descargas truncadas.
  static const int _minApkBytes = 5 * 1024 * 1024;

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
      if (data['draft'] == true || data['prerelease'] == true) return null;

      final latestVersion = (data['tag_name'] as String).replaceFirst('v', '');
      final changelog = data['body'] as String?;

      // Elegir el asset del APK: se prefiere el nombre canonico del CI.
      final assets = data['assets'] as List<dynamic>? ?? [];
      String? downloadUrl;
      String? sha256Url;
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name == 'app-release.apk') {
          downloadUrl = asset['browser_download_url'] as String?;
        }
      }
      if (downloadUrl == null) {
        for (final asset in assets) {
          final name = asset['name'] as String? ?? '';
          if (name.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name == 'app-release.apk.sha256' || name.endsWith('.apk.sha256')) {
          sha256Url = asset['browser_download_url'] as String?;
          break;
        }
      }

      if (downloadUrl == null) return null;

      final isNewer = _compareVersions(latestVersion, currentVersion) > 0;

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        sha256Url: sha256Url,
        changelog: changelog,
        isNewer: isNewer,
      );
    } catch (e) {
      debugPrint('UpdateService.checkForUpdate error: $e');
      return null;
    }
  }

  /// Descarga el APK y lo valida antes de devolverlo.
  ///
  /// Devuelve null si el archivo no parece un APK o, cuando la release publica
  /// `app-release.apk.sha256`, si el hash no coincide.
  static Future<File?> downloadApk(
    String url, {
    void Function(double)? onProgress,
    String? sha256Url,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/psicotarot_update.apk');
      if (await file.exists()) await file.delete();

      await _dio.download(
        url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      final motivo = await motivoApkInvalido(file, sha256Url);
      if (motivo != null) {
        debugPrint('UpdateService: APK rechazado -> $motivo');
        if (await file.exists()) await file.delete();
        return null;
      }

      return file;
    } catch (e) {
      debugPrint('UpdateService.downloadApk error: $e');
      return null;
    }
  }

  /// null = APK aceptable; texto = motivo del rechazo.
  @visibleForTesting
  static Future<String?> motivoApkInvalido(File file, String? sha256Url) async {
    if (!await file.exists()) return 'archivo inexistente';

    final length = await file.length();
    if (length < _minApkBytes) return 'tamano sospechoso ($length bytes)';

    final raf = await file.open();
    try {
      final magic = await raf.read(4);
      if (magic.length < 4 ||
          magic[0] != 0x50 || // P
          magic[1] != 0x4B || // K
          magic[2] != 0x03 ||
          magic[3] != 0x04) {
        return 'no es un zip/APK valido';
      }
    } finally {
      await raf.close();
    }

    if (sha256Url == null) {
      // Sin hash publicado (releases viejas) al menos se valida estructura.
      return null;
    }

    final esperado = await _hashPublicado(sha256Url);
    if (esperado == null) return 'no se pudo leer el hash publicado';
    final real = await _sha256Archivo(file);
    if (real != esperado) return 'hash no coincide ($real != $esperado)';
    return null;
  }

  static Future<String?> _hashPublicado(String sha256Url) async {
    try {
      final resp = await _dio.get<String>(
        sha256Url,
        options: Options(responseType: ResponseType.plain),
      );
      final match =
          RegExp(r'[a-fA-F0-9]{64}').firstMatch(resp.data ?? '');
      return match?.group(0)?.toLowerCase();
    } catch (e) {
      debugPrint('UpdateService._hashPublicado error: $e');
      return null;
    }
  }

  static Future<String> _sha256Archivo(File file) async {
    final output = AccumulatorSink<Digest>();
    final sink = sha256.startChunkedConversion(output);
    await for (final chunk in file.openRead()) {
      sink.add(chunk);
    }
    sink.close();
    return output.events.single.toString();
  }

  /// Open the APK file with the system installer.
  static Future<bool> installApk(String filePath) async {
    const channel = MethodChannel('com.psicotarot.arcanos_mayores/apk_install');
    try {
      final ok = await channel.invokeMethod<bool>('installApk', {'path': filePath});
      if (ok != false) return true;
    } catch (e) {
      debugPrint('UpdateService.installApk channel error: $e, falling back to OpenFilex');
    }
    final result = await OpenFilex.open(filePath, type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      debugPrint('UpdateService.installApk fallback error: ${result.message}');
      return false;
    }
    return true;
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
