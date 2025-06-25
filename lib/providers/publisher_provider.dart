import 'package:flutter/material.dart';
import '../models/publisher.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class PublisherProvider with ChangeNotifier {
  List<Publisher> _publishers = [];

  List<Publisher> get publishers => [..._publishers];

  Future<void> fetchPublishers() async {
    try {
      print('=== DEBUG: Fetching Publishers ===');
      final data = await ApiService.get('/publishers/search?name=');
      print('Publishers response: $data');
      
      _publishers = (data['data'] as List).map((item) => Publisher.fromJson(item)).toList();
      print('=== DEBUG: Parsed Publishers ===');
      print('Publishers count: ${_publishers.length}');
      print('Publishers: ${_publishers.map((p) => '${p.name} (ID: ${p.id})').join(', ')}');
      
      print('=== DEBUG: Notifying Publishers Listeners ===');
      notifyListeners();
      print('=== DEBUG: Publishers Listeners Notified ===');
    } catch (e) {
      print('Error fetching publishers: $e');
    }
  }

  Future<void> searchPublishers(String query) async {
    try {
      final data = await ApiService.get('/publishers/search?name=$query');
      _publishers = (data['data'] as List).map((item) => Publisher.fromJson(item)).toList();
      notifyListeners();
    } catch (e) {
      print('Error searching publishers: $e');
    }
  }

  Future<List<Book>> fetchBooksByPublisher(int publisherId) async {
    try {
      print('=== DEBUG: Fetching Books for Publisher ===');
      print('Publisher ID: $publisherId');
      
      final data = await ApiService.get('/publishers/$publisherId/books');
      print('=== DEBUG: Publisher Books Response ===');
      print('Raw response: $data');
      
      if (data == null) {
        print('=== DEBUG: Data is null ===');
        return [];
      }
      
      final dataSection = data['data'];
      if (dataSection == null) {
        print('=== DEBUG: data["data"] is null ===');
        return [];
      }
      
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
      
      final validBooks = <Book>[];
      for (int i = 0; i < booksJson.length; i++) {
        final bookData = booksJson[i];
        print('=== DEBUG: Processing book $i ===');
        print('Book data: $bookData');
        print('Book data type: ${bookData.runtimeType}');
        
        if (bookData is Map<String, dynamic>) {
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
      
      print('=== DEBUG: Final Parsed Publisher Books ===');
      print('Valid books count: ${validBooks.length}');
      print('Books: ${validBooks.map((b) => '${b.title} (ID: ${b.id})').join(', ')}');
      
      return validBooks;
    } catch (e) {
      print('=== DEBUG: Error fetching publisher books: $e ===');
      return [];
    }
  }
}
