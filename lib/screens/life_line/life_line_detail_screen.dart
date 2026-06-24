import 'package:flutter/material.dart';
import 'package:arcanos_mayores/theme.dart';
import 'package:arcanos_mayores/models/life_line.dart';
import 'package:arcanos_mayores/data/arcanos_data.dart';

class LifeLineDetailScreen extends StatelessWidget {
  final ArcanoPosicion pos;
  const LifeLineDetailScreen({super.key, required this.pos});

  @override
  Widget build(BuildContext context) {
    final arcano = getArcanoByNumero(pos.arcano.numero);
    return Scaffold(
      appBar: AppBar(title: Text(pos.arcano.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/cards/arcano_${pos.arcano.numero}.png',
              width: 200, height: 290, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 200, height: 290,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(pos.arcano.nombreRomano,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.goldAccent))),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('${pos.arcano.nombreRomano} — ${pos.arcano.nombre}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${pos.nombre} (${pos.edadPeriodo})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.goldAccent)),
          ),
          const SizedBox(height: 24),
          if (arcano != null) ...[
            _Section(title: 'Ley Espiritual', body: arcano.leyEspiritual),
            _Section(title: 'Leccion de Vida', body: arcano.leccionVida),
            _Section(title: 'Arquetipo', body: '${arcano.arquetipo} | ${arcano.elemento} | ${arcano.polaridad}'),
            _Section(title: 'Desafio', body: arcano.miedoAsociado),
          ],
          _Section(title: 'Significado en esta posicion', body: pos.significado),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.goldAccent, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(body, style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).colorScheme.onSurface)),
      ]),
    );
  }
}
