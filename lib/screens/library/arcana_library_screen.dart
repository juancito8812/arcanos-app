import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';
import '../../models/arcano.dart';
import '../../utils/animated_widgets.dart';
import '../../utils/route_transitions.dart';
import 'arcana_detail_screen.dart';

class ArcanaLibraryScreen extends StatefulWidget {
  const ArcanaLibraryScreen({super.key});
  @override
  State<ArcanaLibraryScreen> createState() => _ArcanaLibraryScreenState();
}

class _ArcanaLibraryScreenState extends State<ArcanaLibraryScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late AnimationController _ac;
  late Animation<double> _searchAnim;
  bool _showSearch = false;

  List<Arcano> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return q.isEmpty ? allArcanos : allArcanos.where((a) =>
      a.nombre.toLowerCase().contains(q) ||
      a.nombreRomano.toLowerCase().contains(q) ||
      a.leyEspiritual.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _searchAnim = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? FadeTransition(
                opacity: _searchAnim,
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Buscar arcano...', border: InputBorder.none),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  onChanged: (_) => setState(() {}),
                ),
              )
            : const Text('Biblioteca de Arcanos'),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(_showSearch ? Icons.close : Icons.search, key: ValueKey(_showSearch)),
            ),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (_showSearch) { _ac.forward(); } else { _ac.reverse(); _searchCtrl.clear(); }
            },
          ),
        ],
      ),
      body: GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filtered.length,
          itemBuilder: (context, i) => StaggeredFadeIn(
            index: i,
            child: _Card(
              arcano: _filtered[i],
              onTap: () => navigateWithSlide(context, ArcanaDetailScreen(arcano: _filtered[i])),
            ),
          ),
    ));
  }
}

class _Card extends StatelessWidget {
  final Arcano arcano;
  final VoidCallback onTap;
  const _Card({required this.arcano, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(children: [
            Expanded(
              child: Hero(
                  tag: 'arcano_${arcano.numero}',
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                  'assets/cards/arcano_${arcano.numero}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                    ),
                    child: Center(
                      child: Text(arcano.nombreRomano,
                        style: const TextStyle(color: AppTheme.goldAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
                    ),
                  ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: AppTheme.purplePrimary.withAlpha(20),
              child: Text(arcano.nombre,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
