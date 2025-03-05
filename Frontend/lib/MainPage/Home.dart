import 'package:fitsync/Step_Counter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';
import '../MainPage/HomeComponents/aichatbot.dart';
import '../ProfileComponent/ProfilePage.dart';
import '../MainPage/HomeComponents/articles.dart';
import 'HomeComponents/news.dart';
import 'HomeComponents/content.dart';
import 'HomeComponents/labreport.dart';
import 'HomeComponents/NearHospitals.dart';
import 'HomeComponents/Aboutus.dart';
import 'HomeComponents/settings.dart';
import 'package:fitsync/PortSection/ConfigFile.dart';
import '../hospital_finder/NearHospital.dart';// For getSteps and submitSteps

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;
  const HomePage({super.key, this.initialUserData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(selectedIndex: _selectedIndex, initialUserData: widget.initialUserData),
      const AIChatbotPage(),
      ProfilePage(initialUserData: widget.initialUserData),
      const ContentPage(),
      const LabReportPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pages[0] = HomeContent(selectedIndex: _selectedIndex, initialUserData: widget.initialUserData);
    });
  }

  void _onStepUpdate(int steps) {
    // Callback for step updates, can be used to sync with other parts of the app if needed
    print('Steps updated: $steps');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Fit Sync',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade900,
          elevation: 0,
          actions: [
            IconButton(
            icon: const Icon(Icons.local_hospital_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalSection())),
            tooltip: 'View Articles',
          ),
            IconButton(
              icon: const Icon(Icons.article, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesPage())),
              tooltip: 'View Articles',
            ),
            IconButton(
              icon: const Icon(Icons.medical_information, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorScreen())),
              tooltip: 'Nearby Doctors',
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: SafeArea(child: _pages[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "AI Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Content"),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: "Lab Reports"),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue.shade900,
          unselectedItemColor: Colors.grey.shade500,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue.shade50,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.22,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.1,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).size.width * 0.12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    Text(
                      widget.initialUserData?['name'] ?? 'Fit Sync User',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(context, Icons.home, 'Home', () => setState(() => _selectedIndex = 0)),
                  _buildDrawerItem(context, Icons.chat, 'AI Chat', () => setState(() => _selectedIndex = 1)),
                  _buildDrawerItem(context, Icons.person, 'Profile', () => setState(() => _selectedIndex = 2)),
                  _buildDrawerItem(context, Icons.video_library, 'Content', () => setState(() => _selectedIndex = 3)),
                  _buildDrawerItem(context, Icons.report, 'Lab Reports', () => setState(() => _selectedIndex = 4)),
                  _buildDrawerItem(context, Icons.article, 'Articles', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesPage()))),
                  _buildDrawerItem(context, Icons.newspaper, 'News', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsPage()))),
                  _buildDrawerItem(context, Icons.location_on, 'Nearby Doctors', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorScreen()))),
                  _buildDrawerItem(context, Icons.info, 'About Us', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()))),
                  _buildDrawerItem(context, Icons.settings, 'Settings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
                  _buildDrawerItem(context, Icons.directions_walk, 'Step Couter', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StepCounterApp()))),
                  const Divider(color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade900, size: MediaQuery.of(context).size.width * 0.07),
      title: Text(
        title,
        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      hoverColor: Colors.blue.shade100.withOpacity(0.2),
    );
  }
}

