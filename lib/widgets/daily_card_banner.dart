import 'dart:async';
import 'package:flutter/material.dart';
import 'package:arcanos_mayores/data/arcanos_data.dart';
import 'package:arcanos_mayores/models/arcano.dart';
import 'package:arcanos_mayores/models/daily_card.dart';
import 'package:arcanos_mayores/services/daily_card_service.dart';
import 'package:arcanos_mayores/services/ai_service.dart';
import 'package:arcanos_mayores/services/database_service.dart';
import 'package:arcanos_mayores/theme.dart';
import 'package:arcanos_mayores/utils/route_transitions.dart';

class DailyCardBanner extends StatefulWidget {
  const DailyCardBanner({super.key});

  @override
  State<DailyCardBanner> createState() => _DailyCardBannerState();
}

class _DailyCardBannerState extends State<DailyCardBanner> {
  DailyCard? _card;
  bool _loading = true;
  bool _generatingInterpretation = false;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    final existing = await DailyCardService.getTodayCard();
    if (existing != null) {
      setState(() { _card = existing; _loading = false; });
      return;
    }
    setState(() { _loading = false; });
  }

  Future<void> _generateCard() async {
    setState(() { _loading = true; });
    final perfiles = await DatabaseService.obtenerPerfiles();
    final hasProfile = perfiles.isNotEmpty;
    DailyCard card;

    if (hasProfile) {
      final first = perfiles.first;
      final birthDate = DateTime.parse(first['fechaNacimiento'] as String);
      final age = DateTime.now().year - birthDate.year;
      final arcanos = [first['arcano1'], first['arcano2'], first['arcano3'], first['arcano4'], first['arcano5']]
          .whereType<int>().toList();
      card = await DailyCardService.generateDailyCard(
        hasProfile: true, ageYears: age, profileArcanos: arcanos);
    } else {
      card = await DailyCardService.generateDailyCard(hasProfile: false);
    }

    setState(() {
      _card = card;
      _loading = false;
      _generatingInterpretation = true;
    });

    final apiKey = const String.fromEnvironment('ARCANO_AI_KEY', defaultValue: '');
    AIService.setBuildTimeKey(apiKey.isEmpty ? null : apiKey);
    try {
      final interpretation = await AIService.interpretDailyCardByNumero(card.arcanoNumero, card.arcanoNombre);
      if (!interpretation.startsWith('Conectate')) {
        await DailyCardService.updateInterpretation(card.arcanoNumero, interpretation);
        final updated = await DailyCardService.getTodayCard();
        if (updated != null) {
          setState(() { _card = updated; });
        }
      }
    } catch (_) {}

    await DailyCardService.saveCard(_card!);
    setState(() { _generatingInterpretation = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_card == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: _generateCard,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.purplePrimary.withValues(alpha: 0.15), AppTheme.purpleDark.withValues(alpha: 0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.purplePrimary.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Icon(Icons.casino, color: AppTheme.goldAccent, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Carta del Dia',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
                  const SizedBox(height: 2),
                  Text('Toca para recibir tu carta',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                ]),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.purplePrimary, size: 16),
            ]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => navigateWithScale(context, _DailyCardDetail(card: _card!)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.purplePrimary.withValues(alpha: 0.12), AppTheme.purpleDark.withValues(alpha: 0.06)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/cards/arcano_${_card!.arcanoNumero}.jpg',
                width: 52, height: 74, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 52, height: 74,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(_card!.arcanoNombreRomano, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Carta del Dia',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(_card!.arcanoNombre,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
                if (_generatingInterpretation)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(children: [
                      SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.goldAccent),
                      ),
                      const SizedBox(width: 6),
                      Text('Consultando a los astros...',
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                    ]),
                  ),
              ]),
            ),
            Icon(Icons.visibility, color: AppTheme.purplePrimary, size: 20),
          ]),
        ),
      ),
    );
  }
}

class _DailyCardDetail extends StatelessWidget {
  final DailyCard card;
  const _DailyCardDetail({required this.card});

  @override
  Widget build(BuildContext context) {
    final arcano = getArcanoByNumero(card.arcanoNumero);
    return Scaffold(
      appBar: AppBar(title: Text('Carta del Dia — ${card.arcanoNombre}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/cards/arcano_${card.arcanoNumero}.jpg',
                width: 180, height: 258, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 180, height: 258,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(card.arcanoNombreRomano,
                    style: const TextStyle(color: AppTheme.goldAccent, fontSize: 40, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(card.arcanoNombreRomano,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(card.arcanoNombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
          ])),
          if (card.aiInterpretation != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.goldAccent.withAlpha(30), AppTheme.goldAccent.withAlpha(10)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 18),
                  SizedBox(width: 8),
                  Text('Interpretacion del Dia',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.purplePrimary)),
                ]),
                const SizedBox(height: 8),
                Text(card.aiInterpretation!, style: const TextStyle(fontSize: 15, height: 1.6)),
              ]),
            ),
          ],
          if (arcano != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            _Sec(title: 'Ley Espiritual', body: arcano.leyEspiritual, icon: Icons.lightbulb_outline),
            const SizedBox(height: 12),
            _Sec(title: 'Leccion de Vida', body: arcano.leccionVida, icon: Icons.school),
            const SizedBox(height: 12),
            _Sec(title: 'Arquetipo', body: arcano.arquetipo, icon: Icons.psychology),
            const SizedBox(height: 12),
            _Sec(title: 'Desafio', body: arcano.desafio, icon: Icons.warning_amber_rounded),
            const SizedBox(height: 12),
            _Sec(title: 'Perspectiva Transgeneracional', body: arcano.perspectivaTransgeneracional, icon: Icons.account_tree),
            const SizedBox(height: 12),
            _Sec(title: 'Significado', body: arcano.significadoPosicion, icon: Icons.explore),
            const SizedBox(height: 12),
            _Sec(title: 'Afirmacion Sanadora', body: arcano.afirmacionSanadora, icon: Icons.auto_awesome),
            const SizedBox(height: 20),
            _DailyChips(arcano: arcano),
          ],
        ]),
      ),
    );
  }
}

class _Sec extends StatelessWidget {
  final String title; final String body; final IconData icon;
  const _Sec({required this.title, required this.body, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.purplePrimary.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.purplePrimary.withAlpha(20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppTheme.purplePrimary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 1)),
        ]),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(fontSize: 15, height: 1.6)),
      ]),
    );
  }
}

class _DailyChips extends StatelessWidget {
  final Arcano arcano;
  const _DailyChips({required this.arcano});
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _chip('Elemento', arcano.elemento, Icons.water_drop),
      _chip('Arquetipo', arcano.arquetipo, Icons.psychology),
      _chip('Polaridad', arcano.polaridad, Icons.balance),
      _chip('Color', arcano.colorAsociado, Icons.palette),
      _chip('Nivel', '${arcano.nivel}', Icons.layers),
    ]);
  }

  Widget _chip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.purplePrimary.withAlpha(12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.purplePrimary.withAlpha(30)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppTheme.purplePrimary),
        const SizedBox(width: 6),
        Text('$label: $value', style: const TextStyle(fontSize: 12, color: AppTheme.purplePrimary, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
