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
<<<<<<< HEAD
import 'fechas_destacadas_page.dart'; 
import 'recomendaciones_page.dart';
=======
import 'detalle_restaurante_page.dart';
import 'detalle_bares_page.dart';
>>>>>>> 012c0cdbb05fc2a00deb9ec622290cdfce7cba98


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

          "/detalleBar": (context) {
            final args = ModalRoute.of(context)!.settings.arguments;

            late Map<String, dynamic> bar;
            Map<String, dynamic>? usuario;

            if (args is Map<String, dynamic>) {
              bar = args;
            } else if (args is Map && args.containsKey("bar")) {
              bar = args["bar"];
              usuario = args["usuario"];
            } else {
              throw Exception("Argumentos inválidos para detalleBar");
            }

            return DetalleBarPage(
              bar: bar,
              usuario: usuario,
            );
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
        "/fechas": (context) {
          final usuario = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return FechasDestacadasPage(usuario: usuario);
        },
        "/recomendaciones": (context) {
          final usuario = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return RecomendacionesPage(usuario: usuario); 
        "/detalleRestaurante": (context) {
            final args = ModalRoute.of(context)!.settings.arguments;

            late Map<String, dynamic> restaurante;
            Map<String, dynamic>? usuario;

            if (args is Map<String, dynamic>) {
              restaurante = args;
            } else if (args is Map && args.containsKey("restaurante")) {
              restaurante = args["restaurante"];
              usuario = args["usuario"];
            } else {
              throw Exception("Argumentos inválidos para detalleRestaurante");
            }

            return DetalleRestaurantePage(
              restaurante: restaurante,
              usuario: usuario,
            );
          },
        

        }
        
      },
    );
  }
}
