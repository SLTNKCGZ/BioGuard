import 'package:flutter/material.dart';

class PastLabResultsPage extends StatefulWidget {
  final String token;
  const PastLabResultsPage({super.key, required this.token});

  @override
  State<PastLabResultsPage> createState() => _PastLabResultsPageState();
}

class _PastLabResultsPageState extends State<PastLabResultsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> _allResults = [
    {'name': 'Kan Şekeri', 'result': '95', 'unit': 'mg/dL', 'date': '2025-07-28', 'favorite': 'true'},
    {'name': 'Kolesterol', 'result': '190', 'unit': 'mg/dL', 'date': '2025-07-27', 'favorite': 'false'},
    {'name': 'Tansiyon', 'result': '120/80', 'unit': 'mmHg', 'date': '2025-07-25', 'favorite': 'false'},
  ];

  String _searchText = '';

  void _deleteResult(int index) {
    setState(() {
      _allResults.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filtered = _allResults
        .where((r) =>
            r['name']!.toLowerCase().contains(_searchText.toLowerCase()) ||
            r['date']!.contains(_searchText))
        .toList();

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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.biotech,
                      color: item['favorite'] == 'true' ? Colors.red : Colors.blueAccent,
                    ),
                    title: Text(item['name'] ?? ''),
                    subtitle: Text("Sonuç: ${item['result']} ${item['unit']}\nTarih: ${item['date']}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.bar_chart),
                          tooltip: "Grafiğe Git",
                          onPressed: () {
                            // Grafik sayfasına yönlendirme
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: "Sil",
                          onPressed: () => _deleteResult(index),
                        ),
                      ],
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

