import 'dart:convert';
import 'package:http/http.dart' as http;

import 'backend_api_service.dart';

// ======================================================
//   Helper para limpiar la respuesta de Gemini
//   (quita ```json ... ``` y basura antes/después del {} )
// ======================================================
String _limpiarJsonGemini(String raw) {
  var text = raw.trim();

  // Quitar fences tipo ```json ... ```
  if (text.startsWith('```')) {
    // elimina primera línea ``` o ```json
    final firstNewline = text.indexOf('\n');
    if (firstNewline != -1) {
      text = text.substring(firstNewline + 1).trim();
    }
    // elimina cierre ```
    final lastFence = text.lastIndexOf('```');
    if (lastFence != -1) {
      text = text.substring(0, lastFence).trim();
    }
  }

  // Por si aún hay cosas raras: recortar desde el primer '{' hasta el último '}'
  final firstBrace = text.indexOf('{');
  final lastBrace = text.lastIndexOf('}');
  if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
    text = text.substring(firstBrace, lastBrace + 1);
  }

  return text;
}

// ======================================================
//   Servicio de IA para generar itinerarios con Gemini
// ======================================================
class ItinerarioAIService {
  ItinerarioAIService._();
  static final ItinerarioAIService instance = ItinerarioAIService._();

  final BackendApiService _api = BackendApiService.instance;

  // Pon aquí tu API KEY de Gemini:
  static const String _geminiApiKey = 'AIzaSyDvHRwbJXQsiTLOlawNyA-5U8CC-6QsmeE';
  static const String _geminiModel = 'gemini-2.5-flash';

  // --------------------------------------------------
  // Construye un catálogo compacto basado en el backend API
  // --------------------------------------------------
  Future<Map<String, dynamic>> _construirContextoCatalogo(
    DateTime fechaInicio,
    int dias,
  ) async {
    final fechaFin = fechaInicio.add(Duration(days: dias - 1));

    // Obtener datos del backend en lugar de la BD local
    final lugares = await _api.obtenerLugares();
    final restaurantes = await _api.obtenerRestaurantes();
    final bares = await _api.obtenerBares();
    final fechasDestacadas = await _api.obtenerFechas();

    final hitosEnRango = <Map<String, dynamic>>[];
    final eventosPorHito = <int, List<Map<String, dynamic>>>{};

    for (final h in fechasDestacadas) {
      final inicio = DateTime.parse(h['fechaInicio'] as String);
      final fin = DateTime.parse(h['fechaFin'] as String);
      final permanente = (h['permanente'] ?? 0) == 1;

      final intersectaRango =
          !(fin.isBefore(fechaInicio) || inicio.isAfter(fechaFin));

      if (intersectaRango || permanente) {
        hitosEnRango.add(h);
        final int hitoId = h['id'] as int;
        eventosPorHito[hitoId] = await _api.obtenerEventosDeFecha(hitoId);
      }
    }

    return {
      'lugares': lugares
          .map(
            (l) => {
              'id': l['id'],
              'nombre': l['nombre'],
              'categoria': l['categoria'], // caro / economico
              'tipo': l['tipo'], // "lugar"
              'rating': l['rating'],
              'horario': l['horario'],
            },
          )
          .toList(),
      'restaurantes': restaurantes
          .map(
            (r) => {
              'id': r['id'],
              'nombre': r['nombre'],
              'precio': r['precio'], // alto / medio / bajo
              'rating': r['rating'],
              'horario': r['horario'],
            },
          )
          .toList(),
      'bares': bares
          .map(
            (b) => {
              'id': b['id'],
              'nombre': b['nombre'],
              'ambiente': b['ambiente'], // elegante, premium, popular...
              'rating': b['rating'],
              'horario': b['horario'],
            },
          )
          .toList(),
      'fechas_destacadas': hitosEnRango.map((h) {
        final int hitoId = h['id'] as int;
        final eventos = eventosPorHito[hitoId] ?? [];

        return {
          'id': hitoId,
          'titulo': h['titulo'],
          'categoria': h['categoria'],
          'fechaInicio': h['fechaInicio'],
          'fechaFin': h['fechaFin'],
          'permanente': h['permanente'],
          'eventos': eventos
              .map(
                (e) => {
                  'id': e['id'],
                  'titulo': e['titulo'],
                  'descripcion': e['descripcion'],
                  'ubicacion': e['ubicacion'],
                  'fechaHoraInicio': e['fechaHoraInicio'],
                },
              )
              .toList(),
        };
      }).toList(),
    };
  }

