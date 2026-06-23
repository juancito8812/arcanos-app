import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/life_line.dart';
import '../../services/life_line_calculator.dart';

class NumericArrangementsScreen extends StatefulWidget {
  const NumericArrangementsScreen({super.key});
  @override
  State<NumericArrangementsScreen> createState() => _NumericArrangementsScreenState();
}

class _NumericArrangementsScreenState extends State<NumericArrangementsScreen> {
  final _ctrl = TextEditingController();
  DateTime _fecha = DateTime(1990, 1, 1);
  LifeLineResult? _result;
  bool _loading = false;

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _calc() {
    final n = _ctrl.text.trim();
    if (n.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa tu nombre'))); return; }
    setState(() => _loading = true);
    final r = LifeLineCalculator.calcular(nombreCompleto: n, fechaNacimiento: _fecha);
    setState(() { _loading = false; _result = r; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arreglos Numericos')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: _loading ? null : _calc,
            child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Calcular'))),
        ]))),
        if (_result != null) ...[
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Linea de Vida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
            ..._result!.arcanos.map((a) => Padding(padding: const EdgeInsets.only(top: 8), child: Text('${a.nombre}: ${a.arcano.nombreCompleto}'))),
          ]))),
        ],
      ])),
    );
  }
}
