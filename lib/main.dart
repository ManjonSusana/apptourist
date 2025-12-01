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
import 'pages/fechas_destacadas_page.dart';
import 'pages/detalle_fecha_page.dart';
import 'pages/recomendaciones_page.dart';
import 'detalle_restaurante_page.dart';
import 'detalle_bares_page.dart';

// Importamos los modelos HitoDestacado y EventoRelacionado desde la página principal.
// NOTA: ASUMIMOS QUE ESTE ES EL ARCHIVO FUENTE DE LOS MODELOS.
import 'package:apptourist/pages/fechas_destacadas_page.dart'; 
// Importamos la nueva página de detalle de evento
import 'pages/detalle_evento_page.dart'; 


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

      home: const HomePage(),

      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),

        "/perfil": (context) {
          final usuario =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PerfilPage(usuario: usuario);
        },

        "/lugares": (context) {
          final usuario =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return LugaresPage(usuario: usuario);
        },

        "/restaurantes": (context) {
          final usuario =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return RestaurantesPage(usuario: usuario);
        },

        "/bares": (context) {
          final usuario =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return BaresPage(usuario: usuario);
        },

        "/detalleRestaurante": (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          late Map<String, dynamic> restaurante;
          Map<String, dynamic>? usuario;

          if (args is Map && args.containsKey("restaurante")) {
            restaurante = args["restaurante"] as Map<String, dynamic>;
            usuario = args["usuario"] as Map<String, dynamic>?;
          }
          // Caso alternativo (muy raro)
          else if (args is Map<String, dynamic>) {
            restaurante = args;
          } else {
            throw Exception("Argumentos inválidos para detalleRestaurante");
          }

          return DetalleRestaurantePage(
            restaurante: restaurante,
            usuario: usuario,
          );
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

        "/detalleLugar": (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          late Map<String, dynamic> lugar;
          Map<String, dynamic>? usuario;

          if (args is Map && args.containsKey("lugar")) {
            lugar = args["lugar"] as Map<String, dynamic>;
            usuario = args["usuario"] as Map<String, dynamic>?;
          }
          // Caso alternativo (compatibilidad hacia atrás)
          else if (args is Map<String, dynamic>) {
            lugar = args;
          } else {
            throw Exception("Argumentos inválidos para detalleLugar");
          }

          return DetalleLugarPage(
            lugar: lugar,
            usuario: usuario,
          );
        },

        "/favoritos": (context) {
          final usuario =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return FavoritosPage(usuario: usuario);
        },

        "/fullImage": (context) {
          final img =
              ModalRoute.of(context)!.settings.arguments as String;
          return FullImagePage(image: img);
        },

        "/fechas": (context) {
          final usuario =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return FechasDestacadasPage(usuario: usuario);
        },

        "/recomendaciones": (context) {
          final usuario =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return RecomendacionesPage(usuario: usuario);
          },
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
        
        // ------------- RUTA DE DETALLE DE HITO (AGENDA) -------------
        "/detalleFecha": (context) {
          // CORRECCIÓN DE TIPO: Casqueo a HitoDestacado
          final hito = ModalRoute.of(context)!.settings.arguments as HitoDestacado;
          return DetalleFechaPage(evento: hito);
        },

        // ------------- NUEVA RUTA DE DETALLE DE EVENTO ESPECÍFICO -------------
        "/detalleEvento": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          
          final evento = args['evento'] as EventoRelacionado;
          final hitoPadre = args['hitoPadre'] as HitoDestacado;

          return DetalleEventoPage(
            evento: evento,
            hitoPadre: hitoPadre,
          );
        },

      },
    );
  }
}