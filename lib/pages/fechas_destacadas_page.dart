import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importación asumida, ajusta esta ruta si tu db_service está en otra carpeta
import '../db_service.dart';

// --- MODELO (Sin cambios sustanciales) ---

class EventoDestacado {
  final int id;
  final String titulo;
  final String descripcion;
  final String icono;
  final String categoria;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool permanente;
  final String? imagenAsset;

  EventoDestacado({
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

// --- PÁGINA PRINCIPAL (UI Mejorada con texto negro y corrección de layout) ---

class FechasDestacadasPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  const FechasDestacadasPage({super.key, this.usuario});

  @override
  State<FechasDestacadasPage> createState() => _FechasDestacadasPageState();
}

class _FechasDestacadasPageState extends State<FechasDestacadasPage> {
  // --- PALETA DE COLORES (Final con texto en negro) ---
  final Color primaryColor = const Color(0xFF00796B); // Teal oscuro
  final Color cardBaseColor = Colors.white; // Fondo de tarjeta blanco
  final Color todayAccentColor = Colors.white; // La tarjeta "Hoy" se destaca con borde y sombra
  final Color secondaryColor = const Color(0xFF4DB6AC); // Teal más claro
  final Color textColorPrimary = Colors.black87; // Títulos principales en NEGRO
  final Color textColorSecondary = Colors.grey[700]!; // Descripciones y fechas en gris oscuro

  bool _cargando = true;
  String? _error;
  List<EventoDestacado> _hoy = [];
  Map<String, List<EventoDestacado>> _porCategoria = {};

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    try {
      final rows = await DBService.instance.obtenerFechasDestacadas();
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      final todos = rows.map((row) {
        final String? fiStr = row['fechaInicio'] as String?;
        // --- LÍNEA CORREGIDA ---
        final String? ffStr = row['fechaFin'] as String?;

        final fi = fiStr != null ? DateTime.parse(fiStr) : DateTime.now();
        final ff = (ffStr != null && ffStr.isNotEmpty)
            ? DateTime.parse(ffStr)
            : null;

        return EventoDestacado(
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

      List<EventoDestacado> vigentes = [];
      for (final e in todos) {
        final ultimoDia = e.fechaFin ?? e.fechaInicio;
        final u = DateTime(ultimoDia.year, ultimoDia.month, ultimoDia.day);
        if (!e.permanente && u.isBefore(hoy)) {
          continue;
        }
        vigentes.add(e);
      }

      final hoyList = vigentes.where((e) => e.esHoy(hoy)).toList();

      final Map<String, List<EventoDestacado>> porCategoria = {};
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
        _hoy = hoyList;
        _porCategoria = categoriasOrdenadas;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _error = 'Error al cargar eventos: $e';
      });
    }
  }

  String _formatFechaHoy() {
    final now = DateTime.now();
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final diaSemana = dias[now.weekday - 1];
    final mes = meses[now.month];
    return '$diaSemana, ${now.day} de ${_capitalizar(mes)} de ${now.year}';
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  String _formatearRango(EventoDestacado e) {
    final fi = e.fechaInicio;
    final ff = e.fechaFin;
    String inicio = '${fi.day}/${fi.month}/${fi.year}';
    if (ff == null || fi.isAtSameMomentAs(ff)) return inicio;
    String fin = '${ff.day}/${ff.month}/${ff.year}';
    return '$inicio - $fin';
  }

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
            color: textColorPrimary, // Título del App Bar en NEGRO
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

                        if (_hoy.isNotEmpty) ...[
                          _buildSectionTitle('🌟 Eventos de Hoy'),
                          const SizedBox(height: 15),
                          _buildEventListHorizontal(
                            context,
                            _hoy,
                            isTodaySection: true,
                          ),
                          const SizedBox(height: 30),
                        ],

                        ..._porCategoria.entries.map((entry) {
                          final categoria = entry.key;
                          final eventos = entry.value;

                          final eventosRestantes = eventos
                              .where((e) => !_hoy.contains(e))
                              .toList();

                          if (eventosRestantes.isEmpty) {
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
                                  eventosRestantes, 
                                  isTodaySection: false,
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        if (_hoy.isEmpty && _porCategoria.isEmpty)
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
            color: textColorPrimary, // Títulos de sección en NEGRO
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
          const Text(
            '🎉',
            style: TextStyle(fontSize: 60),
          ),
          Text(
            '¡No hay eventos vigentes o fechas destacadas por ahora!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: textColorSecondary, // Texto en gris oscuro
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
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 20,
      ),
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
                    color: textColorSecondary, // Texto en gris oscuro
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColorPrimary, // Fecha en NEGRO
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

  Widget _buildEventListHorizontal(
    BuildContext context,
    List<EventoDestacado> eventos, {
    required bool isTodaySection,
  }) {
    // Altura de la tarjeta ajustada para dar más espacio a la descripción (250 / 230)
    final double cardHeight = isTodaySection ? 250 : 230; 
    
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return Container(
            width: isTodaySection ? 280 : 260, 
            margin: const EdgeInsets.only(right: 18),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detalleFecha',
                  arguments: evento, 
                );
              },
              child: _FechaDestacadaCard(
                titulo: evento.titulo,
                fecha: _formatearRango(evento),
                descripcion: evento.descripcion,
                icono: evento.icono,
                isToday: isTodaySection,
                cardBaseColor: cardBaseColor,
                todayAccentColor: todayAccentColor,
                primaryColor: primaryColor,
                imagenAsset: evento.imagenAsset,
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

// --- TARJETA DE EVENTO (con ajustes de imagen y colores) ---
class _FechaDestacadaCard extends StatelessWidget {
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


  const _FechaDestacadaCard({
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
    final Color currentTitleColor = textColorPrimary; // Título en NEGRO
    final Color currentDateColor = textColorSecondary; // Fecha en gris oscuro

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
                    color: currentTitleColor, // Título en NEGRO
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              color: currentDateColor, // Fecha en gris oscuro
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Descripción (con más líneas para evitar el corte)
          Expanded(
            child: Text(
              descripcion,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: textColorSecondary, // Descripción en gris oscuro
              ),
              maxLines: isToday ? 3 : 4, // Aumentado para asegurar que no se corte
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isToday ? primaryColor.withOpacity(0.8) : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}