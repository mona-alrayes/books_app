import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/author_provider.dart';
import '/models/book.dart';

class AuthorBooksScreen extends StatefulWidget {
  static const routeName = '/author-books';

  const AuthorBooksScreen({super.key});

  @override
  State<AuthorBooksScreen> createState() => _AuthorBooksScreenState();
}

class _AuthorBooksScreenState extends State<AuthorBooksScreen> {
  late int authorId;
  late String authorName;
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    authorId = args['id'];
    authorName = args['name'];
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await Provider.of<AuthorProvider>(context, listen: false)
          .fetchBooksByAuthor(authorId);
      setState(() {
        _books = books;
      });
    } catch (_) {
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
        title: Text('كتب: $authorName'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? Center(child: Text('لا توجد كتب لهذا المؤلف'))
              : RefreshIndicator(
                  onRefresh: _loadBooks,
                  child: ListView.separated(
                    itemCount: _books.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (ctx, i) {
                      final book = _books[i];
                      return ListTile(
                        leading: book.coverImageUrl != null
                            ? Image.network(book.coverImageUrl!,
                                width: 50, fit: BoxFit.cover)
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
