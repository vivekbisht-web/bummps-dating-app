import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PrettyLogger {
  static const String _horizontalLine = '═════════════════════════════════════════════════════════════════════';

  /// Prints a boxed message with double line borders
  static void printBox({
    required String title,
    required List<String> lines,
    String tag = 'API',
  }) {
    debugPrint('╔╣ $title');
    for (var line in lines) {
      debugPrint('║  $line');
    }
    debugPrint('╚$_horizontalLine');
  }

  /// Prints a map or list as pretty JSON
  static void printJson({
    required String title,
    required dynamic data,
    String tag = 'API',
  }) {
    final List<String> lines = formatJson(data);
    printBox(title: title, lines: lines, tag: tag);
  }

  /// Converts a map, list, or dynamic data into list of pretty formatted lines
  static List<String> formatJson(dynamic data) {
    if (data == null) return ['null'];
    if (data is Map || data is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        final prettyString = encoder.convert(data);
        return prettyString.split('\n');
      } catch (_) {
        return [data.toString()];
      }
    }
    return [data.toString()];
  }
}

class PrettyDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Request Header and URI
    PrettyLogger.printBox(
      tag: 'API',
      title: 'Request ║ ${options.method}',
      lines: [options.uri.toString()],
    );

    // Query Parameters
    if (options.queryParameters.isNotEmpty) {
      PrettyLogger.printBox(
        tag: 'API',
        title: 'Query Parameters',
        lines: options.queryParameters.entries
            .map((e) => '${e.key}: ${e.value}')
            .toList(),
      );
    }

    // Headers
    if (options.headers.isNotEmpty) {
      PrettyLogger.printBox(
        tag: 'API',
        title: 'Headers',
        lines: options.headers.entries
            .map((e) => '${e.key}: ${e.value}')
            .toList(),
      );
    }

    // Request Body
    if (options.data != null) {
      PrettyLogger.printBox(
        tag: 'API',
        title: 'Request Body',
        lines: PrettyLogger.formatJson(options.data),
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Response Header
    PrettyLogger.printBox(
      tag: 'API',
      title: 'Response ║ ${response.statusCode} ║ ${response.requestOptions.method}',
      lines: [response.requestOptions.uri.toString()],
    );

    // Response Body
    if (response.data != null) {
      PrettyLogger.printBox(
        tag: 'API',
        title: 'Response Body',
        lines: PrettyLogger.formatJson(response.data),
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    PrettyLogger.printBox(
      tag: 'API',
      title: 'Dio Error ║ ${err.type} ║ ${err.requestOptions.method}',
      lines: [
        'URI: ${err.requestOptions.uri}',
        'Message: ${err.message}',
        if (err.response != null) 'Status Code: ${err.response?.statusCode}',
        if (err.response?.data != null) 'Response Body: ${err.response?.data}',
      ],
    );

    super.onError(err, handler);
  }
}
