import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'home_page.dart';

class RestaurantesPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const RestaurantesPage({super.key, this.usuario});

  @override
  State<RestaurantesPage> createState() => _RestaurantesPageState();
}

class _RestaurantesPageState extends State<RestaurantesPage> {
  List<Map<String, dynamic>> restaurantes = [];
  List<int> favoritos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final db = DBService.instance;

    final listaRestaurantes = await db.obtenerRestaurantes();

    List<int> listaFavoritos = [];
    if (widget.usuario != null) {
      listaFavoritos =
          await db.obtenerFavoritosIds(widget.usuario!["id"]);
    }

    setState(() {
      restaurantes = listaRestaurantes;
      favoritos = listaFavoritos;
      cargando = false;
    });
  }

  Future<void> toggleFav(int restauranteId) async {
    if (widget.usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicia sesión para guardar favoritos.")),
      );
      return;
    }

    await DBService.instance
        .toggleFavorito(widget.usuario!["id"], restauranteId);

    await cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ----------------------------------
              // CABECERA
              // ----------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Restaurantes",
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
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                ],
              ),

              const SizedBox(height: 15),

              const CustomSearchBar(),

              const SizedBox(height: 20),

              // ----------------------------------
              // CONTENIDO
              // ----------------------------------
              Expanded(
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          Text(
                            "Populares",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: restaurantes.length,
                              itemBuilder: (context, index) {
                                final r = restaurantes[index];
                                final esFav = favoritos.contains(r["id"]);

                                return tarjetaRestaurante(
                                  id: r["id"],
                                  nombre: r["nombre"],
                                  direccion: r["direccion"] ?? "",
                                  img: r["imagenAsset"],
                                  esFav: esFav,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------
  // TARJETA DE RESTAURANTE
  // --------------------------------------------------------------------
  Widget tarjetaRestaurante({
    required int id,
    required String nombre,
    required String direccion,
    required String img,
    required bool esFav,
  }) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(img, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => toggleFav(id),
                      child: Icon(
                        esFav ? Icons.favorite : Icons.favorite_border,
                        size: 28,
                        color: esFav ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Textos inferiores
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  direccion,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
