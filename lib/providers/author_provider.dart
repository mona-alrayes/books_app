import 'package:flutter/material.dart';
import '../models/author.dart';
import '../models/book.dart';  // <--- أضف هذا السطر لاستيراد موديل Book
import '../services/api_service.dart';

class AuthorProvider with ChangeNotifier {
  List<Author> _authors = [];

  List<Author> get authors => [..._authors];

  Future<void> fetchAuthors() async {
    try {
      final data = await ApiService.get('/authors/search?name=');
      _authors = (data['data'] as List).map((e) => Author.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print('فشل تحميل المؤلفين: $e');
    }
  }

  Future<void> searchAuthors(String query) async {
    try {
      final data = await ApiService.get('/authors/search?name=$query');
      _authors = (data['data'] as List).map((e) => Author.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print('فشل البحث عن المؤلفين: $e');
    }
  }

 Future<List<Book>> fetchBooksByAuthor(int authorId) async {
  try {
    final data = await ApiService.get('/authors/$authorId/books');
    final booksJson = data['data']?['books'] ?? [];
    return (booksJson as List).map((e) => Book.fromJson(e)).toList();
  } catch (e) {
    print('فشل تحميل كتب المؤلف: $e');
    return [];
  }
}


  Future<void> addAuthor(Author author) async {
    try {
      await ApiService.post('/authors', author.toJson());
      await fetchAuthors(); // تحديث القائمة بعد الإضافة
    } catch (e) {
      print('فشل إضافة المؤلف: $e');
      rethrow;
    }
  }
}
