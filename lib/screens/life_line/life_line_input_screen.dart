import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';
import '../../models/life_line.dart';
import '../../services/life_line_calculator.dart';
import '../../services/database_service.dart';
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
  final _nameFocus = FocusNode();
  DateTime _fecha = DateTime(1990, 1, 1);
  bool _loading = false;
  String? _nameError;
  List<String> _savedNames = [];
  bool _showSuggestions = false;

  static final _nameRegex = RegExp(r"^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ\s.'-]+$");

  @override
  void initState() {
    super.initState();
    _loadNames();
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) setState(() => _showSuggestions = false);
    });
  }

  @override void dispose() { _nameCtrl.dispose(); _nameFocus.dispose(); super.dispose(); }

  Future<void> _loadNames() async {
    final prefs = await SharedPreferences.getInstance();
    _savedNames = prefs.getStringList('saved_names') ?? [];
  }

  Future<void> _saveName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _savedNames.remove(trimmed);
    _savedNames.insert(0, trimmed);
    if (_savedNames.length > 10) _savedNames = _savedNames.sublist(0, 10);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_names', _savedNames);
    await prefs.setString('saved_date_$trimmed', _fecha.toIso8601String());
  }

  Future<void> _loadDateForName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString('saved_date_$name');
    if (dateStr != null) {
      final d = DateTime.tryParse(dateStr);
      if (d != null) setState(() => _fecha = d);
    }
  }

  List<String> _filteredSuggestions() {
    final query = _nameCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _savedNames;
    return _savedNames.where((n) => n.toLowerCase().contains(query)).toList();
  }

  String? _validateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Ingresa tu nombre completo';
    if (v.length < 3) return 'El nombre debe tener al menos 3 caracteres';
    if (v.length > 100) return 'El nombre es demasiado largo (max. 100 caracteres)';
    if (!_nameRegex.hasMatch(v)) return 'Solo se permiten letras y espacios';
    return null;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _fecha,
      firstDate: DateTime(1900), lastDate: DateTime.now(),
      builder: (c, child) => Theme(data: Theme.of(c).copyWith(
        colorScheme: const ColorScheme.light(primary: AppTheme.purplePrimary),
      ), child: child!));
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _guardarPerfil(String name, LifeLineResult result) async {
    await DatabaseService.guardarPerfil({
      'nombre': name,
      'fechaNacimiento': _fecha.toIso8601String(),
      'arcano1': result.arcanos[0].arcano.numero,
      'arcano2': result.arcanos[1].arcano.numero,
      'arcano3': result.arcanos[2].arcano.numero,
      'arcano4': result.arcanos[3].arcano.numero,
      'arcano5': result.arcanos[4].arcano.numero,
      'fechaCreacion': DateTime.now().toIso8601String(),
    });
  }

  void _calc() async {
    final error = _validateName(_nameCtrl.text);
    if (error != null) {
      setState(() => _nameError = error);
      _nameFocus.requestFocus();
      return;
    }
    setState(() { _loading = true; _nameError = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    final name = _nameCtrl.text.trim();
    final result = LifeLineCalculator.calcular(nombreCompleto: name, fechaNacimiento: _fecha);
    setState(() => _loading = false);
    if (mounted && result != null) {
      await _saveName(name);
      await _guardarPerfil(name, result);
      navigateWithSlide(context, LifeLineResultScreen(result: result, nombre: name, fecha: _fecha));
    }
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
            focusNode: _nameFocus,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              hintText: 'Ej: Ana Maria Perez',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: AppTheme.purplePrimary.withAlpha(8),
              errorText: _nameError,
              errorMaxLines: 2,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = _validateName(_nameCtrl.text));
              setState(() => _showSuggestions = _savedNames.isNotEmpty);
            },
            onTap: () => setState(() => _showSuggestions = _savedNames.isNotEmpty),
          )),
          if (_showSuggestions && _filteredSuggestions().isNotEmpty)
            StaggeredFadeIn(index: 1, child: Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.purplePrimary.withAlpha(30)),
              ),
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredSuggestions().length,
                itemBuilder: (c, i) {
                  final name = _filteredSuggestions()[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 18, color: AppTheme.purplePrimary),
                    title: Text(name, style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      _nameCtrl.text = name;
                      _nameCtrl.selection = TextSelection.fromPosition(TextPosition(offset: name.length));
                      _loadDateForName(name);
                      setState(() => _showSuggestions = false);
                    },
                  );
                },
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
