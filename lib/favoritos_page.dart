import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomePage.dart'; // para usar CustomSearchBar

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<String> _favoritos = [];
  String? _nombreUsuario;
  bool _loadedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null) {
        if (args is List) {
          _favoritos = List<String>.from(args.map((e) => e.toString()));
        } else if (args is Map) {
          if (args['favoritos'] is List) {
            _favoritos = List<String>.from((args['favoritos'] as List).map((e) => e.toString()));
          }
          if (args['usuario'] is String) {
            _nombreUsuario = args['usuario'] as String;
          }
        }
      }

      _loadedArgs = true;
    }
  }

  void _removeFavorito(String nombre) {
    setState(() {
      _favoritos.remove(nombre);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TurismoApp',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Avatar (si hay usuario)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/perfil', arguments: _nombreUsuario);
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.purple.shade200,
                      child: Text(
                        (_nombreUsuario != null && _nombreUsuario!.isNotEmpty)
                            ? _nombreUsuario![0].toUpperCase()
                            : 'P',
                        style: const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Buscador + menu + inicio
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 30),
                    onPressed: () {},
                  ),

                  const SizedBox(width: 10),

                  const Expanded(child: CustomSearchBar()),

                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'INICIO',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Título de favoritos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tus Favoritos',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _favoritos.isEmpty
                        ? null
                        : () {
                            setState(() => _favoritos.clear());
                          },
                    child: const Text('Limpiar'),
                  )
                ],
              ),

              const SizedBox(height: 12),

              // Lista de favoritos
              Expanded(
                child: _favoritos.isEmpty
                    ? Center(
                        child: Text(
                          'Aún no tienes favoritos. Agrégalos desde Lugares o Restaurantes.',
                          style: GoogleFonts.poppins(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _favoritos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final nombre = _favoritos[index];
                          return _favoritoTile(nombre);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _favoritoTile(String nombre) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Descripción breve', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeFavorito(nombre),
            tooltip: 'Quitar favorito',
          ),
        ],
      ),
    );
  }
}
