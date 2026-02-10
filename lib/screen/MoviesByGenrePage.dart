import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/movie_provider.dart';

class MoviesByGenrePage extends StatefulWidget {
  final int genreId;
  final String genreName;

  const MoviesByGenrePage({super.key, required this.genreId, required this.genreName});

  @override
  _MoviesByGenrePageState createState() => _MoviesByGenrePageState();
}

class _MoviesByGenrePageState extends State<MoviesByGenrePage> {
  List<Movie> filteredMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMoviesByGenre();
  }

  Future<void> getMoviesByGenre() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/v1/movies');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> results = [];

        if (data.containsKey('data')) results = data['data'];
        else if (data.containsKey('results')) results = data['results'];

        setState(() {
          // 1. Convertimos TODAS las películas
          final allMovies = results.map((m) {
            return Movie(
              title: m['title'] ?? '',
              description: m['overview'] ?? '',
              posterPath: m['poster_path'],
              voteAverage: (m['vote_average'] ?? 0).toDouble(),
              releaseDate: m['release_date'] ?? '',
              // LEEMOS LOS GÉNEROS DE CADA PELÍCULA
              genreIds: List<int>.from(m['genre_ids'] ?? []), 
            );
          }).toList();

          // 2. FILTRAMOS: Solo las que tengan el ID de este género
          filteredMovies = allMovies.where((m) => m.genreIds.contains(widget.genreId)).toList();
          
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genreName), // Título: "Acción", "Aventura", etc.
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.movie_filter, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text('No hay películas de ${widget.genreName}.'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = filteredMovies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: movie.posterPath != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                width: 50, fit: BoxFit.cover,
                                errorBuilder: (c,e,s) => const Icon(Icons.movie),
                              )
                            : const Icon(Icons.movie),
                        title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Puntaje: ${movie.voteAverage}'),
                      ),
                    );
                  },
                ),
    );
  }
}