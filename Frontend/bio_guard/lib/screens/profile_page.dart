import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'bottomNavigationBar.dart';

import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String birthdate;
  final String token;

  const ProfilePage({
    Key? key,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthdate,
    required this.token,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImagePath;
  int? _editingIndex; // Sadece bir alan düzenlenebilir
  String? get token => widget.token;
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

  // Backend'e güncelleme gönderen fonksiyon
  Future<void> _updateProfile(int fieldIndex) async {
    try {
      final fieldNames = ['username', 'firstName', 'lastName', 'email', 'gender', 'birthdate'];
      final fieldName = fieldNames[fieldIndex];
      final newValue = _controllers[fieldIndex].text;

      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/auth/update'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          fieldName: newValue,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fieldName başarıyla güncellendi')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme başarısız: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeriden Seç'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _profileImagePath = image.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Kamera ile Çek'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _profileImagePath = image.path;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : const AssetImage('lib/assets/profile.jpg') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
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
                      subtitle: _editingIndex == index
                          ? TextField(
                              controller: _controllers[index],
                              autofocus: true,
                              onSubmitted: (_) async {
                                setState(() {
                                  _editingIndex = null;
                                });
                                // Backend'e güncelleme isteği gönder
                                await _updateProfile(index);
                              },
                            )
                          : Text(_controllers[index].text),
                      title: Text(_labels[index]),
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
                  onPressed: () async {
                    final response=await http.delete(
                      Uri.parse('http://10.0.2.2:8000/auth/delete'),
                      headers: {
                        'Authorization':'Bearer $token',
                        'Content-type':'application/json'
                      }
                    );
                    if(response.statusCode==200){
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LoginPage()), (route)=>false);
                    }

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