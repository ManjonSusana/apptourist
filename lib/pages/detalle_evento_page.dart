import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Necesario para abrir Google Maps
import 'package:geolocator/geolocator.dart';


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
    // Función para abrir Google Maps con "cómo llegar" desde la ubicación actual
  Future<void> _openMap(BuildContext context) async {
    try {
      // 1. Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permisos de ubicación denegados")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Permisos de ubicación denegados permanentemente"),
          ),
        );
        return;
      }

      // 2. Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Armar destino usando los datos del evento
      final nombre = evento.titulo;
      final ubicacion = evento.ubicacion; // Ej: "Plaza 25 de Mayo"
      final destino = Uri.encodeComponent(
        "$nombre, $ubicacion, Sucre Bolivia",
      );

      // 4. URL con direcciones desde ubicación actual hasta el destino
      final uri = Uri.parse(
        "https://www.google.com/maps/dir/?api=1"
        "&origin=${position.latitude},${position.longitude}"
        "&destination=$destino"
        "&travelmode=driving",
      );

      // 5. Abrir Google Maps
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al abrir el mapa: $e")),
      );
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
                  _buildLocationSection(context),
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
  Widget _buildLocationSection(BuildContext context) {
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
            onPressed: () => _openMap(context),
            icon: const Icon(Icons.map, size: 20),
            label: Text(
              'Ver en Google Maps',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }

}