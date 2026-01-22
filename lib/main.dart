import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const UMKMSederhanaApp());
}

class UMKMSederhanaApp extends StatelessWidget {
  const UMKMSederhanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMKM Sederhana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}