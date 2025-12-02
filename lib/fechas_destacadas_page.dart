import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db_service.dart'; // ajusta esta ruta si tu db_service está en otra carpeta

// --- MODELO 1: HitoDestacado (El tema o fecha importante) ---

class HitoDestacado { 
  final int id;
  final String titulo; // Título del HITO (ej. "Día de la Independencia")
  final String descripcion;
  final String icono;
  final String categoria;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool permanente;
  final String? imagenAsset;

  HitoDestacado({ 
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.categoria,
    required this.fechaInicio,
    this.fechaFin,
    required this.permanente,
    this.imagenAsset,
  });

  bool esHoy(DateTime hoy) {
    final inicio = _soloFecha(fechaInicio);
    final fin = fechaFin != null ? _soloFecha(fechaFin!) : inicio;
    final h = _soloFecha(hoy);
    return !h.isBefore(inicio) && !h.isAfter(fin);
  }

  static DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
}

// --- MODELO 2: EventoRelacionado (Definido aquí para que sea accesible para DetailPage) ---
// Aunque este modelo se usa más en DetalleFechaPage, se define aquí para evitar conflictos de importación circular.
class EventoRelacionado {
  final int id;
  final int hitoId;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final DateTime fechaHoraInicio;

  EventoRelacionado({
    required this.id,
    required this.hitoId,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.fechaHoraInicio,
  });
}


// --- PÁGINA PRINCIPAL: Listado de Hitos ---

class FechasDestacadasPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  const FechasDestacadasPage({super.key, this.usuario});

  @override
  State<FechasDestacadasPage> createState() => _FechasDestacadasPageState();
}

class _FechasDestacadasPageState extends State<FechasDestacadasPage> {
  // --- PALETA DE COLORES FINAL ---
  final Color primaryColor = const Color(0xFF00796B); // Teal oscuro (Acento)
  final Color cardBaseColor = Colors.white; // Fondo de tarjeta blanco
  final Color todayAccentColor = Colors.white; // Tarjeta 'Hoy' también blanca
  final Color secondaryColor = const Color(0xFF4DB6AC); // Teal más claro (Íconos)
  final Color textColorPrimary = Colors.black87; // Títulos en NEGRO (Máxima Legibilidad)
  final Color textColorSecondary = Colors.grey[700]!; // Texto secundario en gris oscuro

  bool _cargando = true;
  String? _error;
  List<HitoDestacado> _hitosHoy = []; 
  Map<String, List<HitoDestacado>> _hitosPorCategoria = {}; 

  @override
  void initState() {
    super.initState();
    _cargarHitos();
  }

  // Lógica de Carga de Hitos
  Future<void> _cargarHitos() async {
    try {
      final rows = await DBService.instance.obtenerFechasDestacadas();
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      final todos = rows.map((row) {
        final String? fiStr = row['fechaInicio'] as String?;
        final String? ffStr = row['fechaFin'] as String?;

        final fi = fiStr != null ? DateTime.parse(fiStr) : DateTime.now();
        final ff = (ffStr != null && ffStr.isNotEmpty)
            ? DateTime.parse(ffStr)
            : null;

        return HitoDestacado( 
          id: row['id'] as int,
          titulo: row['titulo'] as String? ?? '',
          descripcion: row['descripcion'] as String? ?? '',
          icono: row['icono'] as String? ?? '📍',
          categoria: row['categoria'] as String? ?? 'Otros',
          fechaInicio: fi,
          fechaFin: ff,
          permanente: (row['permanente'] as int? ?? 0) == 1,
          imagenAsset: row['imagenAsset'] as String?,
        );
      }).toList();

      List<HitoDestacado> vigentes = [];
      for (final e in todos) {
        final ultimoDia = e.fechaFin ?? e.fechaInicio;
        final u = DateTime(ultimoDia.year, ultimoDia.month, ultimoDia.day);
        if (!e.permanente && u.isBefore(hoy)) {
          continue;
        }
        vigentes.add(e);
      }

      final hoyList = vigentes.where((e) => e.esHoy(hoy)).toList();

      Map<String, List<HitoDestacado>> porCategoria = {}; 
      for (final e in vigentes) {
        final cat = e.categoria;
        porCategoria.putIfAbsent(cat, () => []);
        porCategoria[cat]!.add(e);
      }

      final categoriasOrdenadas = Map.fromEntries(
        porCategoria.entries.toList()
          ..sort((e1, e2) => e1.key.compareTo(e2.key)),
      );

      setState(() {
        _hitosHoy = hoyList; 
        _hitosPorCategoria = categoriasOrdenadas; 
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _error = 'Error al cargar hitos: $e';
      });
    }
  }

