import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class CacheManager {
  late final Directory cacheDir;
  final Directory appDir;
  CacheManager(this.appDir);

  Future<void> init() async {
    cacheDir = Directory('${appDir.path}/.cache/');
    await cacheDir.create(recursive: true);
  }

  Future<void> saveJson(String route, dynamic data) async {
    try {
      final file = _getJsonCacheFile(route);
      await file.writeAsString(jsonEncode(data));
      print("Cached data for $route");
    } catch (e) {
      print("Failed to cache data for $route: $e");
    }
  }

  Future<dynamic> loadJson(String route) async {
    try {
      final file = _getJsonCacheFile(route);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        print("Loaded cached data for $route");
        return jsonDecode(jsonString);
      }
    } catch (e) {
      print("Failed to load cache for $route: $e");
    }
    return null;
  }

  File _getJsonCacheFile(String route) {
    final key = _sanitizeFilename(route);
    return File('${cacheDir.path}$key.json');
  }

  String _sanitizeFilename(String route) {
    return route
        .replaceAll('/', '_')
        .replaceAll('?', '_')
        .replaceAll('&', '_');
  }

  Future<void> saveImage(String url, Uint8List data, Map<String, dynamic> headers) async {
    try {
      final file = File(_getImageCachePath(url));
      final cacheData = {
        'headers': headers,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'body': base64Encode(data),
      };
      await file.writeAsString(jsonEncode(cacheData));
    } catch (e) {
      print('Failed to save image to cache: $e');
    }
  }

  Future<Uint8List?> loadImage(String url) async {
    try {
      final file = File(_getImageCachePath(url));
      if (!await file.exists()) return null;

      final jsonData = jsonDecode(await file.readAsString());
      
      if (_isExpired(jsonData)) {
        await file.delete();
        return null;
      }

      return base64Decode(jsonData['body']);
    } catch (e) {
      print('Failed to read image cache: $e');
      return null;
    }
  }

  String _getImageCachePath(String url) {
    final filename = base64Url.encode(utf8.encode(url));
    return '${cacheDir.path}/$filename';
  }

  bool _isExpired(Map<String, dynamic> jsonData) {
    final headers = Map<String, dynamic>.from(jsonData['headers'] ?? {});
    final timestamp = jsonData['timestamp'] ?? 0;
    
    if (!headers.containsKey('cache-control')) return false;
    
    final cacheControl = headers['cache-control'] as String;
    final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
    
    if (maxAgeMatch == null) return false;
    
    final maxAge = int.tryParse(maxAgeMatch.group(1) ?? '') ?? 0;
    final expiryTime = timestamp + maxAge * 1000;
    
    return DateTime.now().millisecondsSinceEpoch > expiryTime;
  }
}