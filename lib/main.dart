import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stridebase/theme.dart';
import 'package:stridebase/services/auth_service.dart';
import 'package:stridebase/screens/auth_screen.dart';
import 'package:stridebase/screens/home_screen.dart';
import 'package:stridebase/services/backend_status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint(
        'Please make sure you have added your Firebase configuration files');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrideBase',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: BackendStatus.isFirebaseAvailable
          ? StreamBuilder(
              stream: AuthService().authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasData) {
                  return const HomeScreen();
                }
                return const AuthScreen();
              },
            )
          : const HomeScreen(),
    );
  }
}
