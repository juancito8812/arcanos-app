/// Contenido interpretativo del módulo Números Personales (1-9).
/// Dos contextos: Número de Vida (esencia kármica de nacimiento) y
/// Año Personal (energía del ciclo en curso, método clásico del dueño).
class NumeroVidaInfo {
  final String esencia;
  final String dones;
  final String sombras;
  final String karma;
  final String recomendacion;

  const NumeroVidaInfo({
    required this.esencia,
    required this.dones,
    required this.sombras,
    required this.karma,
    required this.recomendacion,
  });
}

class AnoPersonalInfo {
  final String positivo;
  final String negativo;
  final String recomendacion;

  const AnoPersonalInfo({
    required this.positivo,
    required this.negativo,
    required this.recomendacion,
  });
}

const Map<int, NumeroVidaInfo> vidaInfo = {
  1: NumeroVidaInfo(
    esencia: 'El Iniciador. Alma de líder: nació para abrir caminos, tomar la primera decisión y sostenerse con su propio criterio.',
    dones: 'Iniciativa, determinación, originalidad y valor para emprender donde nadie ha entrado.',
    sombras: 'Impaciencia, egoísmo y arrogancia. Puede imponer su voluntad y descartar a quienes no siguen su ritmo.',
    karma: 'Aprender a liderar sin humillar: la autoridad verdadera no necesita pisar a nadie.',
    recomendacion: 'Confía en tu criterio y lanza lo que ya tienes guardado. Consulta, pero no esperes permiso para empezar.',
  ),
  2: NumeroVidaInfo(
    esencia: 'El Mediador. Alma sensible y diplomática: nació para unir, escuchar y sostener a otros desde la cooperación.',
    dones: 'Empatía profunda, tacto para mediar conflictos e intuición para leer a las personas.',
    sombras: 'Dependencia, indecisión e hipersensibilidad. Se apaga si no tiene a alguien al lado y calla por mantener la paz.',
    karma: 'Valerse por sí mismo sin endurecerse: la fuerza no contradice la sensibilidad.',
    recomendacion: 'Pon límites y di lo que piensas aunque incomode. Tu opinión vale tanto como la del resto.',
  ),
  3: NumeroVidaInfo(
    esencia: 'El Comunicador. Alma creativa: nació para expresar, inspirar y alegrar con su palabra y su arte.',
    dones: 'Carisma, talento con la palabra y la estética, capacidad de contagiar entusiasmo.',
    sombras: 'Dispersión y superficialidad: empieza mil cosas, termina pocas y promete más de lo que cumple.',
    karma: 'Sostener el talento con disciplina: la creatividad sin constancia se evapora.',
    recomendacion: 'Elige dos proyectos y llévalos hasta el final. Tu palabra es tu herramienta: úsala para construir, no para escapar.',
  ),
  4: NumeroVidaInfo(
    esencia: 'El Constructor. Alma de cimientos: nació para dar orden, método y solidez a todo lo que toca.',
    dones: 'Constancia, fiabilidad, sentido práctico y capacidad de convertir ideas en obras duraderas.',
    sombras: 'Rigidez y miedo al cambio: se aferra a la rutina y al control hasta bloquear su propia vida.',
    karma: 'Construir sólido sin encerrarse: la seguridad verdadera soporta lo imprevisto.',
    recomendacion: 'Tu orden es tu poder, pero deja huecos para lo nuevo. Ruptura controlada de vez en cuando: un viaje, un cambio, una sorpresa.',
  ),
  5: NumeroVidaInfo(
    esencia: 'El Aventurero. Alma libre: nació para vivir el cambio, moverse, experimentar y romper moldes.',
    dones: 'Adaptabilidad, versatilidad, magnetismo natural y sangre fría ante lo desconocido.',
    sombras: 'Exceso e inconstancia: cae en adicciones, impulsividad y dejar todo a medias cuando se acaba la emoción.',
    karma: 'Usar la libertad sin autodestruirse: la libertad verdadera incluye responsabilidad.',
    recomendacion: 'Muévete, viaja, cambia lo que pide cambio — pero con reglas propias que no negocies bajo impulso.',
  ),
  6: NumeroVidaInfo(
    esencia: 'El Cuidador. Alma de amor y armonía: nació para servir, proteger y crear hogar dondequiera que esté.',
    dones: 'Generosidad, sentido estético, don para armonizar grupos y familias.',
    sombras: 'Sacrificio excesivo y control disfrazado de amor: carga con el bienestar ajeno y luego se resiente.',
    karma: 'Amar sin rescatar: cada alma carga su propia cruz, y la tuya es tu propia vida.',
    recomendacion: 'Date la mitad del cuidado que das a los demás. Servir sí, desaparecerse no.',
  ),
  7: NumeroVidaInfo(
    esencia: 'El Buscador. Alma introspectiva: nació para profundizar, estudiar y encontrar la verdad detrás de las apariencias.',
    dones: 'Análisis agudo, intuición espiritual, capacidad de estudio y de ver lo que otros no ven.',
    sombras: 'Aislamiento y desconfianza: se refugia en la torre de marfil y corta el puente con la gente.',
    karma: 'Equilibrar lo espiritual con lo terrenal: la sabiduría que no se comparte ni se encarna, no sirve.',
    recomendacion: 'Estudia y medita, pero también comparte y participa. Tu hallazgo interior tiene valor cuando toca tierra.',
  ),
  8: NumeroVidaInfo(
    esencia: 'El Ejecutivo. Alma de poder material: nació para administrar, dirigir y prosperar en lo grande.',
    dones: 'Visión de negocio, autoridad natural, capacidad de levantar estructuras y recuperar de cualquier caída.',
    sombras: 'Materialismo y dureza: puede confundir valía con dinero y usar el poder para aplastar en vez de levantar.',
    karma: 'Usar el poder con ética: lo que se administra injustamente, se pierde doble.',
    recomendacion: 'Apunta alto: dinero, cargo, legado. Pero administra con justicia — tu reputación es tu activo más grande.',
  ),
  9: NumeroVidaInfo(
    esencia: 'El Humanitario. Alma compasiva: nació para servir más allá de lo personal y cerrar ciclos viejos.',
    dones: 'Generosidad, visión amplia, capacidad de perdonar y de dar sin quedar en deuda.',
    sombras: 'Dramatismo y victimismo: se aferra a lo que ya se acabó y revive viejas heridas como si fueran actuales.',
    karma: 'Dar sin esperar y soltar sin resentimiento: el cierre es su maestro.',
    recomendacion: 'Suelta lo que se acabó — persona, etapa, reclamo. Tu energía crece cuando termina un capítulo, no cuando lo relee.',
  ),
};

