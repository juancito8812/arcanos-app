import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';
import '../../data/arcanos_menores_data.dart';
import '../../models/arcano.dart';
import '../../models/arcano_menor.dart';
import '../../utils/animated_widgets.dart';
import '../../utils/route_transitions.dart';
import 'arcana_detail_screen.dart';
import 'arcano_menor_detail_screen.dart';

class ArcanaLibraryScreen extends StatefulWidget {
  const ArcanaLibraryScreen({super.key});
  @override
  State<ArcanaLibraryScreen> createState() => _ArcanaLibraryScreenState();
}

class _ArcanaLibraryScreenState extends State<ArcanaLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  late AnimationController _ac;
  late Animation<double> _searchAnim;
  bool _showSearch = false;

  List<Arcano> get _filteredMayores {
    final q = _searchCtrl.text.toLowerCase();
    return q.isEmpty ? allArcanos : allArcanos.where((a) =>
      a.nombre.toLowerCase().contains(q) ||
      a.nombreRomano.toLowerCase().contains(q) ||
      a.leyEspiritual.toLowerCase().contains(q)).toList();
  }

  List<ArcanoMenor> get _filteredMenores {
    final q = _searchCtrl.text.toLowerCase();
    return q.isEmpty ? allArcanosMenores : allArcanosMenores.where((a) =>
      a.nombre.toLowerCase().contains(q) ||
      a.palo.toLowerCase().contains(q) ||
      a.significado.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _searchAnim = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
            : null,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.goldAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Mayores'),
            Tab(text: 'Menores'),
          ],
        ),
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
      body: _tabCtrl.index == 0 ? _buildMayores() : _buildMenores(),
    );
  }

  Widget _buildMayores() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredMayores.length,
      itemBuilder: (context, i) => StaggeredFadeIn(
        index: i,
        child: _CardMayor(
          arcano: _filteredMayores[i],
          onTap: () => navigateWithSlide(context, ArcanaDetailScreen(arcano: _filteredMayores[i])),
        ),
      ),
    );
  }

  Widget _buildMenores() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredMenores.length,
      itemBuilder: (context, i) => StaggeredFadeIn(
        index: i,
        child: _CardMenor(
          arcano: _filteredMenores[i],
          onTap: () => navigateWithSlide(context, ArcanoMenorDetailScreen(arcano: _filteredMenores[i])),
        ),
      ),
    );
  }
}

class _CardMayor extends StatelessWidget {
  final Arcano arcano;
  final VoidCallback onTap;
  const _CardMayor({required this.arcano, required this.onTap});

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

class _CardMenor extends StatelessWidget {
  final ArcanoMenor arcano;
  final VoidCallback onTap;
  const _CardMenor({required this.arcano, required this.onTap});

  String _paloAsset(String palo) {
    switch (palo.toLowerCase()) {
      case 'copas': return 'Cups';
      case 'bastos': return 'Wands';
      case 'espadas': return 'Swords';
      case 'oros': return 'Pents';
      default: return 'Cups';
    }
  }

  String _rangoAsset(String rango) {
    switch (rango) {
      case 'as': return '01';
      case '2': return '02';
      case '3': return '03';
      case '4': return '04';
      case '5': return '05';
      case '6': return '06';
      case '7': return '07';
      case '8': return '08';
      case '9': return '09';
      case '10': return '10';
      case 'sota': return '11';
      case 'caballo': return '12';
      case 'reina': return '13';
      case 'rey': return '14';
      default: return '01';
    }
  }

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
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/cards/minor/${_paloAsset(arcano.palo)}${_rangoAsset(arcano.rango)}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        arcano.palo == 'Copas' ? Colors.blue : 
                        arcano.palo == 'Bastos' ? Colors.orange :
                        arcano.palo == 'Espadas' ? Colors.grey :
                        Colors.green,
                        AppTheme.purpleDark,
                      ]),
                    ),
                    child: Center(
                      child: Text(arcano.nombre,
                        style: const TextStyle(color: AppTheme.goldAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              color: AppTheme.purplePrimary.withAlpha(20),
              child: Text(arcano.nombre,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary),
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
