import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleLugarPage extends StatefulWidget {
  final Map<String, dynamic> lugar;

  const DetalleLugarPage({super.key, required this.lugar});

  @override
  State<DetalleLugarPage> createState() => _DetalleLugarPageState();
}

class _DetalleLugarPageState extends State<DetalleLugarPage> {
  late List imagenes;
  final PageController _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    imagenes = widget.lugar["imagenes"] != null
        ? jsonDecode(widget.lugar["imagenes"])
        : [];
  }

  // ============================================================
  // ABRIR GOOGLE MAPS (CÓMO LLEGAR)
  // ============================================================
  Future<void> _abrirComoLlegar() async {
    final nombre = (widget.lugar["nombre"] ?? "").toString();
    final direccion = (widget.lugar["direccion"] ?? "").toString();

    if (nombre.isEmpty && direccion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay dirección disponible.")),
      );
      return;
    }

    // Aquí puedes cambiar "Sucre, Bolivia" por tu ciudad por defecto
    final query = Uri.encodeComponent("$nombre, $direccion, Sucre, Bolivia");

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir Google Maps.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lugar = widget.lugar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "AppTurismo",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xffe2c4ff),
                    child: Icon(Icons.person, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // -------- BUSCADOR --------
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar...",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Inicio",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ---------------- TITULO ----------------
              Text(
                lugar["nombre"],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // -------------- CARRUSEL -----------------
              _carruselImagenes(),

              const SizedBox(height: 20),

              // ---------------- DIRECCIÓN ----------------
              Text(
                "DIRECCIÓN",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                lugar["direccion"] ?? "",
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              const SizedBox(height: 12),

              // BOTÓN CÓMO LLEGAR
              GestureDetector(
                onTap: _abrirComoLlegar,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "CÓMO LLEGAR",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ---------------- HORARIO ----------------
              Text(
                "HORARIOS DE ATENCIÓN",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                lugar["horario"] ?? "Sin horario registrado",
                style: GoogleFonts.poppins(fontSize: 14),
              ),

              const SizedBox(height: 20),

              // ---------------- RATING ----------------
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 26),
                  const SizedBox(width: 4),
                  Text(
                    lugar["rating"].toString(),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ---------------- COMENTARIOS ----------------
              Text(
                "COMENTARIOS",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              _comentario("Z", "El lugar es muy bonito y cómodo"),
              _comentario("A", "La atención es muy buena y todo estaba rico"),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARRUSEL DE IMÁGENES
  // ============================================================
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
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/fullImage",
                    arguments: imagenes[i],
                  );
                },
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
        const SizedBox(height: 14),
        SmoothPageIndicator(
          controller: _pageCtrl,
          count: imagenes.length,
          effect: ExpandingDotsEffect(
            activeDotColor: Colors.deepPurple,
            dotHeight: 10,
            dotWidth: 10,
          ),
        )
      ],
    );
  }

  Widget _comentario(String letra, String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.red.shade200,
            child: Text(
              letra,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
