import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/route_transitions.dart';
import '../utils/animated_widgets.dart';
import 'life_line/life_line_input_screen.dart';
import 'tarot/tarot_menu_screen.dart';
import 'regressions/regression_screen.dart';
import 'constellations/constellation_screen.dart';
import 'library/arcana_library_screen.dart';
import 'arrangements/numeric_arrangements_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _items = [
    _ModuleData('Mi Linea de Vida', Icons.auto_awesome, 'Descubre tus 5 arcanos', LifeLineInputScreen()),
    _ModuleData('Tiradas de Tarot', Icons.style, 'Lecturas interactivas', TarotMenuScreen()),
    _ModuleData('Regresiones', Icons.self_improvement, 'Guiadas y reflexivas', RegressionScreen()),
    _ModuleData('Constelaciones', Icons.groups, 'Orden del sistema familiar', ConstellationScreen()),
    _ModuleData('Biblioteca', Icons.menu_book, 'Los 22 Arcanos Mayores', ArcanaLibraryScreen()),
    _ModuleData('Arreglos', Icons.grid_on, 'Analisis numerologicos', NumericArrangementsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(children: [
            // Header
            StaggeredFadeIn(index: 0, child: _Header()),
            const SizedBox(height: 28),
            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _items.length,
              itemBuilder: (context, i) => StaggeredFadeIn(
                index: i + 1,
                child: _ModuleCard(
                  data: _items[i],
                  onTap: () => navigateWithScale(context, _items[i].screen),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.purplePrimary, AppTheme.purpleDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purplePrimary.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(35),
          ),
          child: const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 36),
        ),
        const SizedBox(height: 16),
        const Text('PsicoTarot',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text('Arcanos Mayores',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withAlpha(180), letterSpacing: 2)),
      ]),
    );
  }
}

class _ModuleData {
  final String title;
  final IconData icon;
  final String subtitle;
  final Widget screen;
  const _ModuleData(this.title, this.icon, this.subtitle, this.screen);
}

class _ModuleCard extends StatefulWidget {
  final _ModuleData data;
  final VoidCallback onTap;
  const _ModuleCard({required this.data, required this.onTap});
  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, _) => GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) {
          _animController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _animController.reverse(),
        child: Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purplePrimary.withAlpha(25), AppTheme.purpleDark.withAlpha(15)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.purplePrimary.withAlpha(30)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purplePrimary.withAlpha(25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.purplePrimary.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.data.icon, color: AppTheme.purplePrimary, size: 26),
                ),
                const SizedBox(height: 12),
                Text(widget.data.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.purplePrimary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(widget.data.subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
