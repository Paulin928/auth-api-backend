import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.instance.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // TODO: gérer le refresh token plus tard
          handler.next(e);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Dio get dio => _dio;

  /// Transforme une DioException en ApiException lisible.
  static ApiException toApiException(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      String msg = 'Erreur inconnue';
      if (data is Map && data['error'] is String) {
        msg = data['error'] as String;
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        msg = 'Le serveur ne répond pas (timeout).';
      } else if (error.type == DioExceptionType.connectionError) {
        msg = 'Impossible de joindre le serveur.';
      } else if (error.message != null) {
        msg = error.message!;
      }
      return ApiException(statusCode: status, message: msg, data: data);
    }
    return ApiException(message: error.toString());
  }
}
