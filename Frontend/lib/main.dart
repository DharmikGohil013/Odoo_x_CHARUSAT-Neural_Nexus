import 'package:flutter/material.dart';
import 'package:fitsync/LoginSignupCompnent/LoginPage.dart';
import 'package:fitsync/ProfileComponent/ProfilePage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure async before runApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');

      if (token != null && userJson != null) {
        final user = json.decode(userJson);
        print('✅ Token found. Auto-login as ${user['email']}');
        return ProfilePage(initialUserData: user); // Or use Home()
      } else {
        print('⚠️ No token found. Showing login screen.');
      }
    } catch (e) {
      print('❌ Auto-login error: $e');
    }

    return const LoginPage(); // Fallback if token not found or error
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fit Sync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade800,
          secondary: Colors.teal.shade600,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            print('❌ FutureBuilder failed. Showing login screen.');
            return const LoginPage();
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
