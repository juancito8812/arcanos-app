import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../models/arcano.dart';
import '../../../services/database_service.dart';
import '../../../services/life_line_calculator.dart';
import '../../../services/constellation_service.dart';
import '../../../utils/animated_widgets.dart';

class TabPatrones extends StatefulWidget {
  const TabPatrones({super.key});
  @override
  State<TabPatrones> createState() => _TabPatronesState();
}

class _TabPatronesState extends State<TabPatrones> {
  List<Map<String, dynamic>>? _patrones;
  bool _loading = true;
  bool _hasMembers = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final miembros = await DatabaseService.obtenerMiembrosConstelacion();
      final perfiles = await DatabaseService.obtenerPerfiles();

      _hasMembers = miembros.isNotEmpty;

      List<int>? arcanosUsuario;
      if (perfiles.isNotEmpty) {
        final perfil = perfiles.first;
        final nombre = perfil['nombre'] as String?;
        final fechaStr = perfil['fechaNacimiento'] as String?;
        if (nombre != null && fechaStr != null) {
          try {
            final fecha = DateTime.parse(fechaStr);
            final resultado = LifeLineCalculator.calcular(
              nombreCompleto: nombre,
              fechaNacimiento: fecha,
            );
            if (resultado != null) {
              arcanosUsuario =
                  resultado.arcanos.map((a) => a.arcano.numero).toList();
            }
          } catch (_) {}
        }
      }

      final patrones = ConstellationService.detectarPatronesTransgeneracionales(
        miembros,
        arcanosUsuario: arcanosUsuario,
      );

      if (mounted) {
        setState(() {
          _patrones = patrones;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Error al cargar datos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasMembers) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.people_outline, size: 64, color: AppTheme.goldAccent),
        const SizedBox(height: 16),
        Text('Agrega miembros en el genograma para analizar patrones', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey)),
      ]));
    }

    if (_patrones == null || _patrones!.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_outline, size: 64, color: AppTheme.goldAccent),
        const SizedBox(height: 16),
        Text('No se detectaron patrones repetitivos en tu sistema familiar', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey)),
      ]));
    }

    return _buildContent();
  }

  Widget _buildContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.auto_graph, color: AppTheme.goldAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Patrones Transgeneracionales Detectados',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._patrones!.asMap().entries.map((entry) {
          return StaggeredFadeIn(
            index: entry.key,
            child: _buildPatternCard(entry.value, entry.key, isDark),
          );
        }),
      ],
    );
  }

  Widget _buildPatternCard(
    Map<String, dynamic> pattern,
    int index,
    bool isDark,
  ) {
    final arcano = pattern['arcano'] as Arcano?;
    final repeticiones = pattern['repeticiones'] as int;
    final miembrosList = pattern['miembros'] as List<String>;
    final mensaje = pattern['mensaje'] as String;

    final lightGradients = [
      [const Color(0xFFE1BEE7), const Color(0xFFF3E5F5)],
      [const Color(0xFFCE93D8), const Color(0xFFEDE7F6)],
    ];
    final darkGradients = [
      [const Color(0xFF2D1B4E), const Color(0xFF3D2B5E)],
      [const Color(0xFF1C0A2E), const Color(0xFF2D1B4E)],
    ];

    final gradient = isDark ? darkGradients[index % 2] : lightGradients[index % 2];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (arcano != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/cards/arcano_${arcano.numero}.jpg',
                      width: 48,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.purpleLight.withAlpha(80),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.image, color: AppTheme.goldAccent),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arcano?.nombreCompleto ?? 'Desconocido',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        arcano != null ? 'Arcano ${arcano.numero}' : '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                if (repeticiones >= 2) _buildSeverityBadge(repeticiones),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Aparece $repeticiones ${repeticiones == 1 ? 'vez' : 'veces'} en el sistema',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: miembrosList.map((name) {
                final isTu = name == 'TU';
                return Chip(
                  label: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isTu ? Colors.white : null,
                    ),
                  ),
                  backgroundColor: isTu ? AppTheme.goldAccent : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(int repeticiones) {
    if (repeticiones >= 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'FUERTE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'LIGERO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
