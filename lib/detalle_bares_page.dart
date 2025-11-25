import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'db_service.dart';

class DetalleBarPage extends StatefulWidget {
  final Map<String, dynamic> bar;
  final Map<String, dynamic>? usuario;

  const DetalleBarPage({
    super.key,
    required this.bar,
    this.usuario,
  });

  @override
  State<DetalleBarPage> createState() => _DetalleBarPageState();
}

class _DetalleBarPageState extends State<DetalleBarPage> {
  late List imagenes;
  final PageController _pageCtrl = PageController();

  List<Map<String, dynamic>> comentarios = [];
  final TextEditingController comentarioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    imagenes = widget.bar["imagenes"] != null
        ? jsonDecode(widget.bar["imagenes"])
        : [];

    cargarComentarios();
  }

  Future<void> cargarComentarios() async {
    final lista = await DBService.instance
        .obtenerComentariosDeRestaurante(widget.bar["id"]);

    setState(() {
      comentarios = lista;
    });
  }

  Future<void> enviarComentario() async {
    final texto = comentarioCtrl.text.trim();
    if (texto.isEmpty) return;

    await DBService.instance.insertarComentario(
      usuarioId: widget.usuario?["id"],
      restauranteId: widget.bar["id"],
      texto: texto,
    );

    comentarioCtrl.clear();
    await cargarComentarios();
  }

  Future<void> _abrirComoLlegar() async {
    final q = Uri.encodeComponent(
        "${widget.bar["nombre"]}, ${widget.bar["direccion"]}, Sucre Bolivia");

    final uri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$q");

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
    final r = widget.bar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AppTurismo",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu, size: 26),
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

              Text(
                r["nombre"],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _carruselImagenes(),

              const SizedBox(height: 20),

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

              Text(
                "HORARIO",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                r["horario"] ?? "Sin horario registrado",
                style: GoogleFonts.poppins(fontSize: 14),
              ),

              const SizedBox(height: 22),

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
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagenes[i],
                  fit: BoxFit.cover,
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
