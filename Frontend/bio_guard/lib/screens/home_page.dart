import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // fl_chart kütüphanesi için
import 'dart:convert'; // json işlemleri için (gerçek API entegrasyonunda kullanılacak)

// Diğer sayfa importları (dosya yollarını kendi projenize göre güncelleyin)
import 'package:your_app_name/lab_results_page.dart';
import 'package:your_app_name/health_datas_page.dart'; // Önceki etkileşimimizdeki HealthDatasPage

// Placeholder sayfalar (eğer henüz ayrı dosyalarda değillerse veya test amaçlı)
// Eğer bu sayfalar zaten ayrı dosyalardaysa, bu placeholder'ları silin ve yukarıdaki gibi import edin.
class SymptomEntryPage extends StatelessWidget {
  final String token;
  const SymptomEntryPage({super.key, required this.token});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Semptom Girişi'),
          backgroundColor: Colors.blue[600],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Semptom Giriş Sayfası İçeriği')),
      );
}

class ProfilePage extends StatelessWidget {
  final String token;
  const ProfilePage({super.key, required this.token});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Profilim'),
          backgroundColor: Colors.blue[600],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('Profil Sayfası İçeriği')),
      );
}
// Placeholder sayfaların sonu

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Ana Sayfa varsayılan olarak seçili (Bottom nav barda index 2 home)
  String? firstName = "Rabia"; // Örnek olarak sabit isim

  late List<Widget> _pages; // Sayfa listesi

  @override
  void initState() {
    super.initState();
    _pages = [
      SymptomEntryPage(token: widget.token),
      HealthDatasPage(token: widget.token),
      HomePageContent(token: widget.token, firstName: firstName),
      ProfilePage(token: widget.token),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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

// Ana Sayfa İçeriği
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _kaydetTansiyonSeker,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Kaydet", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "📋 Güncel Tahlil Sonuçları",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _currentAnalyses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Henüz kaydedilmiş tahlil sonucunuz bulunmamaktadır."),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _currentAnalyses.length,
                        itemBuilder: (context, index) {
                          final tahlil = _currentAnalyses[index];
                          return ListTile(
                            leading: const Icon(Icons.medical_services, color: Colors.blueAccent),
                            title: Text(tahlil["tahlil"] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text("Sonuç: ${tahlil["sonuc"]}, Tarih: ${tahlil["tarih"]}"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            onTap: () {
                              // Tahlil detay sayfasına gitme gibi bir aksiyon eklenebilir
                            },
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "📊 Sağlık Verileri Grafiği",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGraph(),
              ),
            ),

            // Yeni eklenen Tahlil Girişi Başlığı
            const SizedBox(height: 30),
            const Text(
              "➡️ Tüm Tahlillerime Git", // Yeni başlık
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),

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

            const SizedBox(height: 30),
            const Text(
              "📩 Özel Mesajlarınız",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: _ozelMesajlar.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Henüz yeni bir özel mesajınız yok."),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ozelMesajlar.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_ozelMesajlar[index]),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 30),
            const Text(
              "🔔 Önemli Bildirimler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: _bildirimler.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Bugün için herhangi bir bildirim bulunmamaktadır."),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bildirimler.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_bildirimler[index]),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
