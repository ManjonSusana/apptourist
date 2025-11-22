import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                const SizedBox(height: 20),

                // TÍTULO
                Text(
                  "REGISTRO",
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                // --- Nombre usuario ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "NOMBRE USUARIO",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                TextField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Ingresa tu nombre",
                  ),
                ),

                const SizedBox(height: 30),

                // --- Correo electrónico ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "CORREO ELECTRONICO",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "ejemplo@correo.com",
                  ),
                ),

                const SizedBox(height: 30),

                // --- Contraseña ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "CONTRASEÑA",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Crea una contraseña",
                  ),
                ),

                const SizedBox(height: 30),

                // --- Confirmar contraseña ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "CONFIRMAR CONTRASEÑA",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Repite la contraseña",
                  ),
                ),

                const SizedBox(height: 40),

                // BOTÓN REGISTRARSE
                SizedBox(
                  width: 200,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "REGISTRARSE",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
