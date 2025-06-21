import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '/models/publisher.dart';
import '/providers/publisher_provider.dart';
import 'publisher_books_screen.dart';

class PublishersListScreen extends StatefulWidget {
  static const routeName = '/publishers';

  @override
  State<PublishersListScreen> createState() => _PublishersListScreenState();
}

class _PublishersListScreenState extends State<PublishersListScreen> {
  bool _isLoading = true;
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPublishers();
  }

  Future<void> _loadPublishers() async {
    await Provider.of<PublisherProvider>(context, listen: false)
        .fetchPublishers();
    setState(() {
      _isLoading = false;
    });
  }

  void _search(String query) async {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    if (query.isEmpty) {
      await Provider.of<PublisherProvider>(context, listen: false)
          .fetchPublishers();
    } else {
      await Provider.of<PublisherProvider>(context, listen: false)
          .searchPublishers(query);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final publishers = Provider.of<PublisherProvider>(context).publishers;

    return Scaffold(
      appBar: AppBar(
        title: Text('الناشرون'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'ابحث باسم الناشر',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : publishers.isEmpty
                    ? Center(child: Text('لا يوجد ناشرون مطابقون'))
                    : ListView.separated(
                        itemCount: publishers.length,
                        separatorBuilder: (ctx, i) => Divider(),
                        itemBuilder: (ctx, i) {
                          final publisher = publishers[i];
                          return ListTile(
                            title: Text(publisher.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('الدولة: ${publisher.country}'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                PublisherBooksScreen.routeName,
                                arguments: {
                                  'id': publisher.id,
                                  'name': publisher.name,
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
