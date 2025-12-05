class HighlightedDate {
  final String id;
  final String title;        // Nombre del evento
  final String type;         // cívico, cultural, religioso, etc.
  final String description;  // Descripción corta
  final String location;     // Ciudad / país / región
  final DateTime date;       // Fecha del evento
  final bool isHoliday;      // ¿Es feriado oficial?

  const HighlightedDate({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.location,
    required this.date,
    this.isHoliday = false,
  });
}
