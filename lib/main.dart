import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/register_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/books/add_book_screen.dart';
import 'screens/books/books_list_screen.dart';
import 'screens/books/book_details_screen.dart';
import 'screens/publishers/add_publisher_screen.dart';
import 'screens/publishers/publisher_books_screen.dart';
import 'screens/authors/add_author_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        // Add others like PublisherProvider if used elsewhere
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'تطبيق الكتب',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo',
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/add_book': (_) => const AddBookScreen(),
          '/add_author': (_) => const AddAuthorScreen(),
          '/add_publisher': (_) => const AddPublisherScreen(),
          '/books': (_) => BooksListScreen(),
          '/book-details': (_) => const BookDetailsScreen(),
          '/publisher-books': (_) => const PublisherBooksScreen(),
          '/register': (_) => const RegisterScreen(),
        },
      ),
    );
  }
}
