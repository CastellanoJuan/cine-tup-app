import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<MovieProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos'), backgroundColor: Colors.pink),
      body: favorites.isEmpty
          ? const Center(child: Text('Aún no tenés favoritos'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];
                return ListTile(
                  leading: const Icon(Icons.movie),
                  title: Text(movie.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<MovieProvider>().toggleFavorite(movie);
                    },
                  ),
                );
              },
            ),
    );
  }
}