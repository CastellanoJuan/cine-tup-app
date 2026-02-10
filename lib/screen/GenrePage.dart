import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class GenrePage extends StatefulWidget {
  const GenrePage({super.key});

  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  List<Genre> genres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGenres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Géneros'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : genres.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron géneros.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.category, color: Colors.indigo),
                        title: Text(genre.name),
                        subtitle: Text('ID: ${genre.id}'),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> getGenres() async {
    try {
      // 1. CAMBIO IMPORTANTE: Apuntamos a /genres
      final url = Uri.parse('http://localhost:3000/api/v1/genres');
      
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        // 2. CAMBIO IMPORTANTE: Leemos la lista "genres" que pusimos en el main.js
        if (decodedData.containsKey('genres')) {
          final List<dynamic> parsedResponse = decodedData['genres'];
          
          setState(() {
            genres = parsedResponse.map((genreData) {
              return Genre(
                id: genreData['id'],
                name: genreData['name'],
              );
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error en generos: $error');
      if (mounted) setState(() => isLoading = false);
    }
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});
}