import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'perfil_page.dart';
import 'lugares_page.dart';
import 'restaurantes_page.dart';
import 'favoritos_page.dart';
import 'bares_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tourist',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),

      // Pantalla inicial
      home: const HomePage(),

      // Rutas registradas
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/perfil": (context) {
            final nombre = ModalRoute.of(context)!.settings.arguments as String;
            return PerfilPage(nombre: nombre);
        },
        "/lugares": (context) => const LugaresPage(),
        "/restaurantes": (context) => const RestaurantesPage(),
        "/bares": (context) => const BaresPage(),
        "/favoritos": (context) => const FavoritosPage(),
      },
    );
  }
}
