import 'package:flutter/material.dart';
import '../models/author.dart';
import '../models/book.dart';  // <--- أضف هذا السطر لاستيراد موديل Book
import '../services/api_service.dart';

class AuthorProvider with ChangeNotifier {
  List<Author> _authors = [];

  List<Author> get authors => [..._authors];

  Future<void> fetchAuthors() async {
    try {
      print('=== DEBUG: Fetching Authors ===');
      final data = await ApiService.get('/authors/search?name=');
      print('Authors response: $data');
      
      _authors = (data['data'] as List).map((e) => Author.fromJson(e)).toList();
      print('=== DEBUG: Parsed Authors ===');
      print('Authors count: ${_authors.length}');
      print('Authors: ${_authors.map((a) => '${a.fName} ${a.lName} (ID: ${a.id})').join(', ')}');
      
      print('=== DEBUG: Notifying Authors Listeners ===');
      notifyListeners();
      print('=== DEBUG: Authors Listeners Notified ===');
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
    print('=== DEBUG: Fetching Books for Author ===');
    print('Author ID: $authorId');
    
    final url = '/authors/$authorId/books';
    print('URL: $url');
    
    final data = await ApiService.get(url);
    print('=== DEBUG: Author Books Response ===');
    print('Raw response: $data');
    
    // تحقق من وجود data
    if (data == null) {
      print('=== DEBUG: Data is null ===');
      return [];
    }
    
    // تحقق من وجود data['data']
    final dataSection = data['data'];
    if (dataSection == null) {
      print('=== DEBUG: data["data"] is null ===');
      return [];
    }
    
    // تحقق من وجود books
    final booksJson = dataSection['books'];
    print('=== DEBUG: Books JSON before processing ===');
    print('Books JSON: $booksJson');
    print('Books JSON type: ${booksJson.runtimeType}');
    
    if (booksJson == null) {
      print('=== DEBUG: books is null ===');
      return [];
    }
    
    if (booksJson is! List) {
      print('=== DEBUG: books is not a List, it is: ${booksJson.runtimeType} ===');
      return [];
    }
    
    // تحقق من كل عنصر قبل التحويل
    final validBooks = <Book>[];
    for (int i = 0; i < booksJson.length; i++) {
      final bookData = booksJson[i];
      print('=== DEBUG: Processing book $i ===');
      print('Book data: $bookData');
      print('Book data type: ${bookData.runtimeType}');
      
      if (bookData is Map<String, dynamic>) {
        // تحقق من وجود Title أو title
        final title = bookData['Title'] ?? bookData['title'];
        if (title != null) {
          try {
            final book = Book.fromJson(bookData);
            validBooks.add(book);
            print('=== DEBUG: Successfully parsed book: ${book.title} ===');
          } catch (e) {
            print('=== DEBUG: Failed to parse book $i: $e ===');
          }
        } else {
          print('=== DEBUG: Book $i has no title field ===');
        }
      } else {
        print('=== DEBUG: Book $i is not a Map, it is: ${bookData.runtimeType} ===');
      }
    }
    
    print('=== DEBUG: Final Parsed Author Books ===');
    print('Valid books count: ${validBooks.length}');
    print('Books: ${validBooks.map((b) => '${b.title} (ID: ${b.id})').join(', ')}');
    
    return validBooks;
  } catch (e) {
    print('=== DEBUG: Error fetching author books: $e ===');
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
