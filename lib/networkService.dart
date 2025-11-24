import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:PN2025/cacheManager.dart';
import 'package:PN2025/imageService.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;
import 'utils.dart' as utils;
import 'package:ua_client_hints/ua_client_hints.dart';

const int timeoutSecs = 10;

Dio getInsecureDio() {
  final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: timeoutSecs),
      receiveTimeout: Duration(seconds: timeoutSecs),
      sendTimeout: Duration(seconds: timeoutSecs),
    ));

  // Override HttpClient globally for this Dio instance
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  return dio;
}
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  late final Dio dio;
  late final CacheManager cacheManager;
  late final ImageService imageService;
  
  PersistCookieJar? cookieJar;
  bool _initialized = false;
  

  NetworkService._internal() {
    dio = getInsecureDio();

    // dio = AppDio.getInstance();
  }

  Future<void> _initIfNeeded() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    
    await _setupCookies(dir);
    cacheManager = CacheManager(dir);
    await cacheManager.init();
    
    // cacheManager.cleanup();
    imageService = ImageService(dio, cacheManager);
    
    _initialized = true;
  }

  Future<void> _setupCookies(Directory dir) async {
    final cookiePath = '${dir.path}/.cookies/';
    await Directory(cookiePath).create(recursive: true);
    cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
    dio.interceptors.add(CookieManager(cookieJar!));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final myVar = await userAgentClientHintsHeader();
        options.headers.addAll(myVar);
        handler.next(options);
      },
    ));
  }
  
  Future<dynamic> getRoute(String route, BuildContext context, bool forceRefresh) async {
    await _initIfNeeded();
    if (!forceRefresh) {
      final cached = await cacheManager.loadResource(route);
      if (cached != null) return cached;
    }

    try {
      final response = await dio
          .get('${globals.url}$route')
          .timeout(Duration(seconds: timeoutSecs));
      
      if (response.statusCode == 200 && response.data != null) {
        final headers = _normalizeHeaders(response.headers.map);
        await cacheManager.saveResource(route, response.data, headers);
        return response.data;
      }
      
      print("Non-200 status (${response.statusCode}), loading from cache");
      return await cacheManager.loadResource(route);
      
    } catch (e) {
      return await _handleGetError(route, e, context);
    }
  }

  Future<List<dynamic>?> getMultipleRoute(String route,BuildContext context, {bool forceRefresh = false}) async {
    final data = await getRoute(route, context, forceRefresh);
    
    if (data is List<dynamic>) {
      data.forEach(print);
      return data;
    }
    
    if (data is Map<String, dynamic>) {
      print("Single object received. Not Multiple!");
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> getSingleRoute(String route, BuildContext context, {bool forceRefresh = false}) async {
    final data = await getRoute(route, context, forceRefresh);
    
    if (data is Map<String, dynamic>) {
      print(data.toString());
      return data;
    }
    
    if (data is List<dynamic>) {
      print("Multiple objects received. Not Single!");
    }
    
    return null;
  }

  Future<dynamic> _handleGetError(String route, dynamic error, BuildContext context) async {
    if (error is TimeoutException) {
      utils.snackBarMessage(context, "Request for $route has timed out, loading from previous cache");
    } else if (error is DioException) {
      utils.snackBarMessage(context,"Failed to load $route: ${error.message}, loading from cache" );
    } else {
      utils.snackBarMessage(context,"Unexpected error for $route: $error, loading from cache");
    }
    print(error);
    return await cacheManager.loadResource(route);
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
      ("Status code: ${response.statusCode}");
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
      'photo': await MultipartFile.fromFile(file.path),
      'name': fileName
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

  Map<String, dynamic> _normalizeHeaders(Map<String, List<String>> headers) {
    return headers.map((k, v) => MapEntry(k.toLowerCase(), v.join(',')));
  }
}