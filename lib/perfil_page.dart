import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilPage extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const PerfilPage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nombre = usuario["nombre"] ?? "";
    final correo = usuario["correo"] ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Mi Perfil", style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Avatar con inicial
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.purple[200],
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nombre del usuario
            Text(
              nombre,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Correo
            Text(
              correo,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 40),

            // Botón cerrar sesión
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/", (_) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Cerrar Sesión",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
