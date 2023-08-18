import 'package:call_api_app/provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LikedUsersScreen extends StatelessWidget {
  Future<Map<String, dynamic>> fetchUserData(String login) async {
    final response =
        await http.get(Uri.parse('https://api.github.com/users/$login'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Favotite List User '),
          backgroundColor: Colors.deepPurple.shade300,
        ),
        body: ListView.builder(
          itemCount: favoritesProvider.favoriteUserLogins.length,
          itemBuilder: (context, index) {
            final login = favoritesProvider.favoriteUserLogins.elementAt(index);

            return FutureBuilder(
              future: fetchUserData(login),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show a loading indicator
                } else if (snapshot.hasError) {
                  return const Text('Error loading user data');
                } else if (!snapshot.hasData) {
                  return const SizedBox(); // Return an empty SizedBox if no data
                }

                final userData = snapshot.data as Map<String, dynamic>;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['avatar_url']),
                  ),
                  title: Text(userData['login']),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.star,
                      color: Colors.deepPurple.shade300,
                    ),
                    onPressed: () {
                      favoritesProvider
                          .toggleFavorite(login); // Un-like the user
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
