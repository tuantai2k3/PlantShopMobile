import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  bool isFavorite(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  void addFavorite(Product product) {
    if (!isFavorite(product)) {
      _favorites.add(product);
      notifyListeners();
    }
  }

  void removeFavorite(Product product) {
    _favorites.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      removeFavorite(product);
    } else {
      addFavorite(product);
    }
  }
}
