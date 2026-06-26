import 'dart:convert';

class FamilyMember {
  final int? id;
  final String nombre;
  final String relacion;
  final int generacion;
  final int? arcanoNumero;
  final List<String> eventos;
  final String? fechaNacimiento;
  final String? fechaEvento;
  double posX;
  double posY;

  FamilyMember({
    this.id,
    required this.nombre,
    required this.relacion,
    this.generacion = 0,
    this.arcanoNumero,
    this.eventos = const [],
    this.fechaNacimiento,
    this.fechaEvento,
    this.posX = 0,
    this.posY = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'relacion': relacion,
    'generacion': generacion,
    'arcano_numero': arcanoNumero,
    'eventos': jsonEncode(eventos),
    'fecha_nacimiento': fechaNacimiento,
    'fecha_evento': fechaEvento,
    'pos_x': posX,
    'pos_y': posY,
  };

  factory FamilyMember.fromMap(Map<String, dynamic> map) => FamilyMember(
    id: map['id'] as int?,
    nombre: map['nombre'] as String,
    relacion: map['relacion'] as String,
    generacion: map['generacion'] as int? ?? 0,
    arcanoNumero: map['arcano_numero'] as int?,
    eventos: (map['eventos'] as String?) != null
        ? List<String>.from(jsonDecode(map['eventos'] as String))
        : [],
    fechaNacimiento: map['fecha_nacimiento'] as String?,
    fechaEvento: map['fecha_evento'] as String?,
    posX: (map['pos_x'] as num?)?.toDouble() ?? 0,
    posY: (map['pos_y'] as num?)?.toDouble() ?? 0,
  );

  FamilyMember copyWith({int? id, String? nombre, String? relacion, int? generacion, int? arcanoNumero, List<String>? eventos, String? fechaNacimiento, String? fechaEvento, double? posX, double? posY}) => FamilyMember(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    relacion: relacion ?? this.relacion,
    generacion: generacion ?? this.generacion,
    arcanoNumero: arcanoNumero ?? this.arcanoNumero,
    eventos: eventos ?? this.eventos,
    fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
    fechaEvento: fechaEvento ?? this.fechaEvento,
    posX: posX ?? this.posX,
    posY: posY ?? this.posY,
  );
}
