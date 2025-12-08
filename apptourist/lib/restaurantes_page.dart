import '../services/backend_api_service.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';

class RestaurantesPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const RestaurantesPage({super.key, this.usuario});

  @override
  State<RestaurantesPage> createState() => _RestaurantesPageState();
}

class _RestaurantesPageState extends State<RestaurantesPage> {
  List<Map<String, dynamic>> restaurantes = [];
  List<Map<String, dynamic>> restaurantesFiltrados = [];
  List<int> favoritos = [];
  bool cargando = true;
  String textoBusqueda = "";

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cargarDatos();
  }

  // Removed didPopNext as it is not a valid lifecycle method

  // ============================================================
  // VERIFICAR FAVORITOS
  // ============================================================
  Future<void> _verificarFavoritos() async {
    if (widget.usuario == null) return;
    try {
      final favs = await BackendApiService.instance.obtenerFavoritosPorTipo(
        'Restaurante',
      );
      final ids = favs.map((fav) => (fav['favoritable'] ?? {})['id']).toList();
      setState(() {
        favoritos = ids.cast<int>();
      });
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  // ============================================================
  // CARGAR DATOS
  // ============================================================
  Future<void> cargarDatos() async {
    final db = DBService.instance;

    try {
      final listaDesdeApi = await BackendApiService.instance
          .obtenerRestaurantes();

      setState(() {
        restaurantes = listaDesdeApi;
        restaurantesFiltrados = listaDesdeApi;
        cargando = false;
      });

      // Cargar favoritos después de cargar restaurantes
      await _verificarFavoritos();
    } catch (e) {
      // Si falla el backend, hacemos fallback a SQLite local
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron cargar restaurantes desde el servidor: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );

      final listaLocal = await db.obtenerRestaurantes();

      setState(() {
        restaurantes = listaLocal;
        restaurantesFiltrados = listaLocal;
        cargando = false;
      });
    }
  }

  void filtrarRestaurantes(String query) {
    setState(() {
      textoBusqueda = query;
      if (query.isEmpty) {
        restaurantesFiltrados = restaurantes;
      } else {
        restaurantesFiltrados = restaurantes.where((rest) {
          final nombre = rest["nombre"].toString().toLowerCase();
          final direccion = (rest["direccion"] ?? "").toString().toLowerCase();
          final busqueda = query.toLowerCase();
          return nombre.contains(busqueda) || direccion.contains(busqueda);
        }).toList();
      }
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

    try {
      await BackendApiService.instance.toggleFavorito(
        favoritableType: 'App\\Models\\Restaurante',
        favoritableId: restauranteId,
      );

      // Recargar favoritos después de hacer toggle
      await _verificarFavoritos();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar favorito: $e')));
    }
  }

  // ============================================================
  // NAVEGACIÓN A PÁGINA DETALLE
  // ============================================================
  Future<void> _navigateToDetailPage(
    String route,
    Map<String, dynamic> arguments,
  ) async {
    await Navigator.pushNamed(context, route, arguments: arguments).then((_) {
      setState(() {
        cargarDatos();
      });
    });
  }

  // ============================================================
  // INTERFAZ
  // ============================================================
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
          'Restaurantes',
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
        child: RefreshIndicator(
          onRefresh: cargarDatos,
          child: cargando
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                                padding: EdgeInsets.zero,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomSearchBar(
                              onSearch: filtrarRestaurantes,
                              usuario: widget.usuario,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botón de Favoritos (solo si hay usuario)
                      if (usuario != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                "/favoritos",
                                arguments: {
                                  "usuario": usuario,
                                  "tipo": "Restaurante",
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.brown.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.brown.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.brown.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Mis Favoritos",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.brown.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),

                      // =====================================================
                      // RESTAURANTES CAROS
                      // =====================================================
                      _tituloSeccion("RESTAURANTES CAROS"),
                      _listaHorizontal(
                        restaurantesFiltrados
                            .where((r) => r["precio"] == "alto")
                            .toList(),
                      ),

                      const SizedBox(height: 25),

                      // =====================================================
                      // RESTAURANTES ECONÓMICOS
                      // =====================================================
                      _tituloSeccion("RESTAURANTES ECONÓMICOS"),
                      _listaHorizontal(
                        restaurantesFiltrados
                            .where((r) => r["precio"] == "bajo")
                            .toList(),
                      ),

                      const SizedBox(height: 25),

                      // =====================================================
                      // POPULARES (TODOS)
                      // =====================================================
                      _tituloSeccion("POPULARES"),
                      _listaHorizontal(restaurantesFiltrados),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER MENU
  // ============================================================
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
                _menuItem(Icons.person, "Perfil", () {
                  if (usuario == null) {
                    Navigator.pushNamed(context, "/login");
                  } else {
                    Navigator.pushNamed(context, "/perfil", arguments: usuario);
                  }
                }),
                _menuItem(Icons.logout, "Cerrar sesión", () {
                  Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
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

  // ============================================================
  // SECCIÓN TÍTULO
  // ============================================================
  Widget _tituloSeccion(String texto) {
    return Text(
      texto,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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
              Navigator.pushNamed(
                context,
                "/detalleRestaurante",
                arguments: {"restaurante": r, "usuario": widget.usuario},
              );
            },
            child: _restauranteCard(r, esFav),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // TARJETA RESTAURANTE
  // ============================================================
  Widget _restauranteCard(Map<String, dynamic> r, bool esFav) {
    final rating = (r["rating"] as num?)?.toStringAsFixed(1) ?? "3.5";

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
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

// =============================================================
// SEARCH BAR CON FILTROS
// =============================================================
class CustomSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final Map<String, dynamic>? usuario;

  const CustomSearchBar({super.key, this.onSearch, this.usuario});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona una categoría',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              _opcionCategoria(
                'Actividades',
                Icons.event,
                const Color(0xFFD0C2FF),
                '/fechas',
              ),
              _opcionCategoria(
                'Lugares',
                Icons.place,
                const Color(0xFFFFC8C8),
                '/lugares',
              ),
              _opcionCategoria(
                'Restaurantes',
                Icons.restaurant,
                const Color(0xFFC7F3D0),
                '/restaurantes',
              ),
              _opcionCategoria(
                'Bares',
                Icons.local_bar,
                const Color(0xFFFFE9A8),
                '/bares',
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _opcionCategoria(
    String titulo,
    IconData icono,
    Color color,
    String ruta,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, ruta, arguments: widget.usuario);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icono, color: Colors.black87, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }

  void _realizarBusqueda(String query) {
    if (query.trim().isEmpty) return;

    final queryLower = query.toLowerCase().trim();

    if (queryLower.contains('restaurante') ||
        queryLower.contains('comida') ||
        queryLower.contains('comer')) {
      Navigator.pushNamed(context, '/restaurantes', arguments: widget.usuario);
    } else if (queryLower.contains('bar') ||
        queryLower.contains('bares') ||
        queryLower.contains('cerveza') ||
        queryLower.contains('trago')) {
      Navigator.pushNamed(context, '/bares', arguments: widget.usuario);
    } else if (queryLower.contains('actividad') ||
        queryLower.contains('fecha') ||
        queryLower.contains('evento') ||
        queryLower.contains('destacada')) {
      Navigator.pushNamed(context, '/fechas', arguments: widget.usuario);
    } else if (queryLower.contains('lugar') ||
        queryLower.contains('sitio') ||
        queryLower.contains('visitar')) {
      Navigator.pushNamed(context, '/lugares', arguments: widget.usuario);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            '¿Dónde quieres buscar?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No se detectó una categoría específica. Selecciona dónde buscar:',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _dialogButton('Lugares', Icons.place, () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/lugares',
                  arguments: widget.usuario,
                );
              }),
              _dialogButton('Restaurantes', Icons.restaurant, () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/restaurantes',
                  arguments: widget.usuario,
                );
              }),
              _dialogButton('Bares', Icons.local_bar, () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/bares',
                  arguments: widget.usuario,
                );
              }),
              _dialogButton('Actividades', Icons.event, () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/fechas',
                  arguments: widget.usuario,
                );
              }),
            ],
          ),
        ),
      );
    }
  }

  Widget _dialogButton(String texto, IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icono, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              texto,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(Icons.search, size: 22, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                if (widget.onSearch != null) {
                  widget.onSearch!(value);
                }
              },
              onSubmitted: _realizarBusqueda,
            ),
          ),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final hasText = _ctrl.text.isNotEmpty;
              return Row(
                children: [
                  if (hasText)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _ctrl.clear()),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  IconButton(
                    icon: const Icon(Icons.tune, size: 18),
                    onPressed: _mostrarFiltros,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
