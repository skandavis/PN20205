import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class CacheManager {
  late final Directory cacheDir;
  final Directory appDir;
  CacheManager(this.appDir);

  Future<void> init() async {
    cacheDir = Directory('${appDir.path}/.cache');
    await cacheDir.create(recursive: true);
  }

  Future<void> saveResource(String route, dynamic data, Map<String, dynamic> headers) async {
    try {
      final file = _getResourceCacheFile(route);

      final cacheData = {
        'headers': headers,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'body': data,
      };

      await file.writeAsString(jsonEncode(cacheData));
      print("Cached data for $route");
    } catch (e) {
      print("Failed to cache data for $route: $e");
    }
  }

  Future<dynamic> loadResource(String route) async {
    try {
      final file = _getResourceCacheFile(route);
      if (!await file.exists()) return null;

      final jsonData = jsonDecode(await file.readAsString());

      if (_isExpired(jsonData)) {
        await file.delete();
        return null;
      }

      return jsonData['body'];
    } catch (e) {
      print('Failed to read resource cache: $e');
      return null;
    }
  }

  File _getResourceCacheFile(String route) {
    final key = _sanitizeFilename(route);
    return File('${cacheDir.path}/$key.json');
  }

  String _sanitizeFilename(String route) {
    return route
        .replaceAll('/', '_')
        .replaceAll('?', '_')
        .replaceAll('&', '_');
  }

  Future<void> saveImage(String url, Uint8List data, Map<String, dynamic> headers) async {
    final baseFile = _getImageCacheBasePath(url);
    
    // Ensure parent directory exists
    await baseFile.parent.create(recursive: true);
    
    // Save raw bytes
    await File('${baseFile.path}.data').writeAsBytes(data);
    // Save metadata
    final meta = {
      'headers': headers,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await File('${baseFile.path}.meta').writeAsString(jsonEncode(meta));
  }


  Future<Uint8List?> loadImage(String url) async {
    try {
      final basePath = _getImageCacheBasePath(url);
      final dataFile = File('${basePath.path}.data');
      final metaFile = File('${basePath.path}.meta');

      if (!await dataFile.exists() || !await metaFile.exists()) return null;
      final metaJson = jsonDecode(await metaFile.readAsString());
      
      if (_isExpired(metaJson)) {
        await dataFile.delete();
        await metaFile.delete();
        return null;
      }

      return await dataFile.readAsBytes();
    } catch (e) {
      print('Failed to load image cache: $e');
      return null;
    }
  }

  File _getImageCacheBasePath(String url) {
    // Use URL-safe base64 and remove padding
    final safeFilename = base64Url.encode(utf8.encode(url)).replaceAll('=', '');
    return File('${cacheDir.path}/$safeFilename');
  }


  bool _isExpired(Map<String, dynamic> jsonData) {
    // return true;
    final timestamp = jsonData['timestamp'];
    if (timestamp == null || timestamp is! int) return false;

    final headers = Map<String, dynamic>.from(jsonData['headers'] ?? {});
    final cacheControl = headers['cache-control']?.toString();

    if (cacheControl == null) return false;

    final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
    if (maxAgeMatch == null) return false;

    final maxAge = int.tryParse(maxAgeMatch.group(1) ?? '') ?? 0;
    if (maxAge <= 0) return false;

    final expiryTime = timestamp + maxAge * 1000;
    return DateTime.now().millisecondsSinceEpoch > expiryTime;
  }

  Future<void> cleanup({
    Duration? olderThan,
    bool deleteExpired = true,
    bool deleteAll = false,
  }) async {
    try {
      if (!await cacheDir.exists()) return;

      final cutoffTime = olderThan != null
          ? DateTime.now().millisecondsSinceEpoch - olderThan.inMilliseconds
          : null;

      await for (final entity in cacheDir.list()) {
        if (entity is! File) continue;

        try {
          if (deleteAll) {
            await entity.delete();
            continue;
          }

          // Handle metadata files (.meta) - check expiry from metadata
          if (entity.path.endsWith('.meta')) {
            final metaJson = jsonDecode(await entity.readAsString());
            
            final shouldDelete = (deleteExpired && _isExpired(metaJson)) ||
                (cutoffTime != null && metaJson['timestamp'] < cutoffTime);

            if (shouldDelete) {
              // Delete both .meta and .data files for images
              await entity.delete();
              final dataFile = File(entity.path.replaceAll('.meta', '.data'));
              if (await dataFile.exists()) await dataFile.delete();
            }
          }
          // Handle resource cache files (.json)
          else if (entity.path.endsWith('.json')) {
            final jsonData = jsonDecode(await entity.readAsString());
            
            final shouldDelete = (deleteExpired && _isExpired(jsonData)) ||
                (cutoffTime != null && jsonData['timestamp'] < cutoffTime);

            if (shouldDelete) await entity.delete();
          }
          // Handle orphaned .data files
          else if (entity.path.endsWith('.data')) {
            final metaFile = File(entity.path.replaceAll('.data', '.meta'));
            if (!await metaFile.exists()) {
              await entity.delete();
            }
          }
        } catch (e) {
          print('Failed to process ${entity.path}: $e');
        }
      }

      print('Cache cleanup completed');
    } catch (e) {
      print('Cache cleanup failed: $e');
    }
  }
}