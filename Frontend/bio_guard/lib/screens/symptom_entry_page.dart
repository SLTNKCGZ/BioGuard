import 'package:flutter/material.dart';

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

  void _submitSymptom() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isSubmitted = true;
      _isLoading = false;
      _controller.clear();
    });
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
