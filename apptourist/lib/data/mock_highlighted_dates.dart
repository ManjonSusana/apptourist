import 'package:flutter/material.dart';
import '../models/highlighted_date.dart';

/// Lista fija de fechas destacadas.
/// Puedes repetir el año como el actual, lo importante son día y mes.
final List<HighlightedDate> kHighlightedDates = [
  HighlightedDate(
    id: 'ano_nuevo',
    title: 'Año Nuevo',
    type: 'Feriado cívico',
    description: 'Inicio del nuevo año, muchas ciudades tienen celebraciones especiales.',
    location: 'Bolivia',
    date: DateTime(DateTime.now().year, 1, 1),
    isHoliday: true,
  ),
  HighlightedDate(
    id: 'dia_estado_plurinacional',
    title: 'Día del Estado Plurinacional',
    type: 'Feriado cívico',
    description: 'Conmemoración de la creación del Estado Plurinacional de Bolivia.',
    location: 'Bolivia',
    date: DateTime(DateTime.now().year, 1, 22),
    isHoliday: true,
  ),
  HighlightedDate(
    id: 'carnaval',
    title: 'Carnaval',
    type: 'Cultural / festivo',
    description: 'Fiestas, entradas folclóricas y celebraciones en varias ciudades.',
    location: 'Diversas ciudades de Bolivia',
    date: DateTime(DateTime.now().year, 2, 11), // ej. una fecha de ejemplo
  ),
  HighlightedDate(
    id: '6_agosto',
    title: 'Día de la Independencia de Bolivia',
    type: 'Feriado cívico',
    description: 'Conmemoración de la independencia, desfiles cívicos y actos oficiales.',
    location: 'Bolivia',
    date: DateTime(DateTime.now().year, 8, 6),
    isHoliday: true,
  ),
  HighlightedDate(
    id: 'fundacion_sucre',
    title: 'Aniversario de la ciudad de Sucre',
    type: 'Cívico / local',
    description: 'Actividades culturales y cívicas que celebran la fundación de la ciudad.',
    location: 'Sucre, Bolivia',
    date: DateTime(DateTime.now().year, 11, 30),
  ),
  HighlightedDate(
    id: 'navidad',
    title: 'Navidad',
    type: 'Religioso / festivo',
    description: 'Celebración navideña, ferias artesanales y actividades familiares.',
    location: 'Bolivia',
    date: DateTime(DateTime.now().year, 12, 25),
    isHoliday: true,
  ),
];

/// Función para comparar solo día/mes/año (sin horas)
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Eventos que caen HOY
List<HighlightedDate> getTodayHighlightedDates(DateTime now) {
  return kHighlightedDates.where((event) => isSameDay(event.date, now)).toList();
}

/// Eventos que vienen en los próximos [daysAhead] días
List<HighlightedDate> getUpcomingHighlightedDates(DateTime now, {int daysAhead = 7}) {
  final today = DateTime(now.year, now.month, now.day);

  return kHighlightedDates.where((event) {
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
    final diff = eventDate.difference(today).inDays;
    return diff > 0 && diff <= daysAhead;
  }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

/// Texto tipo "IA" para resumir las fechas
String buildHighlightedSummary({
  required DateTime now,
  required List<HighlightedDate> todayEvents,
  required List<HighlightedDate> upcomingEvents,
}) {
  if (todayEvents.isEmpty && upcomingEvents.isEmpty) {
    return 'Hoy no hay fechas destacadas registradas, pero siempre puedes explorar el centro histórico, plazas y museos de la ciudad.';
  }

  if (todayEvents.isNotEmpty && upcomingEvents.isEmpty) {
    final titles = todayEvents.map((e) => e.title).join(', ');
    return 'Hoy tienes una fecha importante: $titles. Es un buen momento para aprovechar actos cívicos, actividades culturales y recorrer los puntos históricos relacionados.';
  }

  if (todayEvents.isEmpty && upcomingEvents.isNotEmpty) {
    final count = upcomingEvents.length;
    return 'En los próximos días hay $count evento(s) destacado(s) que podrían influir en tu viaje. Te recomendamos revisar la lista para organizar mejor tus recorridos.';
  }

  // Hay hoy y próximos
  final todayTitles = todayEvents.map((e) => e.title).join(', ');
  final upcomingCount = upcomingEvents.length;

  return 'Hoy se celebra: $todayTitles. Además, en los próximos días hay $upcomingCount fecha(s) destacada(s) más. Planifica tu visita aprovechando actos cívicos, ferias y eventos culturales.';
}
