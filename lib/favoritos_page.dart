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

    try {
      final usuarioId = widget.usuario!["id"] as int;
      
      // Obtener todos los favoritos del usuario
      final todosFavoritos = await DBService.instance.obtenerTodosFavoritos(usuarioId);
      
      // Obtener datos de lugares, restaurantes y bares
      final todosLugares = await DBService.instance.obtenerLugares();
      final todosRestaurantes = await DBService.instance.obtenerRestaurantes();
      final todosBares = await DBService.instance.obtenerBares();
      
      List<Map<String, dynamic>> favs = [];
      
      for (var fav in todosFavoritos) {
        final id = fav["lugarId"] as int;
        final tipo = (fav["tipo"] as String?) ?? 'lugar'; // Default si es null
        
        if (tipo == 'lugar') {
          final lugar = todosLugares.firstWhere(
            (l) => l["id"] == id,
            orElse: () => {},
          );
          if (lugar.isNotEmpty) {
            // Crear una copia mutable del Map
            final lugarCopia = Map<String, dynamic>.from(lugar);
            lugarCopia["tipo"] = "lugar";
            favs.add(lugarCopia);
          }
        } else if (tipo == 'restaurante') {
          final restaurante = todosRestaurantes.firstWhere(
            (r) => r["id"] == id,
            orElse: () => {},
          );
          if (restaurante.isNotEmpty) {
            // Crear una copia mutable del Map
            final restauranteCopia = Map<String, dynamic>.from(restaurante);
            restauranteCopia["tipo"] = "restaurante";
            favs.add(restauranteCopia);
          }
        } else if (tipo == 'bar') {
          final bar = todosBares.firstWhere(
            (b) => b["id"] == id,
            orElse: () => {},
          );
          if (bar.isNotEmpty) {
            // Crear una copia mutable del Map
            final barCopia = Map<String, dynamic>.from(bar);
            barCopia["tipo"] = "bar";
            favs.add(barCopia);
          }
        }
      }

      setState(() {
        lugaresFav = favs;
        cargando = false;
      });
    } catch (e) {
      print("ERROR al cargar favoritos: $e");
      setState(() {
        lugaresFav = [];
        cargando = false;
      });
    }
  }

  Future<void> _toggleFavorito(int lugarId, String tipo) async {
    if (widget.usuario == null) return;

    await DBService.instance.toggleFavorito(widget.usuario!["id"], lugarId, tipo: tipo);
    await _cargarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Favoritos',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: _menuDrawer(usuario),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- MENÚ HAMBURGUESA + BUSCADOR ---
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu, size: 28),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        padding: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomSearchBar(usuario: widget.usuario),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botón de Favoritos (solo si hay usuario)
              if (usuario != null)
                GestureDetector(
                  onTap: () {
                    // Ya estamos en favoritos, no hace nada o recarga
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, color: Colors.purple.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "Mis Favoritos",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

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
          tipo: lugar["tipo"] ?? "lugar",
        );
      },
    );
  }

  Widget _favoritoCard({
    required int id,
    required String nombre,
    required String direccion,
    required String img,
    required String tipo,
  }) {
    return GestureDetector(
      onTap: () {
        // Obtener el item completo para navegar al detalle
        final item = lugaresFav.firstWhere(
          (l) => l["id"] == id && l["tipo"] == tipo,
          orElse: () => {},
        );
        
        if (item.isEmpty) return;
        
        // Navegar según el tipo
        if (tipo == "lugar") {
          Navigator.pushNamed(
            context,
            "/detalleLugar",
            arguments: {"lugar": item, "usuario": widget.usuario},
          );
        } else if (tipo == "restaurante") {
          Navigator.pushNamed(
            context,
            "/detalleRestaurante",
            arguments: {"restaurante": item, "usuario": widget.usuario},
          );
        } else if (tipo == "bar") {
          Navigator.pushNamed(
            context,
            "/detalleBar",
            arguments: {"bar": item, "usuario": widget.usuario},
          );
        }
      },
      child: Container(
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
              onPressed: () => _toggleFavorito(id, tipo),
            ),

            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Drawer _menuDrawer(usuario) {
    return Drawer(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(25))),
      child: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD7CCC8),
                  Color(0xFFBCAAA4),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Center(
              child: Text(
                "AppTourist",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _menuItem(Icons.place, "Lugares", () {
                  Navigator.pushNamed(context, "/lugares", arguments: usuario);
                }),
                _menuItem(Icons.restaurant_menu, "Restaurantes", () {
                  Navigator.pushNamed(context, "/restaurantes", arguments: usuario);
                }),
                _menuItem(Icons.local_bar, "Bares", () {
                  Navigator.pushNamed(context, "/bares", arguments: usuario);
                }),
                _menuItem(Icons.event, "Actividades", () {
                  Navigator.pushNamed(context, "/fechas", arguments: usuario);
                }),
                _menuItem(Icons.recommend, "Recomendaciones", () {
                  Navigator.pushNamed(context, "/recomendaciones", arguments: usuario);
                }),
                const Divider(height: 20, thickness: 1),
                _menuItem(Icons.person, "Perfil", () async {
                  if (usuario != null) {
                    await Navigator.pushNamed(context, "/perfil", arguments: usuario);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Debes iniciar sesión para ver tu perfil")),
                    );
                  }
                }),
                _menuItem(Icons.logout, "Cerrar sesión", () {
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
                }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.orange.shade700, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}
