import 'package:flutter/material.dart';
import 'past_lab_results_page.dart';

class LabResultsPage extends StatefulWidget {
  final String token;
  const LabResultsPage({super.key, required this.token});

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  void _addResult() {
    if (_nameController.text.isEmpty || _resultController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen gerekli alanları doldurun')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tahlil sonucu eklendi')),
    );

    _nameController.clear();
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
            const Text(
              'Yeni Tahlil Ekle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildTextField(_nameController, 'Tahlil Adı', Icons.description),
            const SizedBox(height: 8),
            _buildTextField(_resultController, 'Sonuç', Icons.format_list_numbered),
            const SizedBox(height: 8),
            _buildTextField(_unitController, 'Birim (mg/dL, g/dL vb.)', Icons.straighten),
            const SizedBox(height: 8),
            _buildTextField(_dateController, 'Tarih (2025-07-29)', Icons.date_range),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _addResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Ekle'),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('Geçmiş Tahliller'),
                ),
              ],
            ),
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
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
