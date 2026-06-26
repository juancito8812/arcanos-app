import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/life_line.dart';
import '../../services/life_line_calculator.dart';
import '../../services/database_service.dart';
import '../../data/arcanos_data.dart';
import '../../utils/animated_widgets.dart';

class NumericArrangementsScreen extends StatefulWidget {
  const NumericArrangementsScreen({super.key});
  @override
  State<NumericArrangementsScreen> createState() => _NumericArrangementsScreenState();
}

class _NumericArrangementsScreenState extends State<NumericArrangementsScreen> {
  final _ctrl = TextEditingController();
  final _nameFocus = FocusNode();
  DateTime _fecha = DateTime(1990, 1, 1);
  LifeLineResult? _result;
  bool _loading = false;
  String? _nameError;
  List<Map<String, dynamic>> _recent = [];

  static final _nameRegex = RegExp(r"^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ\s.'-]+$");

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override void dispose() { _ctrl.dispose(); _nameFocus.dispose(); super.dispose(); }

  Future<void> _loadRecent() async {
    final perfiles = await DatabaseService.obtenerPerfiles();
    setState(() => _recent = perfiles.take(10).toList());
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
    final d = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(1900), lastDate: DateTime(2030));
    if (d != null) setState(() => _fecha = d);
  }

  void _calcAndSave() {
    final error = _validateName(_ctrl.text);
    if (error != null) {
      setState(() => _nameError = error);
      _nameFocus.requestFocus();
      return;
    }
    setState(() { _loading = true; _nameError = null; });
    final n = _ctrl.text.trim();
    final r = LifeLineCalculator.calcular(nombreCompleto: n, fechaNacimiento: _fecha);
    if (r == null) return;
    setState(() { _loading = false; _result = r; });
    _saveToDb(n, r);
  }

  void _saveToDb(String nombre, LifeLineResult r) {
    final nums = r.arcanos.map((a) => a.arcano.numero).toList();
    DatabaseService.guardarPerfil({
      'nombre': nombre,
      'fechaNacimiento': '${_fecha.year}-${_fecha.month.toString().padLeft(2, '0')}-${_fecha.day.toString().padLeft(2, '0')}',
      'arcano1': nums.isNotEmpty ? nums[0] : null,
      'arcano2': nums.length > 1 ? nums[1] : null,
      'arcano3': nums.length > 2 ? nums[2] : null,
      'arcano4': nums.length > 3 ? nums[3] : null,
      'arcano5': nums.length > 4 ? nums[4] : null,
      'fechaCreacion': DateTime.now().toIso8601String(),
    }).then((_) => _loadRecent());
  }

  void _loadFromHistory(Map<String, dynamic> perfil) {
    _ctrl.text = perfil['nombre'] as String;
    _fecha = DateTime.parse(perfil['fechaNacimiento'] as String);
    final n = perfil['nombre'] as String;
    final r = LifeLineCalculator.calcular(nombreCompleto: n, fechaNacimiento: _fecha);
    setState(() { _result = r; _nameError = null; });
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

  List<int> get _nums => _result!.arcanos.map((a) => a.arcano.numero).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arreglos Numericos')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        if (_recent.isNotEmpty) ...[
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recent.length,
              itemBuilder: (ctx, i) {
                final p = _recent[i];
                final nombre = p['nombre'] as String;
                final fecha = p['fechaNacimiento'] as String;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(Icons.history, size: 16, color: AppTheme.goldAccent),
                    label: Text('$nombre\n$fecha', style: const TextStyle(fontSize: 10)),
                    onPressed: () => _loadFromHistory(p),
                    backgroundColor: AppTheme.purplePrimary.withAlpha(12),
                    side: BorderSide(color: AppTheme.purplePrimary.withAlpha(40)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          TextField(
            controller: _ctrl,
            focusNode: _nameFocus,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _calcAndSave(),
            decoration: InputDecoration(
              labelText: 'Nombre Completo',
              prefixIcon: const Icon(Icons.person_outline),
              hintText: 'Ej: Ana Maria Perez Garcia',
              errorText: _nameError,
              errorMaxLines: 2,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = _validateName(_ctrl.text));
            },
          ),
          const SizedBox(height: 12),
          InkWell(onTap: _pickDate, child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(border: Border.all(color: AppTheme.purplePrimary.withAlpha(80)), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.calendar_today, color: AppTheme.purplePrimary),
              const SizedBox(width: 12),
              Text('${_fecha.day}/${_fecha.month}/${_fecha.year}', style: const TextStyle(fontSize: 16)),
            ]),
          )),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: _loading ? null : _calcAndSave,
            child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Calcular Arreglos'))),
        ]))),
        const SizedBox(height: 16),
        if (_result != null) ...[
          StaggeredFadeIn(index: 0, child: _buildLineaDeVida()),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 1, child: _buildRelacionNuclear()),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 2, child: _buildFactorEspejo()),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 3, child: _buildArregloMaya()),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 4, child: _buildArregloConsciencia()),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 5, child: _buildTrampasMaya()),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 6, child: _buildPolaridad()),
          const SizedBox(height: 12),
          StaggeredFadeIn(index: 7, child: _buildTrios()),
        ],
      ])),
    );
  }

  Widget _buildLineaDeVida() {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.timeline, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Linea de Vida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 12),
      ..._result!.arcanos.map((a) {
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
    final groups = <int, List<int>>{};
    for (var n in _nums) {
      final nu = _nuclear(n);
      groups.putIfAbsent(nu, () => []).add(n);
    }
    final shared = groups.entries.where((e) => e.value.length > 1).toList();
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.grain, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Relacion Nuclear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 4),
      const Text('Conexion por valor numerico nuclear (reduccion a 1-9).', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 10),
      ..._nums.map((n) {
        final arc = getArcanoByNumero(n);
        return Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${arc?.nombre ?? n}: $n (Nuclear: ${_nuclear(n)})', style: const TextStyle(fontSize: 13)));
      }),
      if (shared.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.goldLight.withAlpha(120), borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Comparten energia nuclear:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ...shared.map((e) => Text('Nuclear ${e.key}: ${e.value.map((n) => getArcanoByNumero(n)?.nombre ?? '$n').join(', ')}', style: const TextStyle(fontSize: 12))),
          ])),
      ],
    ])));
  }

  Widget _buildFactorEspejo() {
    final counts = <int, int>{};
    for (var n in _nums) { counts[n] = (counts[n] ?? 0) + 1; }
    final repetidos = counts.entries.where((e) => e.value > 1).toList();
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.flip, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Factor Espejo / Cobel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 4),
      const Text('Cuando un arcano se repite genera exceso de energia.', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 10),
      if (repetidos.isEmpty)
        const Text('No hay arcanos repetidos.', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey))
      else ...[
        ...repetidos.map((e) {
          final arc = getArcanoByNumero(e.key);
          return Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${arc?.nombre ?? e.key} se repite ${e.value} veces', style: const TextStyle(fontSize: 13)));
        }),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.withAlpha(20), borderRadius: BorderRadius.circular(8)),
          child: const Text('Sugerencia: Trabaja la integracion del arcano repetido.', style: TextStyle(fontSize: 12))),
      ],
    ])));
  }

  Widget _buildArregloMaya() {
    return _PairCard(
      icon: Icons.warning_amber, iconColor: Colors.orange,
      title: 'Arreglo de Maya (Suma 23)',
      desc: 'Indica un obstaculo karmico a superar. La caida en la materia.',
      pairs: _findPairs(23),
    );
  }

  Widget _buildArregloConsciencia() {
    return _PairCard(
      icon: Icons.auto_awesome, iconColor: Colors.green,
      title: 'Arreglo de la Consciencia (Suma 21)',
      desc: 'Generan armonia para evolucionar.',
      pairs: _findPairs(21),
    );
  }

  Widget _buildTrampasMaya() {
    return _PairCard(
      icon: Icons.trip_origin, iconColor: Colors.red,
      title: 'Trampas de Maya (Suma 22)',
      desc: 'Espejismos. Advierten sobre el uso inapropiado de principios.',
      pairs: _findPairs(22),
    );
  }

  List<List<int>> _findPairs(int target) {
    final p = <List<int>>[];
    for (int i = 0; i < _nums.length; i++) {
      for (int j = i + 1; j < _nums.length; j++) {
        if (_nums[i] + _nums[j] == target) p.add([_nums[i], _nums[j]]);
      }
    }
    return p;
  }

  Widget _buildPolaridad() {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.balance, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Polaridad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 4),
      const Text('Pares (pasivos) e impares (activos) se complementan.', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 10),
      ..._nums.map((n) {
        final arc = getArcanoByNumero(n);
        final esPar = n % 2 == 0;
        return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
          Icon(esPar ? Icons.woman : Icons.man, size: 16, color: esPar ? AppTheme.purpleLight : Colors.blue[300]),
          const SizedBox(width: 8),
          Text('${arc?.nombre ?? n}: ${esPar ? "Pasivo (Femenino)" : "Activo (Masculino)"}', style: const TextStyle(fontSize: 13)),
        ]));
      }),
      const SizedBox(height: 8),
      Text('${_nums.where((n) => n % 2 == 0).length} pares, ${_nums.where((n) => n % 2 != 0).length} impares',
        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
    ])));
  }

  Widget _buildTrios() {
    final trios = <List<int>>[];
    for (int i = 0; i < _nums.length; i++) {
      for (int j = i + 1; j < _nums.length; j++) {
        for (int k = j + 1; k < _nums.length; k++) {
          if (_nums[i] != 0 && _nums[j] != 0 && _nums[k] != 0) {
            trios.add([_nums[i], _nums[j], _nums[k]]);
          }
        }
      }
    }
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.group, color: AppTheme.purplePrimary, size: 22), SizedBox(width: 8),
        Text('Trios de Arcanos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 4),
      const Text('Interaccion de fuerzas entre tres arcanos.', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 10),
      if (trios.isEmpty)
        const Text('No se encontraron trios.', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey))
      else
        ...trios.map((t) {
          final a1 = getArcanoByNumero(t[0]);
          final a2 = getArcanoByNumero(t[1]);
          final a3 = getArcanoByNumero(t[2]);
          return Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(
            '${a1?.nombre ?? t[0]} + ${a2?.nombre ?? t[1]} + ${a3?.nombre ?? t[2]} = ${t[0] + t[1] + t[2]}',
            style: const TextStyle(fontSize: 13)));
        }),
    ])));
  }
}

class _PairCard extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title; final String desc;
  final List<List<int>> pairs;
  const _PairCard({required this.icon, required this.iconColor, required this.title, required this.desc, required this.pairs});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: iconColor, size: 22), const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 4),
      Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      const SizedBox(height: 10),
      if (pairs.isEmpty)
        Text('No se encontraron pares.', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[500]))
      else
        ...pairs.map((p) {
          final a1 = getArcanoByNumero(p[0]);
          final a2 = getArcanoByNumero(p[1]);
          return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.link, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text('${a1?.nombre ?? p[0]} + ${a2?.nombre ?? p[1]} = ${p[0] + p[1]}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ]));
        }),
    ])));
  }
}