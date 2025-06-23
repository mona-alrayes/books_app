import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/author.dart';
import '../../models/publisher.dart';
import '../../services/api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  List<Author> _authors = [];
  List<Publisher> _publishers = [];

  Author? _selectedAuthor;
  Publisher? _selectedPublisher;

  File? _coverImage;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthorsPublishers();
  }

  Future<void> _loadAuthorsPublishers() async {
    try {
      print('Fetching authors and publishers...');
      final authors = await ApiService.fetchAuthors();
      final publishers = await ApiService.fetchPublishers();

      print(
          'Loaded ${authors.length} authors and ${publishers.length} publishers');

      // ✅ أضف هنا
      print('_authors: $authors');
      print('_publishers: $publishers');

      setState(() {
        _authors = authors;
        _publishers = publishers;

        // لتحديد أول عنصر كافتراضي (اختياري)
        if (_authors.isNotEmpty) _selectedAuthor = _authors.first;
        if (_publishers.isNotEmpty) _selectedPublisher = _publishers.first;
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء تحميل المؤلفين أو الناشرين';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _coverImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAuthor == null || _selectedPublisher == null) {
      setState(() {
        _error = 'يرجى اختيار المؤلف والناشر';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.addBook(
        title: _titleCtrl.text.trim(),
        type: _typeCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        authorId: _selectedAuthor!.id,
        publisherId: _selectedPublisher!.id,
        coverImage: _coverImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الكتاب بنجاح')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'فشل إضافة الكتاب: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة كتاب جديد'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: _loading
            ? Container(
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
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('جاري إضافة الكتاب...'),
                    ],
                  ),
                ),
              )
            : Container(
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
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                Icon(
                                  Icons.add_circle,
                                  size: isSmallScreen ? 40 : 50,
                                  color: Colors.blue.shade700,
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 12),
                                Text(
                                  'إضافة كتاب جديد',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'املأ المعلومات التالية لإضافة كتاب جديد',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Error Message
                          if (_error != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade600),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Book Information Card
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.book, color: Colors.blue.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'معلومات الكتاب',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 20),

                                // Title Field
                                _buildTextField(
                                  controller: _titleCtrl,
                                  label: 'عنوان الكتاب',
                                  icon: Icons.title,
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'يرجى إدخال عنوان الكتاب' : null,
                                ),

                                SizedBox(height: isSmallScreen ? 12 : 16),

                                // Type Field
                                _buildTextField(
                                  controller: _typeCtrl,
                                  label: 'نوع الكتاب',
                                  icon: Icons.category,
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'يرجى إدخال نوع الكتاب' : null,
                                ),

                                SizedBox(height: isSmallScreen ? 12 : 16),

                                // Price Field
                                _buildTextField(
                                  controller: _priceCtrl,
                                  label: 'السعر',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'يرجى إدخال السعر';
                                    }
                                    if (double.tryParse(v) == null) {
                                      return 'يرجى إدخال سعر صحيح';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Author and Publisher Selection Card
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.blue.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'المؤلف والناشر',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 20),

                                // Author Dropdown
                                _buildDropdownField(
                                  label: 'المؤلف',
                                  icon: Icons.person_outline,
                                  value: _selectedAuthor,
                                  items: _authors.map((author) {
                                    return DropdownMenuItem<Author>(
                                      value: author,
                                      child: Text(
                                        '${author.fName} ${author.lName}',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Author? value) {
                                    setState(() {
                                      _selectedAuthor = value;
                                    });
                                  },
                                ),

                                SizedBox(height: isSmallScreen ? 12 : 16),

                                // Publisher Dropdown
                                _buildDropdownField(
                                  label: 'الناشر',
                                  icon: Icons.business_outlined,
                                  value: _selectedPublisher,
                                  items: _publishers.map((publisher) {
                                    return DropdownMenuItem<Publisher>(
                                      value: publisher,
                                      child: Text(
                                        publisher.name,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Publisher? value) {
                                    setState(() {
                                      _selectedPublisher = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 24),

                          // Cover Image Card
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.image, color: Colors.blue.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'صورة الغلاف',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 20),

                                // Cover Image Preview
                                if (_coverImage != null)
                                  Container(
                                    width: double.infinity,
                                    height: isSmallScreen ? 150 : 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _coverImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                SizedBox(height: isSmallScreen ? 12 : 16),

                                // Pick Image Button
                                Container(
                                  width: double.infinity,
                                  height: isSmallScreen ? 48 : 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: Icon(
                                      _coverImage != null ? Icons.edit : Icons.add_photo_alternate,
                                      size: isSmallScreen ? 20 : 24,
                                    ),
                                    label: Text(
                                      _coverImage != null ? 'تغيير الصورة' : 'اختيار صورة الغلاف',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 24 : 32),

                          // Submit Button
                          Container(
                            height: isSmallScreen ? 48 : 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'إضافة الكتاب',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade600),
      ),
    );
  }
}
