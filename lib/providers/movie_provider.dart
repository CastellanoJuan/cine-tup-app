import 'package:flutter/material.dart';

// 1. CLASE MOVIE ACTUALIZADA (Con genreIds)
class Movie {
  final String title;
  final String description;
  final String? posterPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds; // <--- NUEVO CAMPO IMPORTANTE

  Movie({
    required this.title,
    required this.description,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate = '',
    this.genreIds = const [], // Por defecto lista vacía
  });
}

// 2. GESTOR DE ESTADO
class MovieProvider extends ChangeNotifier {
  List<Movie> _favorites = [];
  bool _isLogged = false;
  String _username = "";

  List<Movie> get favorites => _favorites;
  bool get isLogged => _isLogged;
  String get username => _username;

  void toggleFavorite(Movie movie) {
    if (isFavorite(movie)) {
      _favorites.removeWhere((m) => m.title == movie.title);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
  }

  bool isFavorite(Movie movie) {
    return _favorites.any((m) => m.title == movie.title);
  }

  bool login(String name, String password) {
    if (name.isNotEmpty && password.isNotEmpty) {
      _isLogged = true;
      _username = name;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLogged = false;
    _username = "";
    _favorites.clear();
    notifyListeners();
  }
}