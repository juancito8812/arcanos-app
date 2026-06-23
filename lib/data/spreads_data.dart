import '../models/tarot_spread.dart';

final List<TarotSpread> allSpreads = [
  TarotSpread(id: 'tres_cartas', nombre: 'Tirada de Tres Cartas',
    descripcion: 'Lectura simple de pasado, presente y futuro.', numCartas: 3,
    posiciones: ['Pasado', 'Presente', 'Futuro']),
  TarotSpread(id: 'triada_vida_pasada', nombre: 'Triada de una Vida Pasada',
    descripcion: 'Explora una encarnacion anterior.', numCartas: 3,
    posiciones: ['Vida Pasada 1', 'Vida Pasada 2', 'Vida Pasada 3']),
  TarotSpread(id: 'viaje_vidas_pasadas', nombre: 'Viaje a Vidas Pasadas',
    descripcion: 'Lectura profunda de 5 cartas.', numCartas: 5,
    posiciones: ['Nacimiento', 'Infancia', 'Actualidad', 'Reencarnacion Pasada', 'Reencarnacion Futura']),
  TarotSpread(id: 'constelacion_familiar', nombre: 'Constelacion Familiar con Tarot',
    descripcion: 'Analiza dinamicas familiares en un circulo.', numCartas: 7,
    posiciones: ['Relacion estrecha', 'Problemas de comunicacion', 'Autoridad', 'Dominio', 'Sin relacion', 'Oposicion', 'Excluidos']),
  TarotSpread(id: 'arbol_genealogico', nombre: 'Arbol Genealogico',
    descripcion: 'Arcanos para representar miembros de la familia.', numCartas: 6,
    posiciones: ['Yo', 'Padre', 'Madre', 'Hermano/a', 'Abuelo Paterno', 'Abuela Materna']),
];
