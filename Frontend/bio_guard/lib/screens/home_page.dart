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

    final nowIso = DateTime.now().toIso8601String();

    try {
      for (final test in ['Tansiyon', 'Kan Şekeri']) {
        String? result;
        String unit;

        if (test == 'Tansiyon' && tansiyon.isNotEmpty) {
          result = tansiyon;
          unit = 'mmHg';
        } else if (test == 'Kan Şekeri' && seker.isNotEmpty) {
          result = seker;
          unit = 'mg/dL';
        } else {
          continue;
        }

        final existing = _labResults.firstWhere(
          (e) => e['test'].toString().toLowerCase() == test.toLowerCase(),
          orElse: () => {},
        );

        final body = jsonEncode({
          'test': test,
          'result': result,
          'unit': unit,
          'date': nowIso,
        });

        final uri = isUpdate && existing['id'] != null
            ? Uri.parse('http://10.0.2.2:8000/lab_results/${existing['id']}')
            : Uri.parse('http://10.0.2.2:8000/lab_results/');

        final method = isUpdate && existing['id'] != null ? 'PUT' : 'POST';

        final response = await (method == 'PUT'
            ? http.put(uri,
                headers: {
                  'Authorization': 'Bearer ${widget.token}',
                  'Content-Type': 'application/json',
                },
                body: body)
            : http.post(uri,
                headers: {
                  'Authorization': 'Bearer ${widget.token}',
                  'Content-Type': 'application/json',
                },
                body: body));

        if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
          throw Exception('Hata oluştu: ${response.body}');
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

  Widget _buildHealthDataChart() {
    if (_labResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Henüz sağlık verisi bulunmamaktadır.'),
      );
    }

    final Map<String, Map<String, dynamic>> latestResults = {};

    for (var result in _labResults) {
      final test = result['test']?.toString() ?? '';
      final resultVal = result['result']?.toString() ?? '';
      final date = result['date']?.toString() ?? '';

      final value = double.tryParse(resultVal);
      if (value != null) {
        if (!latestResults.containsKey(test) ||
            DateTime.parse(date).isAfter(DateTime.parse(latestResults[test]!['date']))) {
          latestResults[test] = {
            'value': value,
            'date': date,
          };
        }
      }
    }

    if (latestResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Grafik oluşturulabilecek geçerli veri bulunamadı.'),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: latestResults.length,
        itemBuilder: (context, index) {
          final entry = latestResults.entries.elementAt(index);
          final testName = entry.key;
          final value = entry.value['value'] as double;
          final date = entry.value['date'].toString().split('T')[0];

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(value.toStringAsFixed(1)),
                const SizedBox(height: 4),
                Container(
                  height: value,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  testName.length > 8 ? '${testName.substring(0, 8)}...' : testName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
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
        backgroundColor: Colors.blue[500],
        elevation: 0,
        title: Row(
          children: [
            const Text(
              '👋',
              style: TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 8),
            Text(
              'Merhaba ${widget.firstName ?? ''}',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tansiyon / Şeker Girişi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addOrUpdateTansiyonSeker(isUpdate: false),
                  icon: const Icon(Icons.save),
                  label: const Text("Kaydet"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _addOrUpdateTansiyonSeker(isUpdate: true),
                  icon: const Icon(Icons.update),
                  label: const Text("Güncelle"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              '📈 Sağlık Verileri Grafiği',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildHealthDataChart(),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LabResultsPage(token: widget.token),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "🧪 Tahlil Girişi Yap",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Home
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Semptomlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Sağlık Bilgilerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
} 


