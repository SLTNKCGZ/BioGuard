import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int _selectedIndex = 1;

  // Her sekmeye karşılık gelen sayfa gövdeleri
  final List<Widget> _pages = [
    SymptomPage(),
    MainHomePageBody(),
    ReminderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: const [
            Text('Profil Bilgileri', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Analiz Sonuçları', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Raporlar', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('İlaçlar', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Alerjiler', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Randevular', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.healing), label: "Semptom"),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm), label: "Anımsatıcı"),
        ],
      ),
    );
  }
}

// Ana sayfa gövdesi
class MainHomePageBody extends StatefulWidget {
  @override
  State<MainHomePageBody> createState() => _MainHomePageBodyState();
}

class _MainHomePageBodyState extends State<MainHomePageBody> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Satır: Merhaba + İkonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Merhaba Hatice 👋", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.account_circle, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 28),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Arama Çubuğu
              TextField(
                decoration: InputDecoration(
                  hintText: 'Sayfa içinde ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              // Takvim
              TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
              ),

              const SizedBox(height: 20),

              // Bugün gelen özel mesajlar
              const Text(
                "📩 Bugün Gelen Özel Mesajlar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text("Henüz yeni bir mesajınız yok."),

              const SizedBox(height: 20),

              // Grafikle sağlık verisi
              const Text(
                "📊 Sağlık Verileri",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text("📈 Grafik Burada Gösterilecek")),
              ),

              const SizedBox(height: 20),

              // Bildirim Balonu
              const Text(
                "🔔 Bildirimler",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Bugün için herhangi bir bildirim bulunmamaktadır."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Diğer sayfalar örnek:
class SymptomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Semptom Sayfası"));
  }
}

class ReminderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Anımsatıcı Sayfası"));
  }
}
