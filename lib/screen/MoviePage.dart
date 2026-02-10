import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  List<Movie> movies = [];
  List<Movie> filteredMovies = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPeliculas();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    filterMovies(_searchController.text);
  }

  void filterMovies(String query) {
    setState(() {
      filteredMovies = movies
          .where((movie) =>
              movie.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> getPeliculas() async {
    try {
      // Tu API Local
      final url = Uri.parse('http://localhost:3000/api/v1/movies');
      print('Consultando API en: $url');

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        List<dynamic> results = [];

        // --- CORRECCIÓN CLAVE AQUÍ ---
        // Tu API devuelve { "status": "ok", "data": [...] }
        if (decodedData.containsKey('data')) {
          results = decodedData['data'];
        } 
        // Por si acaso alguna vez devuelve "results" (como TMDB original)
        else if (decodedData.containsKey('results')) {
          results = decodedData['results'];
        }

        if (results.isNotEmpty) {
          setState(() {
            movies = results.map((item) {
              return Movie(
                title: item['title'] ?? 'Sin título',
                // Tu API usa 'overview', lo mapeamos a description
                description: item['overview'] ?? 'Sin descripción', 
                // Tu API usa 'poster_path', lo mapeamos a posterPath
                posterPath: item['poster_path'], 
                // Aseguramos que sea double
                voteAverage: (item['vote_average'] ?? 0).toDouble(),
              );
            }).toList();
            
            filteredMovies = List.from(movies);
            isLoading = false;
          });
          print('¡Películas cargadas: ${movies.length}!');
        } else {
          print('La lista "data" estaba vacía.');
          setState(() => isLoading = false);
        }
      } else {
        print('Error Servidor: Código ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error de Conexión: $error');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas TUP'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar película...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMovies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.movie_creation_outlined, size: 60, color: Colors.grey),
                            const SizedBox(height: 10),
                            const Text('No se encontraron películas.'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: getPeliculas, 
                              child: const Text('Recargar')
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = filteredMovies[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: movie.posterPath != null
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                      width: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50),
                                    )
                                  : const Icon(Icons.movie, size: 50),
                              title: Text(
                                movie.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    movie.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                      Text(' ${movie.voteAverage}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class Movie {
  final String title;
  final String description;
  final String? posterPath;
  final double voteAverage;

  Movie({
    required this.title,
    required this.description,
    this.posterPath,
    required this.voteAverage,
  });
}