import 'package:dio/dio.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

class AppDio with DioMixin implements Dio {
  AppDio._([BaseOptions? options]) {
    options = BaseOptions(
      baseUrl: 'http://192.168.86.38:8081/api/v1/',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      sendTimeout: Duration(seconds: 5),
    );

    this.options = options;
    interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final myVar = await userAgentClientHintsHeader();
        options.headers.addAll(myVar);
        handler.next(options); // 👈 VERY IMPORTANT
      },
    ));
  }

  static Dio getInstance() => AppDio._();
}