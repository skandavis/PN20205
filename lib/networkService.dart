import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'globals.dart' as globals;

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  late Dio dio;
  PersistCookieJar? cookieJar;
  bool _initialized = false;
  int timeoutSecs = 30;

  late Directory _cacheDir;

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
    _cacheDir = Directory('${dir.path}/.cache/');
    await _cacheDir.create(recursive: true);

    // Cookie management
    final cookiePath = '${dir.path}/.cookies/';
    await Directory(cookiePath).create(recursive: true);
    cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
    dio.interceptors.add(CookieManager(cookieJar!));

    _initialized = true;
  }

  Future<List<dynamic>?> getMultipleRoute(String route) async {
    final responseData = await getRoute(route);
    if (responseData is Map<String, dynamic>) {
      print("Single object received. Not Multiple!");
      return null;
    } else if (responseData is List<dynamic>) {
      for (var item in responseData) {
        print(item.toString());
      }
      return responseData;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSingleRoute(String route) async {
    final responseData = await getRoute(route);
    if (responseData is Map<String, dynamic>) {
      print(responseData.toString());
      return responseData;
    } else if (responseData is List<dynamic>) {
      print("Multiple objects received. Not Single!");
      return null;
    } else {
      return null;
    }
  }

  Future<dynamic> getRoute(String route) async {
    await _initIfNeeded(); 
    try {
      final response = await dio
          .get(
            '${globals.url}$route',
          )
          .timeout(Duration(seconds: timeoutSecs));
      return response.data;
    } on TimeoutException {
      print("GET request to $route timed out");
      return;
    } on DioException catch (e) {
      print("Failed to load $route: ${e.message}");
      return;
    } catch (e) {
      print("Unexpected error for $route: $e");
      return;
    }
  }

  Future<Response<dynamic>> postRoute(Map<String, dynamic> data, String route) async {
    await _initIfNeeded();
    try {
      final response = await dio
          .post(
            '${globals.url}$route',
            data: json.encode(data),
          )
          .timeout(Duration(seconds: timeoutSecs));
      if (response.statusCode == 200) {
        print('Sent successfully!');
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
      }

      return response;
    } on TimeoutException {
      print('Request timed out.');
      return Response(data: null, statusCode: 408, requestOptions: RequestOptions(path: route));
    } catch (e) {
      print('An error occurred: $e');
      return Response(data: null, statusCode: 500, requestOptions: RequestOptions(path: route));
    }
  }
  
  Future<int> patchNoData(String route) async {
    await _initIfNeeded();
    try {
      final response = await dio
          .patch(
            '${globals.url}$route',
          )
          .timeout(Duration(seconds: timeoutSecs));

      if (response.statusCode == 200) {
        print('Updated successfully!');
      } else {
        print('Failed to update. Status code: ${response.statusCode}');
      }
      return response.statusCode!;
    }  on TimeoutException catch (e) {
      print('Request timed out: $e');
      return 408; // custom code for timeout
    } catch (e) {
      print('Unexpected error: $e');
      return 500; // generic error code
    }
  }
  Future<int> patchRoute(Map<String, dynamic> data, String route) async {
    await _initIfNeeded();
    try {
      final response = await dio
          .patch(
            '${globals.url}$route',
            data: json.encode(data),
          )
          .timeout(Duration(seconds: timeoutSecs));
      if (response.statusCode == 200) {
        print('Patched successfully!');
      } else {
        print('Failed to patch. Status code: ${response.statusCode}');
      }

      return response.statusCode!;
    } on TimeoutException {
      print('PATCH request to $route timed out.');
      return 408;
    } catch (e) {
      print('An error occurred while patching: $e');
      return 500;
    }
  }

  Future<int> deleteRoute(String route) async {
    await _initIfNeeded();
    try {
      final response = await dio
          .delete(
            '${globals.url}$route',
          )
          .timeout(Duration(seconds: timeoutSecs));

      if (response.statusCode == 200) {
        print('Deleted successfully!');
      } else {
        print('Failed to delete data. Status code: ${response.statusCode}');
      }

      return response.statusCode!;
    } on TimeoutException {
      print('Delete request timed out.');
      return 408;
    } catch (e) {
      print('An error occurred while deleting: $e');
      return 500;
    }
  }

  String _getCacheFilePath(String url) {
    final filename = base64Url.encode(utf8.encode(url));
    return '${_cacheDir.path}/$filename';
  }

  Future<void> _saveToCache(String url, Uint8List data, Map<String, dynamic> headers) async {
    final file = File(_getCacheFilePath(url));
    final cacheData = {
      'headers': headers,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'body': base64Encode(data),
    };
    await file.writeAsString(jsonEncode(cacheData));
  }

  Future<Uint8List?> _loadFromCache(String url) async {
    final file = File(_getCacheFilePath(url));
    if (!await file.exists()) return null;

    try {
      final jsonData = jsonDecode(await file.readAsString());
      final headers = Map<String, dynamic>.from(jsonData['headers'] ?? {});
      final body = base64Decode(jsonData['body']);
      final timestamp = jsonData['timestamp'] ?? 0;

      if (headers.containsKey('cache-control')) {
        final cc = headers['cache-control'] as String;
        final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cc);
        if (maxAgeMatch != null) {
          final maxAge = int.tryParse(maxAgeMatch.group(1) ?? '') ?? 0;
          final expiry = timestamp + maxAge * 1000;
          if (DateTime.now().millisecondsSinceEpoch > expiry) {
            await file.delete(); // expired
            return null;
          }
        }
      }

      return body;
    } catch (e) {
      print('Failed to read cache: $e');
      return null;
    }
  }

  Future<Uint8List?> getImage(String route) async {
    await _initIfNeeded();

    final url = '${globals.baseUrl}$route';
    final cached = await _loadFromCache(url);
    if (cached != null) return cached;

    try {
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data is Uint8List) {
        final headers = response.headers.map.map((k, v) => MapEntry(k.toLowerCase(), v.join(',')));
        await _saveToCache(url, response.data, headers);
        return response.data;
      } else {
        print("Unexpected data type: ${response.data.runtimeType}");
        return null;
      }
    } catch (e) {
      print("Failed to fetch image: $e");
      return null;
    }
  }

  void uploadFile(File file, String route) async {
    await _initIfNeeded();
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: 'profile.jpg',
      ),
    });

    try {
      final response = await dio.post(
        globals.url + route,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      print('Upload successful: ${response.data}');
    } catch (e) {
      print('Upload failed: $e');
    }
  }
}
