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

    // Incrementamos la versión para forzar la ejecución de _onUpgrade y _onCreate
    return await openDatabase(
      path,
      version: 53, // <<<<< NUEVA VERSION
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ====================================================
  //              CREACIÓN DE TABLAS
  // ====================================================
  Future _onCreate(Database db, int version) async {
    // Tabla usuarios
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        fotoPerfil TEXT,
        telefono TEXT,
        fechaNacimiento TEXT,
        bio TEXT,
        lugaresPreferidos TEXT,
        restaurantesPreferidos TEXT,
        ambiente TEXT
      );
    ''');

    // Tabla lugares
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
        horario TEXT,
        latitud REAL,
        longitud REAL
      );
    ''');

    // Tabla restaurantes
    await db.execute('''
      CREATE TABLE restaurantes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        direccion TEXT,
        precio TEXT,
        imagenAsset TEXT,
        rating REAL DEFAULT 3.5,
        imagenes TEXT,          -- JSON con 4 imágenes
        horario TEXT,
        latitud REAL,
        longitud REAL
      );

    ''');

    // Tabla bares
    await db.execute('''
      CREATE TABLE bares(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        direccion TEXT,
        ambiente TEXT,
        imagenAsset TEXT,
        rating REAL DEFAULT 3.5,
        imagenes TEXT,
        horario TEXT,
        latitud REAL,
        longitud REAL
      );
    ''');

    // Tabla favoritos
    await db.execute('''
      CREATE TABLE favoritos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        lugarId INTEGER NOT NULL,
        tipo TEXT DEFAULT 'lugar'
      );
    ''');

    // Tabla comentarios
    await db.execute('''
      CREATE TABLE comentarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lugarId INTEGER,
        restauranteId INTEGER,
        usuarioId INTEGER,
        texto TEXT NOT NULL,
        fecha TEXT
      );
    ''');

    // Tabla fechas destacadas (Hitos/Temas)
    await db.execute('''
      CREATE TABLE fechas_destacadas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        icono TEXT,
        categoria TEXT,
        fechaInicio TEXT,   -- guardaremos fecha como ISO8601 (String)
        fechaFin TEXT,      -- opcional, puede ser null
        permanente INTEGER DEFAULT 0,  -- 0 = no, 1 = sí
        imagenAsset TEXT
      );
    ''');
    
    // ===================================================
    // NUEVA TABLA: Eventos Relacionados (Actividades)
    // ===================================================
    await db.execute('''
      CREATE TABLE eventos_relacionados(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hitoId INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        ubicacion TEXT,
        fechaHoraInicio TEXT, -- fecha y hora de la actividad
        FOREIGN KEY (hitoId) REFERENCES fechas_destacadas(id)
      );
    ''');


    await _insertarDatosIniciales(db);


  }

  // ====================================================
  //                    UPGRADE
  // ====================================================
  Future _onUpgrade(Database db, int oldV, int newV) async {
    // Migración inteligente: solo agregar columnas faltantes sin borrar datos
    
    // Si venimos de versión anterior a 42, agregar columna 'tipo' a favoritos
    if (oldV < 42) {
      try {
        await db.execute("ALTER TABLE favoritos ADD COLUMN tipo TEXT DEFAULT 'lugar'");
      } catch (e) {
        // La columna ya existe, ignorar
        print("Columna 'tipo' ya existe o error al agregar: $e");
      }
    }
    
    // Si venimos de versión anterior a 45, agregar campos de perfil a usuarios
    if (oldV < 45) {
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN fotoPerfil TEXT");
      } catch (e) {
        // Columna ya existe
      }
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN telefono TEXT");
      } catch (e) {
        // Columna ya existe
      }
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN bio TEXT");
      } catch (e) {
        // Columna ya existe
      }
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN lugaresPreferidos TEXT");
      } catch (e) {
        // Columna ya existe
      }
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN restaurantesPreferidos TEXT");
      } catch (e) {
        // Columna ya existe
      }
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN ambiente TEXT");
      } catch (e) {
        // Columna ya existe
      }
    }
    
    // Insertar datos iniciales solo si las tablas están vacías
    final lugaresCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM lugares'));
    if (lugaresCount == 0) {
      await _insertarDatosIniciales(db);
    }
    // Aseguramos que se dropea la nueva tabla si existe
    await db.execute("DROP TABLE IF EXISTS eventos_relacionados"); 
    await db.execute("DROP TABLE IF EXISTS comentarios");
    await db.execute("DROP TABLE IF EXISTS favoritos");
    await db.execute("DROP TABLE IF EXISTS bares");
    await db.execute("DROP TABLE IF EXISTS restaurantes");
    await db.execute("DROP TABLE IF EXISTS lugares");
    await db.execute("DROP TABLE IF EXISTS usuarios");
    await db.execute("DROP TABLE IF EXISTS fechas_destacadas");

    await _onCreate(db, newV);
  }

  // ====================================================
  //               DATOS INICIALES
  // ====================================================
  Future _insertarDatosIniciales(Database db) async {
    // ==================== USUARIOS (Ejemplo) ====================
    await db.insert("usuarios", {
      "nombre": "Admin User",
      "correo": "admin@app.com",
      "password": "password",
    });

    // ==================== LUGARES CAROS ====================
    await db.insert("lugares", {
      "nombre": "Castillo de la Glorieta",
      "descripcion": "Antiguo castillo con arquitectura europea y toques románticos, uno de los íconos turísticos de Sucre.",
      "direccion": "Carretera a Yotala",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/glorieta.jpg",
      "rating": 4.5,
      "imagenes": jsonEncode([
        "assets/lugares/glorieta1.jpg",
        "assets/lugares/glorieta2.jpg",
        "assets/lugares/glorieta3.jpg",
        "assets/lugares/glorieta4.jpg",
      ]),
      "horario": "08:00 - 18:00",
      "latitud": -19.0790,
      "longitud": -65.2625,
    });

    await db.insert("lugares", {
      "nombre": "Mirador de la Recoleta",
      "descripcion": "Mirador tradicional con vista panorámica de toda la ciudad de Sucre.",
      "direccion": "Barrio Recoleta",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/recoleta.jpg",
      "rating": 4.7,
      "imagenes": jsonEncode([
        "assets/lugares/recoleta1.jpg",
        "assets/lugares/recoleta2.jpg",
        "assets/lugares/recoleta3.jpg",
        "assets/lugares/recoleta4.jpg",
      ]),
      "horario": "07:00 - 22:00",
      "latitud": -19.0502,
      "longitud": -65.2590,
    });

    await db.insert("lugares", {
      "nombre": "Museo de Arte Indígena ASUR",
      "descripcion": "Museo especializado en textiles y arte indígena de las culturas andinas.",
      "direccion": "Calle Iturricha",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/asur.jpg",
      "rating": 4.8,
      "imagenes": jsonEncode([
        "assets/lugares/asur1.jpg",
        "assets/lugares/asur2.jpg",
        "assets/lugares/asur3.jpg",
        "assets/lugares/asur4.jpg",
      ]),
      "horario": "09:00 - 18:00",
      "latitud": -19.0470,
      "longitud": -65.2540,
    });

    await db.insert("lugares", {
      "nombre": "Casa de la Libertad",
      "descripcion": "Lugar histórico donde se firmó el Acta de la Independencia de Bolivia.",
      "direccion": "Plaza 25 de Mayo",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/casa_libertad.jpg",
      "rating": 4.9,
      "imagenes": jsonEncode([
        "assets/lugares/casa_libertad1.jpg",
        "assets/lugares/casa_libertad2.jpg",
        "assets/lugares/casa_libertad3.jpg",
        "assets/lugares/casa_libertad4.jpg",
      ]),
      "horario": "09:00 - 19:00",
      "latitud": -19.0476,
      "longitud": -65.2601,
    });

    await db.insert("lugares", {
      "nombre": "Catedral Metropolitana",
      "descripcion": "Imponente catedral colonial ubicada frente a la plaza principal.",
      "direccion": "Plaza 25 de Mayo",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/catedral.jpg",
      "rating": 4.6,
      "imagenes": jsonEncode([
        "assets/lugares/catedral1.jpg",
        "assets/lugares/catedral2.jpg",
        "assets/lugares/catedral3.jpg",
        "assets/lugares/catedral4.jpg",
      ]),
      "horario": "07:00 - 20:00",
      "latitud": -19.0474,
      "longitud": -65.2597,
    });

    await db.insert("lugares", {
      "nombre": "Museo del Tesoro",
      "descripcion": "Museo sobre la historia minera y joyas de Bolivia.",
      "direccion": "Calle Nicolás Ortiz",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/tesoro.jpg",
      "rating": 4.5,
      "imagenes": jsonEncode([
        "assets/lugares/tesoro1.jpg",
        "assets/lugares/tesoro2.jpg",
        "assets/lugares/tesoro3.jpg",
        "assets/lugares/tesoro4.jpg",
      ]),
      "horario": "09:30 - 18:30",
      "latitud": -19.0481,
      "longitud": -65.2608,
    });

    await db.insert("lugares", {
      "nombre": "Convento San Felipe Neri",
      "descripcion": "Convento colonial con acceso a las azoteas y vistas únicas.",
      "direccion": "Calle Nicolás Ortiz",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/san_felipe.jpeg",
      "rating": 4.6,
      "imagenes": jsonEncode([
        "assets/lugares/san_felipe1.jpeg",
        "assets/lugares/san_felipe2.jpeg",
        "assets/lugares/san_felipe3.jpeg",
        "assets/lugares/san_felipe4.jpeg",
      ]),
      "horario": "09:00 - 18:00",
      "latitud": -19.0485,
      "longitud": -65.2622,
    });

    await db.insert("lugares", {
      "nombre": "Museo Etnográfico",
      "descripcion": "Muestra de culturas, trajes y tradiciones de Bolivia.",
      "direccion": "Zona Central",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/etnografico.jpeg",
      "rating": 4.4,
      "imagenes": jsonEncode([
        "assets/lugares/etnografico1.jpeg",
        "assets/lugares/etnografico2.jpeg",
        "assets/lugares/etnografico3.jpeg",
        "assets/lugares/etnografico4.jpeg",
      ]),
      "horario": "09:00 - 17:00",
      "latitud": -19.0460,
      "longitud": -65.2580,
    });

    await db.insert("lugares", {
      "nombre": "Museo Militar",
      "descripcion": "Museo dedicado a la historia militar boliviana.",
      "direccion": "Zona Central",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/museo_militar.jpeg",
      "rating": 4.1,
      "imagenes": jsonEncode([
        "assets/lugares/museo_militar1.jpeg",
        "assets/lugares/museo_militar2.jpeg",
        "assets/lugares/museo_militar3.jpeg",
        "assets/lugares/museo_militar4.jpeg",
      ]),
      "horario": "09:00 - 17:00",
      "latitud": -19.0520,
      "longitud": -65.2610,
    });

    await db.insert("lugares", {
      "nombre": "Mirador San Miguel",
      "descripcion": "Mirador menos concurrido con hermosas vistas de la ciudad.",
      "direccion": "Barrio San Miguel",
      "categoria": "caro",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/san_miguel.jpeg",
      "rating": 4.3,
      "imagenes": jsonEncode([
        "assets/lugares/san_miguel1.jpeg",
        "assets/lugares/san_miguel2.jpeg",
        "assets/lugares/san_miguel3.jpeg",
        "assets/lugares/san_miguel4.jpeg",
      ]),
      "horario": "08:00 - 21:00",
      "latitud": -19.0550,
      "longitud": -65.2650,
    });

    // ==================== LUGARES ECONÓMICOS ====================
    await db.insert("lugares", {
      "nombre": "Parque Bolívar",
      "descripcion": "Parque emblemático ideal para paseos, deporte y descanso.",
      "direccion": "Zona Central",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/bolivar.jpg",
      "rating": 4.2,
      "imagenes": jsonEncode([
        "assets/lugares/bolivar1.jpg",
        "assets/lugares/bolivar2.jpg",
        "assets/lugares/bolivar3.jpg",
        "assets/lugares/bolivar4.jpg",
      ]),
      "horario": "06:00 - 22:00",
      "latitud": -19.0468,
      "longitud": -65.2575,
    });

    await db.insert("lugares", {
      "nombre": "Parque Cretácico",
      "descripcion": "Parque temático con huellas de dinosaurios y miradores.",
      "direccion": "Zona de Fancesa",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/cretacico.jpg",
      "rating": 4.3,
      "imagenes": jsonEncode([
        "assets/lugares/cretacico1.jpg",
        "assets/lugares/cretacico2.jpg",
        "assets/lugares/cretacico3.jpg",
        "assets/lugares/cretacico4.jpg",
      ]),
      "horario": "08:30 - 17:30",
      "latitud": -19.0400,
      "longitud": -65.2700,
    });

    await db.insert("lugares", {
      "nombre": "La Rotonda",
      "descripcion": "Plaza tranquila ideal para tomar un helado o descansar.",
      "direccion": "Av. Venezuela",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/rotonda.jpg",
      "rating": 4.1,
      "imagenes": jsonEncode([
        "assets/lugares/rotonda1.jpg",
        "assets/lugares/rotonda2.jpg",
        "assets/lugares/rotonda3.jpg",
        "assets/lugares/rotonda4.jpg",
      ]),
      "horario": "24 horas",
      "latitud": -19.0300,
      "longitud": -65.2550,
    });

    await db.insert("lugares", {
      "nombre": "Mercado Central",
      "descripcion": "Mercado tradicional con comida, frutas y productos típicos.",
      "direccion": "Zona Central",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/mercado_central.jpeg",
      "rating": 4.4,
      "imagenes": jsonEncode([
        "assets/lugares/mercado_central1.jpeg",
        "assets/lugares/mercado_central2.jpeg",
        "assets/lugares/mercado_central3.jpeg",
        "assets/lugares/mercado_central4.jpeg",
      ]),
      "horario": "07:00 - 19:00",
      "latitud": -19.0490,
      "longitud": -65.2590,
    });

    await db.insert("lugares", {
      "nombre": "Mercado Campesino",
      "descripcion": "Mercado grande con productos frescos y ropa a buen precio.",
      "direccion": "Zona Campesino",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/mercado_campesino.jpeg",
      "rating": 4.0,
      "imagenes": jsonEncode([
        "assets/lugares/mercado_campesino1.jpeg",
        "assets/lugares/mercado_campesino2.jpeg",
        "assets/lugares/mercado_campesino3.jpeg",
        "assets/lugares/mercado_campesino4.jpeg",
      ]),
      "horario": "07:00 - 20:00",
      "latitud": -19.0600,
      "longitud": -65.2630,
    });

    await db.insert("lugares", {
      "nombre": "Plaza 25 de Mayo",
      "descripcion": "Plaza principal de Sucre, rodeada de edificios históricos.",
      "direccion": "Centro de la ciudad",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/plaza25.jpeg",
      "rating": 4.8,
      "imagenes": jsonEncode([
        "assets/lugares/plaza25_1.jpeg",
        "assets/lugares/plaza25_2.jpeg",
        "assets/lugares/plaza25_3.jpeg",
        "assets/lugares/plaza25_4.jpeg",
      ]),
      "horario": "24 horas",
      "latitud": -19.0475,
      "longitud": -65.2600,
    });

    await db.insert("lugares", {
      "nombre": "Plazuela Aniceto Arce",
      "descripcion": "Espacio tranquilo con árboles y bancos para descansar.",
      "direccion": "Zona Central",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/aniceto_arce.jpg",
      "rating": 4.1,
      "imagenes": jsonEncode([
        "assets/lugares/aniceto_arce1.jpg",
        "assets/lugares/aniceto_arce2.jpg",
        "assets/lugares/aniceto_arce3.jpg",
        "assets/lugares/aniceto_arce4.jpg",
      ]),
      "horario": "24 horas",
      "latitud": -19.0495,
      "longitud": -65.2615,
    });

    await db.insert("lugares", {
      "nombre": "Parque Infantil",
      "descripcion": "Parque con juegos para niños y áreas verdes.",
      "direccion": "Zona Norte",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/parque_infantil.jpg",
      "rating": 4.0,
      "imagenes": jsonEncode([
        "assets/lugares/parque_infantil1.jpg",
        "assets/lugares/parque_infantil2.jpg",
        "assets/lugares/parque_infantil3.jpg",
        "assets/lugares/parque_infantil4.jpg",
      ]),
      "horario": "08:00 - 20:00",
      "latitud": -19.0350,
      "longitud": -65.2520,
    });

    await db.insert("lugares", {
      "nombre": "Río Chico - Zona Recreativa",
      "descripcion": "Área natural cercana al río para paseos y picnic.",
      "direccion": "Camino a Río Chico",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/rio_chico.jpg",
      "rating": 3.9,
      "imagenes": jsonEncode([
        "assets/lugares/rio_chico1.jpg",
        "assets/lugares/rio_chico2.jpg",
        "assets/lugares/rio_chico3.jpg",
        "assets/lugares/rio_chico4.jpg",
      ]),
      "horario": "08:00 - 18:00",
      "latitud": -19.0700,
      "longitud": -65.2800,
    });

    await db.insert("lugares", {
      "nombre": "Cancha Deportiva Max Toledo",
      "descripcion": "Cancha multiuso para fútbol y otros deportes.",
      "direccion": "Zona Max Toledo",
      "categoria": "economico",
      "tipo": "lugar",
      "imagenAsset": "assets/lugares/max_toledo.jpg",
      "rating": 4.0,
      "imagenes": jsonEncode([
        "assets/lugares/max_toledo1.jpg",
        "assets/lugares/max_toledo2.jpg",
        "assets/lugares/max_toledo3.jpg",
        "assets/lugares/max_toledo4.jpg",
      ]),
      "horario": "08:00 - 23:00",
      "latitud": -19.0305,
      "longitud": -65.2480,
    });



    //--restaurantes--
    await db.insert("restaurantes", {
      "nombre": "La Taverne",
      "descripcion": "Restaurante gourmet francés-boliviano con uno de los menús más elegantes de Sucre.",
      "direccion": "Calle Bolivar 490, Zona Central",
      "precio": "alto",
      "imagenAsset": "assets/restaurantes/la_taverne1.jpg",
      "rating": 4.7,
      "imagenes": jsonEncode([
        "assets/restaurantes/la_taverne1.jpg",
        "assets/restaurantes/la_taverne2.jpg",
        "assets/restaurantes/la_taverne3.jpg",
        "assets/restaurantes/la_taverne4.jpg",
      ]),
      "horario": "12:00 - 22:00",
      "latitud": -19.047019,
      "longitud": -65.259563,
    });

      await db.insert("restaurantes", {
      "nombre": "El Huerto",
      "descripcion": "Restaurante de alta cocina con jardines amplios y ambiente elegante.",
      "direccion": "Calle J.M. Serrano 234",
      "precio": "alto",
      "imagenAsset": "assets/restaurantes/el_huerto1.jpg",
      "rating": 4.6,
      "imagenes": jsonEncode([
        "assets/restaurantes/el_huerto1.jpg",
        "assets/restaurantes/el_huerto2.jpg",
        "assets/restaurantes/el_huerto3.jpg",
        "assets/restaurantes/el_huerto4.jpg",
      ]),
      "horario": "12:00 - 23:00",
      "latitud": -19.045250,
      "longitud": -65.255920,
    });

    await db.insert("restaurantes", {
      "nombre": "Café Gourmet Mirador",
      "descripcion": "Restaurante con vista panorámica, platos internacionales y café de especialidad.",
      "direccion": "Camino a La Recoleta",
      "precio": "alto",
      "imagenAsset": "assets/restaurantes/gourmet_mirador1.jpg",
      "rating": 4.6,
      "imagenes": jsonEncode([
        "assets/restaurantes/gourmet_mirador1.jpg",
        "assets/restaurantes/gourmet_mirador2.jpg",
        "assets/restaurantes/gourmet_mirador3.jpg",
        "assets/restaurantes/gourmet_mirador4.jpg",
      ]),
      "horario": "11:00 - 23:00",
      "latitud": -19.050380,
      "longitud": -65.259500,
    });

    await db.insert("restaurantes", {
      "nombre": "La Vieja Bodega",
      "descripcion": "Cocina gourmet y selecta oferta de vinos en un ambiente colonial.",
      "direccion": "La Recoleta",
      "precio": "alto",
      "imagenAsset": "assets/restaurantes/vieja_bodega1.jpg",
      "rating": 4.6,
      "imagenes": jsonEncode([
        "assets/restaurantes/vieja_bodega1.jpg",
        "assets/restaurantes/vieja_bodega2.jpg",
        "assets/restaurantes/vieja_bodega3.jpg",
        "assets/restaurantes/vieja_bodega4.jpg",
      ]),
      "horario": "12:00 - 22:00",
      "latitud": -19.051200,
      "longitud": -65.260900,
    });


    await db.insert("restaurantes", {
      "nombre": "Japo Sushi Premium",
      "descripcion": "Restaurante de sushi premium y cocina fusión japonesa.",
      "direccion": "Avenida Hernando Siles",
      "precio": "alto",
      "imagenAsset": "assets/restaurantes/japo_sushi1.jpg",
      "rating": 4.5,
      "imagenes": jsonEncode([
        "assets/restaurantes/japo_sushi1.jpg",
        "assets/restaurantes/japo_sushi2.jpg",
        "assets/restaurantes/japo_sushi3.jpg",
        "assets/restaurantes/japo_sushi4.jpg",
      ]),
      "horario": "12:00 - 23:00",
      "latitud": -19.038410,
      "longitud": -65.255881,
    });

// ===================== BARES CAROS =====================
await db.insert("bares", {
  "nombre": "GastroBar El Mercado",
  "descripcion": "Fusión gourmet con ingredientes frescos y carta de vinos premium.",
  "direccion": "Mercado Central, 2do nivel",
  "ambiente": "premium",
  "imagenAsset": "assets/bares/lounge360_4.jpg",
  "rating": 4.7,
  "imagenes": jsonEncode([
    "assets/bares/lounge360_1.jpg",
    "assets/bares/lounge360.jpg",
    "assets/bares/terraza.jpg",
    "assets/bares/skygarden.jpg"
  ]),
  "horario": "11:00 - 22:00",
  "latitud": -19.049101,
  "longitud": -65.259007
});

await db.insert("restaurantes", {
  "nombre": "Café Gourmet Mirador",
  "descripcion": "Café gourmet con vista panorámica a toda la ciudad.",
  "direccion": "La Recoleta",
  "precio": "alto",
  "imagenAsset": "assets/restaurantes/gourmet_mirador.jpg",
  "rating": 4.8,
  "imagenes": jsonEncode([
    "assets/restaurantes/gourmet_mirador1.jpg",
    "assets/restaurantes/gourmet_mirador2.jpg",
    "assets/restaurantes/gourmet_mirador3.jpg",
    "assets/restaurantes/gourmet_mirador4.jpg"
  ]),
  "horario": "10:00 - 22:00",
  "latitud": -19.051271,
  "longitud": -65.259781
});

// ==================== ECONÓMICOS ====================

await db.insert("restaurantes", {
  "nombre": "Sabor Criollo",
  "descripcion": "Comida típica boliviana a precios accesibles.",
  "direccion": "Mercado Central",
  "precio": "bajo",
  "imagenAsset": "assets/restaurantes/sabor_criollo.jpg",
  "rating": 4.3,
  "imagenes": jsonEncode([
    "assets/restaurantes/sabor_criollo1.jpg",
    "assets/restaurantes/sabor_criollo2.jpg",
    "assets/restaurantes/sabor_criollo3.jpg",
    "assets/restaurantes/sabor_criollo4.jpg"
  ]),
  "horario": "08:00 - 21:00",
  "latitud": -19.048712,
  "longitud": -65.259115
});

await db.insert("restaurantes", {
  "nombre": "Pollos Rosita",
  "descripcion": "Pollo broaster crocante y al carbón, tradicional de Sucre, ideal para ir en familia o con amigos.",
  "direccion": "Frente de la Plazuela Zudañez",
  "precio": "bajo",
  "imagenAsset": "assets/restaurantes/rosita.jpg",
  "rating": 4.4,
  "imagenes": jsonEncode([
    "assets/restaurantes/rosita1.jpg",
    "assets/restaurantes/rosita2.jpg",
    "assets/restaurantes/rosita3.jpg",
    "assets/restaurantes/rosita4.jpg"
  ]),
  "horario": "11:30 - 23:00",
  "latitud": -19.047800,
  "longitud": -65.260200
});


await db.insert("restaurantes", {
  "nombre": "Antojitos Doña Chela",
  "descripcion": "Comida casera típica con menú del día.",
  "direccion": "Av. Las Américas",
  "precio": "bajo",
  "imagenAsset": "assets/restaurantes/chela.jpg",
  "rating": 4.4,
  "imagenes": jsonEncode([
    "assets/restaurantes/chela1.jpg",
    "assets/restaurantes/chela2.jpg",
    "assets/restaurantes/chela3.jpg",
    "assets/restaurantes/chela4.jpg"
  ]),
  "horario": "12:00 - 15:00",
  "latitud": -19.042300,
  "longitud": -65.259900
});

await db.insert("restaurantes", {
  "nombre": "Hamburguesas el Paceño",
  "descripcion": "Hamburguesas populares y económicas.",
  "direccion": "Zona Universitaria",
  "precio": "bajo",
  "imagenAsset": "assets/restaurantes/paceño.jpg",
  "rating": 4.1,
  "imagenes": jsonEncode([
    "assets/restaurantes/paceño1.jpg",
    "assets/restaurantes/paceño2.jpg",
    "assets/restaurantes/paceño3.jpg",
    "assets/restaurantes/paceño4.jpg"
  ]),
  "horario": "18:00 - 23:00",
  "latitud": -19.045200,
  "longitud": -65.254300
});

// ==================== POPULARES ====================

await db.insert("restaurantes", {
  "nombre": "El Patio",
  "descripcion": "Restaurante popular con comida variada y ambiente familiar.",
  "direccion": "Av. Las Américas",
  "precio": "medio",
  "imagenAsset": "assets/restaurantes/patio.jpg",
  "rating": 4.5,
  "imagenes": jsonEncode([
    "assets/restaurantes/patio1.jpg",
    "assets/restaurantes/patio2.jpg",
    "assets/restaurantes/patio3.jpg",
    "assets/restaurantes/patio4.jpg"
  ]),
  "horario": "12:00 - 22:00",
  "latitud": -19.042871,
  "longitud": -65.259821
});

await db.insert("restaurantes", {
  "nombre": "Pizzería Napoli",
  "descripcion": "Pizzas al horno de leña y pastas artesanales.",
  "direccion": "Zona Central",
  "precio": "medio",
  "imagenAsset": "assets/restaurantes/napoli.jpg",
  "rating": 4.6,
  "imagenes": jsonEncode([
    "assets/restaurantes/napoli1.jpg",
    "assets/restaurantes/napoli2.jpg",
    "assets/restaurantes/napoli3.jpg",
    "assets/restaurantes/napoli4.jpg"
  ]),
  "horario": "12:00 - 23:00",
  "latitud": -19.048910,
  "longitud": -65.260701
});

// ===================== BARES CAROS =====================
await db.insert("bares", {
  "nombre": "Lounge 360",
  "descripcion": "Bar lounge con vista panorámica, tragos premium y ambiente elegante.",
  "direccion": "Av. German Mendoza",
  "ambiente": "elegante",
  "imagenAsset": "assets/bares/lounge360.jpg",
  "rating": 4.7,
  "imagenes": jsonEncode([
    "assets/bares/lounge360_1.jpg",
    "assets/bares/lounge360_2.jpg",
    "assets/bares/lounge360_3.jpg",
    "assets/bares/lounge360_4.jpg",
  ]),
  "horario": "18:00 - 02:00",
  "latitud": -19.04623,
  "longitud": -65.25910,
});

await db.insert("bares", {
  "nombre": "La Terraza Sucre",
  "descripcion": "Ambiente elegante con coctelería de autor y vista nocturna.",
  "direccion": "Calle Bolívar",
  "ambiente": "premium",
  "imagenAsset": "assets/bares/terraza.jpg",
  "rating": 4.6,
  "imagenes": jsonEncode([
    "assets/bares/terraza1.jpg",
    "assets/bares/terraza2.jpg",
    "assets/bares/terraza3.jpg",
    "assets/bares/terraza4.jpg",
  ]),
  "horario": "17:00 - 02:30",
  "latitud": -19.04850,
  "longitud": -65.25970,
});

await db.insert("bares", {
  "nombre": "Republic Lounge",
  "descripcion": "Cocktails internacionales y ambiente sofisticado.",
  "direccion": "Calle Loa 677",
  "ambiente": "elegante",
  "imagenAsset": "assets/bares/republic.jpeg",
  "rating": 4.5,
  "imagenes": jsonEncode([
    "assets/bares/republic1.jpeg",
    "assets/bares/republic2.jpeg",
    "assets/bares/republic3.jpeg",
    "assets/bares/republic4.jpeg",
  ]),
  "horario": "19:00 - 02:00",
  "latitud": -19.04710,
  "longitud": -65.25940,
});

await db.insert("bares", {
  "nombre": "Mirador Bar Recoleta",
  "descripcion": "Bar con terraza y vista privilegiada a Sucre.",
  "direccion": "La Recoleta",
  "ambiente": "romántico",
  "imagenAsset": "assets/bares/recoleta.jpeg",
  "rating": 4.7,
  "imagenes": jsonEncode([
    "assets/bares/recoleta1.jpeg",
    "assets/bares/recoleta2.jpeg",
    "assets/bares/recoleta3.jpeg",
    "assets/bares/recoleta4.jpeg",
  ]),
  "horario": "16:00 - 01:00",
  "latitud": -19.05052,
  "longitud": -65.25919,
});

await db.insert("bares", {
  "nombre": "SkyBar Sucre",
  "descripcion": "Cocteles premium en altura con vista moderna.",
  "direccion": "Av. Las Américas",
  "ambiente": "skybar",
  "imagenAsset": "assets/bares/skybar.jpg",
  "rating": 4.6,
  "imagenes": jsonEncode([
    "assets/bares/skybar1.jpg",
    "assets/bares/skybar2.jpg",
    "assets/bares/skybar3.jpg",
    "assets/bares/skybar4.jpg",
  ]),
  "horario": "18:00 - 03:00",
  "latitud": -19.03450,
  "longitud": -65.25300,
});

await db.insert("bares", {
  "nombre": "Luxury Bar Sucre",
  "descripcion": "Ambiente de lujo, música en vivo y vinos importados.",
  "direccion": "Zona Retiro",
  "ambiente": "luxury",
  "imagenAsset": "assets/bares/luxury.jpg",
  "rating": 4.8,
  "imagenes": jsonEncode([
    "assets/bares/luxury1.jpg",
    "assets/bares/luxury2.jpg",
    "assets/bares/luxury3.jpg",
    "assets/bares/luxury4.jpg",
  ]),
  "horario": "18:00 - 02:00",
  "latitud": -19.04231,
  "longitud": -65.25981,
});

await db.insert("bares", {
  "nombre": "Pura Pura Bar & Grill",
  "descripcion": "Bar carne premium y tragos exclusivos.",
  "direccion": "Av. Marcelo Quiroga",
  "ambiente": "premium",
  "imagenAsset": "assets/bares/purapura.jpg",
  "rating": 4.5,
  "imagenes": jsonEncode([
    "assets/bares/purapura1.jpg",
    "assets/bares/purapura2.jpg",
    "assets/bares/purapura3.jpg",
    "assets/bares/purapura4.jpg",
  ]),
  "horario": "17:00 - 01:00",
  "latitud": -19.03682,
  "longitud": -65.25221,
});

await db.insert("bares", {
  "nombre": "SkyGarden Rooftop",
  "descripcion": "Bar en terraza con temática botánica y cocteles artesanales.",
  "direccion": "Zona Norte",
  "ambiente": "rooftop",
  "imagenAsset": "assets/bares/skygarden.jpg",
  "rating": 4.7,
  "imagenes": jsonEncode([
    "assets/bares/skygarden1.jpg",
    "assets/bares/skygarden2.jpg",
    "assets/bares/skygarden3.jpg",
    "assets/bares/skygarden4.jpg",
  ]),
  "horario": "17:00 - 02:00",
  "latitud": -19.03211,
  "longitud": -65.25010,
});

await db.insert("bares", {
  "nombre": "Bellavista Bar",
  "descripcion": "Bar de ambiente refinado, vista nocturna y excelente mixología.",
  "direccion": "Zona Retiro Alto",
  "ambiente": "elegante",
  "imagenAsset": "assets/bares/bellavista.jpg",
  "rating": 4.5,
  "imagenes": jsonEncode([
    "assets/bares/bellavista1.jpg",
    "assets/bares/bellavista2.jpg",
    "assets/bares/bellavista3.jpg",
    "assets/bares/bellavista4.jpg",
  ]),
  "horario": "18:30 - 02:00",
  "latitud": -19.04185,
  "longitud": -65.25872,
});

await db.insert("bares", {
  "nombre": "La Esquina Bar",
  "descripcion": "Bar económico con música latina y ambiente juvenil.",
  "direccion": "Calle Aniceto Arce",
  "ambiente": "económico",
  "imagenAsset": "assets/bares/esquina.jpg",
  "rating": 4.1,
  "imagenes": jsonEncode([
    "assets/bares/esquina1.jpg",
    "assets/bares/esquina2.jpg",
    "assets/bares/esquina3.jpg",
    "assets/bares/esquina4.jpg",
  ]),
  "horario": "18:00 - 01:00",
  "latitud": -19.04712,
  "longitud": -65.26084,
});

await db.insert("bares", {
  "nombre": "La Taberna del Sur",
  "descripcion": "Bar tradicional con vinos nacionales y picadas.",
  "direccion": "Zona Sur",
  "ambiente": "tradicional",
  "imagenAsset": "assets/bares/taberna_sur.jpg",
  "rating": 4.2,
  "imagenes": jsonEncode([
    "assets/bares/taberna1.jpg",
    "assets/bares/taberna2.jpg",
    "assets/bares/taberna3.jpg",
    "assets/bares/taberna4.jpg",
  ]),
  "horario": "17:00 - 00:30",
  "latitud": -19.05500,
  "longitud": -65.26600,
});


await db.insert("bares", {
  "nombre": "Joy Ride Café",
  "descripcion": "Uno de los bares más famosos de Sucre. Comida, tragos y música.",
  "direccion": "Calle Nicolás Ortiz",
  "ambiente": "popular",
  "imagenAsset": "assets/bares/joyride.jpg",
  "rating": 4.6,
  "imagenes": jsonEncode([
    "assets/bares/joyride1.jpg",
    "assets/bares/joyride2.jpg",
    "assets/bares/joyride3.jpg",
    "assets/bares/joyride4.jpg",
  ]),
  "horario": "12:00 - 02:00",
  "latitud": -19.04895,
  "longitud": -65.25950,
});

await db.insert("bares", {
  "nombre": "KulturCafe Berlin",
  "descripcion": "Bar cultural con eventos, bandas y bebidas artesanales.",
  "direccion": "Calle Avaroa",
  "ambiente": "popular",
  "imagenAsset": "assets/bares/kultur.jpg",
  "rating": 4.7,
  "imagenes": jsonEncode([
    "assets/bares/kultur1.jpg",
    "assets/bares/kultur2.jpg",
    "assets/bares/kultur3.jpg",
    "assets/bares/kultur4.jpg",
  ]),
  "horario": "15:00 - 02:00",
  "latitud": -19.04720,
  "longitud": -65.26110,
});



// ==================== INSERCIÓN DE HITOS (FECHAS DESTACADAS) ====================

// ----------------------------------------------------
// CATEGORÍAS UNIFICADAS:
// 1. Festividades y Tradiciones
// 2. Arte y Cultura
// 3. Sociedad y Reivindicación
// 4. Gastronomía y Ferias
// ----------------------------------------------------

// ID 1: Festival de Danzas (Arte y Cultura - cercano a la fecha actual)
final hito1Id = await db.insert("fechas_destacadas", {
  "titulo": "Festival de Danzas Folklóricas",
  "descripcion":
      "Muestra de danzas típicas de Chuquisaca y otras regiones de Bolivia, con énfasis en la cultura andina.",
  "icono": "💃",
  "categoria": "Arte y Cultura",
  "fechaInicio": DateTime(2025, 11, 28).toIso8601String(),
  "fechaFin": DateTime(2025, 12, 1).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/danzas_festival.jpg",
});

// ID 2: Sociedad y Reivindicación
final hito2Id = await db.insert("fechas_destacadas", {
  "titulo": "Día contra la Violencia a la Mujer",
  "descripcion":
      "Actividades de concientización, ferias informativas y marchas pacíficas en el centro de la ciudad.",
  "icono": "🎗️",
  "categoria": "Sociedad y Reivindicación",
  "fechaInicio": DateTime(2025, 11, 25).toIso8601String(),
  "fechaFin": DateTime(2025, 11, 25).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/mujer_violencia.jpg",
});

// ID 3: Festividades y Tradiciones (Navidad)
final hito3Id = await db.insert("fechas_destacadas", {
  "titulo": "Navidad y Pesebres Gigantes",
  "descripcion":
      "Celebración de las fiestas de fin de año con pesebres, ferias navideñas y encuentros familiares. Duración: 20 al 31 de diciembre.",
  "icono": "🎄",
  "categoria": "Festividades y Tradiciones",
  "fechaInicio": DateTime(2025, 12, 20).toIso8601String(),
  "fechaFin": DateTime(2025, 12, 31).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/feria_navidad.jpg",
});

// ID 4: Gastronomía y Ferias (Permanente)
final hito4Id = await db.insert("fechas_destacadas", {
  "titulo": "Mercado Central Gastronómico",
  "descripcion":
      "Sabores típicos de Sucre disponibles todo el año en el Mercado Central: chorizos, mondongo, ají de fideo y más.",
  "icono": "🍲",
  "categoria": "Gastronomía y Ferias",
  "fechaInicio": DateTime(2025, 1, 1).toIso8601String(),
  "fechaFin": DateTime(2025, 12, 31).toIso8601String(),
  "permanente": 1,
  "imagenAsset": "assets/fechas/mercado.jpg",
});

// ID 5: Festividades y Tradiciones (25 de Mayo – Primer Grito Libertario)
final hito5Id = await db.insert("fechas_destacadas", {
  "titulo": "25 de Mayo – Primer Grito Libertario",
  "descripcion":
      "Conmemoración del Primer Grito Libertario de América en 1809, con actos cívicos, desfiles escolares, militares y actividades culturales en la ciudad de Sucre.",
  "icono": "🏛️",
  "categoria": "Festividades y Tradiciones",
  "fechaInicio": DateTime(2026, 5, 25).toIso8601String(),
  "fechaFin": DateTime(2026, 5, 25).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/aniversario_sucre.jpg",
});

// ID 6: Arte y Cultura (Festival Internacional de la Cultura)
final hito6Id = await db.insert("fechas_destacadas", {
  "titulo": "Festival Internacional de la Cultura (FIC)",
  "descripcion":
      "Muestra de arte, cine, teatro y música con participación nacional e internacional. Actividades en varios espacios culturales de Sucre.",
  "icono": "🎨",
  "categoria": "Arte y Cultura",
  "fechaInicio": DateTime(2026, 6, 10).toIso8601String(),
  "fechaFin": DateTime(2026, 6, 14).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/fic_festival.jpg",
});

// ID 7: Carnaval de Sucre
final hito7Id = await db.insert("fechas_destacadas", {
  "titulo": "Carnaval de Sucre",
  "descripcion":
      "La festividad más colorida y alegre del año, con corsos, entradas y juegos de agua.",
  "icono": "🎭",
  "categoria": "Festividades y Tradiciones",
  "fechaInicio": DateTime(2026, 2, 10).toIso8601String(),
  "fechaFin": DateTime(2026, 2, 18).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/carnaval.jpg",
});

// ID 8: Fiesta de la Virgen de Guadalupe
final hito8Id = await db.insert("fechas_destacadas", {
  "titulo": "Fiesta de la Virgen de Guadalupe",
  "descripcion":
      "La principal festividad religiosa de Sucre con misas, procesiones, entradas folclóricas y feria popular.",
  "icono": "⛪",
  "categoria": "Festividades y Tradiciones",
  "fechaInicio": DateTime(2026, 9, 8).toIso8601String(),
  "fechaFin": DateTime(2026, 9, 10).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/guadalupe.jpg",
});

// ID 9: Gastronomía y Ferias (Alasita)
final hito9Id = await db.insert("fechas_destacadas", {
  "titulo": "Feria de la Alasita Sucreña",
  "descripcion":
      "Feria tradicional de miniaturas y deseos, con enfoque en la abundancia, juegos y gastronomía.",
  "icono": "🎁",
  "categoria": "Gastronomía y Ferias",
  "fechaInicio": DateTime(2026, 1, 24).toIso8601String(),
  "fechaFin": DateTime(2026, 1, 31).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/alasita.jpg",
});

// ID 10: Arte y Cultura (Encuentro de Poesía)
final hito10Id = await db.insert("fechas_destacadas", {
  "titulo": "Encuentro Nacional de Poesía",
  "descripcion":
      "Lecturas y talleres con poetas de todo el país, actividades en centros culturales y espacios públicos.",
  "icono": "📚",
  "categoria": "Arte y Cultura",
  "fechaInicio": DateTime(2026, 4, 15).toIso8601String(),
  "fechaFin": DateTime(2026, 4, 18).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/poesia.jpg",
});

// ID 11: Sociedad y Reivindicación (Día del Peatón)
final hito11Id = await db.insert("fechas_destacadas", {
  "titulo": "Día del Peatón",
  "descripcion":
      "Jornada sin vehículos motorizados, dedicada al deporte, el esparcimiento y actividades familiares en las avenidas principales.",
  "icono": "🚴",
  "categoria": "Sociedad y Reivindicación",
  "fechaInicio": DateTime(2025, 9, 1).toIso8601String(),
  "fechaFin": DateTime(2025, 9, 1).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/peaton.jpg",
});

// ID 12: Semana Santa
final hito12Id = await db.insert("fechas_destacadas", {
  "titulo": "Semana Santa en Sucre",
  "descripcion":
      "Celebraciones religiosas, procesiones y actividades culturales durante la Semana Santa en el casco histórico.",
  "icono": "✝️",
  "categoria": "Festividades y Tradiciones",
  "fechaInicio": DateTime(2026, 4, 2).toIso8601String(),
  "fechaFin": DateTime(2026, 4, 5).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/semana_santa.jpg",
});

// ID 13: Festival del Chocolate
final hito13Id = await db.insert("fechas_destacadas", {
  "titulo": "Festival del Chocolate Sucrense",
  "descripcion":
      "Feria dedicada al chocolate chuquisaqueño con degustaciones, talleres, concursos y ventas.",
  "icono": "🍫",
  "categoria": "Gastronomía y Ferias",
  "fechaInicio": DateTime(2026, 7, 10).toIso8601String(),
  "fechaFin": DateTime(2026, 7, 14).toIso8601String(),
  "permanente": 0,
  "imagenAsset": "assets/fechas/festival_chocolate.jpg",
});

// ====================================================
// EVENTOS RELACIONADOS (ACTIVIDADES) - ENRIQUECIDOS
// ====================================================

// HITO 1: Festival de Danzas Folklóricas
await db.insert("eventos_relacionados", {
  "hitoId": hito1Id,
  "titulo": "Apertura y Desfile Inaugural",
  "descripcion":
      "Presentación de delegaciones nacionales e internacionales con trajes de gala.",
  "ubicacion": "Plaza 25 de Mayo, frente a la Catedral Metropolitana, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 11, 30, 17, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito1Id,
  "titulo": "Gala de la Cueca Chuquisaqueña",
  "descripcion": "Concurso y exhibición de la danza tradicional de Sucre.",
  "ubicacion": "Teatro Gran Mariscal, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 12, 1, 19, 30).toIso8601String(),
});

// HITO 2: Día contra la Violencia a la Mujer
await db.insert("eventos_relacionados", {
  "hitoId": hito2Id,
  "titulo": "Marcha de Sensibilización",
  "descripcion":
      "Marcha pacífica con carteles y mensajes de reflexión contra la violencia de género.",
  "ubicacion": "Plaza 25 de Mayo, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 11, 25, 9, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito2Id,
  "titulo": "Feria Informativa y Talleres",
  "descripcion":
      "Puestos de instituciones y ONG con orientación legal, psicológica y material informativo.",
  "ubicacion": "Parque Simón Bolívar, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 11, 25, 15, 0).toIso8601String(),
});

// HITO 3: Navidad y Pesebres Gigantes
await db.insert("eventos_relacionados", {
  "hitoId": hito3Id,
  "titulo": "Inauguración de Pesebre Gigante",
  "descripcion":
      "Encendido de luces y apertura oficial del pesebre de la ciudad.",
  "ubicacion": "Parque Infantil, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 12, 20, 19, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito3Id,
  "titulo": "Misa de Gallo y Nochebuena",
  "descripcion": "Ceremonia religiosa principal de Nochebuena.",
  "ubicacion": "Catedral Metropolitana de Sucre, Plaza 25 de Mayo, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 12, 24, 22, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito3Id,
  "titulo": "Feria Navideña de Sucre",
  "descripcion":
      "Feria navideña con artesanías, juguetes, luces y puestos de comida típica.",
  "ubicacion": "Parque Multiproposito, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 12, 21, 18, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito3Id,
  "titulo": "Noche de Coros y Villancicos",
  "descripcion":
      "Presentación de coros navideños y grupos musicales locales al aire libre.",
  "ubicacion": "Plaza 25 de Mayo, frente a la Catedral, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 12, 23, 19, 30).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito3Id,
  "titulo": "Feria Gastronómica Navideña",
  "descripcion":
      "Puestos de comida con buñuelos, api, picana y platos típicos de la temporada.",
  "ubicacion": "Zona ferial, alrededores del Estadio Patria, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 12, 23, 12, 0).toIso8601String(),
});

// HITO 4: Mercado Central Gastronómico (permanente)
await db.insert("eventos_relacionados", {
  "hitoId": hito4Id,
  "titulo": "Día de la Picana Navideña",
  "descripcion": "Promoción especial de picana y platos de Año Nuevo.",
  "ubicacion": "Mercado Central, sección comidas, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 1, 1, 12, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito4Id,
  "titulo": "Taller de preparación de chorizos chuquisaqueños",
  "descripcion":
      "Aprende a preparar chorizos con expertos cocineros del mercado.",
  "ubicacion": "Mercado Central, piso 2, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 1, 15, 10, 0).toIso8601String(),
});

// HITO 5: 25 de Mayo – Primer Grito Libertario
await db.insert("eventos_relacionados", {
  "hitoId": hito5Id,
  "titulo": "Sesión de Honor en la Casa de la Libertad",
  "descripcion":
      "Acto cívico central con autoridades locales y departamentales.",
  "ubicacion": "Casa de la Libertad, Plaza 25 de Mayo, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 5, 25, 9, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito5Id,
  "titulo": "Desfile Cívico Escolar y Militar",
  "descripcion":
      "Desfile con unidades educativas, organizaciones e instituciones armadas.",
  "ubicacion": "Plaza 25 de Mayo y Av. de las Américas, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 5, 25, 10, 30).toIso8601String(),
});

// HITO 6: Festival Internacional de la Cultura (FIC)
await db.insert("eventos_relacionados", {
  "hitoId": hito6Id,
  "titulo": "Muestra de Cine Boliviano",
  "descripcion":
      "Proyección de películas nacionales con conversatorios posteriores.",
  "ubicacion": "Centro Cultural Universitario, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 6, 11, 18, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito6Id,
  "titulo": "Concierto de Clausura FIC",
  "descripcion":
      "Presentación de bandas y artistas invitados en un concierto al aire libre.",
  "ubicacion": "Teatro Gran Mariscal, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 6, 14, 20, 0).toIso8601String(),
});

// HITO 7: Carnaval de Sucre
await db.insert("eventos_relacionados", {
  "hitoId": hito7Id,
  "titulo": "Elección y Coronación de la Reina del Carnaval",
  "descripcion":
      "Evento de gala con presentación de candidatas y fiesta de apertura.",
  "ubicacion": "Coliseo Jorge Revilla Aldana, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 2, 10, 20, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito7Id,
  "titulo": "Entrada Folklórica del Carnaval",
  "descripcion":
      "El evento central con comparsas, bandas y disfraces tradicionales.",
  "ubicacion": "Av. Hernando Siles, recorrido central del Carnaval, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 2, 14, 14, 0).toIso8601String(),
});

// HITO 8: Fiesta de Guadalupe
await db.insert("eventos_relacionados", {
  "hitoId": hito8Id,
  "titulo": "Procesión y desfile de carros alegóricos",
  "descripcion":
      "La procesión más importante de la ciudad, con participación masiva de fieles.",
  "ubicacion": "Desde la Catedral Metropolitana hasta La Recoleta, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 9, 8, 15, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito8Id,
  "titulo": "Feria popular de comida y música",
  "descripcion":
      "Stands de comida tradicional, juegos y música en vivo.",
  "ubicacion": "Zona Estadio Patria, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 9, 9, 10, 0).toIso8601String(),
});

// HITO 9: Feria de la Alasita Sucreña
await db.insert("eventos_relacionados", {
  "hitoId": hito9Id,
  "titulo": "Inauguración de la feria y bendición",
  "descripcion":
      "Apertura oficial con ritos de bendición a las miniaturas y discursos.",
  "ubicacion": "Campo Ferial Multipropósito, zona Max Toledo, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 1, 24, 11, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito9Id,
  "titulo": "Venta de platos típicos a miniatura",
  "descripcion":
      "Platos tradicionales vendidos en tamaño miniatura para rituales de prosperidad.",
  "ubicacion":
      "Sector gastronómico, Campo Ferial Multipropósito, zona Max Toledo, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 1, 27, 12, 0).toIso8601String(),
});

// HITO 10: Encuentro Nacional de Poesía
await db.insert("eventos_relacionados", {
  "hitoId": hito10Id,
  "titulo": "Taller de métrica y verso clásico",
  "descripcion":
      "Taller dirigido a jóvenes escritores en el Centro Cultural Universitario.",
  "ubicacion": "Centro Cultural Universitario, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 4, 16, 15, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito10Id,
  "titulo": "Recital poético central (abierto al público)",
  "descripcion":
      "Lecturas centrales con poetas invitados de renombre.",
  "ubicacion": "Casa de la Cultura, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 4, 17, 19, 0).toIso8601String(),
});

// HITO 11: Día del Peatón
await db.insert("eventos_relacionados", {
  "hitoId": hito11Id,
  "titulo": "Ciclovía recreativa",
  "descripcion":
      "Espacios habilitados para bicicletas, patines y caminatas familiares.",
  "ubicacion": "Av. de las Américas, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 9, 1, 9, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito11Id,
  "titulo": "Feria de salud y deportes",
  "descripcion":
      "Actividades deportivas, chequeos médicos básicos y juegos para niños.",
  "ubicacion": "Plaza 25 de Mayo, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2025, 9, 1, 10, 30).toIso8601String(),
});

// HITO 12: Semana Santa
await db.insert("eventos_relacionados", {
  "hitoId": hito12Id,
  "titulo": "Procesión del Viernes Santo",
  "descripcion":
      "Procesión principal con recorrido por el centro histórico de Sucre.",
  "ubicacion": "Centro histórico, Plaza 25 de Mayo y alrededores, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 4, 3, 18, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito12Id,
  "titulo": "Vía Crucis juvenil",
  "descripcion":
      "Recorrido juvenil con meditaciones en diferentes puntos de la ciudad.",
  "ubicacion": "Desde la Catedral Metropolitana hasta La Recoleta, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 4, 4, 9, 0).toIso8601String(),
});

// HITO 13: Festival del Chocolate Sucrense
await db.insert("eventos_relacionados", {
  "hitoId": hito13Id,
  "titulo": "Inauguración del Festival del Chocolate",
  "descripcion":
      "Apertura oficial con exposición de marcas locales de chocolate.",
  "ubicacion": "Centro Cultural Universitario, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 7, 10, 10, 0).toIso8601String(),
});
await db.insert("eventos_relacionados", {
  "hitoId": hito13Id,
  "titulo": "Taller de bombones artesanales",
  "descripcion":
      "Taller práctico para aprender a hacer bombones con chocolate sucrense.",
  "ubicacion": "Casa de la Cultura, Sucre, Bolivia",
  "fechaHoraInicio": DateTime(2026, 7, 11, 15, 0).toIso8601String(),
});




  }

  // ====================================================
  //                   USUARIOS
  // ====================================================
  Future<int> registrarUsuario(
      String nombre, String correo, String password) async {
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

  Future<Map<String, dynamic>?> loginUsuario(
      String correo, String password) async {
    final database = await db;
    final res = await database.query(
      "usuarios",
      where: "correo = ? AND password = ?",
      whereArgs: [correo, password],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> actualizarPerfil({
    required int usuarioId,
    String? fotoPerfil,
    String? telefono,
    String? bio,
    String? lugaresPreferidos,
    String? restaurantesPreferidos,
    String? ambiente,
  }) async {
    final database = await db;
    
    Map<String, dynamic> updates = {};
    
    if (fotoPerfil != null) updates["fotoPerfil"] = fotoPerfil;
    if (telefono != null && telefono.isNotEmpty) updates["telefono"] = telefono;
    if (bio != null && bio.isNotEmpty) updates["bio"] = bio;
    if (lugaresPreferidos != null) updates["lugaresPreferidos"] = lugaresPreferidos;
    if (restaurantesPreferidos != null) updates["restaurantesPreferidos"] = restaurantesPreferidos;
    if (ambiente != null) updates["ambiente"] = ambiente;
    
    if (updates.isEmpty) return 0;
    
    return await database.update(
      "usuarios",
      updates,
      where: "id = ?",
      whereArgs: [usuarioId],
    );
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorId(int usuarioId) async {
    final database = await db;
    final res = await database.query(
      "usuarios",
      where: "id = ?",
      whereArgs: [usuarioId],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ====================================================
  //                     LUGARES
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerLugares() async {
    final database = await db;
    return await database.query("lugares");
  }

  Future<List<Map<String, dynamic>>> obtenerLugaresPorCategoria(
      String categoria) async {
    final database = await db;
    return await database.query(
      "lugares",
      where: "categoria = ?",
      whereArgs: [categoria],
    );
    }

  // ====================================================
  //                   RESTAURANTES
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerRestaurantes() async {
    final database = await db;
    return await database.query("restaurantes");
  }

  // ====================================================
  //                       BARES
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerBares() async {
    final database = await db;
    return await database.query("bares");
  }

  // ====================================================
  //                     FAVORITOS
  // ====================================================
  Future<void> toggleFavorito(int usuarioId, int lugarId, {String tipo = 'lugar'}) async {
    final database = await db;

    final existe = await database.query(
      "favoritos",
      where: "usuarioId = ? AND lugarId = ? AND tipo = ?",
      whereArgs: [usuarioId, lugarId, tipo],
    );

    if (existe.isNotEmpty) {
      await database.delete(
        "favoritos",
        where: "usuarioId = ? AND lugarId = ? AND tipo = ?",
        whereArgs: [usuarioId, lugarId, tipo],
      );
    } else {
      await database.insert("favoritos", {
        "usuarioId": usuarioId,
        "lugarId": lugarId,
        "tipo": tipo,
      });
    }
  }

  Future<List<int>> obtenerFavoritosIds(int usuarioId, {String tipo = 'lugar'}) async {
    final database = await db;
    final res = await database.query(
      "favoritos",
      where: "usuarioId = ? AND tipo = ?",
      whereArgs: [usuarioId, tipo],
    );

    return res.map((e) => e["lugarId"] as int).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerTodosFavoritos(int usuarioId) async {
    final database = await db;
    final res = await database.query(
      "favoritos",
      where: "usuarioId = ?",
      whereArgs: [usuarioId],
    );

    return res;
  }

  // ====================================================
  //                   COMENTARIOS
  // ====================================================

  // Comentarios para LUGARES
  Future<int> agregarComentario({
    required int lugarId,
    int? usuarioId,
    required String texto,
    required String fecha,
  }) async {
    final database = await db;
    return await database.insert("comentarios", {
      "lugarId": lugarId,
      "usuarioId": usuarioId,
      "texto": texto,
      "fecha": fecha,
    });
  }

  // Comentarios para RESTAURANTES
  Future<int> insertarComentario({
    required int usuarioId,
    int? lugarId,
    int? restauranteId,
    required String texto,
  }) async {
    final database = await db;

    return await database.insert("comentarios", {
      "usuarioId": usuarioId,
      "lugarId": lugarId,
      "restauranteId": restauranteId,
      "texto": texto,
      "fecha": DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> obtenerComentariosDeLugar(int lugarId) async {
    final database = await db;

    final res = await database.rawQuery("""
      SELECT c.id, c.texto, c.fecha, c.usuarioId, u.nombre AS usuarioNombre, u.fotoPerfil AS usuarioFoto
      FROM comentarios c
      LEFT JOIN usuarios u ON u.id = c.usuarioId
      WHERE c.lugarId = ?
      ORDER BY datetime(c.fecha) DESC
    """, [lugarId]);

    return res;
  }

  Future<List<Map<String, dynamic>>> obtenerComentariosDeRestaurante(int restauranteId) async {
    final database = await db;

    final res = await database.rawQuery("""
      SELECT c.id, c.texto, c.fecha, c.usuarioId, u.nombre AS usuarioNombre, u.fotoPerfil AS usuarioFoto
      FROM comentarios c
      LEFT JOIN usuarios u ON u.id = c.usuarioId
      WHERE c.restauranteId = ?
      ORDER BY datetime(c.fecha) DESC
    """, [restauranteId]);
    return res;
  }

  // Editar comentario
  Future<int> editarComentario(int comentarioId, String nuevoTexto) async {
    final database = await db;
    return await database.update(
      "comentarios",
      {"texto": nuevoTexto},
      where: "id = ?",
      whereArgs: [comentarioId],
    );
  }

  // Eliminar comentario
  Future<int> eliminarComentario(int comentarioId) async {
    final database = await db;
    return await database.delete(
      "comentarios",
      where: "id = ?",
      whereArgs: [comentarioId],
    );
  }
  // ====================================================
  //               FECHAS DESTACADAS (HITOS)
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerFechasDestacadas() async {
    final database = await db;
    return await database.query(
      "fechas_destacadas",
      orderBy: "fechaInicio ASC",
    );
  }

  // ====================================================
  // FUNCIÓN: EVENTOS RELACIONADOS (ACTIVIDADES)
  // ====================================================
  Future<List<Map<String, dynamic>>> obtenerEventosPorHito(int hitoId) async {
    final database = await db;
    // Consulta los eventos en la nueva tabla 'eventos_relacionados' filtrando por hitoId
    return await database.query(
      "eventos_relacionados",
      where: "hitoId = ?",
      whereArgs: [hitoId],
      orderBy: "fechaHoraInicio ASC", // Ordena por hora para la agenda
    );
  }

  // Obtiene un lugar por su ID
// Obtiene un lugar por su ID
Future<Map<String, dynamic>?> obtenerLugarPorId(int id) async {
  final database = await db;  // ✅ usamos el getter `db`

  final res = await database.query(
    'lugares',          // tu tabla de lugares
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );

  if (res.isNotEmpty) {
    return res.first;
  }
  return null;
}

Future<Map<String, dynamic>?> obtenerRestaurantePorId(int id) async {
  final database = await db;
  final res = await database.query(
    'restaurantes', // 👈 nombre de tu tabla de restaurantes
    where: 'id = ?',
    whereArgs: [id],
  );
  if (res.isNotEmpty) return res.first;
  return null;
}

Future<Map<String, dynamic>?> obtenerBarPorId(int id) async {
  final database = await db;
  final res = await database.query(
    'bares', // 👈 nombre de tu tabla de bares
    where: 'id = ?',
    whereArgs: [id],
  );
  if (res.isNotEmpty) return res.first;
  return null;
}

}