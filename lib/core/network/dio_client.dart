import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prarambh_infra/core/constant/cons_strings.dart';
import 'package:prarambh_infra/core/navigation/nav_service.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add our custom interceptors
    dio.interceptors.add(AppInterceptor());

    // Add standard logging only in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }
}

class AppInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO: Fetch your saved Auth Token from local storage (SharedPreferences/SecureStorage)
    // String? token = await getAuthToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }

    // You can add global headers here
    options.headers['Accept'] = 'application/json';

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // You can globally catch standard PHP success responses here if needed
    // e.g., if (response.data['status'] == 'error') { throw custom error }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Global Error Handling
    bool isServerError = false;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        isServerError = true;
        debugPrint("Connectivity/Timeout Error: ${err.message}");
        break;
      case DioExceptionType.badResponse:
        debugPrint(
          "Bad Response: ${err.response?.statusCode} - ${err.response?.data}",
        );
        // Handle 5xx Server Errors
        if (err.response != null && err.response!.statusCode! >= 500) {
          isServerError = true;
        }
        
        // e.g., Handle 401 Unauthorized by logging the user out globally
        if (err.response?.statusCode == 401) {
          // trigger logout logic
        }
        break;
      default:
        debugPrint("Unknown Error: ${err.message}");
        break;
    }

    if (isServerError) {
      // Navigate to Server Error Screen globally
      NavService.pushNamed('/server_error');
    }

    super.onError(err, handler);
  }
}
