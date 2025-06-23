import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/author_provider.dart';
import '../providers/publisher_provider.dart';
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
  bool _loadingStats = true;
  
  // إحصائيات
  int _booksCount = 0;
  int _authorsCount = 0;
  int _publishersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث الإحصائيات عند العودة إلى الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    setState(() {
      _loadingStats = true;
    });

    try {
      // جلب الإحصائيات من جميع الـ providers
      await Future.wait([
        _loadBooksCount(),
        _loadAuthorsCount(),
        _loadPublishersCount(),
      ]);
    } catch (e) {
      print('خطأ في تحميل الإحصائيات: $e');
    } finally {
      setState(() {
        _loadingStats = false;
      });
    }
  }

  Future<void> _loadBooksCount() async {
    try {
      await Provider.of<BookProvider>(context, listen: false).fetchBooks();
      final books = Provider.of<BookProvider>(context, listen: false).books;
      setState(() {
        _booksCount = books.length;
      });
    } catch (e) {
      print('خطأ في تحميل عدد الكتب: $e');
    }
  }

  Future<void> _loadAuthorsCount() async {
    try {
      await Provider.of<AuthorProvider>(context, listen: false).fetchAuthors();
      final authors = Provider.of<AuthorProvider>(context, listen: false).authors;
      setState(() {
        _authorsCount = authors.length;
      });
    } catch (e) {
      print('خطأ في تحميل عدد المؤلفين: $e');
    }
  }

  Future<void> _loadPublishersCount() async {
    try {
      await Provider.of<PublisherProvider>(context, listen: false).fetchPublishers();
      final publishers = Provider.of<PublisherProvider>(context, listen: false).publishers;
      setState(() {
        _publishersCount = publishers.length;
      });
    } catch (e) {
      print('خطأ في تحميل عدد الناشرين: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مكتبة الكتب'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              tooltip: 'تسجيل الخروج',
            )
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + (isSmallScreen ? 16 : 20),
              left: isSmallScreen ? 16 : 20,
              right: isSmallScreen ? 16 : 20,
              bottom: isSmallScreen ? 16 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.library_books,
                          size: isSmallScreen ? 32 : 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 16 : 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً بك في مكتبة الكتب',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              auth.isAdmin
                                  ? 'إدارة الكتب والمؤلفين والناشرين'
                                  : 'استكشف مكتبة الكتب الرائعة',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 24 : 30),

                // Quick Stats - دائماً أفقية
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.book,
                        title: 'الكتب',
                        count: _loadingStats ? '...' : _booksCount.toString(),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.person,
                        title: 'المؤلفون',
                        count: _loadingStats ? '...' : _authorsCount.toString(),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.business,
                        title: 'الناشرون',
                        count: _loadingStats ? '...' : _publishersCount.toString(),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 24 : 30),

                // Main Actions
                Text(
                  'إدارة المكتبة',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),

                if (auth.isAdmin) ...[
                  // Books Management
                  _buildActionCard(
                    context,
                    title: 'إدارة الكتب',
                    subtitle: 'إضافة وعرض وتعديل الكتب',
                    icon: Icons.book,
                    color: Colors.blue,
                    onTap: () => Navigator.of(context).pushNamed('/books'),
                  ),

                  const SizedBox(height: 16),

                  // Authors Management
                  _buildActionCard(
                    context,
                    title: 'إدارة المؤلفين',
                    subtitle: 'إضافة وعرض وتعديل المؤلفين',
                    icon: Icons.person,
                    color: Colors.green,
                    onTap: () => Navigator.of(context).pushNamed('/authors'),
                  ),

                  const SizedBox(height: 16),

                  // Publishers Management
                  _buildActionCard(
                    context,
                    title: 'إدارة الناشرين',
                    subtitle: 'إضافة وعرض وتعديل الناشرين',
                    icon: Icons.business,
                    color: Colors.orange,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/publishers'),
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 30),

                  // Quick Actions
                  Text(
                    'إجراءات سريعة',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Quick Actions Grid
                  if (isSmallScreen)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  title: 'إضافة كتاب',
                                  icon: Icons.add,
                                  color: Colors.blue,
                                  loading: _loadingBook,
                                  onTap: () async {
                                    setState(() => _loadingBook = true);
                                    await Navigator.of(context)
                                        .pushNamed('/add_book');
                                    setState(() => _loadingBook = false);
                                    // تحديث الإحصائيات بعد إضافة كتاب جديد
                                    _loadStats();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  title: 'إضافة مؤلف',
                                  icon: Icons.person_add,
                                  color: Colors.green,
                                  loading: _loadingAuthor,
                                  onTap: () async {
                                    setState(() => _loadingAuthor = true);
                                    await Navigator.of(context)
                                        .pushNamed('/add_author');
                                    setState(() => _loadingAuthor = false);
                                    // تحديث الإحصائيات بعد إضافة مؤلف جديد
                                    _loadStats();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  title: 'إضافة ناشر',
                                  icon: Icons.business_center,
                                  color: Colors.orange,
                                  loading: _loadingPublisher,
                                  onTap: () async {
                                    setState(() => _loadingPublisher = true);
                                    await Navigator.of(context)
                                        .pushNamed('/add_publisher');
                                    setState(() => _loadingPublisher = false);
                                    // تحديث الإحصائيات بعد إضافة ناشر جديد
                                    _loadStats();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  title: 'البحث',
                                  icon: Icons.search,
                                  color: Colors.purple,
                                  loading: false,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'سيتم إضافة ميزة البحث قريباً'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else if (isMediumScreen)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  title: 'إضافة كتاب',
                                  icon: Icons.add,
                                  color: Colors.blue,
                                  loading: _loadingBook,
                                  onTap: () async {
                                    setState(() => _loadingBook = true);
                                    await Navigator.of(context)
                                        .pushNamed('/add_book');
                                    setState(() => _loadingBook = false);
                                    // تحديث الإحصائيات بعد إضافة كتاب جديد
                                    _loadStats();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  title: 'إضافة مؤلف',
                                  icon: Icons.person_add,
                                  color: Colors.green,
                                  loading: _loadingAuthor,
                                  onTap: () async {
                                    setState(() => _loadingAuthor = true);
                                    await Navigator.of(context)
                                        .pushNamed('/add_author');
                                    setState(() => _loadingAuthor = false);
                                    // تحديث الإحصائيات بعد إضافة مؤلف جديد
                                    _loadStats();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildQuickActionButton(
                                  context,
                                  title: 'إضافة ناشر',
                                  icon: Icons.business_center,
                                  color: Colors.orange,
                                  loading: _loadingPublisher,
                                  onTap: () async {
                                    setState(() => _loadingPublisher = true);
                                    await Navigator.of(context)
                                        .pushNamed('/add_publisher');
                                    setState(() => _loadingPublisher = false);
                                    // تحديث الإحصائيات بعد إضافة ناشر جديد
                                    _loadStats();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: screenSize.width * 0.33,
                            child: _buildQuickActionButton(
                              context,
                              title: 'البحث',
                              icon: Icons.search,
                              color: Colors.purple,
                              loading: false,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('سيتم إضافة ميزة البحث قريباً'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SingleChildScrollView(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              title: 'إضافة كتاب',
                              icon: Icons.add,
                              color: Colors.blue,
                              loading: _loadingBook,
                              onTap: () async {
                                setState(() => _loadingBook = true);
                                await Navigator.of(context)
                                    .pushNamed('/add_book');
                                setState(() => _loadingBook = false);
                                // تحديث الإحصائيات بعد إضافة كتاب جديد
                                _loadStats();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              title: 'إضافة مؤلف',
                              icon: Icons.person_add,
                              color: Colors.green,
                              loading: _loadingAuthor,
                              onTap: () async {
                                setState(() => _loadingAuthor = true);
                                await Navigator.of(context)
                                    .pushNamed('/add_author');
                                setState(() => _loadingAuthor = false);
                                // تحديث الإحصائيات بعد إضافة مؤلف جديد
                                _loadStats();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              title: 'إضافة ناشر',
                              icon: Icons.business_center,
                              color: Colors.orange,
                              loading: _loadingPublisher,
                              onTap: () async {
                                setState(() => _loadingPublisher = true);
                                await Navigator.of(context)
                                    .pushNamed('/add_publisher');
                                setState(() => _loadingPublisher = false);
                                // تحديث الإحصائيات بعد إضافة ناشر جديد
                                _loadStats();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              title: 'البحث',
                              icon: Icons.search,
                              color: Colors.purple,
                              loading: false,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('سيتم إضافة ميزة البحث قريباً'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ] else ...[
                  // User Actions
                  _buildActionCard(
                    context,
                    title: 'استكشف الكتب',
                    subtitle: 'تصفح جميع الكتب المتاحة',
                    icon: Icons.book,
                    color: Colors.blue,
                    onTap: () => Navigator.of(context).pushNamed('/books'),
                  ),

                  const SizedBox(height: 16),

                  _buildActionCard(
                    context,
                    title: 'البحث عن المؤلفين',
                    subtitle: 'ابحث عن المؤلفين وكتبهم',
                    icon: Icons.person_search,
                    color: Colors.green,
                    onTap: () => Navigator.of(context).pushNamed('/search_authors'),
                  ),

                  const SizedBox(height: 16),

                  _buildActionCard(
                    context,
                    title: 'البحث عن الناشرين',
                    subtitle: 'ابحث عن الناشرين وكتبهم',
                    icon: Icons.business_center,
                    color: Colors.orange,
                    onTap: () => Navigator.of(context).pushNamed('/search_publishers'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 20 : 24,
              color: color,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            count,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: isSmallScreen ? 24 : 30,
                    color: color,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 16 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: isSmallScreen ? 16 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool loading,
    required VoidCallback onTap,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    
    // تقليل الارتفاع لحل مشكلة الـ overflow
    double buttonHeight;
    if (isSmallScreen) {
      buttonHeight = 60; // تقليل من 70 إلى 60
    } else if (isMediumScreen) {
      buttonHeight = 70; // تقليل من 80 إلى 70
    } else {
      buttonHeight = 80; // تقليل من 90 إلى 80
    }
    
    return Container(
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12), // تقليل الـ padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6), // تقليل الـ padding
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: loading
                      ? SizedBox(
                          width: isSmallScreen ? 14 : 18, // تقليل الحجم
                          height: isSmallScreen ? 14 : 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(
                          icon,
                          size: isSmallScreen ? 18 : 22, // تقليل الحجم
                          color: color,
                        ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6), // تقليل المسافة
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 9 : 11, // تقليل حجم الخط
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
