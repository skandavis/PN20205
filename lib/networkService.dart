import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:NagaratharEvents/cacheManager.dart';
import 'package:NagaratharEvents/imageService.dart';
import 'package:NagaratharEvents/introPage.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'utils.dart' as utils;
import 'package:ua_client_hints/ua_client_hints.dart';

const int timeoutSecs = 10;

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  late final Dio dio;
  late final CacheManager cacheManager;
  late final ImageService imageService;
  
  PersistCookieJar? cookieJar;
  bool _initialized = false;
  
  NetworkService._internal() {
    dio = Dio(BaseOptions(
      validateStatus: (status)=> true,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));
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
    dio.interceptors.add(
      InterceptorsWrapper( 
        onRequest: (options, handler) async {
          final myVar = await userAgentClientHintsHeader();
          options.headers.addAll(myVar);
          handler.next(options);
        },
        onResponse: (response, handler) {
          final context = globals.navigatorKey.currentContext;
          if (response.statusCode == 400) {
            // Bad request
          } else if (response.statusCode == 413) {
            utils.snackBarMessage(context!, 'Image too large!');
            print('Image too large');
          } else if (response.statusCode == 403) {
            // Forbidden
          } else if (response.statusCode == 500) {
            // Server problem
          } else if (response.statusCode == 404) {
            utils.snackBarMessage(context!, 'Resource not found!');
          } else if (response.statusCode == 401) {
            final SharedPreferencesAsync prefs = SharedPreferencesAsync();
            prefs.remove('loggedIn');
            globals.mainPageImages.clear();
            // globals.totalActivities.clear();
            Navigator.pushReplacement(
              context!,
              MaterialPageRoute(
                builder: (context) => const introPage(),
              ),
            );
            utils.snackBarMessage(context, 'Unauthorized User! Try Logging In Again.');
          }
          return handler.next(response);
        },
        onError: (e, handler) {
          if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
            utils.snackBarMessage(globals.navigatorKey.currentContext!, 'Connection timed out!');
          }
          return handler.next(e);
        },
      )
    );
  }
  
  Future<dynamic> getRoute(String route, BuildContext context, bool forceRefresh) async {
    await _initIfNeeded();
    if (!forceRefresh) {
      final cached = await cacheManager.loadResource(route);
      if (cached != null) return cached;
    }

    try {
      final response = await dio
          .get('${globals.url}$route');
      
      if (response.statusCode == 200 && response.data != null) {
        final headers = _normalizeHeaders(response.headers.map);
        await cacheManager.saveResource(route, response.data, headers);
        return response.data;
      }
      
      print("Non-200 status (${response.statusCode}), loading from cache");
      return await cacheManager.loadResource(route);
      
    } catch (e) {
      debugPrint(e.toString());
      return await cacheManager.loadResource(route);
    }
  }

  Future<List<dynamic>?> getMultipleRoute(String route, BuildContext context, {bool forceRefresh = false}) async {
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
  
  Future<Response<dynamic>> postRoute(Map<String, dynamic> data, String route) async {
    await _initIfNeeded();
    
    try {
      return await dio
          .post('${globals.url}$route', data: json.encode(data))
          .timeout(Duration(seconds: timeoutSecs));
      
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
      print("Status code: ${response.statusCode}");
      return response.statusCode!;
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
      
    } catch (e) {
      print('An error occurred while deleting: $e');
      return 500;
    }
  }
  
  Future<Response> uploadFile(File file, String route, String fileName, BuildContext context) async {
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
      print(response.data);
      if (response.statusCode == 200) {
        utils.snackBarMessage(context, "File uploaded successfully!", color: Colors.green);  
      }
      return response;
    } catch (e) {
      print('Failed to upload file: $e');
      utils.snackBarMessage(context, "Failed to upload file: $e");
      return _createErrorResponse(route, 500);
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