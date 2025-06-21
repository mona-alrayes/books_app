import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/publisher_provider.dart';
import '/models/book.dart';

class PublisherBooksScreen extends StatefulWidget {
  static const routeName = '/publisher-books';

  const PublisherBooksScreen({super.key});

  @override
  State<PublisherBooksScreen> createState() => _PublisherBooksScreenState();
}

class _PublisherBooksScreenState extends State<PublisherBooksScreen> {
  late int publisherId;
  late String publisherName;
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    publisherId = args['id'];
    publisherName = args['name'];
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final booksData =
          await Provider.of<PublisherProvider>(context, listen: false)
              .fetchBooksByPublisher(publisherId);

      setState(() {
        _books = booksData.map((bookJson) => Book.fromJson(bookJson)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الكتب')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('كتب: $publisherName'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد كتب لهذا الناشر',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBooks,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _books.length,
                    itemBuilder: (ctx, i) {
                      final book = _books[i];
                      return ListTile(
                        leading: book.coverImageUrl != null
                            ? Image.network(
                                book.coverImageUrl!,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.book),
                        title: Text(book.title),
                        subtitle: Text(
                            'النوع: ${book.type} - السعر: \$${book.price}'),
                      );
                    },
                  ),
                ),
    );
  }
}
