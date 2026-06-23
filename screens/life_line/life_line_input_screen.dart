import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/life_line_calculator.dart';
import 'life_line_result_screen.dart';

class LifeLineInputScreen extends StatefulWidget {
  const LifeLineInputScreen({super.key});
  @override
  State<LifeLineInputScreen> createState() => _LifeLineInputScreenState();
}

class _LifeLineInputScreenState extends State<LifeLineInputScreen> {
  final _nombreController = TextEditingController();
  DateTime _fecha = DateTime(1990, 1, 1);
  bool _loading = false;

  @override void dispose() { _nombreController.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(1900), lastDate: DateTime(2030));
    if (d != null) setState(() => _fecha = d);
  }

  void _calcular() {
    final nom = _nombreController.text.trim();
    if (nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa tu nombre completo')));
      return;
    }
    setState(() => _loading = true);
    final r = LifeLineCalculator.calcular(nombreCompleto: nom, fechaNacimiento: _fecha);
    setState(() => _loading = false);
    if (r == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al calcular')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => LifeLineResultScreen(result: r)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Linea de Vida')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 10),
        Icon(Icons.timeline, size: 60, color: AppTheme.goldAccent.withAlpha(180)),
        const SizedBox(height: 16),
        const Text('Descubre tus 5 Arcanos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
        const SizedBox(height: 20),
        TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person_outline), hintText: 'Ej: Ana Maria Perez Garcia'),
          textCapitalization: TextCapitalization.words),
        const SizedBox(height: 16),
        InkWell(onTap: _pickDate, child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(border: Border.all(color: AppTheme.purplePrimary.withAlpha(80)), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(Icons.calendar_today, color: AppTheme.purplePrimary),
            const SizedBox(width: 12),
            Text('${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}', style: const TextStyle(fontSize: 16)),
          ]),
        )),
        const SizedBox(height: 30),
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton(onPressed: _loading ? null : _calcular,
            child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Calcular mi Linea de Vida', style: TextStyle(fontSize: 16)))),
      ])),
    );
  }
}
