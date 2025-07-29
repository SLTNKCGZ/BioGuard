import 'package:flutter/material.dart';

class PastLabResultsPage extends StatelessWidget {
  final String token;
  const PastLabResultsPage({super.key, required this.token});

  final List<Map<String, String>> _labResults = const [
    {
      'name': 'Kan Şekeri',
      'result': '95',
      'unit': 'mg/dL',
      'date': '2025-07-28',
    },
    {
      'name': 'Kolesterol',
      'result': '190',
      'unit': 'mg/dL',
      'date': '2025-07-27',
    },
    {
      'name': 'Tansiyon',
      'result': '120/80',
      'unit': 'mmHg',
      'date': '2025-07-26',
    },
  ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _labResults.length,
        itemBuilder: (context, index) {
          final item = _labResults[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.biotech, color: Colors.blueAccent),
              title: Text(item['name'] ?? ''),
              subtitle: Text(
                'Sonuç: ${item['result']} ${item['unit']}\nTarih: ${item['date']}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
