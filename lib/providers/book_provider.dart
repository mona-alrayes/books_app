import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];

  List<Book> get books {
    print('=== DEBUG: Books Getter Called ===');
    print('Current books count: ${_books.length}');
    print('Books: ${_books.map((b) => '${b.title} (ID: ${b.id})').join(', ')}');
    return [..._books];
  }

  /// Fetch all books
  Future<void> fetchBooks() async {
    try {
      print('=== DEBUG: Fetching Books ===');
      final data = await ApiService.get('/books');
      print('Raw response: $data');
      
      final items = data['data'] as List;
      print('Books count: ${items.length}');
      
      _books = items.map((json) => Book.fromJson(json)).toList();
      print('Parsed books: ${_books.map((b) => '${b.title} (ID: ${b.id})').join(', ')}');
      
      print('=== DEBUG: Notifying Listeners ===');
      notifyListeners();
      print('=== DEBUG: Listeners Notified ===');
      
      // تحقق إضافي من البيانات بعد notifyListeners
      print('=== DEBUG: After notifyListeners ===');
      print('_books count: ${_books.length}');
      print('_books: ${_books.map((b) => '${b.title} (ID: ${b.id})').join(', ')}');
    } catch (e) {
      print('حدث خطأ أثناء جلب الكتب: $e');
    }
  }

  /// Search for books by title
  Future<void> searchBooks(String query) async {
    try {
      final data = await ApiService.get('/books/search?title=$query');
      final items = data['data'] as List;
      _books = items.map((json) => Book.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('حدث خطأ أثناء البحث عن الكتب: $e');
    }
  }

  /// Fetch details of a specific book
  Future<Book?> fetchBookDetails(int id) async {
    try {
      final data = await ApiService.get('/books/$id');
      return Book.fromJson(data['data']);
    } catch (e) {
      print('حدث خطأ أثناء جلب تفاصيل الكتاب: $e');
      return null;
    }
  }

  /// Add a new book (admin only)
  Future<void> addBook(Book book, String? filePath) async {
    try {
      final Map<String, String> fields = {
        'Title': book.title,
        'Type': book.type,
        'Price': book.price.toString(),
        'Publisher_id': book.publisherId.toString(),
        'Author_id': book.authorId.toString(),
      };

      await ApiService.postMultipart('/books', fields, filePath: filePath);
      await fetchBooks(); // Refresh list
    } catch (e) {
      print('فشل في إضافة الكتاب: $e');
      rethrow;
    }
  }

  Future<Book?> fetchBookById(int id) async {
    try {
      final data = await ApiService.get('/books/$id');
      return Book.fromJson(data['data']);
    } catch (e) {
      print('فشل تحميل تفاصيل الكتاب: $e');
      return null;
    }
  }
}
