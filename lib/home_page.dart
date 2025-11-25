import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? usuario; // Recibe el usuario completo

  const HomePage({super.key, this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

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
                    _iconoPerfil(context, usuario),
                ],
              ),

              const SizedBox(height: 24),

              // ---------------- BUSCADOR ----------------
              const CustomSearchBar(),

              const SizedBox(height: 30),

              // ---------------- MENÚ PRINCIPAL ----------------
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      MenuButton(
                        title: 'Lugares',
                        color: const Color(0xFFFFC8C8),
                        ruta: '/lugares',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Restaurantes',
                        color: const Color(0xFFC7F3D0),
                        ruta: '/restaurantes',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Bares',
                        color: const Color(0xFFFFE9A8),
                        ruta: '/bares',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Fechas Destacadas',
                        color: const Color(0xFFD0C2FF),
                        ruta: '/fechas',
                        usuario: usuario,
                      ),
                      MenuButton(
                        title: 'Recomendaciones',
                        color: const Color(0xFFEADCCF),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/perfil", arguments: usuario);
      },
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.purple[200],
        child: Text(
          usuario["nombre"][0].toUpperCase(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =============================================================
// SEARCH BAR
// =============================================================
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
                          const SnackBar(
                            content: Text("Filtros aún no implementados"),
                          ),
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

// =============================================================
// BOTONES DEL MENÚ PRINCIPAL
// =============================================================
class MenuButton extends StatelessWidget {
  final String title;
  final Color color;
  final String ruta;
  final Map<String, dynamic>? usuario;

  const MenuButton({
    super.key,
    required this.title,
    required this.color,
    required this.ruta,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ruta, arguments: usuario);
      },
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: color,
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}


