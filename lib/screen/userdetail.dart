import 'package:call_api_app/provider/favorite_provider.dart';
import 'package:call_api_app/responsive/repository_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserDetailScreen extends StatefulWidget {
  final dynamic user;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final String username;

  const UserDetailScreen({
    super.key,
    required this.user,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.username,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  List<dynamic> repositories = [];
  bool _isFavorite = false;
  List<String> favoriteUserLogins = [];
  late Future<Map<String, dynamic>> _userData; // Add for user Data
  late Future<List<Map<String, dynamic>>> _repositories; // Add for repositories

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
    _isFavorite = widget.isFavorite;
    _repositories = fetchRepositories(
        widget.username); // Fetch repositories when the screen is initialized
    _userData = fetchUserData(widget.username);
  }

  // ignore: unused_element
  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
      widget.onToggleFavorite();
    });
  }

  Future<void> checkFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteUserLogins =
        prefs.getStringList('favoriteUsers') ?? [];
    setState(() {
      _isFavorite = favoriteUserLogins.contains(widget.user['login']);
    });
  }

  Future<bool> isUserFavorite(String userLogin) async {
    List<String> favoriteUsers = await getFavoriteUsers();
    return favoriteUsers.contains(userLogin);
  }

  Future<List<String>> getFavoriteUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favoriteUsers') ?? [];
  }

  Future<List<Map<String, dynamic>>> fetchRepositories(String username) async {
    final response = await http
        .get(Uri.parse('https://api.github.com/users/$username/repos'));

    if (response.statusCode == 200) {
      final List<dynamic> repositoriesData = json.decode(response.body);
      return repositoriesData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load repositories: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String username) async {
    final response =
        await http.get(Uri.parse('https://api.github.com/users/$username'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(response.body);
      return userData;
    } else {
      throw Exception('Failed to load user details: ${response.statusCode}');
    }
  }

  // fucntion Share
  void _shareGitHubURL() {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(
        'Check out ${widget.user['login']}'
        's GitHub profile: ${widget.user['html_url']}',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
        title: const Text(
          'USER DETAILS ',
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(onPressed: _shareGitHubURL, icon: const Icon(Icons.share)),
          IconButton(
            icon: favoritesProvider.favoriteUserLogins
                    .contains(widget.user['login'])
                ? const Icon(
                    Icons.star,
                    color: Colors.white,
                  )
                : const Icon(Icons.star_border),
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.user['login']);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userData,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(
                child:
                    Text('Error loading user details: ${userSnapshot.error}'));
          }
          var user = widget.user;
          final String avatarUrl = user['avatar_url'];
          final String name = user['login'] ?? 'No name available';
          final String bio = user['bio'] ?? 'No bio available';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user's avatar and name
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(bio),
                      ],
                    ),
                  ],
                ),
              ),
              // Display user's repositories
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _repositories,
                  builder: (context, repoSnapshot) {
                    if (repoSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (repoSnapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error loading repositories: ${repoSnapshot.error}'));
                    }

                    final List<Map<String, dynamic>> repositories =
                        repoSnapshot.data!;

                    return ListView.builder(
                      itemCount: repositories.length,
                      itemBuilder: (context, index) {
                        final repo = repositories[index];
                        final String repoName = repo['name'];
                        final String repoUrl = repo['html_url'];

                        return ListTile(
                          title: Text(repoName),
                          subtitle: Text(repoUrl),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RepositoryDetailScreen(
                                          repositoryName: repoName,
                                          repositoryUrl: 'user',
                                          username: 'user',
                                        )));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
