import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/movie_provider.dart'; 

class YearSearchPage extends StatefulWidget {
  const YearSearchPage({super.key});

  @override
  _YearSearchPageState createState() => _YearSearchPageState();
}

class _YearSearchPageState extends State<YearSearchPage> {
  List<Movie> moviesByYear = [];
  final TextEditingController _yearController = TextEditingController();
  bool isLoading = false;
  bool hasSearched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar por Año'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Año (Ej: 2025)',
                      hintText: 'Ingrese año...',
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
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Colors.teal),
            ),

          Expanded(
            child: moviesByYear.isEmpty
                ? Center(
                    child: Text(
                      hasSearched 
                        ? 'No se encontraron películas de ese año.' 
                        : 'Ingresá un año para buscar.',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: moviesByYear.length,
                    itemBuilder: (context, index) {
                      final movie = moviesByYear[index];
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
                          subtitle: Text('Estreno: ${movie.releaseDate}'),
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
    final year = _yearController.text.trim();
    if (year.isEmpty) return;

    FocusScope.of(context).unfocus(); 

    setState(() {
      isLoading = true;
      hasSearched = true;
      moviesByYear = [];
    });

    try {
      final url = Uri.parse('http://localhost:3000/api/v1/movies');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> results = [];
        
        if (data.containsKey('data')) results = data['data'];
        else if (data.containsKey('results')) results = data['results'];

        final allMovies = results.map((m) => Movie(
          title: m['title'] ?? '',
          description: m['overview'] ?? '',
          posterPath: m['poster_path'],
          voteAverage: (m['vote_average'] ?? 0).toDouble(),
          releaseDate: m['release_date'] ?? '',
          // ✅ LÍNEA NUEVA
          genreIds: List<int>.from(m['genre_ids'] ?? []), 
        )).toList();

        setState(() {
          moviesByYear = allMovies.where((m) => m.releaseDate.contains(year)).toList();
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
}