  // --- MÉTODOS DE FORMATO DE FECHA (Sin cambios) ---
  String _formatFechaHoy() {
    final now = DateTime.now();
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final diaSemana = dias[now.weekday - 1];
    final mes = meses[now.month];
    return '$diaSemana, ${now.day} de ${_capitalizar(mes)} de ${now.year}';
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  String _formatearRango(HitoDestacado e) {
    final fi = e.fechaInicio;
    final ff = e.fechaFin;
    String inicio = '${fi.day}/${fi.month}/${fi.year}';
    if (ff == null || fi.isAtSameMomentAs(ff)) return inicio;
    String fin = '${ff.day}/${ff.month}/${ff.year}';
    return '$inicio - $fin';
  }

  // --- WIDGETS DE CONSTRUCCIÓN ---

  @override
  Widget build(BuildContext context) {
    final fechaHoyTexto = _formatFechaHoy();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fechas Destacadas',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColorPrimary, // Negro
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      backgroundColor: Colors.grey[50],
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(fechaHoyTexto),
                        const SizedBox(height: 25),

                        // Sección HOY
                        if (_hitosHoy.isNotEmpty) ...[
                          _buildSectionTitle('🌟 Hitos de Hoy'),
                          const SizedBox(height: 15),
                          _buildEventListHorizontal(
                            context,
                            _hitosHoy,
                            isTodaySection: true,
                          ),
                          const SizedBox(height: 30),
                        ],

                        // Secciones por categoría
                        ..._hitosPorCategoria.entries.map((entry) {
                          final categoria = entry.key;
                          final hitos = entry.value;

                          // Filtramos para evitar duplicados con "Hitos de Hoy"
                          final hitosRestantes = hitos
                              .where((e) => !_hitosHoy.contains(e))
                              .toList();

                          if (hitosRestantes.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('📅 ${categoria}'),
                                const SizedBox(height: 15),
                                _buildEventListHorizontal(
                                  context,
                                  hitosRestantes, 
                                  isTodaySection: false,
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        if (_hitosHoy.isEmpty && _hitosPorCategoria.isEmpty)
                          _buildNoEventsMessage(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColorPrimary, // Negro
          ),
        ),
        const Divider(
          height: 10,
          thickness: 1,
          color: Color(0xFFF0F0F0),
        ),
      ],
    );
  }

  Widget _buildNoEventsMessage() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Text('🎉', style: TextStyle(fontSize: 60)),
          Text(
            '¡No hay hitos o fechas importantes vigentes por ahora!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: textColorSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoy es:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColorSecondary,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColorPrimary, // Negro
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.calendar_month,
            size: 30,
            color: secondaryColor,
          )
        ],
      ),
    );
  }

  // --- LISTA HORIZONTAL DE HITOS ---
  Widget _buildEventListHorizontal(
    BuildContext context,
    List<HitoDestacado> hitos, { 
    required bool isTodaySection,
  }) {
    final double cardHeight = isTodaySection ? 250 : 230; 
    
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hitos.length,
        itemBuilder: (context, index) {
          final hito = hitos[index]; 
          return Container(
            width: isTodaySection ? 280 : 260, 
            margin: const EdgeInsets.only(right: 18),
            child: GestureDetector(
              onTap: () {
                // Navegación a la página de detalle de la fecha (que ahora muestra eventos)
                Navigator.pushNamed(
                  context,
                  // Usamos /detalleFecha, la ruta que ya existe en main.dart
                  "/detalleFecha", 
                  arguments: hito, // Pasamos el HitoDestacado
                );
              },
              child: _HitoDestacadoCard( 
                titulo: hito.titulo,
                fecha: _formatearRango(hito),
                descripcion: hito.descripcion,
                icono: hito.icono,
                isToday: isTodaySection,
                cardBaseColor: cardBaseColor,
                todayAccentColor: todayAccentColor,
                primaryColor: primaryColor,
                imagenAsset: hito.imagenAsset,
                textColorPrimary: textColorPrimary, 
                textColorSecondary: textColorSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- TARJETA DE HITO ---
class _HitoDestacadoCard extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String descripcion;
  final String icono;
  final bool isToday;
  final String? imagenAsset;

  final Color cardBaseColor;
  final Color todayAccentColor;
  final Color primaryColor;
  final Color textColorPrimary;
  final Color textColorSecondary;

  const _HitoDestacadoCard({
    required this.titulo,
    required this.fecha,
    required this.descripcion,
    required this.icono,
    this.isToday = false,
    this.imagenAsset,
    required this.cardBaseColor,
    required this.todayAccentColor,
    required this.primaryColor,
    required this.textColorPrimary,
    required this.textColorSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = Colors.white;
    final Color currentTitleColor = textColorPrimary;
    final Color currentDateColor = textColorSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isToday ? 0.15 : 0.06),
            blurRadius: isToday ? 18 : 10,
            offset: Offset(0, isToday ? 8 : 4),
          ),
        ],
        border: isToday
            ? Border.all(
                color: primaryColor,
                width: 2.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagenAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagenAsset!,
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                icono,
                style: TextStyle(
                  fontSize: isToday ? 48 : 40,
                ),
              ),
            ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: isToday ? 19 : 18,
                    color: currentTitleColor,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isToday)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '¡HOY!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Text(
            fecha,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: currentDateColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Text(
              descripcion,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: textColorSecondary,
              ),
              maxLines: isToday ? 3 : 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isToday
                  ? primaryColor.withOpacity(0.8)
                  : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
