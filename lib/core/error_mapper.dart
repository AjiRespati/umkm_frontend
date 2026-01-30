import 'package:dio/dio.dart';

class ErrorMapper {
  static String from(dynamic error) {
    if (error is DioException) {
      final status = error.response?.statusCode;

      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect. Check your internet.';
      }

      switch (status) {
        case 400:
          return 'Invalid request.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'You do not have access to this feature.';
        case 404:
          return 'Data not found.';
        case 409:
          return 'Data already exists.';
        case 500:
          return 'Server error. Please try again later.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}
