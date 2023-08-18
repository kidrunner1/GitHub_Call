import 'package:call_api_app/provider/favorite_provider.dart';
import 'package:call_api_app/screen/userlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: MaterialApp(
        title: 'Your App Name',
        home: UserListScreen(),
      ),
    );
  }
}
