import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApiService {
  BackendApiService._();
  static final instance = BackendApiService._();

  // ⛔ Cambia esta IP por la de tu PC
  // Ejemplo: 'http://192.168.0.26:8000/api';
  static const String _baseUrl = 'http://192.168.0.26:8000/api';

  Future<List<Map<String, dynamic>>> obtenerLugares() async {
    final uri = Uri.parse('$_baseUrl/lugares');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          'Error al obtener lugares: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data
          .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      throw Exception('Respuesta de lugares no es una lista');
    }
  }

  Future<Map<String, dynamic>> obtenerLugarPorId(int id) async {
    final uri = Uri.parse('$_baseUrl/lugares/$id');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          'Error al obtener lugar $id: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    return Map<String, dynamic>.from(data as Map);
  }

  // Luego podrás añadir:
  // - obtenerRestaurantes()
  // - obtenerBares()
  // - obtenerFechas()
  // - obtenerEventosDeHito(int hitoId)
    // ================== RESTAURANTES ==================
  Future<List<Map<String, dynamic>>> obtenerRestaurantes() async {
    final uri = Uri.parse('$_baseUrl/restaurantes');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener restaurantes: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data
          .map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e as Map),
          )
          .toList();
    } else {
      throw Exception('Respuesta de restaurantes no es una lista');
    }
  }

  Future<Map<String, dynamic>> obtenerRestaurantePorId(int id) async {
    final uri = Uri.parse('$_baseUrl/restaurantes/$id');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener restaurante $id: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);
    return Map<String, dynamic>.from(data as Map);
  }

  // ================== BARES ==================
  Future<List<Map<String, dynamic>>> obtenerBares() async {
    final uri = Uri.parse('$_baseUrl/bares');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener bares: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data
          .map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e as Map),
          )
          .toList();
    } else {
      throw Exception('Respuesta de bares no es una lista');
    }
  }

  Future<Map<String, dynamic>> obtenerBarPorId(int id) async {
    final uri = Uri.parse('$_baseUrl/bares/$id');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener bar $id: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);
    return Map<String, dynamic>.from(data as Map);
  }

  // ================== FECHAS DESTACADAS ==================
Future<List<Map<String, dynamic>>> obtenerFechas() async {
  final uri = Uri.parse('$_baseUrl/fechas');

  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('Error al obtener fechas: ${resp.statusCode}');
  }

  final data = jsonDecode(resp.body);
  return (data as List)
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

Future<Map<String, dynamic>> obtenerFechaPorId(int id) async {
  final uri = Uri.parse('$_baseUrl/fechas/$id');

  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('Error al obtener fecha $id');
  }

  return Map<String, dynamic>.from(jsonDecode(resp.body));
}

// ================== EVENTOS RELACIONADOS ==================
Future<List<Map<String, dynamic>>> obtenerEventosDeFecha(int fechaId) async {
  final uri = Uri.parse('$_baseUrl/fechas/$fechaId/eventos');

  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('Error al obtener eventos de fecha $fechaId');
  }

  final data = jsonDecode(resp.body);
  return (data as List)
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}


}
