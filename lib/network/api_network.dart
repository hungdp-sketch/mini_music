import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiNetwork {
  static final ApiNetwork instance = ApiNetwork._init();
  ApiNetwork._init();

  Dio? _dio;

  Dio get dio {
    if (_dio != null) return _dio!;
    _dio = Dio();
    _dio!.options.headers.addAll({
      'Content-Type': 'application/json',
      'x-app': 'upbeat',
    });
    return _dio!;
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queries,
  }) async {
    try {
      debugPrint('GET: $url, params: $queries');
      final response = await dio.get(url, queryParameters: queries);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint('ApiNetwork GET Error: $e');
    }
    return null;
  }

  Future<dynamic> post(
    String url, {
    dynamic body,
  }) async {
    try {
      debugPrint('POST: $url, body: $body');
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint('ApiNetwork POST Error: $e');
    }
    return null;
  }
}
