import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arcanos_mayores/models/destiny_matrix.dart';
import 'package:arcanos_mayores/services/destiny_matrix_calculator.dart';
import 'package:arcanos_mayores/services/database_service.dart';
import 'package:arcanos_mayores/theme.dart';

class DestinyMatrixScreen extends StatefulWidget {
  const DestinyMatrixScreen({super.key});

  @override
  State<DestinyMatrixScreen> createState() => _DestinyMatrixScreenState();
}

class _DestinyMatrixScreenState extends State<DestinyMatrixScreen> with WidgetsBindingObserver {
  DestinyMatrix? _matrix;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final perfiles = await DatabaseService.obtenerPerfiles();
    setState(() {
      _matrix = perfiles.isNotEmpty
          ? DestinyMatrixCalculator.calculate(DateTime.parse(perfiles.first['fechaNacimiento'] as String))
          : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_matrix == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Matriz del Destino')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 64, color: AppTheme.goldAccent.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Completa tu perfil en Mi Linea de Vida para ver tu Matriz del Destino.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matriz del Destino'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Text('Nacimiento: ${DateFormat('dd/MM/yyyy').format(_matrix!.birthDate)}',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          const SizedBox(height: 20),
          ..._matrix!.positions.map((pos) => _PositionCard(pos: pos)),
        ]),
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  final DestinyPosition pos;
  const _PositionCard({required this.pos});

  String _label(String key) {
    switch (key) {
      case 'day': return 'Energia del Dia';
      case 'month': return 'Energia del Mes';
      case 'year': return 'Energia del Ano';
      case 'essence': return 'Esencia / Proposito de Vida';
      case 'talent': return 'Talento / Herramientas';
      case 'challenge1': return 'Desafio Principal';
      case 'challenge2': return 'Desafio Secundario';
      case 'purpose': return 'Mision / Camino';
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.purplePrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(pos.nombreRomano,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.goldAccent)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_label(pos.key),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(pos.nombre,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
            ]),
          ),
        ]),
      ),
    );
  }
}
