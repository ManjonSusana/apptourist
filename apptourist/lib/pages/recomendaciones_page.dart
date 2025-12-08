import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../db_service.dart';
import '../detalle_lugar_page.dart';
// 👇 Ajusta estos nombres si tus páginas se llaman distinto
import '../detalle_restaurante_page.dart';
import '../detalle_bares_page.dart';

import '../services/itinerario_ai_service.dart';
import '../services/backend_api_service.dart';

class ActividadPlan {
  final String horario;
  final String descripcion;

  /// Tabla de referencia: 'lugares', 'restaurantes', 'bares'
  final String? tabla;

  /// ID dentro de la tabla referenciada
  final int? refId;

  ActividadPlan({
    required this.horario,
    required this.descripcion,
    this.tabla,
    this.refId,
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

  // Estado de carga
  bool _estaCargando = false;

  // Favoritos
  bool _esItinerarioFavorito = false;
  bool _cargandoFavorito = false;

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
      _estaCargando = true;
    });

    try {
      final respuestaIA = await ItinerarioAIService.instance
          .generarItinerarioConIA(
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
          final ref = _extraerReferenciaDesdeIA(act['referencia']);

          actividadesConvertidas.add(
            ActividadPlan(
              horario: act['hora_label'] ?? '',
              descripcion: act['descripcion'] ?? '',
              tabla: ref?.tabla,
              refId: ref?.id,
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
    } finally {
      if (mounted) {
        setState(() {
          _estaCargando = false;
        });
      }
    }
  }

  // ================== GUARDAR ITINERARIO EN FAVORITOS ==================
  Future<void> _toggleItinerarioFavorito() async {
    if (_itinerario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Por favor, genera un itinerario primero.",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _cargandoFavorito = true);

    try {
      // Convertir el mapa de itinerario a formato JSON
      final List<Map<String, dynamic>> dias = [];
      _itinerario.forEach((nombreDia, actividades) {
        dias.add({
          'nombre_dia': nombreDia,
          'actividades': actividades
              .map(
                (a) => {
                  'horario': a.horario,
                  'descripcion': a.descripcion,
                  'tabla': a.tabla,
                  'ref_id': a.refId,
                },
              )
              .toList(),
        });
      });

      final itinerarioData = {'dias': dias};

      // PASO 1: Guardar itinerario en BD
      final response = await BackendApiService.instance.guardarItinerario(
        itinerarioData: itinerarioData,
      );

      // Extraer el ID del itinerario guardado
      final itinerarioId = response['id'];
      if (itinerarioId == null) {
        throw Exception(
          'El servidor no devolvió un ID válido para el itinerario',
        );
      }

      // PASO 2: Agregar a favoritos
      await BackendApiService.instance.agregarItinerarioAFavoritos(
        itinerarioId: itinerarioId as int,
      );

      setState(() {
        _esItinerarioFavorito = true;
        _cargandoFavorito = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "¡Itinerario guardado en favoritos!",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _cargandoFavorito = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: $e", style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ================== VER ITINERARIOS GUARDADOS ==================
  Future<void> _verItinerariosGuardados() async {
    try {
      final itinerarios = await BackendApiService.instance
          .obtenerFavoritosPorTipo('Itinerario');

      if (!mounted) return;

      if (itinerarios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No tienes itinerarios guardados",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mostrar diálogo con la lista de itinerarios
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Mis Itinerarios Guardados',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: itinerarios.length,
              itemBuilder: (context, index) {
                final favorito = itinerarios[index];
                // El favorito contiene: { id, favoritable_type, favoritable_id, favoritable: { itinerario_data, ... } }
                final itinerario = favorito['favoritable'] ?? {};
                final itinerarioData = itinerario['itinerario_data'];
                final fechaCreacion = itinerario['created_at'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.map_rounded,
                      color: Colors.deepPurple,
                    ),
                    title: Text(
                      'Itinerario #${itinerario['id']}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Guardado: ${_formatearFecha(fechaCreacion)}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmarEliminarItinerario(context, itinerario['id']);
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _cargarItinerario(itinerarioData);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error al cargar itinerarios: $e",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Cargar un itinerario guardado
  void _cargarItinerario(dynamic itinerarioData) {
    if (itinerarioData == null) return;

    try {
      final Map<String, List<ActividadPlan>> itinerarioCargado = {};
      final List dias = itinerarioData['dias'] ?? [];

      for (final dia in dias) {
        final String nombreDia = dia['nombre_dia'] ?? 'Día sin nombre';
        final List acts = dia['actividades'] ?? [];
        final actividadesConvertidas = <ActividadPlan>[];

        for (final act in acts) {
          actividadesConvertidas.add(
            ActividadPlan(
              horario: act['horario'] ?? '',
              descripcion: act['descripcion'] ?? '',
              tabla: act['tabla'],
              refId: act['ref_id'],
            ),
          );
        }

        itinerarioCargado[nombreDia] = actividadesConvertidas;
      }

      setState(() {
        _itinerario = itinerarioCargado;
        _esItinerarioFavorito = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Itinerario cargado exitosamente",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error al cargar itinerario: $e",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Confirmar eliminación
  void _confirmarEliminarItinerario(BuildContext context, int itinerarioId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Eliminar itinerario?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Esta acción no se puede deshacer',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarItinerario(itinerarioId);
            },
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Eliminar itinerario
  Future<void> _eliminarItinerario(int itinerarioId) async {
    try {
      await BackendApiService.instance.eliminarItinerarioFavorito(itinerarioId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Itinerario eliminado", style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error al eliminar: $e",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Formatear fecha
  String _formatearFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return fecha;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_rounded),
            tooltip: 'Ver itinerarios guardados',
            onPressed: _verItinerariosGuardados,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _obtenerRecomendaciones,
            child: SingleChildScrollView(
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

                  // Resultado - Título y botón de favorito
                  if (_itinerario.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '4. Tu Plan de Viaje por Día:',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // ❤️ Botón para guardar en favoritos
                        if (_itinerario.isNotEmpty)
                          _cargandoFavorito
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(),
                                )
                              : IconButton(
                                  onPressed: _toggleItinerarioFavorito,
                                  icon: Icon(
                                    _esItinerarioFavorito
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ),
                      ],
                    ),
                  if (_itinerario.isNotEmpty) const SizedBox(height: 10),

                  _construirItinerario(),
                ],
              ),
            ),
          ),

          // Overlay de carga
          if (_estaCargando)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.72),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando recomendaciones...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Por favor, espera un momento.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
          label: Text(preferencia, style: GoogleFonts.poppins(fontSize: 14)),
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
        if (_estaCargando) return;
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
      enabled: !_estaCargando,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Ej: 3',
        labelText: 'Días de estadía',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
      ),
    );
  }

  // ---------- Botón ----------
  Widget _construirBotonRecomendaciones() {
    return GestureDetector(
      onTap: _estaCargando ? null : _obtenerRecomendaciones,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          color: _estaCargando ? Colors.grey[300] : const Color(0xFFEADCCF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!_estaCargando)
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Center(
          child: _estaCargando
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Generando…',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
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
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 15,
                ),
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
                      child: Container(width: 3, color: Colors.grey[300]),
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
                  color: isFeaturedEvent
                      ? const Color(0xFFFFFBE8)
                      : Colors.white,
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

                        // 👇 Aquí ahora se muestran cards de lugar / restaurante / bar
                        if (actividad.refId != null && actividad.tabla != null)
                          _buildRecursoPreview(actividad),

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

  // ---------- Decide qué tipo de card mostrar ----------
  Widget _buildRecursoPreview(ActividadPlan actividad) {
    final tabla = actividad.tabla;
    final id = actividad.refId!;
    switch (tabla) {
      case 'lugares':
        return _buildLugarPreview(id);
      case 'restaurantes':
        return _buildRestaurantePreview(id);
      case 'bares':
        return _buildBarPreview(id);
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- Preview de lugar + navegación ----------
  Widget _buildLugarPreview(int lugarId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DBService.instance.obtenerLugarPorId(lugarId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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

        final String? firstImage = imagenes.isNotEmpty
            ? imagenes[0]?.toString()
            : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetalleLugarPage(lugar: lugar, usuario: widget.usuario),
              ),
            );
          },
          child: _buildMiniCard(
            firstImage: firstImage,
            fallbackIcon: Icons.place,
            titulo: lugar['nombre'] ?? '',
            descripcion: lugar['descripcion'] ?? '',
          ),
        );
      },
    );
  }

  // ---------- Preview de restaurante ----------
  Widget _buildRestaurantePreview(int restauranteId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DBService.instance.obtenerRestaurantePorId(restauranteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final restaurante = snapshot.data!;
        List imagenes = [];
        try {
          if (restaurante['imagenes'] != null) {
            imagenes = jsonDecode(restaurante['imagenes']);
          }
        } catch (_) {}

        final String? firstImage = imagenes.isNotEmpty
            ? imagenes[0]?.toString()
            : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetalleRestaurantePage(
                  restaurante: restaurante,
                  usuario: widget.usuario,
                ),
              ),
            );
          },
          child: _buildMiniCard(
            firstImage: firstImage,
            fallbackIcon: Icons.restaurant,
            titulo: restaurante['nombre'] ?? '',
            descripcion: restaurante['descripcion'] ?? '',
          ),
        );
      },
    );
  }

  // ---------- Preview de bar ----------
  Widget _buildBarPreview(int barId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DBService.instance.obtenerBarPorId(barId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final bar = snapshot.data!;
        List imagenes = [];
        try {
          if (bar['imagenes'] != null) {
            imagenes = jsonDecode(bar['imagenes']);
          }
        } catch (_) {}

        final String? firstImage = imagenes.isNotEmpty
            ? imagenes[0]?.toString()
            : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetalleBarPage(bar: bar, usuario: widget.usuario),
              ),
            );
          },
          child: _buildMiniCard(
            firstImage: firstImage,
            fallbackIcon: Icons.local_bar,
            titulo: bar['nombre'] ?? '',
            descripcion: bar['descripcion'] ?? '',
          ),
        );
      },
    );
  }

  // ---------- Mini card reutilizable ----------
  Widget _buildMiniCard({
    required String? firstImage,
    required IconData fallbackIcon,
    required String titulo,
    required String descripcion,
  }) {
    return Container(
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
                    child: Icon(fallbackIcon, size: 30),
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
              child: Icon(fallbackIcon, size: 30, color: Colors.grey),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descripcion,
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
    );
  }
}

// ---- Helper para leer la referencia que viene de la IA ----

class ReferenciaRecurso {
  final String tabla;
  final int id;

  ReferenciaRecurso({required this.tabla, required this.id});
}

ReferenciaRecurso? _extraerReferenciaDesdeIA(dynamic ref) {
  if (ref == null) return null;

  try {
    final tabla = ref['tabla'];
    final id = ref['id'];

    if (tabla is String && id is int) {
      return ReferenciaRecurso(tabla: tabla, id: id);
    }
  } catch (_) {}

  return null;
}
