import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/author_provider.dart';
import '/models/author.dart';
import 'author_books_screen.dart';

class AuthorsListScreen extends StatefulWidget {
  static const routeName = '/authors';

  @override
  State<AuthorsListScreen> createState() => _AuthorsListScreenState();
}

class _AuthorsListScreenState extends State<AuthorsListScreen> {
  bool _isLoading = true;
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    await Provider.of<AuthorProvider>(context, listen: false).fetchAuthors();
    setState(() {
      _isLoading = false;
    });
  }

  void _search(String query) async {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    await Provider.of<AuthorProvider>(context, listen: false)
        .searchAuthors(query);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authors = Provider.of<AuthorProvider>(context).authors;

    return Scaffold(
      appBar: AppBar(
        title: Text('المؤلفون'),
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
                : authors.isEmpty
                    ? Center(child: Text('لا يوجد مؤلفون'))
                    : ListView.builder(
                        itemCount: authors.length,
                        itemBuilder: (ctx, i) {
                          Author author = authors[i];
                          return ListTile(
                            title: Text('${author.fName} ${author.lName}'),
                            subtitle: Text(author.country),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AuthorBooksScreen.routeName,
                                arguments: {
                                  'id': author.id,
                                  'name': '${author.fName} ${author.lName}',
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
