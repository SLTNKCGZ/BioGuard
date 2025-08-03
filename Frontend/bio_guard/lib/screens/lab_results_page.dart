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

  int? _editingLabResultId;

  @override
  void initState() {
    super.initState();
    _fetchLabResults();
  }

  Future<void> _fetchLabResults() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/lab_results/lab_results'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Fetched lab results: $data');
      setState(() {
        _labResults = data.map((e) => e as Map<String, dynamic>).toList();
      });
      print('Lab results set: $_labResults');
    } else {
      print('Fetch lab results error: ${response.statusCode} - ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tahlil verileri yüklenirken hata oluştu: ${response.statusCode}')),
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
      // Sadece silinen öğeyi listeden kaldır
      setState(() {
        _labResults.removeWhere((item) => item['id'] == id);
      });
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

    print('=== FRONTEND DEBUG ===');
    print('Form data - test: $test, result: $result, unit: $unit, date: $date');
    print('Date type: ${date.runtimeType}');
    print('Date length: ${date.length}');
    print('Date isEmpty: ${date.isEmpty}');

    late http.Response response;

    if (_editingLabResultId == null) {
      // Yeni ekle
      final createBody = jsonEncode({
        'test': test,
        'result': double.tryParse(result) ?? 0.0,
        'unit': unit,
        'date': date,
      });
      
      print('Create Request Body: $createBody');
      print('Create Request Body type: ${createBody.runtimeType}');
      print('=== END FRONTEND DEBUG ===');
      
      response = await http.post(
        Uri.parse('http://10.0.2.2:8000/lab_results/create'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: createBody,
      );
    } else {
      // Güncelle - sadece değişen alanları gönder
      print('=== FRONTEND UPDATE DEBUG ===');
      final updateBody = jsonEncode({
        'test': test,
        'result': double.tryParse(result) ?? 0.0,
        'unit': unit,
        'date': date,
      });
      
      print('Update Request Body: $updateBody');
      print('Update Request Body type: ${updateBody.runtimeType}');
      print('=== END FRONTEND UPDATE DEBUG ===');
      
      response = await http.put(
        Uri.parse('http://10.0.2.2:8000/lab_results/${_editingLabResultId!}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: updateBody,
      );
    }

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Response Headers: ${response.headers}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final isUpdate = _editingLabResultId != null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUpdate ? 'Tahlil güncellendi' : 'Tahlil eklendi')),
      );
      
      if (isUpdate) {
        // Güncelleme durumunda, sadece ilgili öğeyi güncelle
        final responseData = jsonDecode(response.body);
        setState(() {
          final index = _labResults.indexWhere((item) => item['id'] == _editingLabResultId);
          if (index != -1) {
            _labResults[index] = responseData;
          }
        });
      } else {
        // Yeni ekleme durumunda, yeni öğeyi listeye ekle
        final responseData = jsonDecode(response.body);
        setState(() {
          _labResults.insert(0, responseData); // En başa ekle
        });
      }
      
      _clearForm();
    } else {
      print('Error response body: ${response.body}');
      print('Error response status: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem başarısız: ${response.statusCode}\n${response.body}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _testController.clear();
      _resultController.clear();
      _unitController.clear();
      _dateController.clear();
      _editingLabResultId = null;
    });
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
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _dateController.text = formattedDate;
      print('Selected date: $picked, formatted: $formattedDate');
    }
  }

  void _startEditLabResult(Map<String, dynamic> labResult) {
    setState(() {
      _editingLabResultId = labResult['id'] as int?;
      _testController.text = labResult['test'] ?? '';
      _resultController.text = labResult['result']?.toString() ?? '';
      _unitController.text = labResult['unit'] ?? '';
      final originalDate = labResult['date']?.toString() ?? '';
      final formattedDate = originalDate.split('T')[0];
      _dateController.text = formattedDate;
      print('Edit lab result - original date: $originalDate, formatted: $formattedDate');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahlil'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        backgroundColor: Colors.blue[600],
        leading: Icon(Icons.note,size: 25,color: Colors.white,),
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
                              "Sonuç: ${lab['result']?.toString() ?? ''} ${lab['unit'] ?? ''}\nTarih: ${lab['date']?.split('T')[0] ?? ''}"),
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
