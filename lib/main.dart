import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/register_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/author_provider.dart';
import 'providers/publisher_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/books/add_book_screen.dart';
import 'screens/books/books_list_screen.dart';
import 'screens/books/book_details_screen.dart';
import 'screens/publishers/add_publisher_screen.dart';
import 'screens/publishers/publisher_books_screen.dart';
import 'screens/publishers/search_publishers_screen.dart';
import 'screens/authors/add_author_screen.dart';
import 'screens/authors/search_authors_screen.dart';
import 'utils/create_simple_icon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // إنشاء أيقونة التطبيق المخصصة
  try {
    await CreateSimpleIcon.createIcon();
  } catch (e) {
    print('خطأ في إنشاء أيقونة التطبيق: $e');
  }
  
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
        ChangeNotifierProvider(create: (_) => AuthorProvider()),
        ChangeNotifierProvider(create: (_) => PublisherProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مكتبة الكتب',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo',
          // تحسين التصميم العام
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/add_book': (_) => const AddBookScreen(),
          '/add_author': (_) => const AddAuthorScreen(),
          '/add_publisher': (_) => const AddPublisherScreen(),
          '/books': (_) => BooksListScreen(),
          '/book-details': (_) => const BookDetailsScreen(),
          '/publisher-books': (_) => const PublisherBooksScreen(),
          '/register': (_) => const RegisterScreen(),
          '/search_publishers': (_) => const SearchPublishersScreen(),
          '/search_authors': (_) => const SearchAuthorsScreen(),
        },
      ),
    );
  }
}
