import 'dart:typed_data';

import 'package:PN2025/cacheManager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'globals.dart' as globals;

class ImageService {
  final Dio dio;
  final CacheManager cacheManager;
  ImageService(this.dio, this.cacheManager);
  
  Future<Uint8List?> getImage(String route) async {
    final url = '${globals.baseUrl}$route';
    
    final cached = await cacheManager.loadImage(url);
    if (cached != null) return cached;

    try {
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data is Uint8List) {
        final headers = _normalizeHeaders(response.headers.map);
        await cacheManager.saveImage(url, response.data, headers);
        debugPrint('Saved to cache: $url');
        return response.data;
      }
      
      print("Unexpected data type: ${response.data.runtimeType}");
      return null;
      
    } catch (e) {
      print("Failed to fetch image: $e");
      return null;
    }
  }

  Map<String, dynamic> _normalizeHeaders(Map<String, List<String>> headers) {
    return headers.map((k, v) => MapEntry(k.toLowerCase(), v.join(',')));
  }
}