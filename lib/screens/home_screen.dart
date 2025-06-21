import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'books/add_book_screen.dart';
import 'authors/add_author_screen.dart';
import 'publishers/add_publisher_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loadingBook = false;
  bool _loadingAuthor = false;
  bool _loadingPublisher = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الصفحة الرئيسية'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              tooltip: 'تسجيل الخروج',
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مرحبا بك في تطبيق الكتب',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (auth.isAdmin) ...[
                  ElevatedButton.icon(
                    icon: _loadingBook
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.book),
                    label: Text('إضافة كتاب جديد'),
                    onPressed: _loadingBook
                        ? null
                        : () async {
                            setState(() => _loadingBook = true);
                            await Navigator.of(context).pushNamed('/add_book');
                            setState(() => _loadingBook = false);
                          },
                  ),
                  ElevatedButton.icon(
                    icon: _loadingAuthor
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.person_add),
                    label: Text('إضافة مؤلف جديد'),
                    onPressed: _loadingAuthor
                        ? null
                        : () async {
                            setState(() => _loadingAuthor = true);
                            await Navigator.of(context)
                                .pushNamed('/add_author');
                            setState(() => _loadingAuthor = false);
                          },
                  ),
                  ElevatedButton.icon(
                    icon: _loadingPublisher
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.publish),
                    label: Text('إضافة ناشر جديد'),
                    onPressed: _loadingPublisher
                        ? null
                        : () async {
                            setState(() => _loadingPublisher = true);
                            await Navigator.of(context)
                                .pushNamed('/add_publisher');
                            setState(() => _loadingPublisher = false);
                          },
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    icon: Icon(Icons.book),
                    label: Text('عرض الكتب'),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/books');
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
