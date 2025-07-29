import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Bu örnek sadece HomePage ve HomePageContent içeriyor.
// Diğer sayfalar (SymptomEntryPage, HealthDatasPage, ProfilePage) yerine basit placeholder koyduk.

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
  int _selectedIndex = 2;

  String? firstName = "Rabia"; // Sabit isim örnek

  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      SymptomEntryPage(token: widget.token),
      HealthDatasPage(token: widget.token),
      HomePageContent(token: widget.token, firstName: firstName),
      ProfilePage(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      SymptomEntryPage(token: widget.token),
      HealthDatasPage(token: widget.token),
      HomePageContent(token: widget.token, firstName: firstName),
      ProfilePage(token: widget.token),
    ];
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 10),
            ),
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
