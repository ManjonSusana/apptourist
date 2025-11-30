import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? usuario; // Recibe el usuario completo

  const HomePage({super.key, this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic>? usuario;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.usuario != oldWidget.usuario) {
      setState(() {
        usuario = widget.usuario;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- CABECERA ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TurismoApp',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // SI NO HAY USUARIO → INICIAR SESIÓN
                  if (usuario == null)
                    _botonIniciarSesion(context)
                  else
                    _iconoPerfil(context, usuario!),
                ],
              ),

              const SizedBox(height: 24),

              // ---------------- BUSCADOR ----------------
              CustomSearchBar(usuario: usuario),

              const SizedBox(height: 30),

              // ---------------- MENÚ PRINCIPAL ----------------
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      MenuButton(
                        title: 'Lugares',
                        imagePath: 'assets/images/FLugar.png',
                        ruta: '/lugares',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Restaurantes',
                        imagePath: 'assets/images/FRestaurante.png',
                        ruta: '/restaurantes',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Bares',
                        imagePath: 'assets/images/FBares.png',
                        ruta: '/bares',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Fechas Destacadas',
                        imagePath: 'assets/images/FFechas.png',
                        ruta: '/fechas',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Recomendaciones',
                        imagePath: 'assets/images/FRecomendaciones.png',
                        ruta: '/recomendaciones',
                        usuario: usuario,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- BOTÓN INICIAR SESIÓN --------------------
  Widget _botonIniciarSesion(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/login"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFBEE8FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Iniciar Sesión',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // -------------------- ICONO PERFIL --------------------
  Widget _iconoPerfil(BuildContext context, Map<String, dynamic> usuario) {
    final fotoPerfil = usuario["fotoPerfil"];
    
    return GestureDetector(
      onTap: () async {
        final usuarioActualizado = await Navigator.pushNamed(context, "/perfil", arguments: usuario);
        // Actualizar el usuario con los datos recibidos del perfil
        if (usuarioActualizado != null && usuarioActualizado is Map<String, dynamic>) {
          setState(() {
            this.usuario = usuarioActualizado;
          });
        }
      },
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.purple[200],
        backgroundImage: fotoPerfil != null && fotoPerfil.isNotEmpty
            ? FileImage(File(fotoPerfil))
            : null,
        child: fotoPerfil == null || fotoPerfil.isEmpty
            ? Text(
                usuario["nombre"][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}

// =============================================================
// SEARCH BAR
// =============================================================
class CustomSearchBar extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  
  const CustomSearchBar({super.key, this.usuario});

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
        Navigator.pop(context); // Cerrar modal
        Navigator.pushNamed(context, ruta, arguments: widget.usuario); // Navegar con usuario
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
    
    // Detectar palabras clave y redirigir a la sección correspondiente
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
      // Si no detecta ninguna categoría específica, mostrar opciones
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
                Navigator.pushNamed(context, '/lugares', arguments: widget.usuario);
              }),
              _dialogButton('Restaurantes', Icons.restaurant, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/restaurantes', arguments: widget.usuario);
              }),
              _dialogButton('Bares', Icons.local_bar, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/bares', arguments: widget.usuario);
              }),
              _dialogButton('Actividades', Icons.event, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/fechas', arguments: widget.usuario);
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
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.search, size: 26, color: Colors.grey),
            ),

            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: 'Buscar lugares, restaurantes, bares...',
                  border: InputBorder.none,
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
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _ctrl.clear()),
                      ),
                    IconButton(
                      icon: const Icon(Icons.tune, size: 20),
                      onPressed: _mostrarFiltros,
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

// =============================================================
// BOTONES DEL MENÚ PRINCIPAL
// =============================================================
class MenuButton extends StatefulWidget {
  final String title;
  final String imagePath;
  final String ruta;
  final Map<String, dynamic>? usuario;

  const MenuButton({
    super.key,
    required this.title,
    required this.imagePath,
    required this.ruta,
    required this.usuario,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, widget.ruta, arguments: widget.usuario);
        },
        child: AnimatedScale(
          scale: isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: isHovered ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo
                  Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                  // Overlay oscuro para mejorar legibilidad
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // Texto
                  Center(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


