import 'package:flutter/material.dart';
import '../models/publisher.dart';
import '../services/api_service.dart';

class PublisherProvider with ChangeNotifier {
  List<Publisher> _publishers = [];

  List<Publisher> get publishers => [..._publishers];

  Future<void> fetchPublishers() async {
    try {
      final data = await ApiService.get('/publishers/search?name=');
      _publishers = (data['data'] as List).map((item) => Publisher.fromJson(item)).toList();
      notifyListeners();
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

  Future<List<dynamic>> fetchBooksByPublisher(int publisherId) async {
    try {
      final data = await ApiService.get('/publishers/$publisherId/books');
      return data['data']['books'] ?? [];
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }
}
