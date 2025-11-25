import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'detalle_restaurante_page.dart';

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

  // ============================================================
  // CARGAR DATOS
  // ============================================================
  Future<void> cargarDatos() async {
    final db = DBService.instance;

    final lista = await db.obtenerRestaurantes();

    // ⭐ Agregamos rating si no existe (porque tu tabla no lo tiene)
    for (var r in lista) {
      if (r["rating"] == null) {
        r["rating"] = 3.5 + (r["id"] % 3); // bonito y consistente
      }
    }

    List<int> listaFav = [];
    if (widget.usuario != null) {
      listaFav = await db.obtenerFavoritosIds(widget.usuario!["id"]);
    }

    setState(() {
      restaurantes = lista;
      favoritos = listaFav;
      cargando = false;
    });
  }

  // ============================================================
  // FAVORITOS
  // ============================================================
  Future<void> toggleFav(int restauranteId) async {
    if (widget.usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicia sesión para guardar favoritos")),
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
      drawer: Drawer(
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
  ),
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.purple.shade200,
        ),
        child: const Text(
          'AppTurismo',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      ListTile(
        leading: const Icon(Icons.place),
        title: const Text("Lugares"),
        onTap: () {
          Navigator.pushNamed(context, "/lugares", arguments: usuario);
        },
      ),

      ListTile(
        leading: const Icon(Icons.restaurant_menu),
        title: const Text("Restaurantes"),
        onTap: () {
          Navigator.pushNamed(context, "/restaurantes", arguments: usuario);
        },
      ),

      ListTile(
        leading: const Icon(Icons.local_bar),
        title: const Text("Bares"),
        onTap: () {
          Navigator.pushNamed(context, "/bares", arguments: usuario);
        },
      ),

      ListTile(
        leading: const Icon(Icons.event),
        title: const Text("Fechas destacadas"),
        onTap: () {
          Navigator.pushNamed(context, "/fechas", arguments: usuario);
        },
      ),

      ListTile(
        leading: const Icon(Icons.recommend),
        title: const Text("Recomendaciones"),
        onTap: () {
          Navigator.pushNamed(context, "/recomendaciones", arguments: usuario);
        },
      ),

      const Divider(),

      ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Perfil"),
        onTap: () {
          Navigator.pushNamed(context, "/perfil", arguments: usuario);
        },
      ),

      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text("Cerrar sesión"),
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
        },
      ),
    ],
  ),
),

      backgroundColor: Colors.white,
      body: SafeArea(
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= TÍTULO =================
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
                        // Flecha atrás
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 24),
                  ),
                  const SizedBox(width: 10),
                        // Menú
                        Builder(
                          builder: (context) {
                            return GestureDetector(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.menu, size: 28),
                              ),
                            );
                          },
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
                        CircleAvatar(
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
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ========= TÍTULO DE PÁGINA =========
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Text(
                            "RESTAURANTES",
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

                    // ====================================================
                    // RESTAURANTES CAROS
                    // ====================================================
                    Text(
                      "RESTAURANTES CAROS",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _listaHorizontal(
                      restaurantes.where((r) => r["precio"] == "alto").toList(),
                    ),

                    const SizedBox(height: 25),

                    // ====================================================
                    // RESTAURANTES ECONÓMICOS
                    // ====================================================
                    Text(
                      "RESTAURANTES ECONÓMICOS",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _listaHorizontal(
                      restaurantes.where((r) => r["precio"] == "bajo").toList(),
                    ),

                    const SizedBox(height: 25),

                    // ====================================================
                    // POPULARES
                    // ====================================================
                    Text(
                      "POPULARES",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _listaHorizontal(restaurantes),
                  ],
                ),
              ),
      ),
    );
  }

  // ============================================================
  // LISTA HORIZONTAL
  // ============================================================
  Widget _listaHorizontal(List<Map<String, dynamic>> lista) {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: lista.map((r) {
          final esFav = favoritos.contains(r["id"]);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleRestaurantePage(
                    restaurante: r,
                    usuario: widget.usuario,
                  ),
                ),
              );
            },
            child: _restauranteCard(r, esFav),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // TARJETA DE RESTAURANTE
  // ============================================================
  Widget _restauranteCard(Map<String, dynamic> r, bool esFav) {
    final rating = (r["rating"] as num?)?.toStringAsFixed(1) ?? "3.5";

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                Image.asset(
                  r["imagenAsset"],
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () => toggleFav(r["id"]),
                    child: Icon(
                      esFav ? Icons.favorite : Icons.favorite_border,
                      color: esFav ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
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
                  r["nombre"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r["direccion"] ?? "",
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
                    Text(rating),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
