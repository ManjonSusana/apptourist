import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final String? nombreUsuario;

  const HomePage({super.key, this.nombreUsuario});

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

                  // --------- SI NO HAY USUARIO → INICIAR SESIÓN ---------
                  if (nombreUsuario == null)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBEE8FF),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Iniciar Sesión',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    // --------- SI HAY USUARIO → ICONO DE PERFIL ---------
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/perfil",
                          arguments: nombreUsuario,
                        );
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.purple[200],
                        child: Text(
                          nombreUsuario![0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                ],
              ),

              const SizedBox(height: 24),

              // BUSCADOR (YA CORREGIDO)
              const CustomSearchBar(),

              const SizedBox(height: 30),

              // BOTONES GRANDES CON LOS COLORES DEL MOCKUP
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      MenuButton(
                        title: 'Lugares',
                        color: const Color(0xFFFFC8C8),
                        ruta: '/lugares',
                        icon: Icons.place,
                      ),
                      MenuButton(
                        title: 'Restaurantes',
                        color: const Color(0xFFC7F3D0),
                        ruta: '/restaurantes',
                        icon: Icons.restaurant,
                      ),
                      MenuButton(
                        title: 'Bares',
                        color: const Color(0xFFFFE9A8),
                        ruta: '/bares',
                        icon: Icons.local_bar,
                      ),
                      MenuButton(
                        title: 'Fechas Destacadas',
                        color: const Color(0xFFD0C2FF),
                        ruta: '/fechas',
                        icon: Icons.calendar_today,
                      ),
                      MenuButton(
                        title: 'Recomendaciones',
                        color: const Color(0xFFEADCCF),
                        ruta: '/recomendaciones',
                        icon: Icons.thumb_up,
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
}

// ---------------------- CustomSearchBar (renombrado) ----------------------
class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.search, color: Colors.grey[700], size: 26),
            ),
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Buscar lugares, restaurantes, bares...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  Navigator.pushNamed(context, '/search', arguments: value);
                },
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filtros aún no implementados')),
                        );
                      },
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

// ---------------------- MenuButton StatefulWidget ----------------------
class MenuButton extends StatefulWidget {
  final String title;
  final Color color;
  final String ruta;
  final IconData icon;

  const MenuButton({super.key, required this.title, required this.color, required this.ruta, required this.icon});

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _hover = false;

  void _setHover(bool value) => setState(() => _hover = value);

  @override
  Widget build(BuildContext context) {
    final double scale = _hover ? 1.02 : 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, widget.ruta),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
