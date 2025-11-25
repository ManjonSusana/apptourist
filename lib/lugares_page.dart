import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';

class LugaresPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const LugaresPage({super.key, this.usuario});

  @override
  State<LugaresPage> createState() => _LugaresPageState();
}

class _LugaresPageState extends State<LugaresPage> {
  List<Map<String, dynamic>> lugares = [];
  List<int> favoritos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final db = DBService.instance;

    // Todos los lugares
    final listaLugares = await db.obtenerLugares();

    // Favoritos (si hay usuario)
    List<int> listaFavs = [];
    if (widget.usuario != null) {
      listaFavs = await db.obtenerFavoritosIds(widget.usuario!["id"]);
    }

    setState(() {
      lugares = listaLugares;
      favoritos = listaFavs;
      cargando = false;
    });
  }

  Future<void> toggleFav(int lugarId) async {
    if (widget.usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicia sesión para guardar favoritos")),
      );
      return;
    }

    await DBService.instance.toggleFavorito(widget.usuario!["id"], lugarId);
    await cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TÍTULO APP =================
              Text(
                "AppTurismo",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              // ========= MENÚ + BUSCADOR + PERFIL =========
              Row(
                children: [
                  // Menú hamburguesa
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu, size: 28),
                  ),

                  const SizedBox(width: 12),

                  // Buscador
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade200,
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Buscar...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Perfil usuario
                  GestureDetector(
                    onTap: () {
                      if (usuario != null) {
                        Navigator.pushNamed(
                          context,
                          "/perfil",
                          arguments: usuario,
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.purple.shade300,
                      child: Text(
                        usuario == null
                            ? "?"
                            : usuario["nombre"][0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ========= BOTÓN “LUGARES” + CORAZÓN GENERAL =========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      "LUGARES",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.favorite_border, size: 32),
                ],
              ),

              const SizedBox(height: 25),

              // ================= LUGARES CAROS =================
              Text(
                "LUGARES CAROS",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 240,
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: lugares
                            .where((l) => l["categoria"] == "caro")
                            .map((lugar) {
                          final esFav = favoritos.contains(lugar["id"]);
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "/detalleLugar",
                                arguments: lugar, // 👈 enviamos el mapa completo
                              );
                            },
                            child: _lugarCard(lugar, esFav),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 30),

              // ================= LUGARES ECONÓMICOS =================
              Text(
                "LUGARES ECONÓMICOS",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 240,
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: lugares
                            .where((l) => l["categoria"] == "economico")
                            .map((lugar) {
                          final esFav = favoritos.contains(lugar["id"]);
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "/detalleLugar",
                                arguments: lugar,
                              );
                            },
                            child: _lugarCard(lugar, esFav),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TARJETA DE LUGAR =================
  Widget _lugarCard(Map<String, dynamic> lugar, bool esFav) {
    final ratingNum = lugar["rating"] as num?; // puede ser null
    final ratingTexto =
        ratingNum != null ? ratingNum.toStringAsFixed(1) : "3.2";

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Imagen
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                Image.asset(
                  lugar["imagenAsset"],
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () => toggleFav(lugar["id"]),
                    child: Icon(
                      esFav ? Icons.favorite : Icons.favorite_border,
                      color: esFav ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                )
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lugar["nombre"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lugar["direccion"] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(ratingTexto),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}