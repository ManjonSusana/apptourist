import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'home_page.dart';

class BaresPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const BaresPage({super.key, this.usuario});

  @override
  State<BaresPage> createState() => _BaresPageState();
}

class _BaresPageState extends State<BaresPage> {
  List<Map<String, dynamic>> bares = [];
  List<int> favoritos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final db = DBService.instance;

    final listaBares = await db.obtenerBares();

    List<int> listaFavoritos = [];
    if (widget.usuario != null) {
      listaFavoritos =
          await db.obtenerFavoritosIds(widget.usuario!["id"]);
    }

    setState(() {
      bares = listaBares;
      favoritos = listaFavoritos;
      cargando = false;
    });
  }

  Future<void> toggleFav(int barId) async {
    if (widget.usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicia sesión para guardar favoritos")),
      );
      return;
    }

    await DBService.instance.toggleFavorito(widget.usuario!["id"], barId);
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
                    "Bares",
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

              const SizedBox(height: 18),

              const CustomSearchBar(),

              const SizedBox(height: 18),

              Text(
                "Ambientes Nocturnos",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // ----------------------------------
              // LISTA DE BARES
              // ----------------------------------
              Expanded(
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bares.length,
                        itemBuilder: (context, index) {
                          final bar = bares[index];
                          final esFav = favoritos.contains(bar["id"]);

                          return barCard(
                            id: bar["id"],
                            nombre: bar["nombre"],
                            direccion: bar["direccion"] ?? "",
                            img: bar["imagenAsset"],
                            esFav: esFav,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------
  // TARJETA DE BAR
  // --------------------------------------------------------------------
  Widget barCard({
    required int id,
    required String nombre,
    required String direccion,
    required String img,
    required bool esFav,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
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
                    child: Image.asset(
                      img,
                      fit: BoxFit.cover,
                    ),
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

          // Texto
          Padding(
            padding: const EdgeInsets.all(12),
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
          )
        ],
      ),
    );
  }
}
