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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إضافة كتاب جديد')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        // ——— Title ———
                        TextFormField(
                          controller: _titleCtrl,
                          decoration:
                              const InputDecoration(labelText: 'عنوان الكتاب'),
                          validator: (v) => v == null || v.isEmpty
                              ? 'يرجى إدخال العنوان'
                              : null,
                        ),

                        // ——— Type ———
                        TextFormField(
                          controller: _typeCtrl,
                          decoration:
                              const InputDecoration(labelText: 'نوع الكتاب'),
                          validator: (v) => v == null || v.isEmpty
                              ? 'يرجى إدخال النوع'
                              : null,
                        ),

                        // ——— Price ———
                        TextFormField(
                          controller: _priceCtrl,
                          decoration: const InputDecoration(labelText: 'السعر'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'يرجى إدخال السعر';
                            }
                            if (double.tryParse(v) == null) {
                              return 'يرجى إدخال رقم صحيح للسعر';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ——— Author Dropdown ———
                        DropdownButtonFormField<Author>(
                          value: _selectedAuthor,
                          items: _authors.map((a) {
                            return DropdownMenuItem<Author>(
                              value: a,
                              child: Text('${a.fName} ${a.lName}'),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedAuthor = val),
                          decoration:
                              const InputDecoration(labelText: 'المؤلف'),
                          validator: (v) =>
                              v == null ? 'يرجى اختيار المؤلف' : null,
                        ),

                        const SizedBox(height: 12),

                        // ——— Publisher Dropdown ———
                        DropdownButtonFormField<Publisher>(
                          value: _selectedPublisher,
                          items: _publishers.map((p) {
                            return DropdownMenuItem<Publisher>(
                              value: p,
                              child: Text(p.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedPublisher = val),
                          decoration:
                              const InputDecoration(labelText: 'الناشر'),
                          validator: (v) =>
                              v == null ? 'يرجى اختيار الناشر' : null,
                        ),

                        const SizedBox(height: 16),

                        // ——— Cover Image Picker ———
                        _coverImage == null
                            ? const Text('لم يتم اختيار صورة الغلاف')
                            : Image.file(_coverImage!, height: 150),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('اختر صورة الغلاف'),
                        ),

                        const SizedBox(height: 24),

                        // ——— Submit Button ———
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('إضافة الكتاب'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
