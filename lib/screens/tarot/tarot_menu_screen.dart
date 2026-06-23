import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/spreads_data.dart';
import 'tarot_reading_screen.dart';

class TarotMenuScreen extends StatelessWidget {
  const TarotMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiradas de Tarot')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Selecciona una tirada:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
        const SizedBox(height: 16),
        ...allSpreads.map((s) => Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TarotReadingScreen(spread: s))),
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: AppTheme.purplePrimary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.style, color: AppTheme.purplePrimary, size: 26)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.purplePrimary)),
              Text(s.descripcion, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.goldAccent.withAlpha(30), borderRadius: BorderRadius.circular(12)),
              child: Text('${s.numCartas} cartas', style: const TextStyle(fontSize: 11, color: AppTheme.purplePrimary, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: AppTheme.purplePrimary),
          ])))),
      ]),
    );
  }
}
