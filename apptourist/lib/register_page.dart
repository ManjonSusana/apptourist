import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'services/backend_api_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool cargando = false;

  Future<void> registrar() async {
    final nombre = nombreCtrl.text.trim();
    final correo = correoCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (nombre.isEmpty || correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      // Crear usuario
      final data = await BackendApiService.instance.crearUsuario(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      // Login automático para obtener JWT
      final loginData = await BackendApiService.instance.login(
        correo,
        password,
      );

      final usuarioCompleto = {
        "id": data["id"],
        "nombre": data["name"],
        "correo": data["email"],
        "token": loginData["access_token"],
      };
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado correctamente")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(usuario: usuarioCompleto)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: \\${e.toString()}")));
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Registro",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              campo("Nombre Completo", nombreCtrl),
              const SizedBox(height: 25),

              campo("Correo", correoCtrl),
              const SizedBox(height: 25),

              campo("Contraseña", passCtrl, oculto: true),
              const SizedBox(height: 35),

              cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(200, 45),
                      ),
                      child: Text(
                        "Registrarse",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "¿Ya tienes cuenta? Inicia sesión",
                  style: GoogleFonts.poppins(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campo(
    String titulo,
    TextEditingController ctrl, {
    bool oculto = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        TextField(
          controller: ctrl,
          obscureText: oculto,
          decoration: const InputDecoration(border: UnderlineInputBorder()),
        ),
      ],
    );
  }
}
