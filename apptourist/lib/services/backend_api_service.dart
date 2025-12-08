import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendApiService {
  BackendApiService._();
  static final instance = BackendApiService._();

  // ⛔ Cambia esta IP por la de tu PC
  // Ejemplo: 'http://192.168.0.26:8000/api';
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // Token JWT almacenado en memoria
  String? _jwtToken;

  // Clave para SharedPreferences
  static const String _tokenKey = 'jwt_token';

  Future<List<Map<String, dynamic>>> obtenerLugares() async {
    final uri = Uri.parse('$_baseUrl/lugares');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener lugares: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      throw Exception('Respuesta de lugares no es una lista');
    }
  }

  /// Crea un nuevo usuario en el backend
  Future<Map<String, dynamic>> crearUsuario({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/users');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': nombre, 'email': correo, 'password': password}),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Error al crear usuario: \\${resp.statusCode} \\${resp.body}',
      );
    }
    final data = jsonDecode(resp.body);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> obtenerLugarPorId(int id) async {
    final uri = Uri.parse('$_baseUrl/lugares/$id');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener lugar $id: ${resp.statusCode} ${resp.body}',
      );
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
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
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
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
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
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
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

    // El endpoint devuelve {"data": [...], "fecha_id": ..., "count": ...}
    // Extraer la lista de eventos del campo 'data'
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else if (data is List) {
      // Si devuelve directamente una lista
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      return [];
    }
  }

  // ================== AUTENTICACIÓN ==================

  /// Realiza login y guarda el token JWT
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/login');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al hacer login: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body);

    // Guardar el token en memoria y en SharedPreferences
    // El backend devuelve 'access_token', no 'token'
    if (data['access_token'] != null) {
      _jwtToken = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _jwtToken!);
    }

    return Map<String, dynamic>.from(data);
  }

  /// Recupera el token JWT guardado
  Future<void> cargarToken() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString(_tokenKey);
  }

  /// Elimina el token JWT (logout)
  Future<void> logout() async {
    _jwtToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Obtiene el token actual
  String? get token => _jwtToken;

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => _jwtToken != null;

  // ================== FAVORITOS ==================

  /// Toggle favorito (agregar o eliminar)
  /// favoritable_type puede ser: 'lugar', 'bar', 'restaurante'
  /// favoritable_id es el ID del elemento
  Future<Map<String, dynamic>> toggleFavorito({
    required String favoritableType,
    required int favoritableId,
  }) async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/favoritos');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode({
        'favoritable_type': favoritableType,
        'favoritable_id': favoritableId,
      }),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Error al toggle favorito: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);
    return Map<String, dynamic>.from(data);
  }

  /// Obtiene la lista de favoritos del usuario autenticado
  Future<List<Map<String, dynamic>>> obtenerFavoritos() async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/favoritos');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_jwtToken'},
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener favoritos: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      throw Exception('Respuesta de favoritos no es una lista');
    }
  }

  /// Obtiene los favoritos de una categoría específica (Bar, Restaurante, Lugar)
  /// ejemplo: obtenerFavoritosPorTipo('Bar')
  Future<List<Map<String, dynamic>>> obtenerFavoritosPorTipo(
    String tipo,
  ) async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/favoritos/tipo/$tipo');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_jwtToken'},
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener favoritos de tipo $tipo: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    // El endpoint devuelve {"tipo": "...", "data": [...], "count": ...}
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      return [];
    }
  }

  /// Guarda un itinerario en la BD
  /// Primero paso: guardar en tabla itinerarios con user_id e itinerario_data
  Future<Map<String, dynamic>> guardarItinerario({
    required Map<String, dynamic> itinerarioData,
  }) async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/itinerarios');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode({'itinerario_data': itinerarioData}),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Error al guardar itinerario: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    // El backend devuelve: {"message": "...", "data": {...}}
    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Respuesta de guardar itinerario inválida');
  }

  /// Agrega un itinerario guardado a favoritos
  /// Segundo paso: agregar el itinerario guardado a favoritos
  /// Usa el endpoint /api/favoritos con favoritable_type y favoritable_id
  Future<Map<String, dynamic>> agregarItinerarioAFavoritos({
    required int itinerarioId,
  }) async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    // Usar el endpoint /api/favoritos con el tipo Itinerario
    final uri = Uri.parse('$_baseUrl/favoritos');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode({
        'favoritable_type': 'App\\Models\\Itinerario',
        'favoritable_id': itinerarioId,
      }),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Error al agregar a favoritos: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    // El backend devuelve: {"message": "...", "data": {...}} o directamente {...}
    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {};
  }

  /// Guarda un itinerario como favorito (método antiguo para compatibilidad)
  @deprecated
  Future<Map<String, dynamic>> guardarItinerarioFavorito({
    required String nombre,
    required String descripcion,
    required Map<String, dynamic> itinerario,
  }) async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/itinerarios/favoritos/');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'itinerario': itinerario,
      }),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Error al guardar itinerario: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);
    return Map<String, dynamic>.from(data);
  }

  /// Obtiene los itinerarios favoritos del usuario
  Future<List<Map<String, dynamic>>> obtenerItinerariosFavoritos() async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/favoritos/favoritos');

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_jwtToken'},
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener itinerarios favoritos: ${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      return [];
    }
  }

  /// Elimina un itinerario favorito
  Future<void> eliminarItinerarioFavorito(int id) async {
    if (_jwtToken == null) {
      throw Exception('No hay token JWT. Debes iniciar sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/itinerarios/favoritos/$id');

    final resp = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $_jwtToken'},
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
        'Error al eliminar itinerario: ${resp.statusCode} ${resp.body}',
      );
    }
  }
}
