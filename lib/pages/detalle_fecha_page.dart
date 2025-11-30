import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fechas_destacadas_page.dart'; // para usar EventoDestacado

class DetalleFechaPage extends StatelessWidget {
  final EventoDestacado evento;

  const DetalleFechaPage({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    // Aquí podrías en el futuro cargar de otra tabla "subeventos" de esta fecha.
    // Por ahora, simulamos algunas actividades relacionadas.
    final List<Map<String, String>> actividadesEjemplo = [
      {
        'titulo': 'Desfile cívico',
        'lugar': 'Plaza 25 de Mayo',
        'hora': '09:00',
      },
      {
        'titulo': 'Serenata y concierto',
        'lugar': 'Teatro Gran Mariscal',
        'hora': '19:30',
      },
      {
        'titulo': 'Feria cultural',
        'lugar': 'Parque Bolívar',
        'hora': 'Todo el día',
      },
    ];

    final fi = evento.fechaInicio;
    final ff = evento.fechaFin ?? evento.fechaInicio;

    final String rangoFecha = (fi.year == ff.year &&
            fi.month == ff.month &&
            fi.day == ff.day)
        ? '${fi.day}/${fi.month}/${fi.year}'
        : '${fi.day}/${fi.month}/${fi.year} - ${ff.day}/${ff.month}/${ff.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          evento.titulo,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (evento.imagenAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                evento.imagenAsset!,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
          const SizedBox(height: 16),

          Text(
            evento.icono,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),

          Text(
            evento.titulo,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            rangoFecha,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            evento.descripcion,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          const SizedBox(height: 20),

          Text(
            'Actividades relacionadas',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          ...actividadesEjemplo.map((act) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                title: Text(
                  act['titulo']!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${act['lugar']} · ${act['hora']}',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
