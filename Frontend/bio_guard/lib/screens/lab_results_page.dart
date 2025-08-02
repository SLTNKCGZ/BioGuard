import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class LabResultsPage extends StatefulWidget {
  final String token;
  const LabResultsPage({super.key, required this.token});

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  List<Map<String, dynamic>> _labResults = [];

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _testController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  int? _editingLabResultId; // Güncelleme için seçilen lab result id

  @override
  void initState() {
    super.initState();
    _fetchLabResults();
  }

  Future<void> _fetchLabResults() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/lab_results/'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _labResults = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tahlil verileri yüklenirken hata oluştu')),
      );
    }
  }

  Future<void> _deleteLabResult(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/lab_results/$id'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tahlil silindi')),
      );
      _fetchLabResults();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tahlil silme başarısız oldu')),
      );
    }
  }

  Future<void> _addOrUpdateLabResult() async {
    if (!_formKey.currentState!.validate()) return;

    final test = _testController.text.trim();
    final result = _resultController.text.trim();
    final unit = _unitController.text.trim();
    final date = _dateController.text.trim();

    final body = jsonEncode({
      'test': test,
      'result': result,
      'unit': unit,
      'date': date,
    });

    late http.Response response;

    if (_editingLabResultId == null) {
      // Yeni ekle
      response = await http.post(
        Uri.parse('http://10.0.2.2:8000/lab_results/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    } else {
      // Güncelle
      response = await http.put(
        Uri.parse('http://10.0.2.2:8000/lab_results/${_editingLabResultId!}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingLabResultId == null ? 'Tahlil eklendi' : 'Tahlil güncellendi')),
      );
      _clearForm();
      _fetchLabResults();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem başarısız: ${response.statusCode}')),
      );
    }
  }

  void _clearForm() {
    _testController.clear();
    _resultController.clear();
    _unitController.clear();
    _dateController.clear();
    _editingLabResultId = null;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _startEditLabResult(Map<String, dynamic> labResult) {
    setState(() {
      _editingLabResultId = labResult['id'] as int?;
      _testController.text = labResult['test'] ?? '';
      _resultController.text = labResult['result'] ?? '';
      _unitController.text = labResult['unit'] ?? '';
      _dateController.text = labResult['date']?.split('T')[0] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Tahlil Girişi ve Düzenleme'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _testController,
                    decoration: const InputDecoration(
                      labelText: 'Tahlil Türü',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.biotech),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Tahlil türü boş olamaz' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _resultController,
                    decoration: const InputDecoration(
                      labelText: 'Sonuç',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Sonuç boş olamaz' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Birim (mg/dL, mmHg, vb.)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Birim boş olamaz' : null,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Tarih Seç',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Tarih seçiniz' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addOrUpdateLabResult,
                        icon: Icon(_editingLabResultId == null ? Icons.add : Icons.update),
                        label: Text(_editingLabResultId == null ? "Ekle" : "Güncelle"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _editingLabResultId == null ? Colors.blueAccent : Colors.orangeAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                      if (_editingLabResultId != null)
                        ElevatedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.clear),
                          label: const Text("İptal"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            _labResults.isEmpty
                ? const Text("Henüz tahlil kaydı bulunmamaktadır.", style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _labResults.length,
                    itemBuilder: (context, index) {
                      final lab = _labResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(lab['test'] ?? ''),
                          subtitle: Text(
                              "Sonuç: ${lab['result'] ?? ''} ${lab['unit'] ?? ''}\nTarih: ${lab['date']?.split('T')[0] ?? ''}"),
                          isThreeLine: true,
                          trailing: SizedBox(
                            width: 96,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  tooltip: 'Düzenle',
                                  onPressed: () => _startEditLabResult(lab),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Sil',
                                  onPressed: () => _deleteLabResult(lab['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }
}
