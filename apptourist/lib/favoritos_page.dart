import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/backend_api_service.dart';
import 'detalle_lugar_page.dart';
import 'detalle_restaurante_page.dart';
import 'detalle_bares_page.dart';

class FavoritosPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final String? tipo; // 'restaurante', 'bar', 'lugar'

  const FavoritosPage({super.key, this.usuario, this.tipo});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  bool cargando = true;
  List<Map<String, dynamic>> favoritos = [];
  late String tipoActual;

  @override
  void initState() {
    super.initState();
    // Si viene un tipo específico desde la lista, usamos ese
    tipoActual = widget.tipo ?? 'lugar';
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    if (widget.usuario == null) {
      setState(() {
        cargando = false;
        favoritos = [];
      });
      return;
    }

    try {
      // Obtener favoritos del tipo especificado desde el backend
      final favs = await BackendApiService.instance.obtenerFavoritosPorTipo(
        tipoActual,
      );

      // Extraer los datos del objeto favoritable
      final favoritosProcessados = favs.map((fav) {
        final item = Map<String, dynamic>.from(fav['favoritable'] ?? {});
        item['tipo'] = tipoActual;
        return item;
      }).toList();

      setState(() {
        favoritos = favoritosProcessados;
        cargando = false;
      });
    } catch (e) {
      print("ERROR al cargar favoritos: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar favoritos: $e')));
      setState(() {
        favoritos = [];
        cargando = false;
      });
    }
  }

  Future<void> _toggleFavorito(int id) async {
    if (widget.usuario == null) return;

    try {
      await BackendApiService.instance.toggleFavorito(
        favoritableType: tipoActual,
        favoritableId: id,
      );
      await _cargarFavoritos();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
          'Mis Favoritos',
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
              // --- MENÚ HAMBURGUESA ---
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
                    child: Text(
                      'Favoritos de ${tipoActual}s',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Selector de tipo (opcional, para cambiar entre tipos)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tipoButton('Lugar', tipoActual == 'Lugar'),
                    const SizedBox(width: 10),
                    _tipoButton('Restaurante', tipoActual == 'Restaurante'),
                    const SizedBox(width: 10),
                    _tipoButton('Bar', tipoActual == 'Bar'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contenido
              Expanded(child: _buildContenido()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipoButton(String tipo, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tipoActual = tipo;
          cargando = true;
        });
        _cargarFavoritos();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tipo.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
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

    if (favoritos.isEmpty) {
      return Center(
        child: Text(
          "No tienes ${tipoActual}s en favoritos aún.",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final item = favoritos[index];
        return _favoritoCard(
          id: item["id"] as int,
          nombre: item["nombre"] ?? "",
          direccion: item["direccion"] ?? "",
          img: item["imagenAsset"] ?? "",
          item: item,
        );
      },
    );
  }

  Widget _favoritoCard({
    required int id,
    required String nombre,
    required String direccion,
    required String img,
    required Map<String, dynamic> item,
  }) {
    return GestureDetector(
      onTap: () {
        // Navegar según el tipo
        if (tipoActual == "lugar") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DetalleLugarPage(lugar: item, usuario: widget.usuario),
            ),
          );
        } else if (tipoActual == "restaurante") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleRestaurantePage(
                restaurante: item,
                usuario: widget.usuario,
              ),
            ),
          );
        } else if (tipoActual == "bar") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DetalleBarPage(bar: item, usuario: widget.usuario),
            ),
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
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: Container(
                width: 110,
                height: 90,
                color: Colors.grey.shade200,
                child: Image.asset(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
            ),

            // Texto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Drawer _menuDrawer(usuario) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD7CCC8), Color(0xFFBCAAA4)],
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
                  Navigator.pushNamed(
                    context,
                    "/restaurantes",
                    arguments: usuario,
                  );
                }),
                _menuItem(Icons.local_bar, "Bares", () {
                  Navigator.pushNamed(context, "/bares", arguments: usuario);
                }),
                _menuItem(Icons.event, "Actividades", () {
                  Navigator.pushNamed(context, "/fechas", arguments: usuario);
                }),
                _menuItem(Icons.recommend, "Recomendaciones", () {
                  Navigator.pushNamed(
                    context,
                    "/recomendaciones",
                    arguments: usuario,
                  );
                }),
                const Divider(height: 20, thickness: 1),
                _menuItem(Icons.person, "Perfil", () async {
                  if (usuario != null) {
                    await Navigator.pushNamed(
                      context,
                      "/perfil",
                      arguments: usuario,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Debes iniciar sesión para ver tu perfil",
                        ),
                      ),
                    );
                  }
                }),
                _menuItem(Icons.logout, "Cerrar sesión", () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/login",
                    (_) => false,
                  );
                }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
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