class HomeContent extends StatefulWidget {
  final int selectedIndex;
  final Map<String, dynamic>? initialUserData;
  const HomeContent({super.key, required this.selectedIndex, this.initialUserData});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Article> _homeArticles = [];
  List<News> _homeNews = [];
  bool _isLoadingArticles = true;
  bool _isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeArticles();
    _fetchHomeNews();
  }

  Future<void> _fetchHomeArticles() async {
    try {
      final response = await http.get(Uri.parse(
          'https://newsapi.org/v2/everything?q=health&language=en&sortBy=publishedAt&apiKey=97a148d76a9b4075897473440740e39f'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _homeArticles = (data['articles'] as List).map((article) => Article.fromJson(article)).take(3).toList();
          _isLoadingArticles = false;
        });
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoadingArticles = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching articles: $e')));
    }
  }

  Future<void> _fetchHomeNews() async {
    try {
      final response = await http.get(Uri.parse(
          'https://newsapi.org/v2/everything?q=health&language=en&sortBy=publishedAt&apiKey=fdd43d74e64d4c6a9f2710aaf87c61c8'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _homeNews = (data['articles'] as List).map((article) => News.fromJson(article)).take(3).toList();
          _isLoadingNews = false;
        });
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoadingNews = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching news: $e')));
    }
  }

  void _onStepUpdate(int steps) {
    // Handle step updates if needed in HomeContent
    print('HomeContent steps updated: $steps');
  }

  @override
  Widget build(BuildContext context) {
    final String userId = widget.initialUserData?['userId'] ?? '123456'; // Default userId if not available

    return Container(
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
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/homepage_bg.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to Fit Sync, ${widget.initialUserData?['name'] ?? 'User'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    const Text(
                      'Your Health Companion',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            StepCounter(
              userId: userId,
              onStepUpdate: _onStepUpdate,
              initialUserData: widget.initialUserData,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Health",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [Shadow(color: Colors.blue.withOpacity(0.3), blurRadius: 3)],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.035),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      crossAxisSpacing: MediaQuery.of(context).size.width * 0.025,
                      mainAxisSpacing: MediaQuery.of(context).size.height * 0.015,
                      childAspectRatio: 1.5,
                      children: [
                        _buildHealthButton(context, "AI Chat", Icons.chat, Colors.green.shade100, 1),
                        _buildHealthButton(context, "Profile", Icons.person, Colors.blue.shade100, 2),
                        _buildHealthButton(context, "Content", Icons.video_library, Colors.green.shade100, 3),
                        _buildHealthButton(context, "Lab Reports", Icons.report, Colors.blue.shade100, 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Tips",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [Shadow(color: Colors.green.withOpacity(0.3), blurRadius: 3)],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTip(context, "Stay hydrated: Drink 8 glasses of water daily!", Colors.green.shade700),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        _buildTip(context, "Exercise 30 minutes daily for better health!", Colors.green.shade700),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        _buildTip(context, "Get 7-9 hours of quality sleep each night!", Colors.green.shade700),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        _buildTip(context, "Eat a balanced diet rich in fruits and vegetables!", Colors.green.shade700),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health News",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [Shadow(color: Colors.blue.withOpacity(0.3), blurRadius: 3)],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                _isLoadingNews
                    ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                    : _homeNews.isEmpty
                    ? const Center(child: Text('No health news available'))
                    : Column(children: _homeNews.map((news) => _buildNewsCard(context, news)).toList()),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Featured Articles",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [Shadow(color: Colors.purple.withOpacity(0.3), blurRadius: 3)],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                _isLoadingArticles
                    ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                    : _homeArticles.isEmpty
                    ? const Center(child: Text('No articles available'))
                    : Column(children: _homeArticles.map((article) => _buildArticleCard(context, article)).toList()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthButton(BuildContext context, String label, IconData icon, Color defaultColor, int index) {
    bool isSelected = widget.selectedIndex == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade900 : defaultColor,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.01,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSelected ? Colors.blue.shade900 : Colors.grey.shade300, width: 1),
        ),
        elevation: isSelected ? 4 : 2,
      ),
      onPressed: () {
        switch (label) {
          case "AI Chat":
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatbotPage()));
            break;
          case "Profile":
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(initialUserData: widget.initialUserData)));
            break;
          case "Content":
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentPage()));
            break;
          case "Lab Reports":
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LabReportPage()));
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: MediaQuery.of(context).size.width * 0.04,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.003),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.025,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
              shadows: [Shadow(color: isSelected ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2), blurRadius: 1)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text, Color iconColor) {
    return Row(
      children: [
        Icon(Icons.lightbulb_outline, color: iconColor, size: MediaQuery.of(context).size.width * 0.06),
        SizedBox(width: MediaQuery.of(context).size.width * 0.025),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.045,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesPage())),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                  shadows: [Shadow(color: Colors.purple.withOpacity(0.2), blurRadius: 2)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  shadows: [Shadow(color: Colors.grey.withOpacity(0.2), blurRadius: 2)],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, News news) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsPage())),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: news.urlToImage != null && news.urlToImage!.isNotEmpty
                    ? Image.network(
                  news.urlToImage!,
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                )
                    : Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.health_and_safety, color: Colors.blue, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                        shadows: [Shadow(color: Colors.blue.withOpacity(0.2), blurRadius: 2)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        shadows: [Shadow(color: Colors.grey.withOpacity(0.2), blurRadius: 2)],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (news.publishedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Published: ${_formatDate(news.publishedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          shadows: [Shadow(color: Colors.grey.withOpacity(0.2), blurRadius: 2)],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Unknown';
    }
  }
}

class Article {
  final String title, description, url;
  Article({required this.title, required this.description, required this.url});
  factory Article.fromJson(Map<String, dynamic> json) => Article(
    title: json['title'] ?? 'No title',
    description: json['description'] ?? 'No description available',
    url: json['url'] ?? '',
  );
}

class News {
  final String title, description, url;
  final String? urlToImage, publishedAt;
  News({required this.title, required this.description, required this.url, this.urlToImage, this.publishedAt});
  factory News.fromJson(Map<String, dynamic> json) => News(
    title: json['title'] ?? 'No title',
    description: json['description'] ?? 'No description available',
    url: json['url'] ?? '',
    urlToImage: json['urlToImage'],
    publishedAt: json['publishedAt'],
  );
}

// StepCounter Widget
class StepCounter extends StatefulWidget {
  final String userId;
  final Function(int) onStepUpdate;
  final Map<String, dynamic>? initialUserData;
  const StepCounter({
    super.key,
    required this.userId,
    required this.onStepUpdate,
    this.initialUserData,
  });

  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int stepsTaken = 0;
  int stepGoal = 1000;
  bool isLoading = true;
  StreamSubscription<StepCount>? _stepSubscription;

  @override
  void initState() {
    super.initState();
    _initializePedometer();
    _fetchSteps();
  }

  Future<void> _initializePedometer() async {
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    } else {
      print('Permission denied for activity recognition');
      setState(() { isLoading = false; });
    }
  }

  void _onStepCount(StepCount event) {
    if (mounted) {
      setState(() {
        if (event.steps > stepsTaken) {
          stepsTaken = event.steps;
          widget.onStepUpdate(stepsTaken);
          _submitSteps();
        }
      });
    }
  }

  void _onStepCountError(Object error) {
    if (mounted) {
      print('Step counting error: $error');
    }
  }

  Future<void> _fetchSteps() async {
    try {
      final response = await http.get(Uri.parse('$getSteps${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stepsTaken = data['stepsTaken'] ?? 0;
          stepGoal = data['todayStepGoal'] ?? 1000;
          isLoading = false;
        });
      } else {
        print('Failed to fetch steps: ${response.statusCode}');
        setState(() { isLoading = false; });
      }
    } catch (e) {
      print('Error fetching steps: $e');
      setState(() { isLoading = false; });
    }
  }

  Future<void> _submitSteps() async {
    try {
      final response = await http.post(
        Uri.parse(submitSteps),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId, 'stepsTaken': stepsTaken}),
      );
      if (response.statusCode == 201) {
        print('Steps submitted successfully: $stepsTaken');
      } else {
        print('Failed to submit steps: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting steps: $e');
    }
  }



  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = stepsTaken / stepGoal;
    if (progress > 1) progress = 1;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[50]!, Colors.white],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              const Text(
                'Daily Step Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$stepsTaken",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const Text(
                      "Steps",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Colors.teal),
                minHeight: 10,
              ),
              const SizedBox(height: 10),
              Text(
                '$stepsTaken / $stepGoal steps',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    // onTap: _resetSteps,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}