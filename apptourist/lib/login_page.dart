import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'services/backend_api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool cargando = false;

  Future<void> login() async {
    final correo = correoCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (correo.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      // Llamar al endpoint de login del backend
      final response = await BackendApiService.instance.login(correo, pass);

      // El backend devuelve el usuario en 'user'
      final usuarioBackend = response['user'];

      if (usuarioBackend == null) {
        throw Exception('No se recibió información del usuario');
      }

      // Convertir el usuario del backend al formato esperado por la app
      // El backend usa 'name', pero la app puede esperar 'nombre'
      final usuario = <String, dynamic>{
        'id': usuarioBackend['id'],
        'nombre': usuarioBackend['name'] ?? usuarioBackend['nombre'] ?? '',
        'email': usuarioBackend['email'] ?? '',
      };

      // Agregar otros campos del usuario si existen
      if (usuarioBackend is Map) {
        usuarioBackend.forEach((key, value) {
          if (!usuario.containsKey(key)) {
            usuario[key.toString()] = value;
          }
        });
      }

      // Navegar a la página principal con el usuario
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(usuario: usuario)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de login: ${e.toString()}")),
      );
      setState(() => cargando = false);
    }
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
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Iniciar Sesión",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              campo("Correo", correoCtrl),
              const SizedBox(height: 25),

              campo("Contraseña", passCtrl, oculto: true),
              const SizedBox(height: 35),

              cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(200, 45),
                      ),
                      child: Text(
                        "Iniciar Sesión",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/register"),
                child: Text(
                  "¿No tienes cuenta? Regístrate",
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
