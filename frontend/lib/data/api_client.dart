import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:nutriview/core/config.dart';
import 'package:nutriview/core/error_handler.dart';

class ApiClient {
  final http.Client _client;
  final FlutterSecureStorage _storage;
  final String baseUrl;
  void Function()? onUnauthorized;

  ApiClient({
    http.Client? client,
    FlutterSecureStorage? storage,
    String? baseUrl,
    this.onUnauthorized,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage(),
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  static const String _tokenKey = 'nutriview_access_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<Map<String, String>> _headers({bool isMultipart = false}) async {
    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 204) {
      return null;
    }

    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }

    if (body is Map<String, dynamic> && body.containsKey('error')) {
      final err = body['error'] as Map<String, dynamic>;
      throw ApiException(
        statusCode: response.statusCode,
        code: err['code'] as String? ?? 'ERROR',
        message: err['message'] as String? ?? 'Terjadi kesalahan.',
        details: err['details'] as List<dynamic>?,
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_${response.statusCode}',
      message: 'Permintaan gagal (${response.statusCode})',
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    Uri uri = Uri.parse('$baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())),
      );
    }

    final headers = await _headers();
    final response = await _client.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final response = await _client.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final response = await _client.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> uploadImage(String path, File imageFile) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    final headers = await _headers(isMultipart: true);
    request.headers.addAll(headers);

    String filename = imageFile.path.split(Platform.pathSeparator).last;
    final lower = filename.toLowerCase();
    MediaType contentType;
    if (lower.endsWith('.png')) {
      contentType = MediaType('image', 'png');
    } else if (lower.endsWith('.webp')) {
      contentType = MediaType('image', 'webp');
    } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      contentType = MediaType('image', 'jpeg');
    } else {
      filename = '$filename.jpg';
      contentType = MediaType('image', 'jpeg');
    }

    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: filename,
      contentType: contentType,
    );
    request.files.add(multipartFile);

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }
}
