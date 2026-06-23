import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';
import '../../models/arcano.dart';

class ConstellationScreen extends StatefulWidget {
  const ConstellationScreen({super.key});
  @override
  State<ConstellationScreen> createState() => _ConstellationScreenState();
}

class _ConstellationScreenState extends State<ConstellationScreen> {
  int _tab = 0;
  final tabs = ['Que es?', '3 Leyes', 'Rueda', 'Frases', 'Secretos'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Constelaciones Familiares')),
      body: Column(children: [
        SizedBox(height: 50, child: ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: tabs.length,
          itemBuilder: (context, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(label: Text(tabs[i], style: const TextStyle(fontSize: 12)), selected: _tab == i,
              selectedColor: AppTheme.purplePrimary,
              labelStyle: TextStyle(color: _tab == i ? Colors.white : AppTheme.purplePrimary, fontSize: 12),
              onSelected: (v) => setState(() => _tab = i))),
        )),
        Expanded(child: _buildContent()),
      ]),
    );
  }

  Widget _buildContent() {
    switch (_tab) {
      case 0: return _Info();
      case 1: return _Leyes();
      case 2: return _Rueda();
      case 3: return _Frases();
      case 4: return _Secretos();
      default: return const SizedBox();
    }
  }
}

class _Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Constelaciones Familiares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
        const SizedBox(height: 12),
        const Text('Terapia que permite observar y sanar esquemas afectivos y cognitivos que afectan la cotidianidad. Busca ordenar el sistema familiar, dando lugar a todos los miembros, especialmente a los excluidos.', style: TextStyle(fontSize: 14, height: 1.6)),
      ]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Bases Teoricas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
        const SizedBox(height: 12),
        ...['Virginia Satir', 'Fenomenologia de Husserl', 'P.N.L.', 'Gestalt', 'Psicodrama', 'Hipnosis Ericksoniana'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
          Icon(Icons.check_circle, size: 16, color: AppTheme.purplePrimary.withAlpha(150)),
          const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 13))]))),
      ]))),
    ]));
  }
}

class _Leyes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _Ley('1. Pertenencia', 'El sistema llena los vacios. Todos tienen derecho a pertenecer.'),
      _Ley('2. Orden y Jerarquia', 'Saber quien llega primero y respetarlo. Cada miembro en su lugar.'),
      _Ley('3. Equilibrio', 'Importante saber recibir y dar siempre un poco mas.'),
    ]);
  }
}

class _Ley extends StatelessWidget {
  final String t; final String d;
  const _Ley(this.t, this.d);
  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
      const SizedBox(height: 8),
      Text(d, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
    ])));
  }
}

class _Rueda extends StatefulWidget {
  @override
  State<_Rueda> createState() => _RuedaState();
}

class _RuedaState extends State<_Rueda> {
  List<Arcano> _cards = [];

  void _pick() {
    final s = List<Arcano>.from(allArcanos)..shuffle();
    setState(() => _cards = s.take(7).toList());
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Las Constelaciones Familiares revelan dinamicas ocultas del sistema familiar.',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.shuffle),
            label: const Text('Seleccionar Cartas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.purplePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          if (_cards.isNotEmpty)
            SizedBox(
              width: 350,
              height: 350,
              child: Stack(
                children: [
                  for (int i = 0; i < _cards.length; i++)
                    Positioned(
                      left: 175 + 120 * cos(2 * 3.14159 * i / _cards.length) - 27,
                      top: 175 + 120 * sin(2 * 3.14159 * i / _cards.length) - 37,
                      child: GestureDetector(
                        onTap: () => _showInfo(context, _cards[i]),
                        child: Container(
                          width: 55,
                          height: 75,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.goldAccent.withAlpha(120), width: 1.5),
                            boxShadow: [BoxShadow(color: AppTheme.purplePrimary.withAlpha(60), blurRadius: 8)],
                          ),
                          child: Center(
                            child: Text(
                              _cards[i].nombreRomano,
                              style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Toca una carta para ver su mensaje',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext c, Arcano a) {
    showDialog(context: c, builder: (ctx) => AlertDialog(
      title: Text(a.nombreCompleto, style: const TextStyle(color: AppTheme.purplePrimary)),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(a.leyEspiritual, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8), Text(a.leccionVida),
        const SizedBox(height: 8), Text('Miedo: ${a.miedoAsociado}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
    ));
  }
}

class _Frases extends StatelessWidget {
  final frases = ['Te veo. Te tomo como eres.', 'Tu eres el mayor, yo soy el menor.', 'Por favor, bendiceme.', 'Lo siento. Gracias. Te amo.', 'Confio en la vida.', 'Acepto mi origen.', 'Gracias por la vida.', 'Paz entre nosotros.'];
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16),
      children: frases.map((f) => Card(child: ListTile(leading: Icon(Icons.favorite, color: AppTheme.purplePrimary.withAlpha(150)), title: Text(f, style: const TextStyle(fontStyle: FontStyle.italic))))).toList());
  }
}

class _Secretos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Los hijos reproducen los secretos familiares:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
        const SizedBox(height: 12),
        _Secret('- Primogenito: Padre', 'El primero hereda la lealtad del padre.'),
        _Secret('- Segundo: Madre', 'El segundo carga la balanza con la madre.'),
        _Secret('- Tercero: Matrimonio', 'El tercero busca el equilibrio en la pareja.'),
        _Secret('- Cuarto: Familia', 'El cuarto restaura el orden del sistema.'),
      ]))),
    ]));
  }
}

class _Secret extends StatelessWidget {
  final String title;
  final String desc;
  const _Secret(this.title, this.desc);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary)),
      const SizedBox(height: 4),
      Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
    ]));
  }
}
