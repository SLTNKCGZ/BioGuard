import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'lab_results_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String? firstName;

  const HomePage({super.key, required this.token, this.firstName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _tansiyonController = TextEditingController();
  final TextEditingController _sekerController = TextEditingController();

  List<Map<String, dynamic>> _labResults = [];

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
      // Hata yönetimi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tahlil verileri yüklenirken hata oluştu')),
      );
    }
  }

  Future<void> _addOrUpdateTansiyonSeker({bool isUpdate = false}) async {
    final tansiyon = _tansiyonController.text.trim();
    final seker = _sekerController.text.trim();

    if (tansiyon.isEmpty && seker.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen Tansiyon veya Şeker bilgisi giriniz')),
      );
      return;
    }

    // Tansiyon veya Şeker ayrı ayrı lab result olarak kaydedilecek
    // Örnek olarak 'Tansiyon' ve 'Kan Şekeri' adlarıyla
    final List<Map<String, dynamic>> entries = [];

    if (tansiyon.isNotEmpty) {
      entries.add({
        'test': 'Tansiyon',
        'result': tansiyon,
        'unit': 'mmHg',
        'date': DateTime.now().toIso8601String(),
      });
    }

    if (seker.isNotEmpty) {
      entries.add({
        'test': 'Kan Şekeri',
        'result': seker,
        'unit': 'mg/dL',
        'date': DateTime.now().toIso8601String(),
      });
    }

    try {
      for (final entry in entries) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/lab_results/'),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'test': entry['test'],
            'result': entry['result'],
            'unit': entry['unit'],
            'date': entry['date'],
          }),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Kayıt başarısız');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUpdate ? 'Güncelleme başarılı' : 'Veriler kaydedildi')),
      );

      _tansiyonController.clear();
      _sekerController.clear();
      await _fetchLabResults();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem başarısız: $e')),
      );
    }
  }

  // Grafik için örnek sütun grafik kullanabiliriz
  Widget _buildBarChart() {
    if (_labResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Henüz tahlil verisi bulunmamaktadır.'),
      );
    }

    // Kan Şekeri ve Tansiyon verilerini ayıralım ve sayısal olarak kullanabilelim
    // Tansiyon verisi "120/80" gibi olduğu için işleyelim (örn. sistolik 120)
    List<Map<String, dynamic>> sekerResults = [];
    List<Map<String, dynamic>> tansiyonResults = [];

    for (var r in _labResults) {
      final test = r['test']?.toString().toLowerCase();
      if (test == 'kan şekeri') {
        double? val = double.tryParse(r['result'].toString());
        if (val != null) {
          sekerResults.add({'date': r['date'], 'value': val});
        }
      } else if (test == 'tansiyon') {
        final parts = r['result']?.toString().split('/');
        if (parts != null && parts.length == 2) {
          final sistolik = double.tryParse(parts[0]);
          if (sistolik != null) {
            tansiyonResults.add({'date': r['date'], 'value': sistolik});
          }
        }
      }
    }

    // Örnek olarak sadece Kan Şekeri grafiği yapalım
    sekerResults.sort((a, b) => a['date'].compareTo(b['date']));

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sekerResults.length,
        itemBuilder: (context, index) {
          final item = sekerResults[index];
          final value = item['value'] as double;
          final dateStr = item['date'].toString().split('T')[0];
          return Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(value.toStringAsFixed(0)),
                const SizedBox(height: 4),
                Container(
                  height: value, // direkt değer ile ilişkilendir (basit gösterim)
                  width: 20,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: const TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merhaba ${widget.firstName ?? ""}'),
        backgroundColor: Colors.blue[600],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        leading: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 25),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🩺 Tansiyon / Şeker Girişi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tansiyonController,
                            decoration: const InputDecoration(
                              labelText: "Tansiyon (örn: 120/80)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monitor_heart),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _sekerController,
                            decoration: const InputDecoration(
                              labelText: "Kan Şekeri (mg/dL)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.bloodtype),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _addOrUpdateTansiyonSeker(isUpdate: false),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text("Kaydet", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _addOrUpdateTansiyonSeker(isUpdate: true),
                          icon: const Icon(Icons.update, color: Colors.white),
                          label: const Text("Güncelle", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "📊 Kan Şekeri Grafiği",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildBarChart(),
              ),
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LabResultsPage(token: widget.token)),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("🧪 Tahlil Girişi Yap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                    Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

