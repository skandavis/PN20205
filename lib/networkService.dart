import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:PN2025/cacheManager.dart';
import 'package:PN2025/imageService.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  late final Dio dio;
  late final CacheManager cacheManager;
  late final ImageService imageService;
  
  PersistCookieJar? cookieJar;
  bool _initialized = false;
  
  static const int timeoutSecs = 3;

  NetworkService._internal() {
    dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: timeoutSecs),
      receiveTimeout: Duration(seconds: timeoutSecs),
      sendTimeout: Duration(seconds: timeoutSecs),
    ));
  }

  Future<void> _initIfNeeded() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    
    await _setupCookies(dir);
    cacheManager = CacheManager(dir);
    await cacheManager.init();
    
    imageService = ImageService(dio, cacheManager);
    
    _initialized = true;
  }

  Future<void> _setupCookies(Directory dir) async {
    final cookiePath = '${dir.path}/.cookies/';
    await Directory(cookiePath).create(recursive: true);
    cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
    dio.interceptors.add(CookieManager(cookieJar!));
  }
  
  Future<dynamic> getRoute(String route) async {
    await _initIfNeeded();
    
    try {
      final response = await dio
          .get('${globals.url}$route')
          .timeout(Duration(seconds: timeoutSecs));
      
      if (response.statusCode == 200 && response.data != null) {
        await cacheManager.saveJson(route, response.data);
        return response.data;
      }
      
      print("Non-200 status (${response.statusCode}), loading from cache");
      return await cacheManager.loadJson(route);
      
    } catch (e) {
      return await _handleGetError(route, e);
    }
  }

  Future<List<dynamic>?> getMultipleRoute(String route) async {
    final data = await getRoute(route);
    
    if (data is List<dynamic>) {
      data.forEach(print);
      return data;
    }
    
    if (data is Map<String, dynamic>) {
      print("Single object received. Not Multiple!");
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> getSingleRoute(String route) async {
    final data = await getRoute(route);
    
    if (data is Map<String, dynamic>) {
      print(data.toString());
      return data;
    }
    
    if (data is List<dynamic>) {
      print("Multiple objects received. Not Single!");
    }
    
    return null;
  }

  Future<dynamic> _handleGetError(String route, dynamic error) async {
    if (error is TimeoutException) {
      print("GET request to $route timed out, loading from cache");
    } else if (error is DioException) {
      print("Failed to load $route: ${error.message}, loading from cache");
    } else {
      print("Unexpected error for $route: $error, loading from cache");
    }
    
    return await cacheManager.loadJson(route);
  }
  
  Future<Response<dynamic>> postRoute(Map<String, dynamic> data, String route) async {
    await _initIfNeeded();
    
    try {
      return await dio
          .post('${globals.url}$route', data: json.encode(data))
          .timeout(Duration(seconds: timeoutSecs));
      
    } on TimeoutException {
      print('Request timed out.');
      return _createErrorResponse(route, 408);
    } catch (e) {
      print('An error occurred: $e');
      return _createErrorResponse(route, 500);
    }
  }
  
  Future<int> patchRoute(Map<String, dynamic> data, String route) async {
    await _initIfNeeded();
    
    try {
      final response = await dio
          .patch('${globals.url}$route', data: json.encode(data))
          .timeout(Duration(seconds: timeoutSecs));
      return response.statusCode!;
    } on TimeoutException {
      print('PATCH request to $route timed out.');
      return 408;
    } catch (e) {
      print('An error occurred while patching: $e');
      return 500;
    }
  }

  Future<int> patchNoData(String route) async {
    await _initIfNeeded();
    
    try {
      final response = await dio
          .patch('${globals.url}$route')
          .timeout(Duration(seconds: timeoutSecs));
      return response.statusCode!;
    } on TimeoutException {
      print('Request timed out.');
      return 408;
    } catch (e) {
      print('Unexpected error: $e');
      return 500;
    }
  }
  
  Future<int> deleteRoute(String route) async {
    await _initIfNeeded();
    
    try {
      final response = await dio
          .delete('${globals.url}$route')
          .timeout(Duration(seconds: timeoutSecs));
      return response.statusCode!;
      
    } on TimeoutException {
      print('Delete request timed out.');
      return 408;
    } catch (e) {
      print('An error occurred while deleting: $e');
      return 500;
    }
  }
  
  Future<void> uploadFile(File file, String route, String fileName) async {
    await _initIfNeeded();
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final response = await dio.post(
        '${globals.url}$route',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      
      print('Upload successful: ${response.data}');
    } catch (e) {
      print('Upload failed: $e');
    }
  }
  
  Future<Uint8List?> getImage(String route) async {
    await _initIfNeeded();
    return await imageService.getImage(route);
  }
  
  Response<dynamic> _createErrorResponse(String route, int statusCode) {
    return Response(
      data: null,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: route),
    );
  }
}