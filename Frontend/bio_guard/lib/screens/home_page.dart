import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// lab_results_page.dart dosyasından import edildi
import 'lab_results_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Burada token örnek olarak boş bırakıldı, istersen sabit string ver.
    return MaterialApp(
      title: 'Test Home Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(token: 'dummy_token'),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Placeholder sayfalar (sadece basit yazı göstermek için)
class SymptomEntryPage extends StatelessWidget {
  final String token;
  const SymptomEntryPage({super.key, required this.token});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Semptom Sayfası'));
}

class HealthDatasPage extends StatelessWidget {
  final String token;
  const HealthDatasPage({super.key, required this.token});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Sağlık Bilgilerim Sayfası'));
}

class ProfilePage extends StatelessWidget {
  final String token;
  const ProfilePage({super.key, required this.token});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Profil Sayfası'));
}

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Ana Sayfa varsayılan olarak seçili
  String? firstName = "Rabia"; // Sabit isim örnek

  late List<Widget> _pages; // _pages burada tanımlandı

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _pages listesi burada başlatılıyor.
    _pages = [
      SymptomEntryPage(token: widget.token),
      HealthDatasPage(token: widget.token),
      HomePageContent(token: widget.token, firstName: firstName),
      ProfilePage(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // _pages listesini burada tekrar atamaya gerek yok, didChangeDependencies'de zaten ayarlandı.
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.healing),
            label: "Semptom",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: "Sağlık Bilgilerim",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key, required this.token, required this.firstName});
  final String token;
  final String? firstName;

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final TextEditingController _tansiyonController = TextEditingController();
  final TextEditingController _sekerController = TextEditingController();

  List<Map<String, String>> _currentAnalyses = [
    {"tahlil": "Kolesterol", "sonuc": "190 mg/dL", "tarih": "2025-07-28"},
    {"tahlil": "Kan Şekeri", "sonuc": "95 mg/dL", "tarih": "2025-07-27"},
    {"tahlil": "Tansiyon", "sonuc": "120/80 mmHg", "tarih": "2025-07-27"},
  ];

  List<String> _ozelMesajlar = [
    "Yeni reçeteniz eczaneden alınabilir.",
    "Doktorunuz yeni bir kontrol randevusu önerdi."
  ];

  List<String> _bildirimler = [
    "Kan şekeri ölçümü yapılmadı, lütfen ölçüm yapınız.",
    "Son tansiyon değeriniz yüksek, dikkat!"
  ];

  @override
  void dispose() {
    _tansiyonController.dispose();
    _sekerController.dispose();
    super.dispose();
  }

  void _kaydetTansiyonSeker() {
    String tansiyon = _tansiyonController.text.trim();
    String seker = _sekerController.text.trim();

    if (tansiyon.isEmpty && seker.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen en az bir değer giriniz.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tansiyon ve Şeker verileri kaydedildi.")),
    );

    _tansiyonController.clear();
    _sekerController.clear();
  }

  Widget _buildGraph() {
    final List<FlSpot> dataPoints = [
      FlSpot(0, 90),
      FlSpot(1, 95),
      FlSpot(2, 85),
      FlSpot(3, 100),
      FlSpot(4, 92),
      FlSpot(5, 110),
      FlSpot(6, 105),
    ];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, horizontalInterval: 10, verticalInterval: 1),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text('G${value.toInt() + 1}');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 10)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
          minX: 0,
          maxX: 6,
          minY: 70,
          maxY: 120,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.3)),
            ),
          ],
        ),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tansiyonController,
                    decoration: const InputDecoration(
                      labelText: "Tansiyon (örn: 120/80)",
                      border: OutlineInputBorder(),
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
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _kaydetTansiyonSeker,
                  child: const Text("Kaydet"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "📋 Güncel Tahlil Sonuçları",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: _currentAnalyses
                    .map((tahlil) => ListTile(
                          title: Text(tahlil["tahlil"] ?? ""),
                          subtitle: Text("Sonuç: ${tahlil["sonuc"]}, Tarih: ${tahlil["tarih"]}"),
                          leading: const Icon(Icons.medical_services),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "📊 Tahlil Grafik",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildGraph(),

            // ✅ Eklenen "Tahlil Girişi" kutusu
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                // LabResultsPage'e yönlendirme
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
                  border: Border.all(color: Colors.blueAccent),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("🧪 Tahlil Girişi Yap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "📩 Bugün Gelen Özel Mesajlar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_ozelMesajlar.isEmpty)
              const Text("Henüz yeni bir mesajınız yok.")
            else
              ..._ozelMesajlar
                  .map((msg) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg),
                      ))
                  .toList(),
            const SizedBox(height: 20),
            const Text(
              "🔔 Bildirimler",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_bildirimler.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Bugün için herhangi bir bildirim bulunmamaktadır."),
              )
            else
              ..._bildirimler
                  .map((notif) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(notif),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}

// lab_results_page.dart içeriği
class LabResultsPage extends StatefulWidget {
  final String token;
  const LabResultsPage({super.key, required this.token});

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<Map<String, String>> _labResults = [
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
  ];

  void _addResult() {
    if (_nameController.text.isEmpty || _resultController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen gerekli alanları doldurun')),
      );
      return;
    }

    setState(() {
      _labResults.insert(0, {
        'name': _nameController.text,
        'result': _resultController.text,
        'unit': _unitController.text.isNotEmpty ? _unitController.text : '', // Birim boş bırakılabilir
        'date': _dateController.text.isNotEmpty ? _dateController.text : DateTime.now().toString().substring(0, 10), // Tarih boşsa bugünün tarihini kullan
      });
      _nameController.clear();
      _resultController.clear();
      _unitController.clear();
      _dateController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tahlil sonucu eklendi')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _resultController.dispose();
    _unitController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '🧪 Tahlil Sonuçları',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Geri oku rengi
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Tahlil Ekleme Alanı
            const Text(
              'Yeni Tahlil Girişi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildTextField(_nameController, 'Tahlil Adı', Icons.description),
            const SizedBox(height: 8),
            _buildTextField(_resultController, 'Sonuç', Icons.format_list_numbered),
            const SizedBox(height: 8),
            _buildTextField(_unitController, 'Birim (mg/dL, g/dL vb.)', Icons.straighten),
            const SizedBox(height: 8),
            _buildTextField(_dateController, 'Tarih (örn: 2025-07-29)', Icons.date_range),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Buton arka plan rengi
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ekle', style: TextStyle(color: Colors.white)), // Buton metin rengi
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Tahlil Listesi
            const Text(
              'Geçmiş Tahliller',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            // Tahlil listesi boşsa mesaj göster
            if (_labResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Henüz kaydedilmiş tahlil sonucunuz bulunmamaktadır."),
              )
            else
              ..._labResults.map((result) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50], // Liste öğesi arka plan rengi
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.biotech, color: Colors.blueAccent),
                      title: Text(result['name'] ?? ''),
                      subtitle: Text(
                        'Sonuç: ${result['result']} ${result['unit']}\nTarih: ${result['date']}',
                      ),
                      isThreeLine: true, // Alt başlık birden fazla satır olabilir
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  // Yeniden kullanılabilir TextField widget'ı
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
