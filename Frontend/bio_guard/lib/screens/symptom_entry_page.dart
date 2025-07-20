import 'package:bio_guard/screens/bottomNavigationBar.dart';
import 'package:flutter/material.dart';

class SymptomEntryPage extends StatefulWidget {
  const SymptomEntryPage({super.key});

  @override
  State<SymptomEntryPage> createState() => _SymptomEntryPageState();
}

class _SymptomEntryPageState extends State<SymptomEntryPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitted = false;

  void _submitSymptom() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isSubmitted = true;
      // _controller.clear(); // Eğer gönderimden sonra temizlensin istersen açabilirsin.
    });

    // TODO: Yapay zekaya gönderim işlemi burada gerçekleşecek.
    print("Gönderilen metin: ${_controller.text}");
  }

  void _editSymptom() {
    setState(() {
      _isSubmitted = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semptom Girişi'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          enabled: !_isSubmitted,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: "Bugünkü semptomlarınızı detaylıca yazın...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isSubmitted)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: _editSymptom,
                                tooltip: "Düzenle",
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: _isSubmitted ? Colors.grey : Colors.blue,
                              ),
                              onPressed: _isSubmitted ? null : _submitSymptom,
                              tooltip: "Gönder",
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Geri bildirim
                  if (_isSubmitted)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(child: Text("Semptomlarınız başarıyla gönderildi.")),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
    );
  }
}
