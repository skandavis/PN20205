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
      // Read metadata
      final metaJson = jsonDecode(await metaFile.readAsString());
      
      // Check expiry
      if (_isExpired(metaJson)) {
        await dataFile.delete();
        await metaFile.delete();
        return null;
      }

      // Read image bytes
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

  Future<void> cleanup() async {
    await for (final entity in cacheDir.list()) {
      if (entity is! File) continue;

      final path = entity.path;

      try {
        if (path.endsWith('.json')) {
          // Resource cache
          final jsonData = jsonDecode(await entity.readAsString());
          if (_isExpired(jsonData)) {
            await entity.delete();
          }
        } else if (path.endsWith('.meta')) {
          // Image cache
          final jsonData = jsonDecode(await entity.readAsString());
          if (_isExpired(jsonData)) {
            print("Deleting expired image cache: $path");
            final basePath = path.substring(0, path.length - 5);
            final dataFile = File('$basePath.data');
            if (await dataFile.exists()) await dataFile.delete();
            await entity.delete();
          }
        } else {
          await entity.delete();
        }
      } catch (_) {
        // JSON parse failed then delete the file (and its paired data file if it's a meta)
        if (path.endsWith('.meta')) {
          final basePath = path.substring(0, path.length - 5);
          final dataFile = File('$basePath.data');
          if (await dataFile.exists()) await dataFile.delete();
        }
        await entity.delete();
      }
    }
  }
}