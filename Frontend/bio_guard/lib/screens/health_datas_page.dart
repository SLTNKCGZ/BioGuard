import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HealthDatasPage extends StatefulWidget {
  final String token;
  const HealthDatasPage({super.key, required this.token});

  @override
  State<HealthDatasPage> createState() => _HealthDatasPageState();
}

class _HealthDatasPageState extends State<HealthDatasPage> {
  List<String> _diseases = [];
  List<String> _allergies = [];
  List<String> _medications = [];

  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();

  String? get token => widget.token;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchDiseases(),
      _fetchAllergies(),
      _fetchMedications(),
    ]);
  }

  Future<void> _fetchDiseases() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/disease/diseases'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _diseases = data.map((e) => e.toString()).toList();
      });
    }
  }

  Future<void> _fetchAllergies() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/allergy/allergies'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _allergies = data.map((e) => e.toString()).toList();
      });
    }
  }

  Future<void> _fetchMedications() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/medicine/medicines'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _medications = data.map((e) => e.toString()).toList();
      });
    }
  }

  Future<void> _addDisease(String disease) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/disease/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': disease}),
    );
    if (response.statusCode == 200) {
      await _fetchDiseases();
    }
  }

  Future<void> _addAllergy(String allergy) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/allergy/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': allergy}),
    );
    if (response.statusCode == 200) {
      await _fetchAllergies();
    }
  }

  Future<void> _addMedication(String medication) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/medicine/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': medication}),
    );
    if (response.statusCode == 200) {
      await _fetchMedications();
    }
  }

  Future<void> _deleteDisease(String title) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/disease/delete-by-title/$title'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      await _fetchDiseases();
    }
  }

  Future<void> _deleteAllergy(String title) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/allergy/delete-by-title/$title'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      await _fetchAllergies();
    }
  }

  Future<void> _deleteMedicine(String title) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/medicine/delete-by-title/$title'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      await _fetchMedications();
    }
  }

  void _addItem(List<String> list, TextEditingController controller, String type) async {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      if (type == 'disease') {
        await _addDisease(text);
      } else if (type == 'allergy') {
        await _addAllergy(text);
      } else if (type == 'medicine') {
        await _addMedication(text);
      }
      controller.clear();
    }
  }

  Widget _buildAddCard(TextEditingController controller, String hint, String type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () => _addItem([], controller, type),
                  child: const Icon(Icons.add, color: Colors.white,weight: 20,size: 22,),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(List<String> items, String type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: items.isEmpty
            ? const Text('Henüz eklenmedi.', style: TextStyle(color: Colors.grey))
            : SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Row(
                        children: [
                          Text(
                            items[index],
                            style: const TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (type == 'disease') {
                                await _deleteDisease(items[index]);
                              } else if (type == 'allergy') {
                                await _deleteAllergy(items[index]);
                              } else if (type == 'medicine') {
                                await _deleteMedicine(items[index]);
                              }
                            },
                            child: const Icon(Icons.close, size: 20, color: Colors.black,weight: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sağlık Bilgileri'),
          backgroundColor: Colors.blue[600],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          leading: const Icon(Icons.health_and_safety, color: Colors.white, size: 25),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Hastalıklar'),
              Tab(text: 'Alerjiler'),
              Tab(text: 'İlaçlar'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF5F6FA),
        body: TabBarView(
          children: [
            // Hastalıklar
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAddCard(_diseaseController, 'Hastalık ekle...', 'disease'),
                  _buildListCard(_diseases, 'disease'),
                ],
              ),
            ),
            // Alerjiler
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAddCard( _allergyController, 'Alerji ekle...', 'allergy'),
                  _buildListCard(_allergies, 'allergy'),
                ],
              ),
            ),
            // İlaçlar
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAddCard(_medicationController, 'İlaç ekle...', 'medicine'),
                  _buildListCard(_medications, 'medicine'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
