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
      version: 36, // <<<<< NUEVA VERSION
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
        password TEXT NOT NULL
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
        lugarId INTEGER NOT NULL
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

    await _insertarDatosIniciales(db);
  }

  // ====================================================
  //                    UPGRADE
  // ====================================================
  Future _onUpgrade(Database db, int oldV, int newV) async {
    await db.execute("DROP TABLE IF EXISTS comentarios");
    await db.execute("DROP TABLE IF EXISTS favoritos");
    await db.execute("DROP TABLE IF EXISTS bares");
    await db.execute("DROP TABLE IF EXISTS restaurantes");
    await db.execute("DROP TABLE IF EXISTS lugares");
    await db.execute("DROP TABLE IF EXISTS usuarios");

    await _onCreate(db, newV);
  }

  // ====================================================
  //               DATOS INICIALES
  // ====================================================
  Future _insertarDatosIniciales(Database db) async {
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
  // ==================== RESTAURANTES ====================

// ==================== CAROS ====================

await db.insert("restaurantes", {
  "nombre": "La Taverne",
  "descripcion": "Restaurante gourmet de alta cocina francesa, ubicado en la zona central.",
  "direccion": "Calle Grau 680, Sucre",
  "precio": "alto",
  "imagenAsset": "assets/restaurantes/la_taverne.jpg",
  "rating": 4.8,
  "imagenes": jsonEncode([
    "assets/restaurantes/la_taverne1.jpg",
    "assets/restaurantes/la_taverne2.jpg",
    "assets/restaurantes/la_taverne3.jpg",
    "assets/restaurantes/la_taverne4.jpg"
  ]),
  "horario": "12:00 - 23:00",
  "latitud": -19.048627,
  "longitud": -65.261964
});

await db.insert("restaurantes", {
  "nombre": "El Huerto",
  "descripcion": "Comida internacional con un ambiente elegante y jardines amplios.",
  "direccion": "Av. Hernando Siles 50",
  "precio": "alto",
  "imagenAsset": "assets/restaurantes/el_huerto.jpg",
  "rating": 4.7,
  "imagenes": jsonEncode([
    "assets/restaurantes/el_huerto1.jpg",
    "assets/restaurantes/el_huerto2.jpg",
    "assets/restaurantes/el_huerto3.jpg",
    "assets/restaurantes/el_huerto4.jpg"
  ]),
  "horario": "12:00 - 22:00",
  "latitud": -19.044821,
  "longitud": -65.255993
});

await db.insert("restaurantes", {
  "nombre": "La Posada del Sol",
  "descripcion": "Cocina tradicional y gourmet en una casona colonial restaurada.",
  "direccion": "Calle España 123",
  "precio": "alto",
  "imagenAsset": "assets/restaurantes/posada_sol.jpg",
  "rating": 4.6,
  "imagenes": jsonEncode([
    "assets/restaurantes/posada_sol1.jpg",
    "assets/restaurantes/posada_sol2.jpg",
    "assets/restaurantes/posada_sol3.jpg",
    "assets/restaurantes/posada_sol4.jpg"
  ]),
  "horario": "12:00 - 23:00",
  "latitud": -19.050512,
  "longitud": -65.259231
});

await db.insert("restaurantes", {
  "nombre": "GastroBar El Mercado",
  "descripcion": "Fusión gourmet con ingredientes frescos y carta de vinos premium.",
  "direccion": "Mercado Central, 2do nivel",
  "precio": "alto",
  "imagenAsset": "assets/restaurantes/gastrobar.jpg",
  "rating": 4.7,
  "imagenes": jsonEncode([
    "assets/restaurantes/gastrobar1.jpg",
    "assets/restaurantes/gastrobar2.jpg",
    "assets/restaurantes/gastrobar3.jpg",
    "assets/restaurantes/gastrobar4.jpg"
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
  "nombre": "Pollos Copacabana",
  "descripcion": "Pollo frito, hamburguesas y comida rápida económica.",
  "direccion": "Plaza 25 de Mayo",
  "precio": "bajo",
  "imagenAsset": "assets/restaurantes/copacabana.jpg",
  "rating": 4.2,
  "imagenes": jsonEncode([
    "assets/restaurantes/copacabana1.jpg",
    "assets/restaurantes/copacabana2.jpg",
    "assets/restaurantes/copacabana3.jpg",
    "assets/restaurantes/copacabana4.jpg"
  ]),
  "horario": "10:00 - 22:30",
  "latitud": -19.048001,
  "longitud": -65.259800
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
  "nombre": "Hamburguesas Tahuichi",
  "descripcion": "Hamburguesas populares y económicas.",
  "direccion": "Zona Universitaria",
  "precio": "bajo",
  "imagenAsset": "assets/restaurantes/tahuichi.jpg",
  "rating": 4.1,
  "imagenes": jsonEncode([
    "assets/restaurantes/tahuichi1.jpg",
    "assets/restaurantes/tahuichi2.jpg",
    "assets/restaurantes/tahuichi3.jpg",
    "assets/restaurantes/tahuichi4.jpg"
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
      SELECT c.id, c.texto, c.fecha, u.nombre AS usuarioNombre
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
      SELECT c.id, c.texto, c.fecha, u.nombre AS usuarioNombre
      FROM comentarios c
      LEFT JOIN usuarios u ON u.id = c.usuarioId
      WHERE c.restauranteId = ?
      ORDER BY datetime(c.fecha) DESC
    """, [restauranteId]);

    return res;
  }
}
