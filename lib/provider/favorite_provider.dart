import 'package:flutter/cupertino.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<String> _favoriteUserLogins = {};

  Set<String> get favoriteUserLogins => _favoriteUserLogins;

  void toggleFavorite(String login) {
    if (_favoriteUserLogins.contains(login)) {
      _favoriteUserLogins.remove(login);
    } else {
      _favoriteUserLogins.add(login);
    }
    notifyListeners();
  }
}
