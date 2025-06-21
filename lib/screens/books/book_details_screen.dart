import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/book_provider.dart';
import '/models/book.dart';

class BookDetailsScreen extends StatefulWidget {
  static const routeName = '/book-details';

  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  Book? _book;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bookId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchBookDetails(bookId);
  }

  Future<void> _fetchBookDetails(int id) async {
    final book = await Provider.of<BookProvider>(context, listen: false).fetchBookById(id);
    setState(() {
      _book = book;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الكتاب'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _book == null
              ? Center(child: Text('الكتاب غير موجود'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      _book!.coverImageUrl != null
                          ? Image.network(_book!.coverImageUrl!)
                          : Icon(Icons.book, size: 150),
                      SizedBox(height: 16),
                      Text(
                        _book!.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('المؤلف: ${_book!.authorName ?? "غير معروف"}'),
                      SizedBox(height: 4),
                      Text('الناشر: ${_book!.publisherName ?? "غير معروف"}'),
                      SizedBox(height: 4),
                      Text('نوع الكتاب: ${_book!.type}'),
                      SizedBox(height: 4),
                      Text('السعر: \$${_book!.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
    );
  }
}