const Map<int, AnoPersonalInfo> anoInfo = {
  1: AnoPersonalInfo(
    positivo: 'Año de inicios: energía fresca para emprender, decidir y arrancar proyectos propios.',
    negativo: 'Impaciencia y soledad inicial: los frutos no llegan enseguida y la tentación es abandonar.',
    recomendacion: 'Siembra sin mirar la cosecha. Todo lo que inicies este año marca la base de los próximos 9.',
  ),
  2: AnoPersonalInfo(
    positivo: 'Año de alianzas: llegan socios, amor, acuerdos y desarrollos lentos pero firmes.',
    negativo: 'Espera y sensibilidad al borde: el avance es lento y puede sentirse como estancamiento.',
    recomendacion: 'Cultiva paciencia y cuida vínculos. No fuerces: lo de este año madura solo.',
  ),
  3: AnoPersonalInfo(
    positivo: 'Año de expansión: creatividad, socialización, alegría y contactos que abren puertas.',
    negativo: 'Dispersión: tanto estímulo y tan poca disciplina que el año se va sin dejar obra.',
    recomendacion: 'Comunica, crea, muestra tu trabajo — pero con agenda. Elige los proyectos y ciérralos.',
  ),
  4: AnoPersonalInfo(
    positivo: 'Año de cimientos: orden, trabajo serio y resultados tangibles para quien sostiene el esfuerzo.',
    negativo: 'Carga y limitación: rutina, gastos fijos, sensación de que todo cuesta el doble.',
    recomendacion: 'Disciplina, salud y finanzas al día. Es el año menos glamuroso y el que más deja parado.',
  ),
  5: AnoPersonalInfo(
    positivo: 'Año de movimiento: cambios, viajes, oportunidades inesperadas y vida que se acelera.',
    negativo: 'Caos e impulsividad: decisiones a la brava que traen deudas, rompimientos o accidentes.',
    recomendacion: 'Acepta el cambio, pero piénsalo 24 horas antes de firmar nada. La libertad con cabeza, no con impulso.',
  ),
  6: AnoPersonalInfo(
    positivo: 'Año de corazón: familia, pareja, hogar y compromisos que llegan con madurez.',
    negativo: 'Cargas ajenas y conflicto doméstico: todos piden y pocos dan, y el agotamiento llega.',
    recomendacion: 'Comprométete con lo que amas, pero no heredes los problemas de nadie. Servicio sí, martirio no.',
  ),
  7: AnoPersonalInfo(
    positivo: 'Año interior: estudio, espiritualidad, claridad mental y respuestas que no llegan afuera.',
    negativo: 'Aislamiento y confusión emocional: sin apoyo, el silencio se vuelve cueva y la duda se instala.',
    recomendacion: 'Retírate a procesar, pero no huyas. Terapia, estudio, meditación: es año de aprender, no de actuar en grande.',
  ),
  8: AnoPersonalInfo(
    positivo: 'Año de cosecha: dinero, ascensos, logros materiales y poder real para quien jugó limpio.',
    negativo: 'Choques de poder y presión financiera: el año cobra caro las deudas pendientes, materiales y morales.',
    recomendacion: 'Actúa con decisión y ética: negocia, cobra lo tuyo, invierte. Es tu año de mayor impacto y mayor responsabilidad.',
  ),
  9: AnoPersonalInfo(
    positivo: 'Año de cierre: se completan ciclos, llegan recompensas por lo sembrado y espacio para lo nuevo.',
    negativo: 'Pérdidas y nostalgia: se van personas, etapas y cosas a las que te negabas a soltar.',
    recomendacion: 'Cierra con voluntad: perdona, despídete, ordena y limpia. Lo que sueltes este año le abre la puerta al año 1 que viene.',
  ),
};
