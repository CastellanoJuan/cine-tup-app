import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.indigo,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.movie_creation_outlined, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Portal Cine',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    'Alumno: Juan Castellano',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
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
              const Text(
                'Bienvenido al Portal de Cine',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'API: Node.js (Express) - Render',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
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