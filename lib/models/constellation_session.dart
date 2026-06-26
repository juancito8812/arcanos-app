import 'dart:convert';

class ConstellationPosition {
  String memberName;
  String relacion;
  String posicionSistemica;
  int arcanoNumero;
  double posX;
  double posY;

  ConstellationPosition({
    required this.memberName,
    required this.relacion,
    required this.posicionSistemica,
    required this.arcanoNumero,
    this.posX = 0,
    this.posY = 0,
  });

  Map<String, dynamic> toMap() => {
    'member_name': memberName,
    'relacion': relacion,
    'posicion_sistemica': posicionSistemica,
    'arcano_numero': arcanoNumero,
    'pos_x': posX,
    'pos_y': posY,
  };

  factory ConstellationPosition.fromMap(Map<String, dynamic> map) => ConstellationPosition(
    memberName: map['member_name'] as String,
    relacion: map['relacion'] as String,
    posicionSistemica: map['posicion_sistemica'] as String,
    arcanoNumero: map['arcano_numero'] as int,
    posX: (map['pos_x'] as num?)?.toDouble() ?? 0,
    posY: (map['pos_y'] as num?)?.toDouble() ?? 0,
  );
}

class ConstellationSession {
  final int? id;
  final String tema;
  final List<ConstellationPosition> posiciones;
  final String? interpretacionIa;
  final String? fraseAplicada;
  final String fechaCreacion;

  ConstellationSession({
    this.id,
    required this.tema,
    required this.posiciones,
    this.interpretacionIa,
    this.fraseAplicada,
    String? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'tema': tema,
    'posiciones': jsonEncode(posiciones.map((p) => p.toMap()).toList()),
    'interpretacion_ia': interpretacionIa,
    'frase_aplicada': fraseAplicada,
    'fecha_creacion': fechaCreacion,
  };

  factory ConstellationSession.fromMap(Map<String, dynamic> map) => ConstellationSession(
    id: map['id'] as int?,
    tema: map['tema'] as String,
    posiciones: (jsonDecode(map['posiciones'] as String) as List)
        .map((e) => ConstellationPosition.fromMap(e as Map<String, dynamic>))
        .toList(),
    interpretacionIa: map['interpretacion_ia'] as String?,
    fraseAplicada: map['frase_aplicada'] as String?,
    fechaCreacion: map['fecha_creacion'] as String?,
  );
}
