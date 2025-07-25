import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({super.key, required this.token});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  int? _editingIndex;
  String? get token => widget.token;
  late List<TextEditingController> _controllers;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? gender;
  String? birthdate;
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (index) => TextEditingController());
    fetchProfileData();
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fieldName başarıyla güncellendi')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme başarısız: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
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
        title: const Text('Profil'),
        backgroundColor: Colors.blue[600],
        titleTextStyle: const TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),
        leading: const Icon(Icons.account_circle,color: Colors.white,size: 25),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profil resmi
                const Center(
                  child: Stack(
                    children: [
                      Icon(Icons.account_circle,size: 120)
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    }

                  },
                  child: const Text('Çıkış Yap'),
                ),
              ],
            ),
          ),
      ),


    );
  }
  
  Future<void> fetchProfileData() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-type': 'application/json'
      }
    );
    if(response.statusCode==200){
      final data=jsonDecode(response.body);
      setState(() {
        _controllers[0].text=data['username'];
        _controllers[1].text=data['firstName'];
        _controllers[2].text=data['lastName'];
        _controllers[3].text=data['email'];
        _controllers[4].text=data['gender'];
        _controllers[5].text=data['birthdate'];
      });
    }
  }
}