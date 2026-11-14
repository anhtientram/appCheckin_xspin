import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLogInterceptor extends Interceptor {
  static final JsonEncoder _prettyJson = JsonEncoder.withIndent('  ');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_shouldSkipLog(options.uri)) {
      handler.next(options);
      return;
    }

    _printSection(
      'REQUEST',
      [
        'method: ${options.method.toUpperCase()}',
        'url: ${options.uri}',
        'query: ${_formatValue(options.queryParameters)}',
        'body: ${_formatValue(options.data)}',
      ],
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldSkipLog(response.requestOptions.uri)) {
      handler.next(response);
      return;
    }

    _printSection(
      'RESPONSE',
      [
        'method: ${response.requestOptions.method.toUpperCase()}',
        'url: ${response.requestOptions.uri}',
        'status: ${response.statusCode}',
        'data: ${_formatValue(response.data)}',
      ],
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldSkipLog(err.requestOptions.uri)) {
      handler.next(err);
      return;
    }

    _printSection(
      'ERROR',
      [
        'method: ${err.requestOptions.method.toUpperCase()}',
        'url: ${err.requestOptions.uri}',
        'status: ${err.response?.statusCode ?? 'N/A'}',
        'query: ${_formatValue(err.requestOptions.queryParameters)}',
        'body: ${_formatValue(err.requestOptions.data)}',
        'response: ${_formatValue(err.response?.data)}',
        'message: ${err.message ?? err.error}',
      ],
    );
    handler.next(err);
  }

  void _printSection(String label, List<String> lines) {
    debugPrint(
        '[API][$label] --------------------------------------------------');
    for (final line in lines) {
      debugPrint('[API][$label] $line');
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return 'null';
    }

    final sanitizedValue = _sanitizeValue(value);
    if (sanitizedValue is String) {
      return sanitizedValue;
    }

    try {
      return _prettyJson.convert(sanitizedValue);
    } catch (_) {
      return sanitizedValue.toString();
    }
  }

  dynamic _sanitizeValue(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key.toString(),
          _shouldMask(key.toString()) ? '***' : _sanitizeValue(item),
        ),
      );
    }

    if (value is Iterable) {
      return value.map(_sanitizeValue).toList();
    }

    return value;
  }

  bool _shouldMask(String key) {
    final normalizedKey = key.toLowerCase();
    return normalizedKey.contains('password') ||
        normalizedKey.contains('matkhau') ||
        normalizedKey.contains('token') ||
        normalizedKey.contains('authorization') ||
        normalizedKey.contains('x-api-key');
  }

  bool _shouldSkipLog(Uri uri) {
    final url = uri.toString();
    return url.contains('/getListNguoiThamDu') ||
        url.contains('/getListNguoiThamDu_1L') ||
        url.contains('/getDemSoNguoiThamDu') ||
        url.contains('/getDemSoNguoiThamDu_1L') ||
        url.contains('/getDemSoLuotCheckin');
  }
}
