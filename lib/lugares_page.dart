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
    final lista = await db.obtenerLugares();

    List<int> favs = [];
    if (widget.usuario != null) {
      favs = await db.obtenerFavoritosIds(widget.usuario!["id"]);
    }

    setState(() {
      lugares = lista;
      favoritos = favs;
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lugares',
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
                              onPressed: () => Scaffold.of(context).openDrawer(),
                              padding: EdgeInsets.zero,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(14),
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
                      ],
                    ),
                    const SizedBox(height: 25),

                    // --- Título sección ---
                    _tituloSeccion("LUGARES CAROS"),
                    _listaHorizontal(
                        lugares.where((l) => l["categoria"] == "caro").toList()),

                    const SizedBox(height: 25),

                    _tituloSeccion("LUGARES ECONÓMICOS"),
                    _listaHorizontal(lugares
                        .where((l) => l["categoria"] == "economico")
                        .toList()),
                  ],
                ),
              ),
      ),
    );
  }

  Drawer _menuDrawer(usuario) {
    return Drawer(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(25))),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.purple.shade200),
            child: const Text("AppTurismo",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          ListTile(
              leading: const Icon(Icons.place),
              title: const Text("Lugares"),
              onTap: () => Navigator.pushNamed(context, "/lugares",
                  arguments: usuario)),
          ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text("Restaurantes"),
              onTap: () => Navigator.pushNamed(context, "/restaurantes",
                  arguments: usuario)),
          ListTile(
              leading: const Icon(Icons.local_bar),
              title: const Text("Bares"),
              onTap: () =>
                  Navigator.pushNamed(context, "/bares", arguments: usuario)),
          ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Fechas destacadas"),
              onTap: () =>
                  Navigator.pushNamed(context, "/fechas", arguments: usuario)),
          ListTile(
              leading: const Icon(Icons.recommend),
              title: const Text("Recomendaciones"),
              onTap: () => Navigator.pushNamed(
                  context, "/recomendaciones",
                  arguments: usuario)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Perfil"),
            onTap: () =>
                Navigator.pushNamed(context, "/perfil", arguments: usuario),
          ),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (_) => false)),
        ],
      ),
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Text(titulo,
        style:
            GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _listaHorizontal(List<Map<String, dynamic>> lista) {
    return SizedBox(
      height: 240,
      child: ListView(
          scrollDirection: Axis.horizontal,
          children: lista.map((lugar) {
            final esFav = favoritos.contains(lugar["id"]);
            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                  context, "/detalleLugar",
                  arguments: lugar),
              child: _lugarCard(lugar, esFav),
            );
          }).toList()),
    );
  }

  Widget _lugarCard(Map<String, dynamic> lugar, bool esFav) {
    final rating = (lugar["rating"] as num?)?.toStringAsFixed(1) ?? "3.2";

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          color: Colors.white,
          borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
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
                      size: 28,
                      color: esFav ? Colors.red : Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lugar["nombre"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(lugar["direccion"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating),
                    ],
                  )
                ]),
          )
        ],
      ),
    );
  }
}
