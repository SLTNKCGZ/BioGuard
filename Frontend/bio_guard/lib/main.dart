import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';



void main() {
  runApp(SaglikUygulamasi());
}

class SaglikUygulamasi extends StatelessWidget {
  const SaglikUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sağlık Uygulaması',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}





