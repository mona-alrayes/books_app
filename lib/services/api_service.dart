import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
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
      } catch (_) {
        message = response.body;
      }
      throw HttpException('خطأ ${response.statusCode}: $message');
    }
  }

  /// GET request
  static Future<dynamic> get(String endpoint) async {
  final url = Uri.parse('$baseUrl$endpoint');
  final response = await http.get(url, headers: _headers());
  print('GET $url status: ${response.statusCode}');
  print('Response body: ${response.body}');
  _handleErrors(response);
  return jsonDecode(response.body);
}


  /// POST request with JSON body
  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode(data),
    );
    _handleErrors(response);
    return jsonDecode(response.body);
  }

  /// POST multipart (مثل غلاف الكتاب)
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
      request.files
          .add(await http.MultipartFile.fromPath('cover_image', filePath));
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
    final response = await post('/login', {
      'email': email,
      'password': password,
    });
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
    await post('/publishers', {
      'PName': pName,
      'Country': country,
    });
  }

  static Future<List<Author>> fetchAuthors() async {
    final jsonResponse = await get('/authors');
    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('data')) {
      final authorsList = jsonResponse['data'] as List;
      return authorsList.map((e) => Author.fromJson(e)).toList();
    } else {
      throw Exception('Invalid response format for authors');
    }
  }

  static Future<List<Publisher>> fetchPublishers() async {
    final jsonResponse = await get('/publishers');
    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('data')) {
      final publishersList = jsonResponse['data'] as List;
      return publishersList.map((e) => Publisher.fromJson(e)).toList();
    } else {
      throw Exception('Invalid response format for publishers');
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
      'author_id': authorId.toString(),
      'publisher_id': publisherId.toString(),
    };
    await postMultipart('/books', fields, filePath: coverImage?.path);
  }
}
