import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el nombre del usuario desde el Provider
    final username = context.watch<MovieProvider>().username;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.indigo,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.movie_creation_outlined, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  const Text('Portal Cine', style: TextStyle(color: Colors.white, fontSize: 24)),
                  Text('Usuario: $username', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('Películas (Listado)'),
              onTap: () => Navigator.pushNamed(context, '/movies'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Géneros'),
              onTap: () => Navigator.pushNamed(context, '/genres'),
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Tendencias'),
              onTap: () => Navigator.pushNamed(context, '/trends'),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar por Año'),
              onTap: () => Navigator.pushNamed(context, '/year_search'),
            ),
            const Divider(),
            ListTile( // NUEVO: Favoritos
              leading: const Icon(Icons.favorite, color: Colors.pink),
              title: const Text('Mis Favoritos'),
              onTap: () => Navigator.pushNamed(context, '/favorites'),
            ),
            ListTile( // NUEVO: Cerrar Sesión
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                context.read<MovieProvider>().logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie, size: 100, color: Colors.indigo),
              const SizedBox(height: 20),
              Text(
                'Hola, $username',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Bienvenido al Portal de Cine', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Ver Películas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/movies');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}