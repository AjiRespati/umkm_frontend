import 'package:dio/dio.dart';
import 'auth_storage.dart';
import 'constants.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        print('❌ API Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}

final apiClient = ApiClient().client;