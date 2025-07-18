import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/symptom_entry_page.dart';
import 'screens/health_datas_page.dart';


void main() {
  runApp(SaglikUygulamasi());
}

class SaglikUygulamasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sağlık Uygulaması',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage()
      },
    );
  }
}



