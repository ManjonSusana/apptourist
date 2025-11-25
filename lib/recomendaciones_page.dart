import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecomendacionesPage extends StatefulWidget {
  final Map<String, dynamic>? usuario; 
  
  const RecomendacionesPage({super.key, this.usuario});

  @override
  State<RecomendacionesPage> createState() => _RecomendacionesPageState();
}

class _RecomendacionesPageState extends State<RecomendacionesPage> {
  final TextEditingController _diasCtrl = TextEditingController();
  
  List<String> _preferenciasSeleccionadas = [];
  final List<String> _opcionesPreferencia = ['Histórico', 'Cultural', 'Gastronomía', 'Naturaleza'];

  DateTime? _fechaInicio; 
  Map<String, Map<String, String>> _itinerario = {}; 
  bool _isLoading = false; // Estado para simular la carga

  void _obtenerRecomendaciones() async {
    FocusScope.of(context).unfocus();
    final String textDias = _diasCtrl.text.trim();
    final int dias = int.tryParse(textDias) ?? 0;

    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, selecciona la fecha de inicio del viaje.", style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      _itinerario = {};
      setState(() {});
      return;
    }
    
    if (dias <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ingresa un número de días válido (mayor a cero).", style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      _itinerario = {};
      setState(() {});
      return; 
    }

    // --- INICIO DE CARGA SIMULADA ---
    setState(() {
      _isLoading = true;
      _itinerario = {}; // Limpiar itinerario anterior
    });
    
    // Simular un retraso de red
    await Future.delayed(const Duration(seconds: 2)); 

    // --- LÓGICA SIMULADA DE ITINERARIO ---
    _itinerario = {};
    final String foco = _preferenciasSeleccionadas.isNotEmpty 
                        ? _preferenciasSeleccionadas.first 
                        : 'General';

    DateTime fechaActual = _fechaInicio!;

    for (int i = 1; i <= dias; i++) {
      String nombreDia = 'Día $i (${fechaActual.day}/${fechaActual.month})';
      Map<String, String> actividades = {};

      // Lógica de personalización basada en fecha y foco
      if (fechaActual.month == 12 && fechaActual.day == 1) { 
        actividades = {
          'Mañana (9:00)': 'Visita al Cementerio General (histórico).',
          'Almuerzo (13:00)': 'Comida rápida cerca del centro.',
          'Tarde (16:00)': 'Paseo por la Plaza 25 de Mayo.',
          'Noche (20:00)': '✨ **¡Evento Especial!** Concierto de Música Clásica en Teatro Gran Mariscal Sucre.',
        };
      } else {
        // Lógica general basada en la preferencia
        actividades = {
          'Mañana (8:00)': foco == 'Histórico' ? 'Casa de la Libertad.' : 'Exploración del Parque Bolívar.',
          'Almuerzo (13:00)': foco == 'Gastronomía' ? 'Mercado Central y Salteñas.' : 'Comida cerca del hotel.',
          'Tarde (15:00)': foco == 'Naturaleza' ? 'Exploración del Parque Cretácico.' : 'Mirador de La Recoleta.',
          'Noche (20:00)': 'Cena y descanso.',
        };
      }

      _itinerario[nombreDia] = actividades;
      fechaActual = fechaActual.add(const Duration(days: 1));
    }
    
    // --- FIN DE CARGA SIMULADA ---
    setState(() {
      _isLoading = false;
    });
  }

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- 1. SELECCIÓN DE PREFERENCIAS ----------------
              Text(
                '1. Selecciona tus intereses principales:',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildPreferenceChips(),
              const SizedBox(height: 20),

              // ---------------- 2. SELECCIÓN DE FECHA ----------------
              Text(
                '2. ¿Cuándo inicias tu viaje?',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildDatePicker(), 
              const SizedBox(height: 20),
              
              // ---------------- 3. ENTRADA DE DÍAS ----------------
              Text(
                '3. Ingresa la duración de tu estadía:',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _construirCampoDias(),
              const SizedBox(height: 20),

              // ---------------- BOTÓN DE ACCIÓN ----------------
              _construirBotonRecomendaciones(),
              const SizedBox(height: 30),

              // ---------------- ITINERARIO RESULTANTE O LOADING ----------------
              _buildResultsOrLoading(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA SELECCIÓN DE FECHA ---
  Widget _buildDatePicker() {
    String fechaDisplay = _fechaInicio == null 
      ? 'Toca para seleccionar la fecha' 
      : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}';

    return GestureDetector(
      onTap: () async {
        final DateTime? fechaSeleccionada = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(), 
          lastDate: DateTime(DateTime.now().year + 2), 
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

  // --- WIDGET PARA LAS OPCIONES SELECCIONABLES (CHIPS) ---
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
                if (_preferenciasSeleccionadas.length < 3) {
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
  
  // --- WIDGET PARA MOSTRAR RESULTADOS O LOADING ---
  Widget _buildResultsOrLoading() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_itinerario.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4. Tu Plan de Viaje por Día:',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _construirItinerario(),
        ],
      );
    }
    
    return Center(
      child: Text(
        'Ingresa los datos para generar tu itinerario en Sucre.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  // --- WIDGET PARA MOSTRAR EL ITINERARIO DÍA POR DÍA ---
  Widget _construirItinerario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _itinerario.entries.map((entryDia) {
        String nombreDia = entryDia.key;
        Map<String, String> actividades = entryDia.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$nombreDia:',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFFD0C2FF)),
              ),
              const Divider(thickness: 1, color: Color(0xFFEADCCF)),

              ...actividades.entries.map((entryActividad) {
                String horario = entryActividad.key;
                String actividad = entryActividad.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Text(
                          horario,
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          actividad,
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Widgets de Entrada y Botón (Mantenidos) ---
  Widget _construirCampoDias() {
    return TextField(
      controller: _diasCtrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Ej: 3',
        labelText: 'Días de estadía',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  Widget _construirBotonRecomendaciones() {
    return GestureDetector(
      onTap: _obtenerRecomendaciones,
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
}