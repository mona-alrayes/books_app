import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/book_provider.dart';
import '/models/book.dart';
import 'book_details_screen.dart';

class BooksListScreen extends StatefulWidget {
  static const routeName = '/books';

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  bool _isLoading = true;
  // ignore: unused_field
  bool _isSearching = false;
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    await Provider.of<BookProvider>(context, listen: false).fetchBooks();
    setState(() {
      _isLoading = false;
    });
  }

  void _search(String query) async {
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    await Provider.of<BookProvider>(context, listen: false).searchBooks(query);
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = Provider.of<BookProvider>(context).books;

    return Scaffold(
      appBar: AppBar(
        title: Text('الكتب'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'بحث',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadBooks,
                    child: books.isEmpty
                        ? ListView(
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text('لا توجد كتب'),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: books.length,
                            itemBuilder: (ctx, i) {
                              Book book = books[i];
                              return ListTile(
                                leading: book.coverImageUrl != null
                                    ? Image.network(book.coverImageUrl!,
                                        width: 50, fit: BoxFit.cover)
                                    : Icon(Icons.book),
                                title: Text(book.title),
                                subtitle: Text(
                                    '${book.authorName ?? ''} - ${book.publisherName ?? ''}'),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    BookDetailsScreen.routeName,
                                    arguments: book.id,
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
