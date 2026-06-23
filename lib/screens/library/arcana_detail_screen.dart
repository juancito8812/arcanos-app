import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/arcano.dart';

class ArcanaDetailScreen extends StatelessWidget {
  final Arcano arcano;
  const ArcanaDetailScreen({super.key, required this.arcano});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(arcano.nombre)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppTheme.purplePrimary.withAlpha(80), blurRadius: 20, spreadRadius: 2)]),
          child: Column(children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.goldAccent, width: 3)),
              child: Center(child: Text(arcano.nombreRomano, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 28, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 16),
            Text(arcano.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(arcano.arquetipo, style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(200), fontStyle: FontStyle.italic)),
          ])),
        const SizedBox(height: 20),
        _Sec(title: 'Ley Espiritual', content: arcano.leyEspiritual),
        const SizedBox(height: 12),
        _Sec(title: 'Leccion de Vida', content: arcano.leccionVida),
        const SizedBox(height: 12),
        _Sec(title: 'Miedo Asociado', content: arcano.miedoAsociado),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Chip(label: 'Elemento', value: arcano.elemento)),
          const SizedBox(width: 8),
          Expanded(child: _Chip(label: 'Polaridad', value: arcano.polaridad)),
          const SizedBox(width: 8),
          Expanded(child: _Chip(label: 'Nuclear', value: '${arcano.valorNuclear}')),
        ]),
        const SizedBox(height: 20),
      ])),
    );
  }
}

class _Sec extends StatelessWidget {
  final String title; final String content;
  const _Sec({required this.title, required this.content});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
      const SizedBox(height: 8),
      Text(content, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
    ])));
  }
}

class _Chip extends StatelessWidget {
  final String label; final String value;
  const _Chip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: AppTheme.purplePrimary.withAlpha(15), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary), textAlign: TextAlign.center),
      ]));
  }
}
