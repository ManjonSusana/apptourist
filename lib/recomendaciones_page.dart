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
  
  // Estado para el manejo de preferencias seleccionadas
  List<String> _preferenciasSeleccionadas = [];
  final List<String> _opcionesPreferencia = ['Histórico', 'Cultural', 'Gastronomía', 'Naturaleza'];

  // El resultado ahora es un mapa estructurado para el itinerario
  Map<String, Map<String, String>> _itinerario = {}; 

  void _obtenerRecomendaciones() {
    FocusScope.of(context).unfocus();
    final String textDias = _diasCtrl.text.trim();
    final int dias = int.tryParse(textDias) ?? 0;

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

    // --- LÓGICA SIMULADA DE ITINERARIO (Ajustada a preferencias y horarios) ---
    _itinerario = {};
    
    // Simplificación: la preferencia más importante define el foco del viaje
    final String foco = _preferenciasSeleccionadas.isNotEmpty 
                        ? _preferenciasSeleccionadas.first 
                        : 'General';

    if (dias >= 1) {
      // Día 1: Enfocado en el centro y la preferencia principal
      _itinerario['Día 1'] = {
        'Mañana (8:00)': foco == 'Histórico' ? 'Visita guiada a la Casa de la Libertad.' : 'Recorrido por el centro colonial.',
        'Almuerzo (13:00)': 'Salteñas en "El Patio" o similar.',
        'Tarde (15:00)': foco == 'Naturaleza' ? 'Recorrido por el Parque Bolívar y la Piscina Olímpica.' : 'Convento de San Felipe Neri (terrazas y vistas).',
        'Noche (20:00)': 'Cena con ambiente local y descanso.',
      };
    }
    
    if (dias >= 2) {
      // Día 2: Ampliación y segunda preferencia
      _itinerario['Día 2'] = {
        'Mañana (9:00)': foco == 'Cultural' ? 'Museo ASUR y Templo de San Lázaro.' : 'Mercado Central (experiencia local).',
        'Almuerzo (13:30)': 'Prueba el "Mondongo" en un restaurante tradicional.',
        'Tarde (16:00)': 'Mirador de La Recoleta para ver el atardecer.',
        'Noche (20:30)': 'Ruta del chocolate sucrense (degustación y postres).',
      };
    }
    
    if (dias >= 3) {
      // Día 3: Lugares periféricos o de alto interés
      _itinerario['Día 3'] = {
        'Mañana (9:30)': foco == 'Naturaleza' ? 'Excursión al Parque Cretácico (Huellas de dinosaurio).' : 'Visita a la Universidad San Francisco Xavier (UNSACH).',
        'Almuerzo (14:00)': 'Comida rápida cerca del Parque Cretácico.',
        'Tarde (17:00)': foco == 'Histórico' ? 'Castillo de La Glorieta.' : 'Compras de artesanías locales.',
        'Noche (20:00)': 'Cena de despedida.',
      };
    }
    // Si la lógica se vuelve muy compleja, puedes añadir un mensaje de que la IA está en desarrollo.
    
    setState(() {});
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
              // ---------------- SELECCIÓN DE PREFERENCIAS ----------------
              Text(
                '1. Selecciona tus intereses principales:',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildPreferenceChips(),
              const SizedBox(height: 20),

              // ---------------- ENTRADA DE DÍAS ----------------
              Text(
                '2. Ingresa la duración de tu estadía:',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _construirCampoDias(),
              const SizedBox(height: 20),

              // ---------------- BOTÓN DE ACCIÓN ----------------
              _construirBotonRecomendaciones(),
              const SizedBox(height: 30),

              // ---------------- ITINERARIO RESULTANTE ----------------
              _itinerario.isNotEmpty ? 
                Text(
                  '3. Tu Plan de Viaje por Día:',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                ) : 
                Container(),
              const SizedBox(height: 10),
              _construirItinerario(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA LAS OPCIONES SELECCIONABLES (CHIPS) ---
  Widget _buildPreferenceChips() {
    return Wrap(
      spacing: 8.0, // Espacio horizontal entre chips
      children: _opcionesPreferencia.map((preferencia) {
        final isSelected = _preferenciasSeleccionadas.contains(preferencia);
        return ChoiceChip(
          label: Text(preferencia, style: GoogleFonts.poppins(fontSize: 14)),
          selected: isSelected,
          selectedColor: const Color(0xFFD0C2FF).withOpacity(0.8), // Color morado
          backgroundColor: Colors.grey[200],
          onSelected: (selected) {
            setState(() {
              if (selected) {
                // Permitimos seleccionar hasta 3 preferencias
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

  // --- WIDGET PARA MOSTRAR EL ITINERARIO DÍA POR DÍA ---
  Widget _construirItinerario() {
    if (_itinerario.isEmpty) {
      return Center(
        child: Text(
          'Ingresa los días y preferencias para generar tu itinerario en Sucre.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    
    // Itera sobre cada día (Día 1, Día 2, etc.)
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
              // Título del Día
              Text(
                '$nombreDia:',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFFD0C2FF)), // Color morado
              ),
              const Divider(thickness: 1, color: Color(0xFFEADCCF)), // Color crema

              // Lista de Actividades por Horario
              ...actividades.entries.map((entryActividad) {
                String horario = entryActividad.key;
                String actividad = entryActividad.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Horario (en negrita)
                      Container(
                        width: 100, // Ancho fijo para alinear los horarios
                        child: Text(
                          horario,
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Actividad
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