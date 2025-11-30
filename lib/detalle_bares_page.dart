import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
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

    try {
      imagenes = widget.bar["imagenes"] != null
          ? jsonDecode(widget.bar["imagenes"])
          : [];
    } catch (e) {
      imagenes = [];
    }

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

    // Verificar que el usuario esté logueado
    if (widget.usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes iniciar sesión para comentar")),
      );
      return;
    }

    await DBService.instance.insertarComentario(
      usuarioId: widget.usuario!["id"],
      restauranteId: widget.bar["id"],
      texto: texto,
    );

    comentarioCtrl.clear();
    await cargarComentarios();
  }

  // Editar comentario
  Future<void> _editarComentario(int comentarioId, String textoActual) async {
    final TextEditingController editController = TextEditingController(text: textoActual);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar comentario', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe tu comentario...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoTexto = editController.text.trim();
              if (nuevoTexto.isNotEmpty) {
                await DBService.instance.editarComentario(comentarioId, nuevoTexto);
                await cargarComentarios();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comentario actualizado', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Guardar', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Eliminar comentario
  Future<void> _eliminarComentario(int comentarioId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar comentario', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          '¿Estás seguro de que deseas eliminar este comentario?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DBService.instance.eliminarComentario(comentarioId);
      await cargarComentarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comentario eliminado', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _abrirComoLlegar() async {
    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permisos de ubicación denegados")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permisos de ubicación denegados permanentemente")),
        );
        return;
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final nombre = widget.bar["nombre"] ?? "Bar";
      final direccion = widget.bar["direccion"] ?? "Sucre";
      final destino = Uri.encodeComponent("$nombre, $direccion, Sucre Bolivia");

      // URL con direcciones desde ubicación actual hasta el destino
      final uri = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$destino&travelmode=driving"
      );

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener ubicación: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.bar;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bares',
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
      drawer: _menuDrawer(),
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
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
                    child: CustomSearchBar(),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Text(
                r["nombre"] ?? "Sin nombre",
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
                  comentarioId: c["id"],
                  usuarioId: c["usuarioId"],
                  usuario: c["usuarioNombre"] ?? "Anónimo",
                  fotoPerfil: c["usuarioFoto"],
                  texto: c["texto"] ?? "",
                  fecha: c["fecha"] ?? "",
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

  Drawer _menuDrawer() {
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
                  Navigator.pushNamed(context, "/lugares");
                }),
                _menuItem(Icons.restaurant_menu, "Restaurantes", () {
                  Navigator.pushNamed(context, "/restaurantes");
                }),
                _menuItem(Icons.local_bar, "Bares", () {
                  Navigator.pushNamed(context, "/bares");
                }),
                _menuItem(Icons.event, "Actividades", () {
                  Navigator.pushNamed(context, "/fechas");
                }),
                _menuItem(Icons.recommend, "Recomendaciones", () {
                  Navigator.pushNamed(context, "/recomendaciones");
                }),
                const Divider(height: 20, thickness: 1),
                _menuItem(Icons.person, "Perfil", () {
                  Navigator.pushNamed(context, "/perfil");
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
              final imagePath = imagenes[i]?.toString() ?? "";
              if (imagePath.isEmpty) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Text("Sin imagen")),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
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
    required int comentarioId,
    int? usuarioId,
    required String usuario,
    String? fotoPerfil,
    required String texto,
    required String fecha,
  }) {
    final bool esComentarioPropio = widget.usuario != null && 
                                     usuarioId != null && 
                                     widget.usuario!["id"] == usuarioId;

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
            radius: 20,
            backgroundColor: Colors.deepPurpleAccent,
            backgroundImage: fotoPerfil != null && fotoPerfil.isNotEmpty
                ? FileImage(File(fotoPerfil))
                : null,
            child: fotoPerfil == null || fotoPerfil.isEmpty
                ? Text(
                    usuario[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        usuario,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (esComentarioPropio)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                            onPressed: () => _editarComentario(comentarioId, texto),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => _eliminarComentario(comentarioId),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
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

// =====================================================================
//                        CUSTOM SEARCH BAR
// =====================================================================
class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final _ctrl = TextEditingController();

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
        Navigator.pushNamed(context, ruta);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: Colors.black87,
              size: 24,
            ),
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
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 18,
            ),
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
      Navigator.pushNamed(context, '/restaurantes');
    } else if (queryLower.contains('bar') || 
               queryLower.contains('bares') || 
               queryLower.contains('cerveza') || 
               queryLower.contains('trago')) {
      Navigator.pushNamed(context, '/bares');
    } else if (queryLower.contains('actividad') || 
               queryLower.contains('fecha') || 
               queryLower.contains('evento') || 
               queryLower.contains('destacada')) {
      Navigator.pushNamed(context, '/fechas');
    } else if (queryLower.contains('lugar') || 
               queryLower.contains('sitio') || 
               queryLower.contains('visitar')) {
      Navigator.pushNamed(context, '/lugares');
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
                Navigator.pushNamed(context, '/lugares');
              }),
              _dialogButton('Restaurantes', Icons.restaurant, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/restaurantes');
              }),
              _dialogButton('Bares', Icons.local_bar, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/bares');
              }),
              _dialogButton('Actividades', Icons.event, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/fechas');
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
          )
        ],
      ),
    );
  }
}
