import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';
import '../../models/arcano.dart';
import 'arcana_detail_screen.dart';

class ArcanaLibraryScreen extends StatefulWidget {
  const ArcanaLibraryScreen({super.key});
  @override
  State<ArcanaLibraryScreen> createState() => _ArcanaLibraryScreenState();
}

class _ArcanaLibraryScreenState extends State<ArcanaLibraryScreen> {
  String _query = '';
  List<Arcano> get _filtered => _query.isEmpty ? allArcanos : allArcanos.where((a) =>
    a.nombre.toLowerCase().contains(_query.toLowerCase()) ||
    a.nombreRomano.toLowerCase().contains(_query.toLowerCase()) ||
    a.leyEspiritual.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Arcanos')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search), suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _query = '')) : null))),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _filtered.length,
          itemBuilder: (context, i) => _Card(arcano: _filtered[i]),
        )),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final Arcano arcano;
  const _Card({required this.arcano});

  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArcanaDetailScreen(arcano: arcano))),
      child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/cards/arcano_${arcano.numero}.png',
            width: 120, height: 170, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 120, height: 170,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(arcano.nombreRomano, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(arcano.nombre, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.purplePrimary)),
      ]))));
  }
}
