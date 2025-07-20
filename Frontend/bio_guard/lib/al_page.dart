import 'package:flutter/material.dart';

class AlPage extends StatefulWidget {
  const AlPage({super.key});

  @override
  State<AlPage> createState() => _AlPageState();
}

class _AlPageState extends State<AlPage> {
  final List<String> _semptomListesi = [];
  final TextEditingController _controller = TextEditingController();

  void _semptomEkle() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _semptomListesi.add(text);
        _controller.clear();
      });
    }
  }

  void _gonder() {
    // Burada verileri bir API'ye gönderebilirsin
    print('Gönderilen semptomlar: $_semptomListesi');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Başarılı'),
        content: const Text('Semptomlar gönderildi!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2D2F2),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F1FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFE28DE0),
                width: double.infinity,
                child: const Text(
                  'Semptom Girişi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Semptom',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.purple),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.add, size: 32),
                    onPressed: _semptomEkle,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                ),
                onPressed: _gonder,
                child: const Text(
                  'Gönder',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              if (_semptomListesi.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _semptomListesi.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_semptomListesi[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _semptomListesi.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
