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
      print('Loading authors and publishers...');
      final authors = await ApiService.fetchAuthors();
      final publishers = await ApiService.fetchPublishers();
      print('Authors loaded: ${authors.length}');
      print('Publishers loaded: ${publishers.length}');
      print('Authors: ${authors.map((a) => '${a.fName} ${a.lName}').toList()}');
      print('Publishers: ${publishers.map((p) => p.name).toList()}');
      setState(() {
        _authors = authors;
        _publishers = publishers;
      });
    } catch (e) {
      print('Error loading authors/publishers: $e');
      setState(() {
        _error = e.toString();
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
        SnackBar(content: Text('تم إضافة الكتاب بنجاح')),
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
        appBar: AppBar(title: Text('إضافة كتاب جديد')),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_error != null)
                          Text(_error!, style: TextStyle(color: Colors.red)),
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: InputDecoration(labelText: 'عنوان الكتاب'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'يرجى إدخال العنوان' : null,
                        ),
                        TextFormField(
                          controller: _typeCtrl,
                          decoration: InputDecoration(labelText: 'نوع الكتاب'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'يرجى إدخال نوع الكتاب' : null,
                        ),
                        TextFormField(
                          controller: _priceCtrl,
                          decoration: InputDecoration(labelText: 'السعر'),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
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
                        SizedBox(height: 12),
                        DropdownButtonFormField<Author>(
                          value: _selectedAuthor,
                          items: _authors
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a,
                                  child: Text('${a.fName} ${a.lName}'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _selectedAuthor = val),
                          decoration: InputDecoration(labelText: 'المؤلف'),
                          validator: (v) =>
                              v == null ? 'يرجى اختيار المؤلف' : null,
                        ),
                        DropdownButtonFormField<Publisher>(
                          value: _selectedPublisher,
                          items: _publishers
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _selectedPublisher = val),
                          decoration: InputDecoration(labelText: 'الناشر'),
                          validator: (v) =>
                              v == null ? 'يرجى اختيار الناشر' : null,
                        ),
                        SizedBox(height: 12),
                        _coverImage == null
                            ? Text('لم يتم اختيار صورة الغلاف')
                            : Image.file(_coverImage!, height: 150),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.image),
                          label: Text('اختر صورة الغلاف'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text('إضافة الكتاب'),
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
