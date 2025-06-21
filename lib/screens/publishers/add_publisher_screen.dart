import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddPublisherScreen extends StatefulWidget {
  const AddPublisherScreen({Key? key}) : super(key: key);

  @override
  State<AddPublisherScreen> createState() => _AddPublisherScreenState();
}

class _AddPublisherScreenState extends State<AddPublisherScreen> {
  final _formKey = GlobalKey<FormState>();

  final _pNameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.addPublisher(
        pName: _pNameCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الناشر بنجاح')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'فشل إضافة الناشر: $e';
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
        appBar: AppBar(title: const Text('إضافة ناشر جديد')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (_error != null)
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                      TextFormField(
                        controller: _pNameCtrl,
                        decoration: const InputDecoration(labelText: 'اسم الناشر'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال اسم الناشر' : null,
                      ),
                      TextFormField(
                        controller: _countryCtrl,
                        decoration: const InputDecoration(labelText: 'الدولة'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال الدولة' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('إضافة الناشر'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
