import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import 'storage_service.dart';

class ApiService {
  static late Dio _dio;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final token = await StorageService.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
          await StorageService.clearAll();
        }
        handler.next(error);
      },
    ));
    _initialized = true;
  }

  static Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;
      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refresh}',
        data: {'refreshToken': refreshToken},
      );
      await StorageService.saveTokens(
        response.data['accessToken'],
        response.data['refreshToken'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static AppException _handleError(DioException e) {
    final message = e.response?.data?['message'] ?? e.message ?? 'Something went wrong';
    return AppException(
      message is List ? message.first : message.toString(),
      statusCode: e.response?.statusCode,
    );
  }
}
