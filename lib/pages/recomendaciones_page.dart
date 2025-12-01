import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../db_service.dart';
import '../detalle_lugar_page.dart';
import '../services/itinerario_ai_service.dart';

class ActividadPlan {
  final String horario;
  final String descripcion;
  final int? lugarId; // Enlaza con la tabla de lugares

  ActividadPlan({
    required this.horario,
    required this.descripcion,
    this.lugarId,
  });
}

class RecomendacionesPage extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const RecomendacionesPage({super.key, this.usuario});

  @override
  State<RecomendacionesPage> createState() => _RecomendacionesPageState();
}

class _RecomendacionesPageState extends State<RecomendacionesPage> {
  final TextEditingController _diasCtrl = TextEditingController();

  DateTime? _fechaInicio;

  // Preferencias
  List<String> _preferenciasSeleccionadas = [];
  final List<String> _opcionesPreferencia = [
    'Histórico',
    'Cultural',
    'Gastronomía',
    'Naturaleza',
  ];

  // Itinerario: Día -> Lista de actividades
  Map<String, List<ActividadPlan>> _itinerario = {};

  @override
  void dispose() {
    _diasCtrl.dispose();
    super.dispose();
  }

  // ================== LÓGICA PRINCIPAL ==================
 Future<void> _obtenerRecomendaciones() async {
  FocusScope.of(context).unfocus();

  final String textDias = _diasCtrl.text.trim();
  final int dias = int.tryParse(textDias) ?? 0;

  if (_fechaInicio == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Por favor, selecciona la fecha de inicio del viaje.",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.orange,
      ),
    );
    setState(() => _itinerario = {});
    return;
  }

  if (dias <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Ingresa un número de días válido (mayor a cero).",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
    setState(() => _itinerario = {});
    return;
  }

  setState(() {
    _itinerario = {};
  });

  try {
    final respuestaIA =
        await ItinerarioAIService.instance.generarItinerarioConIA(
      fechaInicio: _fechaInicio!,
      dias: dias,
      preferencias: _preferenciasSeleccionadas,
      usuario: widget.usuario,
    );

    final Map<String, List<ActividadPlan>> nuevoItinerario = {};

    final List diasIA = respuestaIA['dias'] ?? [];
    for (final dia in diasIA) {
      final String nombreDia = dia['nombre_dia'] ?? 'Día sin nombre';
      final List acts = dia['actividades'] ?? [];
      final actividadesConvertidas = <ActividadPlan>[];

      for (final act in acts) {
        actividadesConvertidas.add(
          ActividadPlan(
            horario: act['hora_label'] ?? '',
            descripcion: act['descripcion'] ?? '',
            lugarId: _extraerLugarIdDesdeReferencia(act['referencia']),
          ),
        );
      }

      nuevoItinerario[nombreDia] = actividadesConvertidas;
    }

    setState(() {
      _itinerario = nuevoItinerario;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "No se pudo generar el itinerario con IA: $e",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Itinerario Personalizado',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Preferencias
            Text(
              '1. Selecciona tus intereses principales:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildPreferenceChips(),
            const SizedBox(height: 20),

            // 2. Fecha
            Text(
              '2. ¿Cuándo inicias tu viaje?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildDatePicker(),
            const SizedBox(height: 20),

            // 3. Días
            Text(
              '3. Ingresa la duración de tu estadía:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _construirCampoDias(),
            const SizedBox(height: 20),

            // Botón
            _construirBotonRecomendaciones(),
            const SizedBox(height: 30),

            // Resultado
            if (_itinerario.isNotEmpty)
              Text(
                '4. Tu Plan de Viaje por Día:',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (_itinerario.isNotEmpty) const SizedBox(height: 10),

            _construirItinerario(),
          ],
        ),
      ),
    );
  }

  // ---------- Preferencias ----------
  Widget _buildPreferenceChips() {
    return Wrap(
      spacing: 8.0,
      children: _opcionesPreferencia.map((preferencia) {
        final isSelected = _preferenciasSeleccionadas.contains(preferencia);
        return ChoiceChip(
          label: Text(
            preferencia,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          selected: isSelected,
          selectedColor: const Color(0xFFD0C2FF).withOpacity(0.8),
          backgroundColor: Colors.grey[200],
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (_preferenciasSeleccionadas.length < 3 &&
                    !_preferenciasSeleccionadas.contains(preferencia)) {
                  _preferenciasSeleccionadas.add(preferencia);
                }
              } else {
                _preferenciasSeleccionadas.remove(preferencia);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // ---------- DatePicker ----------
  Widget _buildDatePicker() {
    String fechaDisplay = _fechaInicio == null
        ? 'Toca para seleccionar la fecha'
        : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}';

    return GestureDetector(
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime? fechaSeleccionada = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: now,
          lastDate: DateTime(now.year + 2),
          helpText: 'Selecciona la fecha de inicio del viaje',
          cancelText: 'Cancelar',
          confirmText: 'Aceptar',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFD0C2FF),
                  onPrimary: Colors.black,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFFD0C2FF),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (fechaSeleccionada != null) {
          setState(() {
            _fechaInicio = fechaSeleccionada;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '📅 Fecha de Inicio: $fechaDisplay',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: _fechaInicio == null ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }

  // ---------- Campo de días ----------
  Widget _construirCampoDias() {
    return TextField(
      controller: _diasCtrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Ej: 3',
        labelText: 'Días de estadía',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  // ---------- Botón ----------
  Widget _construirBotonRecomendaciones() {
    return GestureDetector(
      onTap: () async {
      await _obtenerRecomendaciones();
    },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFEADCCF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Generar Itinerario',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Itinerario ----------
  Widget _construirItinerario() {
    if (_itinerario.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Selecciona la fecha, días y preferencias para generar tu plan de viaje.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _itinerario.entries.map((entryDia) {
        final nombreDia = entryDia.key;
        final actividades = entryDia.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0C2FF).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '📅 $nombreDia',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTimelineForDay(actividades),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------- Timeline ----------
  Widget _buildTimelineForDay(List<ActividadPlan> activitiesList) {
    return Column(
      children: activitiesList.asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final actividad = mapEntry.value;

        final horario = actividad.horario;
        final descripcion = actividad.descripcion;

        IconData icon;
        Color iconColor;
        final bool isFeaturedEvent =
            descripcion.contains('¡Evento!') ||
            descripcion.contains('Actividad Central');

        if (horario.toLowerCase().contains('mañana')) {
          icon = Icons.wb_sunny_rounded;
          iconColor = Colors.orangeAccent;
        } else if (horario.toLowerCase().contains('almuerzo') ||
            horario.toLowerCase().contains('cena')) {
          icon = Icons.restaurant_menu_rounded;
          iconColor = Colors.green;
        } else if (horario.toLowerCase().contains('tarde')) {
          icon = Icons.landscape_rounded;
          iconColor = Colors.blueAccent;
        } else {
          icon = Icons.bedtime_rounded;
          iconColor = Colors.indigo;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // marcador timeline
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFeaturedEvent
                          ? Colors.redAccent
                          : iconColor.withOpacity(0.8),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFeaturedEvent ? Icons.star_border_rounded : icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (index < activitiesList.length - 1)
                    Expanded(
                      child: Container(
                        width: 3,
                        color: Colors.grey[300],
                      ),
                    ),
                  if (index == activitiesList.length - 1)
                    const SizedBox(height: 20),
                ],
              ),
              const SizedBox(width: 15),

              Expanded(
                child: Card(
                  elevation: isFeaturedEvent ? 8 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color:
                      isFeaturedEvent ? const Color(0xFFFFFBE8) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          horario,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: isFeaturedEvent
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isFeaturedEvent
                                ? Colors.red[800]
                                : Colors.black87,
                          ),
                        ),
                        if (actividad.lugarId != null)
                          _buildLugarPreview(actividad.lugarId!),
                        if (isFeaturedEvent)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              '¡Evento de Fechas Destacadas!',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.redAccent,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------- Preview de lugar + navegación a DetalleLugarPage ----------
  Widget _buildLugarPreview(int lugarId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DBService.instance.obtenerLugarPorId(lugarId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final lugar = snapshot.data!;
        List imagenes = [];
        try {
          if (lugar['imagenes'] != null) {
            imagenes = jsonDecode(lugar['imagenes']);
          }
        } catch (_) {}

        final String? firstImage =
            imagenes.isNotEmpty ? imagenes[0]?.toString() : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetalleLugarPage(
                  lugar: lugar,
                  usuario: widget.usuario,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                if (firstImage != null && firstImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      firstImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 30),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.place,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lugar['nombre'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lugar['descripcion'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ver detalles',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.deepPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
int? _extraerLugarIdDesdeReferencia(dynamic ref) {
  if (ref == null) return null;

  // La IA devuelve algo como:
  // { "tabla": "lugares", "id": 4 }
  try {
    final tabla = ref['tabla'] as String?;
    final id = ref['id'];

    if (tabla == 'lugares' && id is int) {
      return id;
    }
  } catch (_) {}

  return null;
}
