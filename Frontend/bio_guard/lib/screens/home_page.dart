import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bio_guard/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'symptom_entry_page.dart';
import 'health_datas_page.dart';


class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

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

  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      SymptomEntryPage(token: widget.token),
      HealthDatasPage(token: widget.token),
      HomePageContent(token:widget.token,firstName:firstName),
      ProfilePage(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      SymptomEntryPage(token:widget.token),
      HealthDatasPage(token: widget.token),
      HomePageContent(token:widget.token,firstName:firstName),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merhaba ${widget.firstName}'),
        backgroundColor: Colors.blue[600],
        titleTextStyle: const TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),
        leading:const Icon(Icons.waving_hand_rounded,color: Colors.white,size: 25)
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
}