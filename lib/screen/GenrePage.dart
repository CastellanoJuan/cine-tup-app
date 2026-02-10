import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'MoviesByGenrePage.dart'; // Importamos la pantalla nueva

class GenrePage extends StatefulWidget {
  const GenrePage({super.key});

  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  List<Map<String, dynamic>> genres = [];
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
              ? const Center(child: Text('No hay géneros disponibles.'))
              : ListView.builder(
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.category, color: Colors.indigo),
                        title: Text(genre['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // AL HACER CLIC: Navegamos a la lista filtrada
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoviesByGenrePage(
                                genreId: genre['id'],
                                genreName: genre['name'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> getGenres() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/v1/genres');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> results = [];

        if (data.containsKey('genres')) results = data['genres'];
        else if (data.containsKey('data')) results = data['data'];
          
        setState(() {
          genres = results.map((g) => {
            "id": g['id'],
            "name": g['name']
          }).toList().cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (error) {
      setState(() => isLoading = false);
    }
  }
}