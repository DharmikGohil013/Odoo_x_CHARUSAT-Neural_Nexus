import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './LoginSignupCompnent/LoginPage.dart';
import './ProfileComponent/ProfilePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');

    await Future.delayed(const Duration(seconds: 1)); // Optional splash delay

    if (token != null && userJson != null) {
      try {
        final user = json.decode(userJson);
        print('✅ Token found. Auto-login successful for user: ${user['email'] ?? 'Unknown'}');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(initialUserData: user),
            ),
          );
        }
      } catch (e) {
        print('❌ Failed to decode user data: $e');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      print('⚠️ No token found. Redirecting to login page.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Or app logo
      ),
    );
  }
}
