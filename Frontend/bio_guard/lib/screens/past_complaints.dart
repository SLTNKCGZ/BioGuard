import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PastComplaints extends StatefulWidget {
  const PastComplaints({super.key, required this.token});
  final String token;

  @override
  State<PastComplaints> createState() => _PastComplaintsState();
}

class _PastComplaintsState extends State<PastComplaints> {
  List<Map<String, dynamic>> _complaints = [];

  Future<void> _fetchComplaints() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/complaint/complaints'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _complaints = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
      print('Updated complaints list: ${_complaints.length}');
    } else {
      print('Fetch failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null).then((_) {
      _fetchComplaints();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geçmiş Şikayetler"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white,size: 28),
        backgroundColor: Colors.blue[600],
      ),
      body: _complaints.isEmpty
          ? const Center(child: Text('Hiç şikayet bulunamadı.'))
          : ListView.builder(
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                String formattedDate = '';
                if (complaint['dateTime'] != null) {
                  try {
                    final dateTime = DateTime.parse(complaint['dateTime']).toLocal();
                    formattedDate = DateFormat('d MMMM y, HH:mm', 'tr_TR').format(dateTime);
                  } catch (e) {
                    formattedDate = complaint['dateTime'];
                  }
                }
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintDetailPage(
                          text: complaint['text'] ?? '',
                          date: formattedDate,
                          complimentId: complaint['id'],
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                complaint['text'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Positioned(
                            top: -15,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Emin misiniz?'),
                                    content: const Text('Bu şikayeti silmek istediğinize emin misiniz?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Hayır'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Evet'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await deleteComplaint(complaint['id']);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Future<void> deleteComplaint(int complimentId) async {
    print('Deleting complaint with ID: $complimentId');
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/complaint/complaints/$complimentId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    print('Delete response status: ${response.statusCode}');
    print('Delete response body: ${response.body}');
    if (response.statusCode == 200) {
        print('Delete successful, refreshing complaints...');
        await _fetchComplaints();
    } else {
        print('Delete failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
    }
  }

}

class ComplaintDetailPage extends StatefulWidget {
  final String text;
  final String date;
  final int complimentId;
  final String token;
  const ComplaintDetailPage({super.key, required this.text, required this.date, required this.complimentId, required this.token});

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  String? aiResponse;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/complaint/complaints/${widget.complimentId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final complaintData = jsonDecode(response.body);
        setState(() {
          aiResponse = complaintData['response'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şikayet Detayı'),
        backgroundColor: Colors.blue[600],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white,size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.date,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              widget.text,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (aiResponse != null && aiResponse!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Analiz Sonucu:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      aiResponse!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}