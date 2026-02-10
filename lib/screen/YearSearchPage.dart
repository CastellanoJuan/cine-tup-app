import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class YearSearchPage extends StatefulWidget {
  const YearSearchPage({super.key});

  @override
  _YearSearchPageState createState() => _YearSearchPageState();
}

class _YearSearchPageState extends State<YearSearchPage> {
  List<Movie> moviesByYear = [];
  TextEditingController _yearController = TextEditingController();
  bool isLoading = false;
  bool hasSearched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar por Año'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: <Widget>[
          // CAMPO DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ingresá el año (ej: 2024)',
                      hintText: 'Ej: 2024, 2025...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : _searchMoviesByYear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          
          // INDICADOR DE CARGA
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Colors.teal),
            ),

          // LISTA DE RESULTADOS
          Expanded(
            child: moviesByYear.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasSearched ? Icons.search_off : Icons.movie_filter,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hasSearched 
                            ? 'No encontré películas de ese año.' 
                            : 'Escribí un año arriba para empezar.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: moviesByYear.length,
                    itemBuilder: (context, index) {
                      final movie = moviesByYear[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: movie.posterPath != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, size: 50),
                              )
                            : const Icon(Icons.movie, size: 50, color: Colors.teal),
                          title: Text(
                            movie.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              // Mostramos el año para confirmar que funcionó
                              Text(
                                "Estreno: ${movie.releaseDate.isNotEmpty ? movie.releaseDate : 'Desconocido'}",
                                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
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
          ),
        ],
      ),
    );
  }

  Future<void> _searchMoviesByYear() async {
    final yearToFind = _yearController.text.trim();
    
    if (yearToFind.isEmpty) return;

    FocusScope.of(context).unfocus(); // Baja el teclado

    setState(() {
      isLoading = true;
      hasSearched = true;
      moviesByYear = []; // Limpiamos lista anterior
    });

    try {
      // Pedimos TODAS las películas a la API
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

        // Convertimos a objetos Movie
        List<Movie> allMovies = listData.map((movieData) {
          return Movie(
            title: movieData['title'] ?? 'Sin título',
            description: movieData['overview'] ?? 'Sin descripción',
            posterPath: movieData['poster_path'],
            voteAverage: (movieData['vote_average'] ?? 0).toDouble(),
            // IMPORTANTE: Capturamos la fecha del JSON
            releaseDate: movieData['release_date'] ?? '',
          );
        }).toList();

        // --- FILTRO MANUAL (LA CLAVE DEL ÉXITO) ---
        // Filtramos aquí en Flutter para asegurar que funcione
        List<Movie> filteredList = allMovies.where((movie) {
          // Si la película tiene fecha "2025-12-01", contains("2025") dará true
          return movie.releaseDate.contains(yearToFind);
        }).toList();

        setState(() {
          moviesByYear = filteredList;
          isLoading = false;
        });
        
        print("Encontradas: ${filteredList.length} películas del año $yearToFind");

      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error buscando año: $error');
      if (mounted) setState(() => isLoading = false);
    }
  }
}

class Movie {
  final String title;
  final String description;
  final String? posterPath;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.title,
    required this.description,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate = '',
  });
}