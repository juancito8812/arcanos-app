import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/life_line.dart';
import '../../data/arcanos_data.dart';

class LifeLineResultScreen extends StatelessWidget {
  final LifeLineResult result;
  const LifeLineResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Linea de Vida')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 32),
            const SizedBox(height: 8),
            Text(result.nombreCompleto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            Text('${result.fechaNacimiento.day}/${result.fechaNacimiento.month}/${result.fechaNacimiento.year}', style: TextStyle(color: Colors.white.withAlpha(180))),
          ])),
        const SizedBox(height: 20),
        ...result.arcanos.map((p) => _PosCard(pos: p)),
        const SizedBox(height: 20),
      ])),
    );
  }
}

class _PosCard extends StatelessWidget {
  final ArcanoPosicion pos;
  const _PosCard({required this.pos});

  @override
  Widget build(BuildContext context) {
    final arc = getArcanoByNumero(pos.arcano.numero);
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/cards/arcano_${pos.arcano.numero}.png',
            width: 55, height: 80, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(width: 55, height: 80,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(pos.arcano.nombreRomano, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold)))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pos.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.purplePrimary)),
          Text('Edad: ${pos.edadPeriodo}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.goldAccent.withAlpha(30), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.goldAccent.withAlpha(100))),
          child: Text('${pos.posicion}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.purplePrimary))),
      ]),
      const SizedBox(height: 12),
      Text(pos.significado, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
      if (arc != null) ...[
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.purplePrimary.withAlpha(10), borderRadius: BorderRadius.circular(12)),
          child: Text(arc.leyEspiritual, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic))),
      ],
    ])));
  }
}
