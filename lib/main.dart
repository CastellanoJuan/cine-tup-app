import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importamos tus pantallas
import 'providers/movie_provider.dart';
import 'Screen/LoginScreen.dart';
import 'Screen/HomeScreen.dart';
import 'Screen/MoviePage.dart';
import 'Screen/TrendsPage.dart';
import 'Screen/YearSearchPage.dart';
import 'Screen/GenrePage.dart';
import 'Screen/FavoritesPage.dart'; // LA CREAREMOS EN EL PASO 5

void main() {
  runApp(
    // Inyectamos el Provider en la raíz
    ChangeNotifierProvider(
      create: (_) => MovieProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cine TUP',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/movies': (context) => const MoviePage(),
        '/trends': (context) => const TrendsPage(),
        '/genres': (context) => const GenrePage(),
        '/year_search': (context) => const YearSearchPage(),
        '/favorites': (context) => const FavoritesPage(),
      },
    );
  }
}