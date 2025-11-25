import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'perfil_page.dart';
import 'lugares_page.dart';
import 'restaurantes_page.dart';
import 'favoritos_page.dart';
import 'bares_page.dart';
import 'detalle_lugar_page.dart';
import 'full_image_page.dart';


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

      // ============ PANTALLA INICIAL ============
      home: const HomePage(),

      // ============ RUTAS ============
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),

        // ---------- PERFIL ----------
        "/perfil": (context) {
          final usuario = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return PerfilPage(usuario: usuario);
        },

        // ---------- LUGARES ----------
        "/lugares": (context) {
          final usuario = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return LugaresPage(usuario: usuario);
        },

        // ---------- RESTAURANTES ----------
        "/restaurantes": (context) {
          final usuario = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return RestaurantesPage(usuario: usuario);
        },

        // ---------- BARES ----------
        "/bares": (context) {
          final usuario = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return BaresPage(usuario: usuario);
        },

        // ---------- FAVORITOS ----------
        "/favoritos": (context) {
          final usuario = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return FavoritosPage(usuario: usuario);
        },
        "/detalleLugar": (context) {
          final lugar = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DetalleLugarPage(lugar: lugar);
        },
        "/fullImage": (context) {
          final String img = ModalRoute.of(context)!.settings.arguments as String;
          return FullImagePage(image: img);
        },


      },
    );
  }
}
