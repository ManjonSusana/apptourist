import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'home_page.dart';

class FavoritosPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const FavoritosPage({super.key, this.usuario});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  bool cargando = true;
  List<Map<String, dynamic>> lugaresFav = [];

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    if (widget.usuario == null) {
      setState(() {
        cargando = false;
        lugaresFav = [];
      });
      return;
    }

    final usuarioId = widget.usuario!["id"] as int;
    final favoritosIds = await DBService.instance.obtenerFavoritosIds(usuarioId);
    final todosLugares = await DBService.instance.obtenerLugares();

    final favs = todosLugares.where((lugar) {
      final id = lugar["id"] as int;
      return favoritosIds.contains(id);
    }).toList();

    setState(() {
      lugaresFav = favs;
      cargando = false;
    });
  }

  Future<void> _toggleFavorito(int lugarId) async {
    if (widget.usuario == null) return;

    await DBService.instance.toggleFavorito(widget.usuario!["id"], lugarId);
    await _cargarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- CABECERA ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Favoritos",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  usuario == null
                      ? const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        )
                      : CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.purple.shade200,
                          child: Text(
                            usuario["nombre"][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 16),

              const CustomSearchBar(),

              const SizedBox(height: 20),

              // ---------------- CONTENIDO ----------------
              Expanded(
                child: _buildContenido(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (widget.usuario == null) {
      return Center(
        child: Text(
          "Inicia sesión para ver tus favoritos.",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      );
    }

    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lugaresFav.isEmpty) {
      return Center(
        child: Text(
          "No tienes lugares en favoritos aún.",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: lugaresFav.length,
      itemBuilder: (context, index) {
        final lugar = lugaresFav[index];
        return _favoritoCard(
          id: lugar["id"] as int,
          nombre: lugar["nombre"] ?? "",
          direccion: lugar["direccion"] ?? "",
          img: lugar["imagenAsset"] ?? "",
        );
      },
    );
  }

  Widget _favoritoCard({
    required int id,
    required String nombre,
    required String direccion,
    required String img,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
            child: Container(
              width: 110,
              height: 90,
              color: Colors.grey.shade200,
              child: Image.asset(
                img,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Texto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    direccion,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Corazón para quitar de favoritos
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => _toggleFavorito(id),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
