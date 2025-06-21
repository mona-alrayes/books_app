import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddAuthorScreen extends StatefulWidget {
  const AddAuthorScreen({Key? key}) : super(key: key);

  @override
  State<AddAuthorScreen> createState() => _AddAuthorScreenState();
}

class _AddAuthorScreenState extends State<AddAuthorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fNameCtrl = TextEditingController();
  final _lNameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.addAuthor(
        fName: _fNameCtrl.text.trim(),
        lName: _lNameCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المؤلف بنجاح')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'فشل إضافة المؤلف: $e';
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
        appBar: AppBar(title: const Text('إضافة مؤلف جديد')),
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
                        controller: _fNameCtrl,
                        decoration: const InputDecoration(labelText: 'الاسم الأول'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال الاسم الأول' : null,
                      ),
                      TextFormField(
                        controller: _lNameCtrl,
                        decoration: const InputDecoration(labelText: 'اسم العائلة'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال اسم العائلة' : null,
                      ),
                      TextFormField(
                        controller: _countryCtrl,
                        decoration: const InputDecoration(labelText: 'الدولة'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال الدولة' : null,
                      ),
                      TextFormField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(labelText: 'المدينة'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال المدينة' : null,
                      ),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(labelText: 'العنوان'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'يرجى إدخال العنوان' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('إضافة المؤلف'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
