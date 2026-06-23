import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/life_line.dart';
import '../../models/arcano.dart';
import '../../services/life_line_calculator.dart';
import '../../data/arcanos_data.dart';

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

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(1900), lastDate: DateTime(2030));
    if (d != null) setState(() => _fecha = d);
  }

  void _calc() {
    final n = _ctrl.text.trim();
    if (n.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa tu nombre completo')));
      return;
    }
    setState(() => _loading = true);
    final r = LifeLineCalculator.calcular(nombreCompleto: n, fechaNacimiento: _fecha);
    setState(() { _loading = false; _result = r; });
  }

  int _nuclear(int num) {
    if (num <= 9) return num;
    int n = num;
    while (n > 9 && n != 11 && n != 22) {
      int s = 0;
      while (n > 0) { s += n % 10; n ~/= 10; }
      n = s;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arreglos Numericos')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // Input form
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person_outline), hintText: 'Ej: Ana Maria Perez Garcia'),
            textCapitalization: TextCapitalization.words),
          const SizedBox(height: 12),
          InkWell(onTap: _pickDate, child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(border: Border.all(color: AppTheme.purplePrimary.withAlpha(80)), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.calendar_today, color: AppTheme.purplePrimary),
              const SizedBox(width: 12),
              Text('${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}', style: const TextStyle(fontSize: 16)),
            ]),
          )),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: _loading ? null : _calc,
            child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Calcular Arreglos'))),
        ]))),
        const SizedBox(height: 16),
        if (_result != null) ...[
          _buildLineaDeVida(),
          const SizedBox(height: 12),
          _buildRelacionNuclear(),
          const SizedBox(height: 12),
          _buildFactorEspejo(),
          const SizedBox(height: 12),
          _buildArregloMaya(),
          const SizedBox(height: 12),
          _buildArregloConsciencia(),
          const SizedBox(height: 12),
          _buildTrampasMaya(),
          const SizedBox(height: 12),
          _buildPolaridad(),
          const SizedBox(height: 12),
          _buildTrios(),
        ],
      ])),
    );
  }

  List<int> get _nums => _result!.arcanos.map((a) => a.arcano.numero).toList();

  Widget _buildLineaDeVida() {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.timeline, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Linea de Vida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 12),
      ..._result!.arcanos.map((a) {
        final arc = getArcanoByNumero(a.arcano.numero);
        return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.purplePrimary, borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text('${a.posicion}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
          const SizedBox(width: 10),
          Expanded(child: Text('${a.nombre}: ${a.arcano.nombreCompleto}', style: const TextStyle(fontSize: 13))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.goldAccent.withAlpha(30), borderRadius: BorderRadius.circular(10)),
            child: Text('Edad ${a.edadPeriodo}', style: const TextStyle(fontSize: 10, color: AppTheme.purplePrimary))),
        ]));
      }),
    ])));
  }

  Widget _buildRelacionNuclear() {
    final nuclears = <int, List<int>>{};
    for (var n in _nums) {
      final nu = _nuclear(n);
      nuclears.putIfAbsent(nu, () => []);
      nuclears[nu]!.add(n);
    }
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.grain, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Relacion Nuclear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 4),
      Text('Conexion por valor numerico nuclear (reduccion a 1-9). Los arcanos que comparten valor nuclear comparten una energia base.',
        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      const SizedBox(height: 10),
      ..._nums.map((n) {
        final arc = getArcanoByNumero(n);
        final nu = _nuclear(n);
        return Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${arc?.nombre ?? n}: $n (Nuclear: $nu)', style: const TextStyle(fontSize: 13)));
      }),
      if (nuclears.entries.where((e) => e.value.length > 1).isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.goldLight.withAlpha(120), borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Arcanos que comparten energia nuclear:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ...nuclears.entries.where((e) => e.value.length > 1).map((e) {
              final names = e.value.map((n) => getArcanoByNumero(n)?.nombre ?? '$n').join(', ');
              return Text('Nuclear $e.key: $names', style: TextStyle(fontSize: 12, color: Colors.grey[700]));
            }),
          ])),
      ],
    ])));
  }

  Widget _buildFactorEspejo() {
    final repetidos = _nums.groupBy((n) => n).entries.where((e) => e.value.length > 1).toList();
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.flip, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Factor Espejo / Cobel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 4),
      Text('Cuando un arcano se repite genera exceso de energia. El arcano espejo ayuda a reestablecer el equilibrio.',
        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      const SizedBox(height: 10),
      if (repetidos.isEmpty)
        Text('No hay arcano
