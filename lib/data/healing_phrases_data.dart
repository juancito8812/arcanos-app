class HealingPhrase {
  final String texto;
  final String intencion;

  const HealingPhrase({required this.texto, required this.intencion});
}

class HealingPhrasesData {
  static const nivel1Ver = [
    HealingPhrase(texto: 'Te veo. Tienes un lugar en mi corazon.', intencion: 'Reconocer la existencia del otro'),
    HealingPhrase(texto: 'Veo tu destino y lo honro.', intencion: 'Aceptar la historia del otro sin juicio'),
    HealingPhrase(texto: 'Veo lo que paso. No lo aparto.', intencion: 'Integrar eventos dificiles'),
    HealingPhrase(texto: 'Tu perteneces. Eres parte de este sistema.', intencion: 'Restaurar pertenencia'),
    HealingPhrase(texto: 'Veo tu lugar en la familia.', intencion: 'Reconocer posicion sistémica'),
  ];

  static const nivel2Honrar = [
    HealingPhrase(texto: 'Eres mi [relacion]. Yo soy el hijo/la hija.', intencion: 'Restaurar jerarquia'),
    HealingPhrase(texto: 'Gracias por la vida que me diste a traves de ti.', intencion: 'Agradecer a padres'),
    HealingPhrase(texto: 'Tomaste lo que era tuyo. Yo tomo lo que es mio.', intencion: 'Separar destinos'),
    HealingPhrase(texto: 'Te respeto como [relacion]. Te honro.', intencion: 'Honrar el lugar del otro'),
    HealingPhrase(texto: 'Lo siento. Gracias. Te amo.', intencion: 'Sanacion basica sistémica'),
    HealingPhrase(texto: 'Acepto tu destino. No lo juzgo.', intencion: 'Liberar juicio'),
  ];

  static const nivel3Soltar = [
    HealingPhrase(texto: 'Tomo mi vida. Dejo lo tuyo contigo.', intencion: 'Devolver cargas ajenas'),
    HealingPhrase(texto: 'Confio en la vida. Confio en mi lugar.', intencion: 'Afirmacion de confianza'),
    HealingPhrase(texto: 'Acepto mi origen tal como es.', intencion: 'Aceptacion radical'),
    HealingPhrase(texto: 'Paz entre nosotros. Paz en mi corazon.', intencion: 'Cierre y reconciliacion'),
    HealingPhrase(texto: 'Por favor, bendiceme.', intencion: 'Pedir bendicion al sistema'),
  ];

  static String personalizar(String frase, String? relacion, String? nombre) {
    var f = frase;
    if (relacion != null) f = f.replaceAll('[relacion]', relacion);
    if (nombre != null) f = f.replaceAll('[nombre]', nombre);
    f = f.replaceAll('[relacion]', 'familiar');
    f = f.replaceAll('[nombre]', 'hermano/hermana');
    return f;
  }
}
