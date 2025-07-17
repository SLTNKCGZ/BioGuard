import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String birthdate;

  const ProfilePage({
    Key? key,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthdate,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImagePath;
  int? _editingIndex; // Sadece bir alan düzenlenebilir

  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      TextEditingController(text: widget.username),
      TextEditingController(text: widget.firstName),
      TextEditingController(text: widget.lastName),
      TextEditingController(text: widget.email),
      TextEditingController(text: widget.gender),
      TextEditingController(text: widget.birthdate),
    ];
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }



  final List<String> _labels = [
    'Kullanıcı Adı',
    'Ad',
    'Soyad',
    'E-posta',
    'Cinsiyet',
    'Doğum Tarihi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profil resmi
                Center(
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundImage:AssetImage('lib/assets/profile.jpg') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: ()=>{} ,
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(Icons.camera_alt, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Bilgi kartları
                ...List.generate(_labels.length, (index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: _editingIndex == index
                          ? TextField(
                              controller: _controllers[index],
                              autofocus: true,
                              onSubmitted: (_) {
                                setState(() {
                                  _editingIndex = null;
                                });
                                // Burada backend'e güncelleme isteği gönderebilirsin
                              },
                            )
                          : Text(_controllers[index].text),
                      subtitle: Text(_labels[index]),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            setState(() {
                              _editingIndex = index;
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Değiştir'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Çıkış yap
                  },
                  child: Text('Çıkış Yap'),
                ),
              ],
            ),
          ),
      ),
      
    );
  }
}