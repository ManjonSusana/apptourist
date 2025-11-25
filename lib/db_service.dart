import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DBService {
  DBService._privateConstructor();
  static final DBService instance = DBService._privateConstructor();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, "turismo_app.db");

    return await openDatabase(
      path,
      version: 12,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ====================================================
  //                 CREACIÓN DE TABLAS
  // ====================================================
  Future _onCreate(Database db, int version) async {
    // ---------------- TABLA USUARIOS ----------------
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    // ---------------- TABLA LUGARES ----------------
    await db.execute('''
      CREATE TABLE lugares(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        direccion TEXT,
        categoria TEXT,
        tipo TEXT,
        imagenAsset TEXT,
        rating REAL DEFAULT 3.5,
        imagenes TEXT,
        horario TEXT
      );
    ''');

    // ---------------- TABLA RESTAURANTES ----------------
    await db.execute('''
      CREATE TABLE restaurantes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        direccion TEXT,
        precio TEXT,
        imagenAsset TEXT
      );
    ''');

    // ---------------- TABLA BARES ----------------
    await db.execute('''
      CREATE TABLE bares(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        direccion TEXT,
        ambiente TEXT,
        imagenAsset TEXT
      );
    ''');

    // ---------------- TABLA FAVORITOS ----------------
    await db.execute('''
      CREATE TABLE favoritos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        lugarId INTEGER NOT NULL
      );
    ''');

    // Insertar datos iniciales
    await _insertarDatosIniciales(db);
  }

  // ====================================================
  //                   ACTUALIZACIÓN
  // ====================================================
  Future _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 3) {
      // recrear tabla de lugares si falta alguna columna
      await db.execute("DROP TABLE IF EXISTS lugares");

      await db.execute('''
        CREATE TABLE lugares(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          descripcion TEXT,
          direccion TEXT,
          categoria TEXT,
          tipo TEXT,
          imagenAsset TEXT,
          rating REAL DEFAULT 3.5,
          imagenes TEXT,
          horario TEXT
        );
      ''');

      await _insertarDatosIniciales(db);
    }
  }

  // ====================================================
  //               DATOS INICIALES
  // ====================================================
  Future _insertarDatosIniciales(Database db) async {
    // ==================== LUGARES ====================
    // --------- LUGARES CAROS ---------
    await db.insert("lugares", {
      "nombre": "Castillo de la Glorieta",
      "descripcion": "Antiguo castillo con arquitectura europea.",
      "direccion": "Camino a Yotala",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/glorieta.jpg",
      "rating": 4.5,
      "imagenes": jsonEncode([
        "assets/lugares/glorieta1.jpg",
        "assets/lugares/glorieta2.jpg"
      ]),
      "horario": "08:00 - 18:00"
    });

    await db.insert("lugares", {
      "nombre": "Mirador de Recoleta",
      "descripcion": "Vista panorámica de la ciudad, tradicional y turístico.",
      "direccion": "Recoleta",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/recoleta.jpg",
      "rating": 4.7,
      "imagenes": jsonEncode([
        "assets/lugares/recoleta1.jpg",
        "assets/lugares/recoleta2.jpg"
      ]),
      "horario": "07:00 - 22:00"
    });

    await db.insert("lugares", {
      "nombre": "Museo Arte Indígena ASUR",
      "descripcion": "Museo especializado en textiles de culturas andinas.",
      "direccion": "Calle Iturricha",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/asur.jpg",
      "rating": 4.8,
      "imagenes": jsonEncode([
        "assets/lugares/asur1.jpg",
        "assets/lugares/asur2.jpg"
      ]),
      "horario": "09:00 - 18:00"
    });

    // --------- LUGARES ECONÓMICOS ---------
    await db.insert("lugares", {
      "nombre": "Yotala",
      "descripcion": "Municipio turístico conocido por su arquitectura colonial, naturaleza y gastronomía típica.",
      "direccion": "Yotala – Sucre",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/yotala.jpg",
      "rating": 4.5,
      "imagenes": jsonEncode([
        "assets/lugares/yotala1.jpg",
        "assets/lugares/yotala2.jpg"
      ]),
      "horario": "Todo el día"
    });


    await db.insert("lugares", {
  "nombre": "La Glorieta",
  "descripcion": "Lugar turístico histórico",
  "direccion": "Carretera a Yotala",
  "categoria": "caro",
  "tipo": "lugar",
  "imagenAsset": "assets/lugares/glorieta.jpg",
  "rating": 4.2,
  "imagenes": jsonEncode([
    "assets/lugares/glorieta1.jpg",
    "assets/lugares/glorieta2.jpg",
    "assets/lugares/glorieta3.jpg",
    "assets/lugares/glorieta4.jpg"
  ]),
  "horario": "08:00 - 18:00",
  "latitud": -19.0790,
  "longitud": -65.2625,
});



    await db.insert("lugares", {
      "nombre": "La Rotonda",
      "descripcion": "Plaza tranquila ideal para descansar.",
      "direccion": "Av. Venezuela",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/rotonda.jpg",
      "rating": 4.1,
      "imagenes": jsonEncode([
        "assets/lugares/rotonda1.jpg",
        "assets/lugares/rotonda2.jpg"
      ]),
      "horario": "24 horas"
    });



    // ==================== RESTAURANTES ====================
    await db.insert("restaurantes", {
      "nombre": "La Posada del Sol",
      "descripcion": "Comida tradicional y gourmet.",
      "direccion": "Calle España 123",
      "precio": "alto",
      "imagenAsset": "assets/restaurantes/posada.jpg",
    });

    await db.insert("restaurantes", {
      "nombre": "El Patio",
      "descripcion": "Restaurante familiar con menú variado.",
      "direccion": "Av. Las Américas",
      "precio": "medio",
      "imagenAsset": "assets/restaurantes/patio.jpg",
    });

    // ==================== BARES ====================
    await db.insert("bares", {
      "nombre": "Bar Central",
      "descripcion": "Ambiente juvenil y moderno.",
      "direccion": "Calle Bolívar",
      "ambiente": "moderno",
      "imagenAsset": "assets/bares/bar_central.jpg",
    });

    await db.insert("bares", {
      "nombre": "La Esquina Bar",
      "descripcion": "Buena música y cócteles.",
      "direccion": "Calle Aniceto Arce",
      "ambiente": "relajado",
      "imagenAsset": "assets/bares/esquina.jpg",
    });
  }

  // ====================================================
  //                     USUARIOS
  // ====================================================
  Future<int> registrarUsuario(String nombre, String correo, String password) async {
    final database = await db;
    return await database.insert(
      "usuarios",
      {
        "nombre": nombre,
        "correo": correo,
        "password": password,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, dynamic>?> loginUsuario(String correo, String password) async {
    final database = await db;
    final res = await database.query(
      "usuarios",
      where: "correo = ? AND password = ?",
      whereArgs: [correo, password],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ====================================================
  //                     LUGARES
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerLugaresPorCategoria(String categoria) async {
    final database = await db;
    return await database.query(
      "lugares",
      where: "categoria = ?",
      whereArgs: [categoria],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerLugares() async {
    final database = await db;
    return await database.query("lugares");
  }

  // ====================================================
  //                   RESTAURANTES
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerRestaurantes() async {
    final database = await db;
    return await database.query("restaurantes");
  }

  // ====================================================
  //                        BARES
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerBares() async {
    final database = await db;
    return await database.query("bares");
  }

  // ====================================================
  //                     FAVORITOS
  // ====================================================
  Future<void> toggleFavorito(int usuarioId, int lugarId) async {
    final database = await db;
    final existe = await database.query(
      "favoritos",
      where: "usuarioId = ? AND lugarId = ?",
      whereArgs: [usuarioId, lugarId],
    );

    if (existe.isNotEmpty) {
      await database.delete(
        "favoritos",
        where: "usuarioId = ? AND lugarId = ?",
        whereArgs: [usuarioId, lugarId],
      );
    } else {
      await database.insert("favoritos", {
        "usuarioId": usuarioId,
        "lugarId": lugarId,
      });
    }
  }

  Future<List<int>> obtenerFavoritosIds(int usuarioId) async {
    final database = await db;
    final res = await database.query(
      "favoritos",
      where: "usuarioId = ?",
      whereArgs: [usuarioId],
    );
    return res.map((e) => e["lugarId"] as int).toList();
  }
}
