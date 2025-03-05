import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  _AIChatbotPageState createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String _selectedChatType = 'General';
  String? _selectedIssue;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _physicalIssues = [
    "Back Pain", "Joint Pain", "Muscle Strain", "Obesity", "Diabetes", "Hypertension",
    "Asthma", "Cold", "Fever", "Headache", "Flu", "Cough", "Stomach Ache", "Allergies",
    "Fatigue", "Dizziness", "Arthritis", "Heart Disease", "Chronic Pain", "Injury Recovery",
  ];

  final List<String> _mentalIssues = [
    "Anxiety", "Depression", "Stress", "Insomnia", "Burnout", "Panic Attacks",
    "Mood Swings", "Irritability", "Low Self-Esteem", "Phobias", "Trauma",
    "Eating Disorders", "Addiction", "OCD", "PTSD",
  ];

  final Map<String, List<Map<String, dynamic>>> _messages = {
    'Physical': [],
    'Mental': [],
    'General': [],
  };

  List<Map<String, dynamic>> get _currentMessages => _messages[_selectedChatType]!;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getBotResponse(String message) async {
    if (_isLoading) return; // Prevent multiple simultaneous requests
    setState(() {
      _isLoading = true;
      _animationController.repeat(reverse: true);
    });

    const apiKey = 'AIzaSyDlRnwAMR7t-K-kwn1ORdqPkClh0dN03_U'; // Replace with secure storage in production
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    String prefixedMessage = _selectedChatType == 'General'
        ? "Provide a concise, useful response to: $message. Use **bold** for key terms."
        : "Focus on ${_selectedChatType.toLowerCase()} health - ${_selectedIssue ?? 'General'}: $message. Provide practical, concise advice and use **bold** for key terms.";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prefixedMessage}]}],
        }),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = _extractResponse(data) ?? 'Sorry, I couldn’t process that.';
        setState(() {
          _currentMessages.add({"bot": _parseMarkdownToRichText(botResponse)});
        });
      } else {
        throw Exception('API failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _currentMessages.add({"bot": _parseMarkdownToRichText('Oops! Something went wrong: $e')});
      });
    } finally {
      setState(() {
        _isLoading = false;
        _animationController.stop();
      });
    }
  }

  Widget _parseMarkdownToRichText(String text) {
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    final RegExp italicPattern = RegExp(r'\*(.*?)\*');
    List<TextSpan> spans = [];
    String remainingText = text;
    int lastEnd = 0;

    while (remainingText.isNotEmpty) {
      Match? boldMatch = boldPattern.firstMatch(remainingText);
      Match? italicMatch = italicPattern.firstMatch(remainingText);

      Match? nextMatch;
      if (boldMatch != null && italicMatch != null) {
        nextMatch = boldMatch.start < italicMatch.start ? boldMatch : italicMatch;
      } else {
        nextMatch = boldMatch ?? italicMatch;
      }

      if (nextMatch == null) {
        spans.add(TextSpan(text: remainingText));
        break;
      }

      if (nextMatch.start > lastEnd) {
        spans.add(TextSpan(text: remainingText.substring(0, nextMatch.start)));
      }

      if (nextMatch == boldMatch) {
        spans.add(TextSpan(
          text: nextMatch.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (nextMatch == italicMatch) {
        spans.add(TextSpan(
          text: nextMatch.group(1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }

      remainingText = remainingText.substring(nextMatch.end);
      lastEnd = 0;
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  String? _extractResponse(Map<String, dynamic> data) {
    try {
      return data['candidates']?[0]['content']['parts']?[0]['text'] as String?;
    } catch (e) {
      return null;
    }
  }

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    _controller.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    setState(() => _currentMessages.add({"user": message}));
    await _getBotResponse(message);
  }

  void _sendPredefinedQuery(String issue) async {
    final query = "Provide advice for $issue.";
    setState(() => _currentMessages.add({"user": query}));
    await _getBotResponse(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Health Companion',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.purple.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat Type Selection
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Wrap(
                  spacing: MediaQuery.of(context).size.width * 0.02,
                  runSpacing: 8,
                  children: [
                    _buildChatButton('Physical', Icons.fitness_center),
                    _buildChatButton('Mental', Icons.psychology),
                    _buildChatButton('General', Icons.chat),
                  ],
                ),
              ),
              // Issue Dropdown
              if (_selectedChatType != 'General')
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: _buildIssueDropdown(),
                ),
              // Messages Area
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  itemCount: _currentMessages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _currentMessages.length) {
                      return _buildLoadingBubble();
                    }
                    final entry = _currentMessages[index];
                    final isUser = entry.containsKey("user");
                    return _buildMessageBubble(entry, isUser);
                  },
                ),
              ),
              // Input Area
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton(String type, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedChatType = type;
        _selectedIssue = null;
        _currentMessages.clear(); // Clear messages on type switch
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.015,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _selectedChatType == type
                ? [Colors.blue.shade700, Colors.purple.shade600]
                : [Colors.grey.shade200, Colors.grey.shade300],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (_selectedChatType == type)
              BoxShadow(
                color: Colors.blue.shade900.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _selectedChatType == type ? Colors.white : Colors.black87, size: 20),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Text(
              type,
              style: TextStyle(
                color: _selectedChatType == type ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _selectedIssue,
        hint: Text('Pick a ${_selectedChatType.toLowerCase()} issue'),
        onChanged: (String? value) {
          setState(() => _selectedIssue = value);
          if (value != null && !_isLoading) _sendPredefinedQuery(value);
        },
        items: (_selectedChatType == 'Physical' ? _physicalIssues : _mentalIssues)
            .map((issue) => DropdownMenuItem<String>(
          value: issue,
          child: Text(issue, style: const TextStyle(fontSize: 14)),
        ))
            .toList(),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> entry, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUser
                ? [Colors.blue.shade600, Colors.blue.shade800]
                : [Colors.purple.shade600, Colors.purple.shade800],
          ),
          borderRadius: BorderRadius.circular(20).copyWith(
            topLeft: isUser ? const Radius.circular(20) : Radius.zero,
            topRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? 'You' : 'AI Companion',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.008),
            isUser
                ? Text(
              entry["user"],
              style: const TextStyle(color: Colors.white, fontSize: 16),
            )
                : entry["bot"],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitWave(
                color: Colors.purple.shade700,
                size: 30,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              const Text(
                'AI Companion is thinking...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: Colors.blue.shade900,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}