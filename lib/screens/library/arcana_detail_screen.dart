import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/arcano.dart';
import '../../utils/animated_widgets.dart';

class ArcanaDetailScreen extends StatelessWidget {
  final Arcano arcano;
  const ArcanaDetailScreen({super.key, required this.arcano});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(arcano.nombre)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Hero card image
          StaggeredFadeIn(index: 0, child: _CardImage(arcano: arcano)),
          const SizedBox(height: 20),
          // Name and archetype
          StaggeredFadeIn(index: 1, child: _Title(arcano: arcano)),
          const SizedBox(height: 20),
          // Info sections
          StaggeredFadeIn(index: 2, child: _Sec(title: 'Ley Espiritual', body: arcano.leyEspiritual, icon: Icons.lightbulb_outline)),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 3, child: _Sec(title: 'Leccion de Vida', body: arcano.leccionVida, icon: Icons.school_outline)),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 4, child: _Sec(title: 'Miedo Asociado', body: arcano.miedoAsociado, icon: Icons.psychology_outline)),
          const SizedBox(height: 20),
          // Chips
          StaggeredFadeIn(index: 5, child: _Chips(arcano: arcano)),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final Arcano arcano;
  const _CardImage({required this.arcano});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: 'arcano_\${arcano.numero}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/cards/arcano_\${arcano.numero}.png',
            width: 200, height: 290, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 200, height: 290,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.purplePrimary.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Center(
                child: Text(arcano.nombreRomano,
                  style: const TextStyle(color: AppTheme.goldAccent, fontSize: 32, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final Arcano arcano;
  const _Title({required this.arcano});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(arcano.nombreCompleto,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text(arcano.arquetipo,
        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)),
    ]);
  }
}

class _Sec extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  const _Sec({required this.title, required this.body, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.purplePrimary.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purplePrimary.withAlpha(25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.purplePrimary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.purplePrimary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.purplePrimary)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
        ])),
      ]),
    );
  }
}

class _Chips extends StatelessWidget {
  final Arcano arcano;
  const _Chips({required this.arcano});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _Chip(label: arcano.elemento, color: Colors.orange, icon: Icons.whatshot),
      const SizedBox(width: 12),
      _Chip(label: arcano.polaridad, color: Colors.blue, icon: Icons.balance),
      const SizedBox(width: 12),
      _Chip(label: arcano.nuclear, color: Colors.green, icon: Icons.tag),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _Chip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
