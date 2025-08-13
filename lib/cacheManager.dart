import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();
  
  CacheManager._();
  
  // In-memory caches
  final Map<String, Map<String, dynamic>> _eventInfoCache = {};
  final Map<String, Uint8List> _imageCache = {};
  final Map<String, LatLng> _geocodeCache = {};
  
  // Cache duration (in milliseconds)
  static const int cacheExpirationTime = 30 * 60 * 1000; // 30 minutes
  
  // Event info caching
  Future<Map<String, dynamic>?> getEventInfo(String eventId) async {
    final cacheKey = 'event_$eventId';
    
    // Check in-memory cache first
    if (_eventInfoCache.containsKey(cacheKey)) {
      final cached = _eventInfoCache[cacheKey]!;
      final timestamp = cached['_cached_at'] as int? ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - timestamp < cacheExpirationTime) {
        return cached['data'];
      }
    }
    
    // Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      try {
        final cached = json.decode(cachedJson);
        final timestamp = cached['_cached_at'] as int? ?? 0;
        if (DateTime.now().millisecondsSinceEpoch - timestamp < cacheExpirationTime) {
          // Update in-memory cache
          _eventInfoCache[cacheKey] = cached;
          return cached['data'];
        }
      } catch (e) {
        debugPrint('Error parsing cached event info: $e');
      }
    }
    
    return null;
  }
  
  Future<void> setEventInfo(String eventId, Map<String, dynamic> data) async {
    final cacheKey = 'event_$eventId';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cachedData = {
      'data': data,
      '_cached_at': timestamp,
    };
    
    // Update in-memory cache
    _eventInfoCache[cacheKey] = cachedData;
    
    // Update persistent cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, json.encode(cachedData));
  }
  
  // Image caching
  Uint8List? getImage(String imageId) {
    return _imageCache[imageId];
  }
  
  void setImage(String imageId, Uint8List imageData) {
    _imageCache[imageId] = imageData;
  }
  
  // Geocoding cache
  LatLng? getGeocode(String address) {
    return _geocodeCache[address];
  }
  
  void setGeocode(String address, LatLng coordinates) {
    _geocodeCache[address] = coordinates;
  }
  
  // Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    
    // Clear expired in-memory event info cache
    _eventInfoCache.removeWhere((key, value) {
      final timestamp = value['_cached_at'] as int? ?? 0;
      return currentTime - timestamp >= cacheExpirationTime;
    });
    
    // Clear expired persistent cache
    final keys = prefs.getKeys().where((key) => key.startsWith('event_'));
    for (final key in keys) {
      final cachedJson = prefs.getString(key);
      if (cachedJson != null) {
        try {
          final cached = json.decode(cachedJson);
          final timestamp = cached['_cached_at'] as int? ?? 0;
          if (currentTime - timestamp >= cacheExpirationTime) {
            await prefs.remove(key);
          }
        } catch (e) {
          // Remove corrupted cache entries
          await prefs.remove(key);
        }
      }
    }
  }
}

class LatLng {
}