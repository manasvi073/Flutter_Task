import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/option_page.dart';
import 'package:firebase_log/screens/configscreen.dart';
import 'package:firebase_log/screens/dashboard.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Firebase database',
      debugShowCheckedModeBanner: false,
      home: user != null ? const Dashboard() : const OptionPage(),
    );
  }
}


