import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/life_line.dart';
import '../../services/life_line_calculator.dart';
import '../../utils/animated_widgets.dart';
import '../../utils/route_transitions.dart';
import 'life_line_result_screen.dart';

class LifeLineInputScreen extends StatefulWidget {
  const LifeLineInputScreen({super.key});
  @override
  State<LifeLineInputScreen> createState() => _LifeLineInputScreenState();
}

class _LifeLineInputScreenState extends State<LifeLineInputScreen> {
  final _nameCtrl = TextEditingController();
  DateTime _fecha = DateTime(1990, 1, 1);
  bool _loading = false;

  @override void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _fecha,
      firstDate: DateTime(1900), lastDate: DateTime.now(),
      builder: (c, child) => Theme(data: Theme.of(c).copyWith(
        colorScheme: const ColorScheme.light(primary: AppTheme.purplePrimary),
      ), child: child!));
    if (d != null) setState(() => _fecha = d);
  }

  void _calc() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa tu nombre completo')));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final r = LifeLineCalculator.calcular(_nameCtrl.text.trim(), _fecha);
    setState(() => _loading = false);
    if (mounted) navigateWithSlide(context, LifeLineResultScreen(result: r, nombre: _nameCtrl.text.trim(), fecha: _fecha));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Linea de Vida')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          StaggeredFadeIn(index: 0, child: Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.purplePrimary.withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Column(children: [
              Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 40),
              SizedBox(height: 12),
              Text('Calcula tu Linea de Vida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 4),
              Text('Basado en tu nombre y fecha de nacimiento', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ]),
          )),
          const SizedBox(height: 28),
          StaggeredFadeIn(index: 1, child: TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              hintText: 'Ej: Ana Maria Perez',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: AppTheme.purplePrimary.withAlpha(8),
            ),
          )),
          const SizedBox(height: 16),
          StaggeredFadeIn(index: 2, child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.purplePrimary.withAlpha(50)),
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.purplePrimary.withAlpha(8),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppTheme.purplePrimary),
                const SizedBox(width: 12),
                Text('Fecha: ${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ]),
            ),
          )),
          const SizedBox(height: 28),
          StaggeredFadeIn(index: 3, child: SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _calc,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purplePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppTheme.purplePrimary.withAlpha(80),
              ),
              child: _loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Calcular mis 5 Arcanos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          )),
        ]),
      ),
    );
  }
}
