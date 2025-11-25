import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'db_service.dart';

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

    final usuario = await DBService.instance.loginUsuario(correo, pass);

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo o contraseña incorrectos")),
      );
      setState(() => cargando = false);
      return;
    }

    // PASAMOS EL USUARIO COMPLETO
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(usuario: usuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Iniciar Sesión",
                style: GoogleFonts.poppins(
                    fontSize: 32, fontWeight: FontWeight.bold),
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
                            fontSize: 16, fontWeight: FontWeight.bold),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget campo(String titulo, TextEditingController ctrl,
      {bool oculto = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        TextField(
          controller: ctrl,
          obscureText: oculto,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
          ),
        )
      ],
    );
  }
}
