import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'db_service.dart';

class DetalleRestaurantePage extends StatefulWidget {
  final Map<String, dynamic> restaurante;
  final Map<String, dynamic>? usuario;

  const DetalleRestaurantePage({
    super.key,
    required this.restaurante,
    this.usuario,
  });

  @override
  State<DetalleRestaurantePage> createState() => _DetalleRestaurantePageState();
}

class _DetalleRestaurantePageState extends State<DetalleRestaurantePage> {
  late List imagenes;
  final PageController _pageCtrl = PageController();

  List<Map<String, dynamic>> comentarios = [];
  final TextEditingController comentarioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    imagenes = widget.restaurante["imagenes"] != null
        ? jsonDecode(widget.restaurante["imagenes"])
        : [];

    cargarComentarios();
  }

  // ================= COMENTARIOS =================
  Future<void> cargarComentarios() async {
    final lista = await DBService.instance
        .obtenerComentariosDeRestaurante(widget.restaurante["id"]);

    setState(() {
      comentarios = lista;
    });
  }

  Future<void> enviarComentario() async {
    final texto = comentarioCtrl.text.trim();
    if (texto.isEmpty) return;

    await DBService.instance.insertarComentario(
      usuarioId: widget.usuario?["id"],
      restauranteId: widget.restaurante["id"],
      texto: texto,
    );

    comentarioCtrl.clear();
    await cargarComentarios();
  }

  // ================= GOOGLE MAPS =================
  Future<void> _abrirComoLlegar() async {
    final q = Uri.encodeComponent(
        "${widget.restaurante["nombre"]}, ${widget.restaurante["direccion"]}, Sucre Bolivia");

    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$q");

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurante;

    return Scaffold(
      backgroundColor: Colors.white,
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
            Navigator.pushNamed(context, "/lugares");
          },
        ),

        ListTile(
          leading: const Icon(Icons.restaurant),
          title: const Text("Restaurantes"),
          onTap: () {
            Navigator.pushNamed(context, "/restaurantes");
          },
        ),

        ListTile(
          leading: const Icon(Icons.local_bar),
          title: const Text("Bares"),
          onTap: () {
            Navigator.pushNamed(context, "/bares");
          },
        ),

        ListTile(
          leading: const Icon(Icons.event),
          title: const Text("Fechas destacadas"),
          onTap: () {
            Navigator.pushNamed(context, "/fechas");
          },
        ),

        ListTile(
          leading: const Icon(Icons.recommend),
          title: const Text("Recomendaciones"),
          onTap: () {
            Navigator.pushNamed(context, "/recomendaciones");
          },
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Perfil"),
          onTap: () {
            Navigator.pushNamed(context, "/perfil");
          },
        ),

        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Cerrar sesión"),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, "/login", (_) => false);
          },
        ),
      ],
    ),
  ),

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

              const SizedBox(height: 14),

              // =========== FLECHA + MENÚ + BUSCADOR ===========
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 24),
                  ),
                  const SizedBox(width: 10),

                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.menu, size: 26),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar...",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =============== TÍTULO DEL RESTAURANTE ===============
              Text(
                r["nombre"],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================== CARRUSEL ==================
              _carruselImagenes(),

              const SizedBox(height: 20),

              // ================= DESCRIPCIÓN =================
              Text(
                "DESCRIPCIÓN",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r["descripcion"] ?? "",
                style: GoogleFonts.poppins(fontSize: 14),
              ),

              const SizedBox(height: 20),

              // ================= DIRECCIÓN =================
              Text(
                "DIRECCIÓN",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                r["direccion"] ?? "",
                style: GoogleFonts.poppins(fontSize: 14),
              ),

              const SizedBox(height: 10),

              // ================= CÓMO LLEGAR =================
              GestureDetector(
                onTap: _abrirComoLlegar,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "CÓMO LLEGAR",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ================= COMENTARIOS =================
              Text(
                "COMENTARIOS",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              ...comentarios.map((c) {
                return _comentarioItem(
                  usuario: c["usuarioNombre"] ?? "Anónimo",
                  texto: c["texto"],
                  fecha: c["fecha"],
                );
              }),

              const SizedBox(height: 20),

              Text(
                "Deja tu comentario",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: comentarioCtrl,
                        decoration: const InputDecoration(
                          hintText: "Escribe tu experiencia...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: enviarComentario,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("Enviar"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CARRUSEL =================
  Widget _carruselImagenes() {
    if (imagenes.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text("Sin imágenes"),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: imagenes.length,
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  "/fullImage",
                  arguments: imagenes[i],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagenes[i],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageCtrl,
          count: imagenes.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: Colors.deepPurple,
            dotHeight: 10,
            dotWidth: 10,
          ),
        ),
      ],
    );
  }

  // ================= ITEM COMENTARIO =================
  Widget _comentarioItem({
    required String usuario,
    required String texto,
    required String fecha,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.deepPurpleAccent,
            child: Text(
              usuario[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  texto,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fecha,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
