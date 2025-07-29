import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'past_complaints.dart';

class SymptomEntryPage extends StatefulWidget {
  const SymptomEntryPage({super.key, required this.token});
  final String token;

  @override
  State<SymptomEntryPage> createState() => _SymptomEntryPageState();
}

class _SymptomEntryPageState extends State<SymptomEntryPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitted = false;
  bool _isLoading = false;
  
  // AI yanıtı için değişkenler
  String _aiResponse = '';
  bool _showAIResponse = false;

  void _submitSymptom() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _showAIResponse = false;
    });

    try {
      // Backend API'sine istek gönder
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/complaint/create'), // Android emülatör için
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'text': _controller.text.trim(),
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _aiResponse = data['ai_response'];
          _isSubmitted = true;
          _isLoading = false;
          _showAIResponse = true;
          _controller.clear();
        });
      } else {
        // Hata durumunda
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editSymptom() {
    setState(() {
      _isSubmitted = false;
      _showAIResponse = false;
      _aiResponse = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semptom Bildirimi'),
        backgroundColor: Colors.blue[500],
        leading: const Icon(Icons.healing,color: Colors.white,size: 25),
        titleTextStyle: const TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PastComplaints(token: widget.token)));
            },
            icon: const Icon(Icons.history,color: Colors.white,size: 30),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve açıklama
                Text(
                  "Semptomunu Bildir",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Kendini nasıl hissediyorsun? Lütfen yaşadığın semptomları detaylıca yaz.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 24),

                // Kart
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          enabled: !_isSubmitted && !_isLoading,
                          maxLines: 6,
                          minLines: 4,
                          decoration: InputDecoration(
                            hintText: "Şikayetinizi detaylıca yazın...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: Colors.blue[50],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isSubmitted)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 20),
                                label: const Text("Düzenle"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blueAccent,
                                  elevation: 0,
                                  side: const BorderSide(color: Colors.blueAccent),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _editSymptom,
                              ),
                            if (!_isSubmitted)
                              ElevatedButton.icon(
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.send),
                                label: const Text("Gönder"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                onPressed: _isLoading ? null : _submitSymptom,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Animasyonlu başarı mesajı
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isSubmitted
                      ? Container(
                          key: const ValueKey('success'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Semptomlarınız başarıyla gönderildi.",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // AI Yanıtı
                if (_showAIResponse) ...[
                  const SizedBox(height: 20),
                  
                  // AI Analiz Yanıtı
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology, color: Colors.purple[600], size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'AI Analiz Sonucu',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple[200]!),
                            ),
                            child: Text(
                              _aiResponse,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.purple[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