  // --------------------------------------------------
  // Llama a Gemini y devuelve JSON:
  // { "dias": [ { "nombre_dia": "...", "actividades": [...] } ] }
  // --------------------------------------------------
  Future<Map<String, dynamic>> generarItinerarioConIA({
    required DateTime fechaInicio,
    required int dias,
    required List<String> preferencias,
    Map<String, dynamic>? usuario,
  }) async {
    final catalogo = await _construirContextoCatalogo(fechaInicio, dias);

    final contexto = {
      'usuario': {
        'id': usuario?['id'],
        'nombre': usuario?['nombre'],
        'ambiente': usuario?['ambiente'],
        'lugaresPreferidos': usuario?['lugaresPreferidos'],
        'restaurantesPreferidos': usuario?['restaurantesPreferidos'],
      },
      'parametros_viaje': {
        'fecha_inicio': fechaInicio.toIso8601String(),
        'dias': dias,
        'preferencias': preferencias,
      },
      'catalogo': catalogo,
    };

    // Prompt para Gemini: TODO junto en un texto
    final prompt =
        '''
Eres un planificador turístico experto en Sucre, Bolivia.

REGLAS IMPORTANTES:
- SOLO puedes usar lugares, restaurantes, bares y eventos que estén dentro del "catalogo" que te envío en JSON.
- Debes adaptar el itinerario a las "preferencias" del usuario:

  * Si incluye "Histórico":
    - Prioriza lugares históricos (plazas, catedrales, museos, castillos, conventos, casas coloniales).
  * Si incluye "Cultural":
    - Prioriza museos, festivales, fechas_destacadas de categoría "Arte y Cultura" o similares.
  * Si incluye "Gastronomía":
    - Asegúrate de incluir restaurantes todos los días y, cuando sea posible,
      fechas_destacadas de categoría "Gastronomía y Ferias" (ferias, mercados, comida típica).
  * Si incluye "Naturaleza":
    - Prioriza parques, miradores, zonas verdes y excursiones (Parque Cretácico, miradores, río, etc.).

- Si el usuario tiene varias preferencias, mezcla tipos de actividades en el día (mañana/tarde/noche), manteniendo variedad.
- Respeta las fechas de las "fechas_destacadas" y sus "eventos_relacionados": solo sugiérelos si caen dentro del rango de viaje o si el hito es permanente.
- Intenta que el plan diario tenga sentido (mañana actividades ligeras, tarde recorridos, noche cena/bar).

El contexto es este (en formato JSON):
${jsonEncode(contexto)}

Debes devolver SOLO un JSON (sin explicaciones, sin comentarios, sin texto antes o después) con esta estructura EXACTA:

{
  "dias": [
    {
      "nombre_dia": "Día 1 (dd/mm)",
      "actividades": [
        {
          "hora_label": "Mañana (09:00)",
          "descripcion": "Texto descriptivo amigable para el usuario",
          "tipo": "lugar" | "restaurante" | "bar" | "evento",
          "referencia": {
            "tabla": "lugares" | "restaurantes" | "bares" | "fechas_destacadas" | "eventos_relacionados",
            "id": 0
          }
        }
      ]
    }
  ]
}

Reglas:
- Ajusta las actividades a la duración del viaje (parametros_viaje.dias).
- Aprovecha las fechas_destacadas y sus eventos_relacionados que caigan dentro del rango del viaje o que sean permanentes.
- Mezcla lugares turísticos, restaurantes y bares según las preferencias.
- NO incluyas nada que no sea JSON. NO uses ```json ni fences de código.
''';

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    };

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$_geminiModel:generateContent?key=$_geminiApiKey',
    );

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error IA: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);

    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('IA no devolvió candidates válidos');
    }

    final content = candidates[0]['content'];
    final parts = content['parts'] as List;
    if (parts.isEmpty || parts[0]['text'] == null) {
      throw Exception('IA no devolvió texto en parts');
    }

    final rawText = parts[0]['text'] as String;

    // Limpiamos fences ```json y demás antes de parsear
    final jsonPuro = _limpiarJsonGemini(rawText);

    return jsonDecode(jsonPuro) as Map<String, dynamic>;
  }
}
