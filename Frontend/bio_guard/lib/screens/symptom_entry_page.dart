import 'package:flutter/material.dart';

class SymptomEntryPage extends StatefulWidget {
  const SymptomEntryPage({Key? key}) : super(key: key);

  @override
  State<SymptomEntryPage> createState() => _SymptomEntryPageState();
}

class _SymptomEntryPageState extends State<SymptomEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şikayet Girişi'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Şikayetinizi detaylıca yazınız:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TextFormField(
                    controller: _symptomController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Örneğin: Son 2 gündür baş ağrım var ve ateşim yükseldi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen şikayetinizi giriniz';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'AI’ya Gönder',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Burada AI'ya gönderme işlemi yapılacak
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Şikayetiniz AI’ya gönderildi!')),
                        );
                        _symptomController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
