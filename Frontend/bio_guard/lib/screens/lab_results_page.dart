import 'package:flutter/material.dart';
import 'past_lab_results_page.dart';
import 'package:intl/intl.dart';

class LabResultsPage extends StatefulWidget {
  final String token;
  const LabResultsPage({super.key, required this.token});

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedTest;

  final List<String> _commonTests = [
    'Kan Şekeri',
    'Tansiyon',
    'Kolesterol',
    'Hemoglobin',
    'Trigliserid',
    'Beyaz Kan Hücresi'
  ];

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _addResult() {
    if (_selectedTest == null || _resultController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen gerekli alanları doldurun')),
      );
      return;
    }

    // API gönderimi yapılacak alan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tahlil başarıyla eklendi')),
    );

    setState(() {
      _selectedTest = null;
    });
    _resultController.clear();
    _unitController.clear();
    _dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '🧪 Tahlil Girişi',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tahlil Türü', style: TextStyle(fontWeight: FontWeight.w600)),
            DropdownButtonFormField<String>(
              value: _selectedTest,
              hint: const Text("Tahlil seçiniz"),
              items: _commonTests.map((test) {
                return DropdownMenuItem(value: test, child: Text(test));
              }).toList(),
              onChanged: (val) => setState(() => _selectedTest = val),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(_resultController, 'Sonuç', Icons.format_list_numbered),
            const SizedBox(height: 10),
            _buildTextField(_unitController, 'Birim (mg/dL, vb.)', Icons.straighten),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _buildTextField(_dateController, 'Tarih Seç', Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _addResult,
                  icon: const Icon(Icons.add),
                  label: const Text("Ekle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PastLabResultsPage(token: widget.token),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("Geçmiş Tahliller"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
