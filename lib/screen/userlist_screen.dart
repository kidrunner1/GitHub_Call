import 'package:call_api_app/screen/user_like_screen.dart';
import 'package:call_api_app/screen/userdetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../provider/favorite_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserListScreenState createState() => _UserListScreenState();
}

List<String> favoriteUserLogins = [];

List<TextSpan> _highlightOccurrences(String source, String search) {
  if (search.isEmpty) {
    return [TextSpan(text: source)];
  }

  List<TextSpan> spans = [];
  int startIndex = 0;
  int index = source.toLowerCase().indexOf(search.toLowerCase());

  while (index >= 0) {
    spans.add(TextSpan(
      text: source.substring(startIndex, index),
    ));
    spans.add(TextSpan(
      text: source.substring(index, index + search.length),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    ));

    startIndex = index + search.length;
    index = source.toLowerCase().indexOf(search.toLowerCase(), startIndex);
  }

  spans.add(TextSpan(text: source.substring(startIndex)));

  return spans;
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = [];
  List<String> favoriteUserLogins = [];
  TextEditingController _searchController = TextEditingController();
  List<String> userNames = [
    'user1',
    'user2',
    'user3'
  ]; // Replace with actual usernames

  final isDialOpen = ValueNotifier(false);

  Future<void> _toggleFavorite(String login) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteUserLogins.contains(login)) {
        favoriteUserLogins.remove(login);
      } else {
        favoriteUserLogins.add(login);
      }
      prefs.setStringList('favoriteUsers', favoriteUserLogins);
    });
  }

  // use api link
  Future<void> _fetchUsers(String query) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/search/users?q=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        users = data['items'];
      });
    } else {
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteUserLogins = prefs.getStringList('favoriteUsers') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            const Text(
              'GITHUB USER LIST',
              style: TextStyle(fontSize: 25),
            ),
            // Search Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _fetchUsers(query);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'ค้ น ห า ผู้ ใ ช้ ง า น',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isFavorite = favoritesProvider.favoriteUserLogins
                      .contains(user['login']);

                  // use Api call User
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['avatar_url']),
                    ),
                    title: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: _highlightOccurrences(
                          user['login'],
                          _searchController.text,
                        ),
                      ),
                    ),
                    trailing: isFavorite
                        ? Icon(
                            Icons.star,
                            color: Colors.deepPurple.shade300,
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailScreen(
                            user: user,
                            isFavorite: isFavorite,
                            onToggleFavorite: () {
                              _toggleFavorite(user['login']);
                            },
                            username: 'user',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.deepPurple.shade300,
        spacing: 12,
        openCloseDial: isDialOpen,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.favorite),
            label: 'FavoriteList',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LikedUsersScreen()));
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
