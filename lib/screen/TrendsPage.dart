import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class TrendsPage extends StatefulWidget {
  const TrendsPage({super.key});

  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  List<Movie> trendingMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getTrendingMovies();
  }

  Future<void> getTrendingMovies() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/v1/movies');
      
      final response = await http.get(url);
      
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        List<dynamic> listData = [];

        // Buscamos 'data' o 'results'
        if (decodedData.containsKey('data')) {
          listData = decodedData['data'];
        } else if (decodedData.containsKey('results')) {
          listData = decodedData['results'];
        }

        setState(() {
          // 1. Mapeamos los datos
          trendingMovies = listData.map((movieData) {
            return Movie(
              title: movieData['title'] ?? 'Sin título',
              description: movieData['overview'] ?? 'Sin descripción',
              posterPath: movieData['poster_path'],
              voteAverage: (movieData['vote_average'] ?? 0).toDouble(),
            );
          }).toList();
          
          // 2. MAGIA AQUÍ: Ordenamos por Puntaje (Mayor a Menor)
          // Esto hará que la lista se vea distinta a la del Home
          trendingMovies.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));

          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error tendencias: $error');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tendencias (Top Rated)'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // Botón extra para invertir el orden si querés probar
              setState(() {
                trendingMovies = trendingMovies.reversed.toList();
              });
            },
          )
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : trendingMovies.isEmpty
            ? const Center(child: Text('No hay tendencias disponibles.'))
            : ListView.builder(
                itemCount: trendingMovies.length,
                itemBuilder: (context, index) {
                  final movie = trendingMovies[index];
                  // Destacamos las 3 primeras con un color o icono especial
                  final isTop3 = index < 3;
                  
                  return Card(
                    elevation: isTop3 ? 6 : 2, // Más sombra a las top
                    color: isTop3 ? Colors.red.shade50 : null, // Fondo rojizo a las top
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: Stack(
                        children: [
                          movie.posterPath != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.movie, size: 50),
                              )
                            : const Icon(Icons.local_fire_department, size: 50, color: Colors.red),
                          if (isTop3)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                color: Colors.red,
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  '#${index + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        movie.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isTop3 ? Colors.red.shade900 : Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 18, color: Colors.amber),
                              Text(
                                ' ${movie.voteAverage}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (isTop3) 
                                const Text(' 🔥 HOT', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            movie.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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