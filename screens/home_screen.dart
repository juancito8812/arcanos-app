import 'package:flutter/material.dart';
import '../theme.dart';
import 'life_line/life_line_input_screen.dart';
import 'tarot/tarot_menu_screen.dart';
import 'regressions/regression_screen.dart';
import 'constellations/constellation_screen.dart';
import 'library/arcana_library_screen.dart';
import 'arrangements/numeric_arrangements_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: AppTheme.purplePrimary.withAlpha(80), blurRadius: 20, spreadRadius: 2)]),
                child: const Icon(Icons.auto_awesome, size: 50, color: AppTheme.goldAccent)),
              const SizedBox(height: 16),
              const Text('PsicoTarot', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary, letterSpacing: 2)),
              const SizedBox(height: 30),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: _items.length,
                itemBuilder: (context, i) => _ModuleCard(item: _items[i]),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleData {
  final String title; final IconData icon; final Widget screen; final String subtitle;
  const _ModuleData(this.title, this.icon, this.screen, this.subtitle);
}

const List<_ModuleData> _items = [
  _ModuleData('Mi Linea de Vida', Icons.timeline, LifeLineInputScreen(), '5 arcanos'),
  _ModuleData('Tiradas de Tarot', Icons.style, TarotMenuScreen(), 'Lecturas'),
  _ModuleData('Regresiones', Icons.self_improvement, RegressionScreen(), 'Vidas pasadas'),
  _ModuleData('Constelaciones', Icons.people, ConstellationScreen(), 'Sistemica'),
  _ModuleData('Biblioteca', Icons.menu_book, ArcanaLibraryScreen(), '22 Arcanos'),
  _ModuleData('Arreglos', Icons.calculate, NumericArrangementsScreen(), 'Numerologia'),
];

class _ModuleCard extends StatelessWidget {
  final _ModuleData item;
  const _ModuleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
        child: Padding(padding: const EdgeInsets.all(14),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: AppTheme.purplePrimary.withAlpha(25), borderRadius: BorderRadius.circular(15)),
              child: Icon(item.icon, color: AppTheme.purplePrimary, size: 26)),
            const SizedBox(height: 10),
            Text(item.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary)),
            const SizedBox(height: 4),
            Text(item.subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ]),
        ),
      ),
    );
  }
}
