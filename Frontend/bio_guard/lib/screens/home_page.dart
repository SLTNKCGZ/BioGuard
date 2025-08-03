import 'package:bio_guard/screens/health_datas_page.dart';
import 'package:bio_guard/screens/profile_page.dart';
import 'package:bio_guard/screens/symptom_entry_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'lab_results_page.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key, required this.token});
  final String token;

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _selectedIndex = 2;
  late List<Widget> _pages = [];

  String? _firstName;

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      SymptomEntryPage(token: widget.token),
      HealthDatasPage(token: widget.token),
      HomePage(token: widget.token, firstName: _firstName),
      LabResultsPage(token: widget.token),
      ProfilePage(token: widget.token)
    ];
  }

  Future<void> _fetchFirstName() async {
    try {
      print('Fetching first name...');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/auth/me'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      print('FirstName response status: ${response.statusCode}');
      print('FirstName response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstName = data['firstName'];
        });
        print('FirstName set to: $_firstName');
      } else {
        print('Failed to fetch first name: ${response.statusCode}');
      }
    } catch (e) {
      print('FirstName fetch error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      SymptomEntryPage(token: widget.token),
      HealthDatasPage(token: widget.token),
      HomePage(token: widget.token, firstName: _firstName),
      LabResultsPage(token: widget.token),
      ProfilePage(token: widget.token)
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Şikayet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Sağlık Bilgilerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled,),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Tahlil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


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
  
  // Son değerler için
  Map<String, dynamic>? _lastTansiyon;
  Map<String, dynamic>? _lastSeker;

  @override
  void initState() {
    super.initState();
    _fetchLabResults();
  }

  Future<void> _fetchLabResults() async {
    try {
      print('Tahlil verileri çekiliyor...');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/lab_results/lab_results'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Çekilen veri sayısı: ${data.length}');
        setState(() {
          _labResults = data.map((e) => e as Map<String, dynamic>).toList();
        });
        print('Lab results güncellendi: ${_labResults.length}');
        _updateLastValues();
      } else {
        print('Hata status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tahlil verileri yüklenirken hata oluştu: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Fetch hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tahlil verileri yüklenirken hata oluştu: $e')),
      );
    }
  }

  void _updateLastValues() {
    print('Updating last values...');
    
    setState(() {
      // Son tansiyon değerini bul
      final tansiyonResults = _labResults.where((r) => 
        r['test']?.toString().toLowerCase() == 'tansiyon'
      ).toList();
      
      print('Tansiyon results found: ${tansiyonResults.length}');
      
      if (tansiyonResults.isNotEmpty) {
        // Debug: Tüm tansiyon sonuçlarını yazdır
        print('All tansiyon results:');
        for (var result in tansiyonResults) {
          print('  - ID: ${result['id']}, ${result['result']} ${result['unit']} on ${result['date']}');
        }
        
        // ID'ye göre sırala (en yüksek ID en yeni)
        tansiyonResults.sort((a, b) {
          final idA = a['id'] as int? ?? 0;
          final idB = b['id'] as int? ?? 0;
          return idB.compareTo(idA); // En yüksek ID önce
        });
        
        // Debug: Sıralama sonrası
        print('After sorting tansiyon results:');
        for (var result in tansiyonResults) {
          print('  - ID: ${result['id']}, ${result['result']} ${result['unit']} on ${result['date']}');
        }
        
        _lastTansiyon = tansiyonResults.first;
        print('Last tansiyon set to: ID: ${_lastTansiyon!['id']}, ${_lastTansiyon!['result']} ${_lastTansiyon!['unit']} on ${_lastTansiyon!['date']}');
      } else {
        _lastTansiyon = null;
        print('No tansiyon results found');
      }

      // Son şeker değerini bul
      final sekerResults = _labResults.where((r) => 
        r['test']?.toString().toLowerCase() == 'kan şekeri'
      ).toList();
      
      print('Seker results found: ${sekerResults.length}');
      
      if (sekerResults.isNotEmpty) {
        // Debug: Tüm şeker sonuçlarını yazdır
        print('All seker results:');
        for (var result in sekerResults) {
          print('  - ID: ${result['id']}, ${result['result']} ${result['unit']} on ${result['date']}');
        }
        
        // ID'ye göre sırala (en yüksek ID en yeni)
        sekerResults.sort((a, b) {
          final idA = a['id'] as int? ?? 0;
          final idB = b['id'] as int? ?? 0;
          return idB.compareTo(idA); // En yüksek ID önce
        });
        
        // Debug: Sıralama sonrası
        print('After sorting seker results:');
        for (var result in sekerResults) {
          print('  - ID: ${result['id']}, ${result['result']} ${result['unit']} on ${result['date']}');
        }
        
        _lastSeker = sekerResults.first;
        print('Last seker set to: ID: ${_lastSeker!['id']}, ${_lastSeker!['result']} ${_lastSeker!['unit']} on ${_lastSeker!['date']}');
      } else {
        _lastSeker = null;
        print('No seker results found');
      }
    });
  }

  Future<void> _saveTansiyon() async {
    final tansiyon = _tansiyonController.text.trim();

    if (tansiyon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen Tansiyon bilgisi giriniz')),
      );
      return;
    }

    final now = DateTime.now();
    final currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    print('Generated date: $currentDate');

    try {
      final tansiyonResult = double.tryParse(tansiyon) ?? 0.0;
      
      final tansiyonBody = jsonEncode({
        'test': 'Tansiyon',
        'result': tansiyonResult,
        'unit': 'mmHg',
        'date': currentDate,
      });

      print('Tansiyon kaydetme isteği gönderiliyor...');
      print('Request body: $tansiyonBody');
      print('Token: ${widget.token}');

      final tansiyonResponse = await http.post(
        Uri.parse('http://10.0.2.2:8000/lab_results/create'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: tansiyonBody,
      );

      print('Tansiyon response status: ${tansiyonResponse.statusCode}');
      print('Tansiyon response body: ${tansiyonResponse.body}');

      if (tansiyonResponse.statusCode == 200 || tansiyonResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tansiyon kaydedildi')),
        );
        _tansiyonController.clear();
        await _fetchLabResults();
      } else {
        print('Tansiyon kaydetme hatası: ${tansiyonResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tansiyon kaydetme başarısız: ${tansiyonResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('Tansiyon kaydetme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tansiyon kaydetme başarısız: $e')),
      );
    }
  }

  Future<void> _saveSeker() async {
    final seker = _sekerController.text.trim();

    if (seker.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen Şeker bilgisi giriniz')),
      );
      return;
    }

    final now = DateTime.now();
    final currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    print('Generated date: $currentDate');

    try {
      final sekerResult = double.tryParse(seker) ?? 0.0;
      
      final sekerBody = jsonEncode({
        'test': 'Kan Şekeri',
        'result': sekerResult,
        'unit': 'mg/dL',
        'date': currentDate,
      });

      print('Şeker kaydetme isteği gönderiliyor...');
      print('Request body: $sekerBody');
      print('Token: ${widget.token}');

      final sekerResponse = await http.post(
        Uri.parse('http://10.0.2.2:8000/lab_results/create'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: sekerBody,
      );

      print('Şeker response status: ${sekerResponse.statusCode}');
      print('Şeker response body: ${sekerResponse.body}');

      if (sekerResponse.statusCode == 200 || sekerResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şeker kaydedildi')),
        );
        _sekerController.clear();
        await _fetchLabResults();
      } else {
        print('Şeker kaydetme hatası: ${sekerResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şeker kaydetme başarısız: ${sekerResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('Şeker kaydetme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şeker kaydetme başarısız: $e')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.firstName != null ? 'Merhaba ${widget.firstName}' : 'Merhaba'),
        backgroundColor: Colors.blue[600],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        leading: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 25),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
               "Tansiyon ve Şeker Girişi",
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
             ),
             const SizedBox(height: 12),
             
             // Tansiyon Kutucuğu
             Card(
               elevation: 4,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                        children: [
                          Icon(Icons.monitor_heart, color: Colors.blue[700], size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "Tansiyon",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                          ),
                        ],
                      ),
                     const SizedBox(height: 12),
                     
                     // Son değer gösterimi
                     if (_lastTansiyon != null)
                                               Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.history, color: Colors.blue[700], size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "Son değer: ${_lastTansiyon!['result']} ${_lastTansiyon!['unit']}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700]),
                              ),
                             const Spacer(),
                             Text(
                               _lastTansiyon!['date'].toString().split('T')[0],
                               style: const TextStyle(fontSize: 12, color: Colors.grey),
                             ),
                           ],
                         ),
                       ),
                     
                     const SizedBox(height: 12),
                                           TextField(
                        controller: _tansiyonController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Tansiyon (mmHg)",
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monitor_heart, color: Colors.blue[700]),
                        ),
                      ),
                     const SizedBox(height: 12),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         ElevatedButton.icon(
                            onPressed: _saveTansiyon,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text("Kaydet", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                       ],
                     ),
                   ],
                 ),
               ),
             ),
             
             const SizedBox(height: 16),
             
             // Şeker Kutucuğu
             Card(
               elevation: 4,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                                           Row(
                        children: [
                          Icon(Icons.bloodtype, color: Colors.blue[600], size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "Kan Şekeri",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[600]),
                          ),
                        ],
                      ),
                     const SizedBox(height: 12),
                     
                     // Son değer gösterimi
                     if (_lastSeker != null)
                                               Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.history, color: Colors.blue[600], size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "Son değer: ${_lastSeker!['result']} ${_lastSeker!['unit']}",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[600]),
                              ),
                             const Spacer(),
                             Text(
                               _lastSeker!['date'].toString().split('T')[0],
                               style: const TextStyle(fontSize: 12, color: Colors.grey),
                             ),
                           ],
                         ),
                       ),
                     
                     const SizedBox(height: 12),
                     TextField(
                        controller: _sekerController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Kan Şekeri (mg/dL)",
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bloodtype, color: Colors.blue[600]),
                        ),
                      ),
                     const SizedBox(height: 12),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                                                   ElevatedButton.icon(
                            onPressed: _saveSeker,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text("Kaydet", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                       ],
                     ),
                   ],
                 ),
               ),
             ),
            const SizedBox(height: 30),
            const Text(
              "Son Tahlil Verileri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _labResults.isEmpty
                    ? const Text('Henüz tahlil verisi bulunmamaktadır.')
                    : Column(
                        children: _labResults.take(5).map((result) {
                          final testName = result['test'] ?? '';
                          final testResult = result['result']?.toString() ?? '';
                          final unit = result['unit'] ?? '';
                          final date = result['date']?.toString().split('T')[0] ?? '';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        testName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        '$testResult $unit',
                                        style: const TextStyle(fontSize: 14, color: Colors.blueAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  date,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
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
                  border: Border.all(color: Colors.blueAccent),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tahlil Girişi Yap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent)),
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

