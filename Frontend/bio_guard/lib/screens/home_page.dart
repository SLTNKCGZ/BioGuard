import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bio_guard/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'symptom_entry_page.dart';
import 'health_datas_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
      _HomeContent(),
      SymptomEntryPage(),
      HealthDatasPage(token: widget.token),
      ProfilePage(
        username: username ?? '',
        email: email ?? '',
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        gender: gender ?? '',
        birthdate: birthdate ?? '',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      _HomeContent(),
      SymptomEntryPage(),
      HealthDatasPage(token: widget.token),
      ProfilePage(
        username: username ?? '',
        email: email ?? '',
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        gender: gender ?? '',
        birthdate: birthdate ?? '',
      ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Şikayet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Sağlık Bilgileri',
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

class _HomeContent extends StatelessWidget {
  const _HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BioGuard'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoş geldiniz!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 16),
              Text(
                'BioGuard ile sağlığınızı koruyun ve takip edin. Aşağıda sizin için bazı önemli sağlık bilgileri ve öneriler bulabilirsiniz:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              _InfoCard(
                title: 'Düzenli Kontroller',
                content: 'Yılda en az bir kez genel sağlık kontrolü yaptırmak, hastalıkların erken teşhisi için önemlidir.',
                icon: Icons.medical_services,
              ),
              _InfoCard(
                title: 'Sağlıklı Beslenme',
                content: 'Her gün taze sebze ve meyve tüketmeye, işlenmiş gıdalardan uzak durmaya özen gösterin.',
                icon: Icons.restaurant,
              ),
              _InfoCard(
                title: 'Hareketli Yaşam',
                content: 'Günde en az 30 dakika yürüyüş veya egzersiz yaparak sağlığınızı destekleyin.',
                icon: Icons.directions_walk,
              ),
              _InfoCard(
                title: 'Alerji ve İlaç Takibi',
                content: 'Kullandığınız ilaçları ve alerjilerinizi kaydedin, acil durumlarda sağlık personeline kolayca bilgi verin.',
                icon: Icons.healing,
              ),
              _InfoCard(
                title: 'Şikayetlerinizi Not Edin',
                content: 'Herhangi bir sağlık şikayetinizde, detaylıca not alıp doktorunuza danışın.',
                icon: Icons.note_alt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoCard({required this.title, required this.content, required this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Colors.blueAccent),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
