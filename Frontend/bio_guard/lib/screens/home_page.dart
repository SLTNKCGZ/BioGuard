import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bio_guard/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'symptom_entry_page.dart';
import 'health_datas_page.dart';
import 'bottomNavigationBar.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? gender;
  String? birthdate;
  bool isLoading = true;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/auth/me'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        username = data['username'];
        email = data['email'];
        firstName = data['firstName'];
        lastName = data['lastName'];
        gender = data['gender'];
        birthdate = data['birthdate'];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merhaba ${firstName}'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.7,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[600],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'BioGuard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sağlık Takip Sistemi',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              autofocus: true,
              leading: const Icon(Icons.account_circle),
              title: const Text("Profil Bilgileri"),
              onTap: () {
                setState(() {
                  _selectedIndex = 2; // Profil sayfasına geç
                });
                Navigator.pop(context); // Drawer'ı kapat
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              autofocus: true,
              leading: const Icon(Icons.home),
              title: const Text("Analiz Sonuçları"),
              onTap: () {
                Navigator.pop(context); // Önce drawer'ı kapat
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => (HealthDatasPage(
                        token: widget.token))));
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              autofocus: true,
              leading: const Icon(Icons.library_books),
              title: const Text("Raporlar"),
              onTap: () {
                Navigator.pop(context); // Önce drawer'ı kapat
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => (HealthDatasPage(
                      token: widget.token,))));
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              autofocus: true,
              leading: const Icon(Icons.person),
              title: const Text("İlaçlar"),
              onTap: () {
                Navigator.pop(context); // Önce drawer'ı kapat
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => (HealthDatasPage(
                        token: widget.token))));
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              autofocus: true,
              leading: const Icon(Icons.person),
              title: const Text("Alerjiler"),
              onTap: () {
                Navigator.pop(context); // Önce drawer'ı kapat
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => (HealthDatasPage(
                        token: widget.token))));
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              autofocus: true,
              leading: const Icon(Icons.person),
              title: const Text("Randevular"),
              onTap: () {
                Navigator.pop(context); // Önce drawer'ı kapat
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => (HealthDatasPage(
                        token: widget.token))));
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Sayfa içinde ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) => false,
              onDaySelected: (selectedDay, focusedDay) {
                // Takvim seçimi işlemleri
              },
              calendarFormat: CalendarFormat.month,
            ),
            const SizedBox(height: 20),
            const Text(
              "📩 Bugün Gelen Özel Mesajlar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text("Henüz yeni bir mesajınız yok."),
            const SizedBox(height: 20),
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
              child: const Text(
                  "Bugün için herhangi bir bildirim bulunmamaktadır."),
            ),
          ],
        ),
      ),

    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      const SymptomEntryPage(),
      _buildHomeContent(),
      ProfilePage(
          username: username ?? '',
          email: email ?? '',
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          gender: gender ?? '',
          birthdate: birthdate ?? '',
          token: widget.token
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      const SymptomEntryPage(),
      _buildHomeContent(),
      ProfilePage(
          username: username ?? '',
          email: email ?? '',
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          gender: gender ?? '',
          birthdate: birthdate ?? '',
          token: widget.token
      ),
    ];
    return Scaffold(

      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

}
