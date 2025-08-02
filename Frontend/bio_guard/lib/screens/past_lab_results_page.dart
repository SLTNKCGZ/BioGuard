import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PastLabResultsPage extends StatefulWidget {
  final String token;
  const PastLabResultsPage({super.key, required this.token});

  @override
  State<PastLabResultsPage> createState() => _PastLabResultsPageState();
}

class _PastLabResultsPageState extends State<PastLabResultsPage> {
  List<Map<String, dynamic>> _labResults = [];
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

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

  List<Map<String, dynamic>> get _filteredLabResults {
    if (_searchText.isEmpty) return _labResults;
    return _labResults.where((lab) {
      final test = (lab['test'] ?? '').toString().toLowerCase();
      final date = (lab['date'] ?? '').toString();
      return test.contains(_searchText.toLowerCase()) || date.contains(_searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '📋 Geçmiş Tahliller',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchText = val),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tahlil adı veya tarih ara...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredLabResults.isEmpty
                ? const Center(
                    child: Text(
                      'Aradığınız kritere uygun tahlil bulunamadı.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredLabResults.length,
                    itemBuilder: (context, index) {
                      final lab = _filteredLabResults[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.biotech,
                            color: lab['favorite'] == true ? Colors.red : Colors.blueAccent,
                          ),
                          title: Text(lab['test'] ?? ''),
                          subtitle: Text(
                            "Sonuç: ${lab['result'] ?? ''} ${lab['unit'] ?? ''}\nTarih: ${lab['date']?.split('T')[0] ?? ''}",
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Sil",
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Silme Onayı'),
                                  content: const Text('Bu tahlili silmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                _deleteLabResult(lab['id']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
