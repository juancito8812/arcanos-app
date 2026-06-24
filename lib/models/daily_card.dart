class DailyCard {
  final DateTime date;
  final int arcanoNumero;
  final String arcanoNombre;
  final String arcanoNombreRomano;
  final String? aiInterpretation;
  final bool hasProfile;

  const DailyCard({
    required this.date,
    required this.arcanoNumero,
    required this.arcanoNombre,
    required this.arcanoNombreRomano,
    this.aiInterpretation,
    required this.hasProfile,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Map<String, dynamic> toMap() => {
    'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'arcano_numero': arcanoNumero,
    'arcano_nombre': arcanoNombre,
    'arcano_nombre_romano': arcanoNombreRomano,
    'ai_interpretation': aiInterpretation,
    'has_profile': hasProfile ? 1 : 0,
  };

  factory DailyCard.fromMap(Map<String, dynamic> map) {
    final parts = (map['date'] as String).split('-');
    return DailyCard(
      date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
      arcanoNumero: map['arcano_numero'] as int,
      arcanoNombre: map['arcano_nombre'] as String,
      arcanoNombreRomano: map['arcano_nombre_romano'] as String,
      aiInterpretation: map['ai_interpretation'] as String?,
      hasProfile: (map['has_profile'] as int) == 1,
    );
  }
}
