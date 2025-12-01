import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Necesario para abrir Google Maps

// Importamos los modelos HitoDestacado y EventoRelacionado desde la fuente
import 'fechas_destacadas_page.dart'; 

class DetalleEventoPage extends StatelessWidget {
  final EventoRelacionado evento;
  final HitoDestacado? hitoPadre; // Para mostrar la imagen del hito

  const DetalleEventoPage({
    super.key,
    required this.evento,
    this.hitoPadre,
  });

  // Paleta coherente
  final Color primaryColor = const Color(0xFF00796B);
  final Color textColorPrimary = Colors.black87;
  final Color textColorSecondary = const Color(0xFF4DB6AC);

  // Auxiliar para formatear la fecha y hora
  String _formatDateTime(DateTime d) {
    const dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final diaSemana = dias[d.weekday % 7];
    final mes = meses[d.month - 1];
    final hora = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} hrs';
    return '$diaSemana, ${d.day} de $mes, $hora';
  }

  // Función para abrir Google Maps
  void _openMap(String locationQuery) async {
    // Intenta abrir Google Maps con el query de ubicación
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationQuery)}'
    );
    
    // Verifica si la URL puede ser lanzada
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Manejo de error (usar un Snackbar o AlertDialog en producción)
      print('ERROR: No se pudo abrir el mapa para $locationQuery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          evento.titulo,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen del Hito Padre (para coherencia visual)
            _buildImageHeader(),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // 2. Información Clave (Fecha y Hora)
                  _buildInfoRow(
                    Icons.schedule,
                    'Fecha y Hora:',
                    _formatDateTime(evento.fechaHoraInicio),
                    Colors.deepOrange, // Color de acento para la hora
                  ),
                  const SizedBox(height: 15),

                  // 3. Ubicación y Botón de Mapa
                  _buildLocationSection(),
                  const SizedBox(height: 25),

                  // 4. Descripción
                  Text(
                    'Detalles del Evento',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const Divider(color: Color(0xFFF0F0F0)),
                  Text(
                    evento.descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.5,
                      color: textColorPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget para el encabezado de Imagen (Usa la imagen del Hito Padre)
  Widget _buildImageHeader() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: hitoPadre?.imagenAsset != null
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Image.asset(
                hitoPadre!.imagenAsset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 60, color: Colors.grey[600]),
          Text('Imagen del Hito Padre', style: GoogleFonts.poppins(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Widget para la fila de información
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColorSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColorPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget de Ubicación con botón de Mapa
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.place,
          'Ubicación:',
          evento.ubicacion,
          Colors.blue,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 39.0),
          child: ElevatedButton.icon(
            onPressed: () => _openMap(evento.ubicacion),
            icon: const Icon(Icons.map, size: 20),
            label: Text(
              'Ver en Google Maps',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }
}