import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importamos el DBService (asumimos que la ruta es correcta)
import '../../db_service.dart';

// ----------------------------------------------------------------------
// IMPORTAMOS HitoDestacado y EventoRelacionado desde el archivo de la página principal.
// NOTA: La definición de las clases HitoDestacado y EventoRelacionado se asume en este archivo.
import 'fechas_destacadas_page.dart'; 
// ----------------------------------------------------------------------

// Función para parsear el Map de la BD a un objeto de Dart
// Esta función es esencial para convertir los datos del DBService a objetos de Dart seguros.
EventoRelacionado _parseEventoRelacionado(Map<String, dynamic> row) {
  // Aseguramos el casteo y el parseo de la fecha/hora guardada como ISO8601 String
  return EventoRelacionado(
    id: row['id'] as int,
    hitoId: row['hitoId'] as int,
    titulo: row['titulo'] as String? ?? '',
    descripcion: row['descripcion'] as String? ?? '',
    ubicacion: row['ubicacion'] as String? ?? '',
    // Usamos DateTime.tryParse y fallback para mayor seguridad
    fechaHoraInicio: DateTime.tryParse(row['fechaHoraInicio'] as String? ?? '') ?? DateTime.now(), 
  );
}


// --- PÁGINA DE DETALLE (Ahora es el listado de Eventos) ---

class DetalleFechaPage extends StatefulWidget { 
  // CORRECCIÓN DE TIPO: Aceptamos HitoDestacado
  final HitoDestacado evento; 
  const DetalleFechaPage({super.key, required this.evento});

  @override
  State<DetalleFechaPage> createState() => _DetalleFechaPageState();
}

class _DetalleFechaPageState extends State<DetalleFechaPage> {
  // Paleta coherente con la página principal
  final Color primaryColor = const Color(0xFF00796B);
  final Color textColorPrimary = Colors.black87;
  final Color textColorSecondary = Colors.grey[700]!;

  late Future<List<EventoRelacionado>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    // Inicia la carga y parseo de eventos asociados al ID del Hito
    _eventosFuture = _cargarEventosDelHito(widget.evento.id);
  }

  // Lógica de carga y parseo de Eventos
  Future<List<EventoRelacionado>> _cargarEventosDelHito(int hitoId) async {
    // Usamos el DBService real para obtener los Mapas
    final rows = await DBService.instance.obtenerEventosPorHito(hitoId);
    // Mapeamos cada Map al objeto EventoRelacionado
    return rows.map(_parseEventoRelacionado).toList();
  }


  // Auxiliar para formatear la hora (ej: "19:00 hrs")
  String _formatHora(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} hrs';
  }
  
  // Auxiliar para formatear la fecha (ej: "Mié, 18 Nov")
  String _formatFechaCorta(DateTime d) {
    const dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${dias[d.weekday % 7]}, ${d.day} ${meses[d.month - 1]}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El título refleja el hito
        title: Text(
          'Eventos para ${widget.evento.titulo}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColorPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de información del Hito
          _buildHitoHeader(), 
          
          Expanded(
            child: FutureBuilder<List<EventoRelacionado>>(
              future: _eventosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                }
                
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error al cargar eventos: ${snapshot.error}', style: GoogleFonts.poppins(color: Colors.red)));
                }

                final eventos = snapshot.data ?? [];

                if (eventos.isEmpty) {
                  return _buildNoEventsMessage();
                }

                // --- MEJORA UX: Título de la Sección de Actividades ---
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      child: Text(
                        'Actividades Programadas (${eventos.length})', // Título explícito
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor, // Usar color primario para distinguirlo
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20), // Ajuste de padding
                        itemCount: eventos.length,
                        itemBuilder: (context, index) {
                          final evento = eventos[index];
                          
                          // Envuelve la tarjeta en un GestureDetector para la navegación
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/detalleEvento', // RUTA AL DETALLE ESPECÍFICO DEL EVENTO
                                arguments: {
                                  'evento': evento,
                                  'hitoPadre': widget.evento, // Pasamos el hito para la imagen de fondo
                                },
                              );
                            },
                            child: _EventoRelacionadoCard(
                              evento: evento,
                              primaryColor: primaryColor,
                              textColorPrimary: textColorPrimary,
                              textColorSecondary: textColorSecondary,
                              formatHora: _formatHora,
                              formatFechaCorta: _formatFechaCorta,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
                // ----------------------------------------------------
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el encabezado del Hito (Banner)
  Widget _buildHitoHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGEN DEL HITO 
          if (widget.evento.imagenAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.evento.imagenAsset!,
                width: double.infinity,
                height: 180, // Altura prominente para un banner
                fit: BoxFit.cover,
                // Fallback si la imagen no carga
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text('🖼️ Imagen no disponible', style: GoogleFonts.poppins(color: Colors.grey[600]))
                  ),
                ),
              ),
            ),
          const SizedBox(height: 15),

          // 2. TÍTULO Y DESCRIPCIÓN
          Text(
            widget.evento.titulo,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.evento.icono} ${widget.evento.categoria}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textColorSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.evento.descripcion,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textColorPrimary,
              fontWeight: FontWeight.w500
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚧', style: TextStyle(fontSize: 60)),
          Text(
            'No hay eventos específicos programados para este Hito por ahora.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: textColorSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- TARJETA DE EVENTO RELACIONADO (Lista Vertical) ---
class _EventoRelacionadoCard extends StatelessWidget {
  final EventoRelacionado evento;
  final Color primaryColor;
  final Color textColorPrimary;
  final Color textColorSecondary;
  final String Function(DateTime) formatHora;
  final String Function(DateTime) formatFechaCorta;

  const _EventoRelacionadoCard({
    required this.evento,
    required this.primaryColor,
    required this.textColorPrimary,
    required this.textColorSecondary,
    required this.formatHora,
    required this.formatFechaCorta,
  });

  @override
  Widget build(BuildContext context) {
    // La tarjeta no es un GestureDetector aquí, sino en el widget padre
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200), // Borde suave
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna de Fecha y Hora (El principal foco de la agenda)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  formatFechaCorta(evento.fechaHoraInicio),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatHora(evento.fechaHoraInicio),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColorPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),
          
          // Columna de Título y Ubicación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColorPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        evento.ubicacion,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: textColorSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  evento.descripcion,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textColorSecondary,
                  ),
                  maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}