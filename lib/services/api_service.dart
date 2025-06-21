import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/author.dart';
import '../models/publisher.dart';

class ApiService {
  static const String baseUrl = 'https://e-library-7gta.onrender.com/api';
  static String? _token;

  /// تعيين التوكن بعد تسجيل الدخول
  static void setToken(String token) {
    print('Setting token: ${token.substring(0, 20)}...');
    _token = token;
  }

  /// مسح التوكن عند تسجيل الخروج
  static void clearToken() {
    _token = null;
  }

  /// Build headers for requests
  static Map<String, String> _headers({bool isJson = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (isJson) 'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    print('Building headers. Token present: ${_token != null}');
    print('Headers: $headers');
    return headers;
  }

  /// Handle non-2xx responses
  static void _handleErrors(http.Response response) {
    print('Checking response status: ${response.statusCode}');
    if (response.statusCode >= 400) {
      String message;
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? body.toString();
        print('Error message from API: $message');
      } catch (_) {
        message = response.body;
        print('Raw error response: $message');
      }
      throw HttpException('Error ${response.statusCode}: $message');
    }
  }

  /// GET request
  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('Making GET request to: $url');
    print('Headers: ${_headers()}');
    final response = await http.get(url, headers: _headers());
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    _handleErrors(response);
    return jsonDecode(response.body);
  }

  /// POST request with JSON body
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('Making POST request to: $url');
    print('POST data: $data');
    print('POST headers: ${_headers()}');
    
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode(data),
    );
    
    print('POST response status: ${response.statusCode}');
    print('POST response body: ${response.body}');
    
    _handleErrors(response);
    return jsonDecode(response.body);
  }

  /// POST multipart (e.g., book cover upload)
  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? filePath,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(_headers(isJson: false))
      ..fields.addAll(fields);

    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('cover_image', filePath));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _handleErrors(response);
    return jsonDecode(response.body);
  }

  // ——————————————————————
  // Auth
  // ——————————————————————

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('Logging in with email: $email');
    final response = await post('/login', {
      'email': email,
      'password': password,
    });
    print('Login response: $response');
    return response;
  }

  // ——————————————————————
  // Authors & Publishers
  // ——————————————————————

  static Future<void> addAuthor({
    required String fName,
    required String lName,
    required String country,
    required String city,
    required String address,
  }) async {
    await post('/authors', {
      'FName': fName,
      'LName': lName,
      'Country': country,
      'City': city,
      'Address': address,
    });
  }

  static Future<void> addPublisher({
    required String pName,
    required String country,
  }) async {
    // note: backend now expects 'name' instead of 'PName'
    await post('/publishers', {
      'PName': pName,
      'Country': country,
    });
  }

  static Future<List<Author>> fetchAuthors() async {
    print('Fetching authors from API...');
    try {
      final data = await get('/authors/search?name=');
      print('Authors API response: $data');
      return (data['data'] as List).map((e) => Author.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching authors: $e');
      rethrow;
    }
  }

  static Future<List<Publisher>> fetchPublishers() async {
    print('Fetching publishers from API...');
    try {
      final data = await get('/publishers/search?name=');
      print('Publishers API response: $data');
      return (data['data'] as List).map((e) => Publisher.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching publishers: $e');
      rethrow;
    }
  }

  // ——————————————————————
  // Books
  // ——————————————————————

  static Future<void> addBook({
    required String title,
    required String type,
    required double price,
    required int authorId,
    required int publisherId,
    File? coverImage,
  }) async {
    final fields = {
      'Title': title,
      'Type': type,
      'Price': price.toString(),
      'Author_id': authorId.toString(),
      'Publisher_id': publisherId.toString(),
    };
    await postMultipart('/books', fields, filePath: coverImage?.path);
  }
}
