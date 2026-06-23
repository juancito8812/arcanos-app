import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';
import '../../models/tarot_spread.dart';
import '../../models/arcano.dart';

class TarotReadingScreen extends StatefulWidget {
  final TarotSpread spread;
  const TarotReadingScreen({super.key, required this.spread});
  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> with SingleTickerProviderStateMixin {
  List<Arcano>? _cards;
  bool _shuffling = false;
  late AnimationController _ac;
  late Animation<double> _anim;

  @override void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
  }
  @override void dispose() { _ac.dispose(); super.dispose(); }

  void _shuffle() {
    setState(() { _shuffling = true; _cards = null; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      final s = List<Arcano>.from(allArcanos)..shuffle(Random());
      setState(() { _cards = s.take(widget.spread.numCartas).toList(); _shuffling = false; });
      _ac.reset(); _ac.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.spread.nombre)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: _shuffling ? null : _shuffle,
            icon: _shuffling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.shuffle),
            label: Text(_shuffling ? 'Barajando...' : (_cards == null ? 'Barajar y Tirar' : 'Volver a Tirar')))),
        const SizedBox(height: 20),
        if (_shuffling)
          const SizedBox(height: 100, child: Center(child: Column(children: [
            Icon(Icons.style, size: 60, color: AppTheme.purplePrimary),
            SizedBox(height: 8),
            Text('Concentra tu intencion...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            SizedBox(height: 16),
            LinearProgressIndicator(color: AppTheme.purplePrimary, backgroundColor: AppTheme.purpleLight),
          ])))
        else if (_cards != null)
          FadeTransition(opacity: _anim, child: Column(children: _cards!.asMap().entries.map((e) => _CardWidget(position: e.key, posName: widget.spread.posiciones[e.key], arcano: e.value)).toList())),
      ])),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final int position; final String posName; final Arcano arcano;
  const _CardWidget({required this.position, required this.posName, required this.arcano});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.purplePrimary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
          child: Text('Pos. ${position + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary))),
        const SizedBox(width: 8),
        Text(posName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.purplePrimary)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/cards/arcano_${arcano.numero}.png',
            width: 65, height: 95, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(width: 65, height: 95,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(arcano.nombreRomano, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold)))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(arcano.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.purplePrimary)),
          const SizedBox(height: 4),
          Text(arcano.leyEspiritual, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 3),
        ])),
      ]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.goldLight.withAlpha(100), borderRadius: BorderRadius.circular(12)),
        child: Text(_reflexion(arcano.numero), style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600], height: 1.4))),
    ])));
  }

  String _reflexion(int n) {
    switch (n) {
      case 0: return 'Que nuevo comienzo llama a tu puerta?';
      case 1: return 'Que estas creando con tus pensamientos?';
      case 2: return 'Que recuerdos necesitan ser comprendidos?';
      case 3: return 'Que debes nutrir y hacer crecer?';
      case 4: return 'Donde necesitas poner orden?';
      case 5: return 'Que ensenanza trae esta circunstancia?';
      case 6: return 'Que decisiones del corazon evitas?';
      case 7: return 'Hacia donde te impulsa tu voluntad?';
      case 8: return 'Que consecuencias debes reconocer?';
      case 9: return 'Que sabiduria encuentras en el silencio?';
      case 10: return 'Que ciclo esta terminando?';
      case 11: return 'Donde encuentras fuerza interior?';
      case 12: return 'A que debes rendirte?';
      case 13: return 'Que transformacion ocurre?';
      case 14: return 'Como encuentras equilibrio?';
      case 15: return 'Que ataduras reconoces?';
      case 16: return 'Que estructuras se derrumban?';
      case 17: return 'Por que sientes gratitud?';
      case 18: return 'Que miedos emergen?';
      case 19: return 'Como conectas con tu alegria?';
      case 20: return 'A que despertar eres llamado?';
      case 21: return 'Que completitud buscas?';
      default: return 'Que mensaje trae esta carta?';
    }
  }
}
