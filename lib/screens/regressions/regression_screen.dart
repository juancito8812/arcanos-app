import 'package:flutter/material.dart';
import '../../theme.dart';

class RegressionScreen extends StatefulWidget {
  const RegressionScreen({super.key});
  @override
  State<RegressionScreen> createState() => _RegressionScreenState();
}

class _RegressionScreenState extends State<RegressionScreen> {
  int _type = 0;
  final List<_Type> _types = [
    _Type('Edad Temprana', Icons.child_care, 'Accede a recuerdos de la infancia para identificar patrones, traumas y bloqueos.'),
    _Type('Vidas Pasadas', Icons.history, 'Explora encarnaciones anteriores para comprender relaciones y miedos.'),
    _Type('Espacio entre Vidas', Icons.stars, 'Conecta con el proposito del alma y acuerdos prenatales.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Regresiones Guiadas')),
      body: Column(children: [
        SizedBox(height: 100, child: ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(12),
          itemCount: _types.length,
          itemBuilder: (context, i) {
            final sel = _type == i;
            return GestureDetector(onTap: () => setState(() => _type = i), child: Container(
              width: 140, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: sel ? AppTheme.purplePrimary : Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sel ? AppTheme.purplePrimary : AppTheme.purplePrimary.withAlpha(40))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(_types[i].icon, color: sel ? Colors.white : AppTheme.purplePrimary, size: 24),
                const SizedBox(height: 6),
                Text(_types[i].title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.purplePrimary)),
              ]),
            ));
          },
        )),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_types[_type].desc, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
          const SizedBox(height: 20),
          const Text('Guia de Regresion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
          const SizedBox(height: 16),
          _Paso(1, 'Preparacion', 'Busca un lugar tranquilo. Sientate comodamente. Cierra los ojos y respira profundamente 3 veces.'),
          _Paso(2, 'Relajacion', 'Inhala profundamente, exhala lentamente. Relaja cada parte de tu cuerpo, desde los pies hasta la cabeza.'),
          _Paso(3, 'Visualizacion', 'Imagina un tunel de luz. La luz te envuelve y te lleva a un espacio seguro.'),
          _Paso(4, 'Exploracion', 'Que ves? Que colores o personas estan presentes? Que emociones surgen?'),
          _Paso(5, 'Integracion', 'Pregunta: Que mensaje trae esta experiencia? Agradece y regresa contando del 1 al 5.'),
        ]))),
      ]),
    );
  }
}

class _Type { final String title; final IconData icon; final String desc; const _Type(this.title, this.icon, this.desc); }

class _Paso extends StatelessWidget {
  final int n; final String t; final String d;
  const _Paso(this.n, this.t, this.d);
  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppTheme.purplePrimary, shape: BoxShape.circle),
          child: Center(child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.purplePrimary)),
          Text(d, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
        ])),
      ])));
  }
}
