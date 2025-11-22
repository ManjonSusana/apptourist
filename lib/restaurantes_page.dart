import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomePage.dart'; // para usar el CustomSearchBar

class RestaurantesPage extends StatefulWidget {
  final String? nombreUsuario;

  const RestaurantesPage({super.key, this.nombreUsuario});

  @override
  State<RestaurantesPage> createState() => _RestaurantesPageState();
}

class _RestaurantesPageState extends State<RestaurantesPage> {
  final Set<String> favoritos = {};

  void toggleFavorito(String nombre) {
    setState(() {
      if (favoritos.contains(nombre)) favoritos.remove(nombre);
      else favoritos.add(nombre);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABECERA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TurismoApp',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Avatar (si hay usuario) -> perfil
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/perfil', arguments: widget.nombreUsuario);
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.purple.shade200,
                      child: Text(
                        widget.nombreUsuario != null ? widget.nombreUsuario![0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // BARRA DE BUSQUEDA + MENU + INICIO
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 30),
                    onPressed: () {},
                  ),

                  const SizedBox(width: 10),

                  // Usar el CustomSearchBar del HomePage
                  const Expanded(child: CustomSearchBar()),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'INICIO',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Encabezado sección y botón favoritos
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7F3D0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RESTAURANTES',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Icono favorito como botón que navega a /favoritos
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      size: 30,
                      color: favoritos.isEmpty ? Colors.grey : Colors.redAccent,
                    ),
                    tooltip: 'Ver favoritos',
                    onPressed: () {
                      Navigator.pushNamed(context, '/favoritos', arguments: {
                        'usuario': widget.nombreUsuario,
                        'favoritos': favoritos.toList(),
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // SECCIÓN 1
              Text(
                'Restaurantes Populares',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    restauranteCard('La Octava', 'C. Mayor 12'),
                    restauranteCard('Mar & Tierra', 'Av. Luna 3'),
                    restauranteCard('Trattoria Bella', 'Pza. Italia 7'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // SECCIÓN 2
              Text(
                'Económicos y Rápidos',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    restauranteCard('Comida Express', 'Plaza Norte'),
                    restauranteCard('Sabor Callejero', 'C. 10'),
                    restauranteCard('Rincón Casero', 'Barrio Sur'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget restauranteCard(String nombre, String direccion) {
    final bool esFav = favoritos.contains(nombre);

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Container(
              height: 110,
              color: Colors.grey.shade300,
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => toggleFavorito(nombre),
                      child: Icon(
                        esFav ? Icons.favorite : Icons.favorite_border,
                        color: esFav ? Colors.red : Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  direccion,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text('3.8', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
