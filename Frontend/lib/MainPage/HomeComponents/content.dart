import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../HomeComponents/addpostscreen.dart';
import '../../PortSection/ConfigFile.dart'; // Import the config file

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<List<Map<String, dynamic>>> _postsFuture;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _postsFuture = fetchPosts();
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await http.get(Uri.parse(getPosts)); // Use config constant
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _likePost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse(likePost), // Use config constant
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'postId': postId, 'userId': '123456'}), // Replace '123456' with actual user ID
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _postsFuture = fetchPosts(); // Refresh posts to update like count
        });
      } else {
        print('Failed to like post: ${response.statusCode}');
      }
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Health & Wellness Posts",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No posts available'));
            } else {
              return _buildPostsSection(context, snapshot.data!);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          ).then((_) => setState(() {
            _postsFuture = fetchPosts();
          }));
        },
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostsSection(BuildContext context, List<Map<String, dynamic>> posts) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildPostCard(
          context,
          posts[index]['Posttitle'] ?? '',
          posts[index]['Discription'] ?? '',
          posts[index]['createdAt'] ?? '',
          posts[index]['postphoto'] ?? '',
          posts[index]['_id'] ?? '',
          posts[index]['likeCount'] ?? 0,
        );
      },
    );
  }

  Widget _buildPostCard(BuildContext context, String title, String description, String date, String imagePath, String postId, int likeCount) {
    bool isLiked = false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(
                  title: title,
                  description: description,
                  date: date,
                  imagePath: imagePath,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    title,
                    textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
              const SizedBox(height: 8),
              Text(date, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imagePath.startsWith('http') ? imagePath : '$imageBaseUrl$imagePath', // Use config constant for image URL
                      fit: BoxFit.cover,
                      width: double.infinity,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          child: child,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.blue.shade50,
                          child: const Center(child: Text('Image not found', style: TextStyle(color: Colors.blue, fontSize: 16))),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    description,
                    textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    duration: const Duration(milliseconds: 1000),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) => Row(
                      children: [
                        IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(isLiked),
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked;
                            });
                            _likePost(postId);
                          },
                        ),
                        Text('$likeCount', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5, // Replace with posts.length for dynamic dots
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.blue.shade900 : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
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

class PostDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String imagePath;

  const PostDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Text(date, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imagePath.startsWith('http') ? imagePath : '$imageBaseUrl$imagePath', // Use config constant for image URL
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: child,
                      curve: Curves.easeIn,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.blue.shade50,
                      child: const Center(child: Text('Image not found', style: TextStyle(color: Colors.blue, fontSize: 16))),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(description, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 20),
              const Text("Full content and additional tips coming soon...", style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}