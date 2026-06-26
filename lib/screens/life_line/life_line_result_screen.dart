import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/life_line.dart';
import '../../data/arcanos_data.dart';
import '../../utils/animated_widgets.dart';
import '../../utils/route_transitions.dart';
import 'life_line_detail_screen.dart';

class LifeLineResultScreen extends StatelessWidget {
  final LifeLineResult result;
  final String nombre;
  final DateTime fecha;
  const LifeLineResultScreen({super.key, required this.result, required this.nombre, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Linea de Vida')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // User info header
          StaggeredFadeIn(index: 0, child: _Header(nombre: nombre, fecha: fecha)),
          const SizedBox(height: 24),
          // Arcana cards
          for (int i = 0; i < result.arcanos.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: StaggeredFadeIn(
                index: i + 1,
                child: _PosCard(pos: result.arcanos[i], index: i + 1),
              ),
            ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String nombre;
  final DateTime fecha;
  const _Header({required this.nombre, required this.fecha});

  @override
  Widget build(BuildContext context) {
        final fmt = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year.toString()}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.purplePrimary.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(fmt, style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(170))),
        ])),
      ]),
    );
  }
}

class _PosCard extends StatefulWidget {
  final ArcanoPosicion pos;
  final int index;
  const _PosCard({required this.pos, required this.index});

  @override
  State<_PosCard> createState() => _PosCardState();
}

class _PosCardState extends State<_PosCard> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arcano = getArcanoByNumero(widget.pos.arcano.numero);
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
      child: Card(
        elevation: 3,
        shadowColor: AppTheme.purplePrimary.withAlpha(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTapDown: (_) => _ac.forward(),
          onTapUp: (_) { _ac.reverse(); navigateWithScale(context, LifeLineDetailScreen(pos: widget.pos)); },
          onTapCancel: () => _ac.reverse(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // Card image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/cards/arcano_${widget.pos.arcano.numero}.jpg',
                  width: 80, height: 115, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 80, height: 115,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(widget.pos.arcano.nombreRomano, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Position name with number badge
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.goldAccent.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('#${widget.index}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.purplePrimary)),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.pos.nombre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
                ]),
                const SizedBox(height: 4),
                Text('Edad ${widget.pos.edadPeriodo}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                if (arcano != null) ...[
                  const SizedBox(height: 6),
                  Text(arcano.leyEspiritual, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                ],
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}
