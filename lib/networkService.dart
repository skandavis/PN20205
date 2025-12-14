import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:NagaratharEvents/cacheManager.dart';
import 'package:NagaratharEvents/imageService.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;
import 'utils.dart' as utils;
import 'package:ua_client_hints/ua_client_hints.dart';

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
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      baseUrl: globals.url
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
        onResponse: (response, handler) async {
          bool showAboveSnackBar = response.requestOptions.extra['showAboveSnackBar'] == true;
          if (response.statusCode == 403) {
            showMessage("You're not authorized!", showAboveSnackBar);
          } else if (response.statusCode == 422) {
            showMessage(response.data, showAboveSnackBar);
          } else if (response.statusCode == 413) {
            showMessage(response.data ?? 'Image way too large!', showAboveSnackBar);
          } else if (response.statusCode == 498) {
            return handler.resolve(await refresh(response.requestOptions));
          } else if (response.statusCode == 500) {
            showMessage('Something Went Wrong! Try again later.', showAboveSnackBar);
          } else if (response.statusCode == 404) {
            if(response.requestOptions.extra['skipIntercept'] == true) {
              return handler.next(response);
            }
            showMessage('Resource not found!', showAboveSnackBar);
          } else if(response.statusCode == 400){
            showMessage('Request Failed!', showAboveSnackBar);
          } else if (response.statusCode == 401) {
            if(response.requestOptions.extra['skipIntercept'] == true) {
              return handler.next(response);
            }
            // utils.logout();
            utils.snackBarMessage('Unauthorized User! Try Logging In Again.');
          }
          return handler.next(response);
        },
        onError: (e, handler) {
          if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
            showMessage('Internet connection timed out. Check your connection and try again.',e.requestOptions.extra['showAboveSnackBar'] == true);
          }
          return handler.next(e);
        },
      )
    );
  }
  
  void showMessage(String message, bool showAboveSnackBar) {
    if (showAboveSnackBar) {
      utils.snackBarAboveMessage(message);
    } else {
      utils.snackBarMessage(message);
    }
  }

  Future<Response> refresh(RequestOptions options) async
  {
    await dio.get('auth/refresh-token');
    if(options.data is FormData)
    {
      FormData formData = options.data as FormData;
      return await dio.post(options.path, data: formData,options: Options(headers: {'Content-Type': 'multipart/form-data'}));
    }
    return dio.fetch(options);
  }

  Future<Response<dynamic>> getRoute(String route, bool forceRefresh) async {
    await _initIfNeeded();
    if (!forceRefresh) {
      final cached = await cacheManager.loadResource(route);
      if (cached != null) return Response (requestOptions: RequestOptions(path: route), data: cached);
    }

    try {
      final response = await dio
          .get(route);

      if (response.statusCode == 200 && response.data != null) {
        final headers = _normalizeHeaders(response.headers.map);
        await cacheManager.saveResource(route, response.data, headers);
        return response;
      }
      
      return Response (requestOptions: RequestOptions(path: route), data: await cacheManager.loadResource(route));
      
    } catch (e) {
      return Response (requestOptions: RequestOptions(path: route), data: await cacheManager.loadResource(route));
    }
  }

  Future<List<dynamic>?> getMultipleRoute(String route, {bool forceRefresh = false}) async {
    final response = await getRoute(route, forceRefresh);
    final data = response.data;
    
    if (data is List<dynamic>) {
      return data;
    }
    
    if (data is Map<String, dynamic>) {
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> getSingleRoute(String route, {bool forceRefresh = false}) async {
    final response = await getRoute(route, forceRefresh);
    final data = response.data;
    
    if (data is Map<String, dynamic>) {
      return data;
    }
    
    if (data is List<dynamic>) {
    }
    
    return null;
  }
  
  void clearCache() {
    cacheManager.cleanup(deleteAll: true);
  }

  Future<Response<dynamic>> postRoute(Map<String, dynamic> data, String route, {bool skipIntercept = false, bool showAboveSnackBar = false}) async {
    await _initIfNeeded();
    
    try {
      final response = await dio.post(
        route, 
        data: json.encode(data),
        options: Options(
          extra: {
            "skipIntercept": skipIntercept, 
            "showAboveSnackBar": showAboveSnackBar
          }
        )
      );
      return response;
    } catch (e) {
      return _createErrorResponse(route, 500);
    }
  }
  
  Future<Response<dynamic>> patchRoute(Map<String, dynamic> data, String route, {showAboveSnackBar = false}) async {
    await _initIfNeeded();
    
    try {
      final response = await dio.patch(
        route, 
        data: json.encode(data),
        options: Options(
          extra: {
            "showAboveSnackBar": showAboveSnackBar
          }
        )
      );
      return response;
    } catch (e) {
      return _createErrorResponse(route, 500);
    }
  }

  Future<Response<dynamic>> patchNoData(String route) async {
    await _initIfNeeded();
    
    try {
      final response = await dio
          .patch(route);
      return response;
    } catch (e) {
      return _createErrorResponse(route, 500);
    }
  }
  
  Future<Response<dynamic>> deleteRoute(String route, {showAboveSnackBar = false}) async {
    await _initIfNeeded();
    
    try {
      final response = await dio.delete(
        route,
        options: Options(
          extra: {
            "showAboveSnackBar": showAboveSnackBar
          }
        )
      );
      return response;
      
    } catch (e) {
      return _createErrorResponse(route, 500);
    }
  }
  
  Future<Response> uploadFile(MultipartFile file, String route, String fileName, BuildContext context, {showAboveSnackBar = false}) async {
    await _initIfNeeded();
    
    final formData = FormData.fromMap({
      'file': file,
      'name': fileName
    });

    try {
      final response = await dio.post(
        route,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          extra: {
            "showAboveSnackBar": showAboveSnackBar
          }
        ),
      );
      if (response.statusCode == 200) {
        if(showAboveSnackBar)
        {
          utils.snackBarAboveMessage("File uploaded successfully!", color: Colors.green);
        }else{
          utils.snackBarMessage("File uploaded successfully!", color: Colors.green);  
        }
      }
      return response;
    } catch (e) {
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