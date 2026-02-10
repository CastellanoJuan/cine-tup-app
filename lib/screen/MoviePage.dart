import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import '../providers/movie_provider.dart'; 

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
      final url = Uri.parse('http://localhost:3000/api/v1/movies');
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        List<dynamic> results = [];

        if (decodedData.containsKey('data')) {
          results = decodedData['data'];
        } else if (decodedData.containsKey('results')) {
          results = decodedData['results'];
        }

        if (results.isNotEmpty) {
          setState(() {
            movies = results.map((item) {
              return Movie(
                title: item['title'] ?? 'Sin título',
                description: item['overview'] ?? 'Sin descripción',
                posterPath: item['poster_path'],
                voteAverage: (item['vote_average'] ?? 0).toDouble(),
                releaseDate: item['release_date'] ?? '',
                // ✅ LÍNEA NUEVA: Leemos los géneros para que no falle
                genreIds: List<int>.from(item['genre_ids'] ?? []), 
              );
            }).toList();
            
            filteredMovies = List.from(movies);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error: $error');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas TUP'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          )
        ],
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
                                  width: 50, fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(Icons.movie, size: 50),
                                )
                              : const Icon(Icons.movie, size: 50),
                          title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movie.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              Row(children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                Text(' ${movie.voteAverage}'),
                              ]),
                            ],
                          ),
                          trailing: Consumer<MovieProvider>(
                            builder: (context, provider, child) {
                              final isFav = provider.isFavorite(movie);
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  provider.toggleFavorite(movie);
                                },
                              );
                            },
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