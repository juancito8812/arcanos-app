import 'dart:async';
import 'package:flutter/material.dart';
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
        onTap: () => navigateWithScale(context, _buildDetailScreen()),
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
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppTheme.purplePrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(_card!.arcanoNombreRomano,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
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
                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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

  Widget _buildDetailScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Carta del Dia — ${_card!.arcanoNombre}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.purplePrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Text(_card!.arcanoNombreRomano,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
              const SizedBox(height: 12),
              Text(_card!.arcanoNombre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
            ]),
          ),
          if (_card!.aiInterpretation != null) ...[
            const SizedBox(height: 24),
            const Text('Interpretacion',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(_card!.aiInterpretation!,
              style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
          ],
        ]),
      ),
    );
  }
}
