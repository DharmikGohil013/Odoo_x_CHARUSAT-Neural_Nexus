import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Us Content
              _buildSectionTitle(context, 'About Fit Sync'),
              const Text(
                'Fit Sync is a premium health and wellness app designed to help you manage your health, access AI-driven insights, and stay informed with the latest health news and articles. Our mission is to empower users with tools and knowledge for a healthier lifestyle.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              // Contact Us Section
              _buildSectionTitle(context, 'Contact Us'),
              const Text(
                'Email: dharmikgohil395003@gmail.com\nPhone: 9624105887',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              // Footer
              Center(
                child: Text(
                  'Made by Neural Nexus team',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
      child: Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
