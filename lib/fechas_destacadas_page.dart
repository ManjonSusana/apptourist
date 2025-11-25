import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FechasDestacadasPage extends StatelessWidget {
  final Map<String, dynamic>? usuario; 
  final Color baseCardColor = const Color(0xFFD0C2FF); // Morado base

  const FechasDestacadasPage({super.key, this.usuario});

  // --- DATOS SIMULADOS POR CATEGORÍA, ORDENADOS CRONOLÓGICAMENTE ---
  final Map<String, List<Map<String, dynamic>>> _eventosPorCategoria = const {
    // HOY: 25 de Noviembre (El evento más importante del día)
    'HOY: 25 de Noviembre': [
      {
        'titulo': '¡HOY! Día Internacional contra la Violencia a la Mujer',
        'fecha': '25 de Noviembre',
        'descripcion': 'Actividades de concientización y marchas pacíficas en la Plaza 25 de Mayo.',
        'icono': '🎗️',
        'isToday': true, 
      },
    ],
    // Eventos futuros inmediatos (ordenados por fecha próxima)
    'Musical y Danza': [
      {
        'titulo': 'Festival de Danzas Folklóricas',
        'fecha': '28 de Noviembre', // Ocurre primero
        'descripcion': 'Muestra de danzas típicas de Chuquisaca y otras regiones de Bolivia.',
        'icono': '💃',
        'isToday': false,
      },
      {
        'titulo': 'Concierto de Temporada de Música Clásica',
        'fecha': '1 de Diciembre', // Ocurre después
        'descripcion': 'Presentación especial en el Teatro Gran Mariscal Sucre. Venta de entradas limitada.',
        'icono': '🎻',
        'isToday': false,
      },
    ],
    'Patrimonio y Tradición': [
      {
        'titulo': 'Procesión de la Virgen',
        'fecha': '8 de Diciembre', // Ocurre primero en esta categoría
        'descripcion': 'Acto religioso por la Inmaculada Concepción en la Catedral Metropolitana.',
        'icono': '🙏',
        'isToday': false,
      },
      {
        'titulo': 'Noche de Museos Abiertos',
        'fecha': '15 de Diciembre', // Ocurre después
        'descripcion': 'Acceso gratuito a varios museos y centros culturales en horario nocturno.',
        'icono': '🏛️',
        'isToday': false,
      },
    ],
    'Ferias, Mercados y Comercio': [
      {
        'titulo': 'Feria Navideña de Artesanías',
        'fecha': '5 al 24 de Diciembre', // Ocurre primero
        'descripcion': 'Mercado de regalos y artesanías hechos a mano en el Parque Bolívar. Ideal para compras.',
        'icono': '🛍️', 
        'isToday': false,
      },
      {
        'titulo': 'Mercado Central Gastronómico',
        'fecha': 'Todo el año', // Ocurre constantemente
        'descripcion': 'Prueba los sabores típicos de Sucre, desde el ají de fideos hasta el salteño.',
        'icono': '🍲',
        'isToday': false,
      },
      {
        'titulo': 'Feria de Alasitas (Previsión)',
        'fecha': 'Enero 2026', // Ocurre último
        'descripcion': 'Muestra de miniaturas y deseos de la suerte, una tradición boliviana fundamental.',
        'icono': '🎉',
        'isToday': false,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fechas Destacadas',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black87), 
      ),
      backgroundColor: Colors.white,
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- ENCABEZADO DE FECHA ACTUAL ----------------
              _buildDateHeader('Martes, 25 de Noviembre de 2025'),
              const SizedBox(height: 20),

              // ---------------- LISTADO DE EVENTOS POR CATEGORÍA ----------------
              _buildCategorizedEvents(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA MOSTRAR LA FECHA DE HOY (Igual que antes) ---
  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFC7F3D0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC7F3D0), width: 2),
      ),
      child: Text(
        '🗓️ Hoy es: $date',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // --- WIDGET PRINCIPAL QUE CONSTRUYE LAS SECCIONES Y EL SCROLL HORIZONTAL (Igual que antes) ---
  Widget _buildCategorizedEvents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _eventosPorCategoria.entries.map((entry) {
        String categoria = entry.key;
        List<Map<String, dynamic>> eventos = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la Categoría
              Text(
                categoria,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Divider(height: 10, thickness: 1, color: Color(0xFFD0C2FF)),
              const SizedBox(height: 10),

              // Contenedor para el Desplazamiento Horizontal
              _buildEventListHorizontal(context, eventos),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- WIDGET: LISTA DE EVENTOS CON DESPLAZAMIENTO HORIZONTAL (Igual que antes) ---
  Widget _buildEventListHorizontal(BuildContext context, List<Map<String, dynamic>> eventos) {
    return SizedBox(
      height: 200, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal, 
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return Container(
            width: 300, 
            margin: EdgeInsets.only(right: 15), 
            child: _FechaDestacadaCard(
              titulo: evento['titulo'] as String,
              fecha: evento['fecha'] as String,
              descripcion: evento['descripcion'] as String,
              icono: evento['icono'] as String,
              isToday: evento['isToday'] as bool,
              color: baseCardColor,
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET DE LA TARJETA (MANTENIDO) ---
class _FechaDestacadaCard extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String descripcion;
  final String icono;
  final Color color;
  final bool isToday;

  const _FechaDestacadaCard({
    required this.titulo,
    required this.fecha,
    required this.descripcion,
    required this.icono,
    required this.color,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveColor = isToday ? const Color(0xFFFFC8C8) : color.withOpacity(0.7);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor, 
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isToday ? 0.3 : 0.18), 
            blurRadius: isToday ? 10 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isToday 
            ? Border.all(color: const Color(0xFFD0C2FF), width: 3)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icono,
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(width: 15),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: isToday ? Colors.red[800] : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                
                Text(
                  fecha,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  descripcion,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
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