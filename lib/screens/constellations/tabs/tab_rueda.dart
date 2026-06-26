import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../data/arcanos_data.dart';
import '../../../models/arcano.dart';
import '../../../models/constellation_session.dart';
import '../../../models/family_member.dart';
import '../../../services/constellation_service.dart';
import '../../../utils/animated_widgets.dart';

class _WheelEntry {
  final Arcano arcano;
  final String posicion;
  final String memberName;
  final String relacion;
  const _WheelEntry({
    required this.arcano,
    required this.posicion,
    required this.memberName,
    required this.relacion,
  });
}

class TabRueda extends StatefulWidget {
  @override
  State<TabRueda> createState() => _TabRuedaState();
}

class _TabRuedaState extends State<TabRueda> with TickerProviderStateMixin {
  static const _posiciones = [
    'YO', 'PADRE', 'MADRE', 'HERMANO/A', 'SECRETO', 'ANCESTRO', 'EXCLUIDO',
  ];

  final _temaController = TextEditingController();
  List<FamilyMember> _miembros = [];
  Map<String, FamilyMember?> _selecciones = {};
  List<_WheelEntry> _entries = [];

  late AnimationController _wheelAc;
  late Animation<double> _wheelAnim;
  late AnimationController _glowAc;
  late Animation<double> _glowAnim;

  bool _constelado = false;
  bool _cargandoIa = false;

  @override
  void initState() {
    super.initState();
    _wheelAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _wheelAnim = CurvedAnimation(
      parent: _wheelAc,
      curve: Curves.easeOutBack,
    );
    _glowAc = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowAc, curve: Curves.easeInOut),
    );
    _cargarMiembros();
  }

  @override
  void dispose() {
    _temaController.dispose();
    _wheelAc.dispose();
    _glowAc.dispose();
    super.dispose();
  }

  Future<void> _cargarMiembros() async {
    final miembros = await ConstellationService.cargarMiembros();
    if (mounted) setState(() => _miembros = miembros);
  }

  void _constelar() {
    final entries = <_WheelEntry>[];
    for (final pos in _posiciones) {
      final miembro = _selecciones[pos];
      final arcano = ConstellationService.arcanoParaPosicion(pos, miembro: miembro);
      if (arcano != null) {
        entries.add(_WheelEntry(
          arcano: arcano,
          posicion: pos,
          memberName: miembro?.nombre ?? pos,
          relacion: miembro?.relacion ?? '',
        ));
      }
    }
    setState(() {
      _entries = entries;
      _constelado = true;
    });
    _wheelAc.reset();
    _wheelAc.forward();
  }

  Future<void> _guardarSesion() async {
    final tema = _temaController.text.trim().isEmpty
        ? 'Sin tema'
        : _temaController.text.trim();
    final posiciones = <ConstellationPosition>[];
    for (int i = 0; i < _entries.length; i++) {
      final angle = 2 * pi * i / _entries.length;
      posiciones.add(ConstellationPosition(
        memberName: _entries[i].memberName,
        relacion: _entries[i].relacion,
        posicionSistemica: _entries[i].posicion,
        arcanoNumero: _entries[i].arcano.numero,
        posX: 175 + 120 * cos(angle),
        posY: 175 + 120 * sin(angle),
      ));
    }
    final sesion = ConstellationSession(tema: tema, posiciones: posiciones);
    await ConstellationService.guardarSesion(sesion);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesion guardada')),
      );
    }
  }

  Future<void> _interpretarConIA() async {
    setState(() => _cargandoIa = true);
    final tema = _temaController.text.trim().isEmpty
        ? 'Sin tema'
        : _temaController.text.trim();
    final posiciones = <ConstellationPosition>[];
    for (final e in _entries) {
      posiciones.add(ConstellationPosition(
        memberName: e.memberName,
        relacion: e.relacion,
        posicionSistemica: e.posicion,
        arcanoNumero: e.arcano.numero,
      ));
    }
    final sesion = ConstellationSession(tema: tema, posiciones: posiciones);
    final resultado = await ConstellationService.interpretarConIA(sesion);
    if (mounted) {
      setState(() => _cargandoIa = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Interpretacion de IA'),
          content: SingleChildScrollView(
            child: Text(
              resultado ?? 'No hay interpretacion disponible. Verifica tu API key.',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _temaController,
            decoration: const InputDecoration(
              labelText: '¿Que tema quieres constelar?',
              prefixIcon: Icon(Icons.auto_awesome),
            ),
          ),
          const SizedBox(height: 16),
          for (final pos in _posiciones) ...[
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    pos,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<FamilyMember>(
                    value: _selecciones[pos],
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Seleccionar miembro...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<FamilyMember>(
                        value: null,
                        child: Text('(Ninguno)'),
                      ),
                      for (final m in _miembros)
                        DropdownMenuItem<FamilyMember>(
                          value: m,
                          child: Text('${m.nombre} (${m.relacion})'),
                        ),
                    ],
                    onChanged: (val) {
                      setState(() => _selecciones[pos] = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _constelar,
              icon: AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, _) {
                  return Icon(
                    Icons.shuffle,
                    color: Colors.white.withValues(alpha: 0.7 + _glowAnim.value * 0.3),
                  );
                },
              ),
              label: const Text('Constelar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purplePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: AppTheme.purplePrimary.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_constelado)
            AnimatedBuilder(
              animation: Listenable.merge([_wheelAnim, _glowAnim]),
              builder: (context, _) {
                return SizedBox(
                  width: 350,
                  height: 350,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.goldAccent.withValues(alpha: _glowAnim.value * 0.15),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      CustomPaint(
                        size: const Size(350, 350),
                        painter: _WheelLinesPainter(
                          count: _entries.length,
                          progress: _wheelAnim.value,
                        ),
                      ),
                      for (int i = 0; i < _entries.length; i++)
                        Positioned(
                          left: 175 + 120 * cos(2 * pi * i / _entries.length) * _wheelAnim.value - 27,
                          top: 175 + 120 * sin(2 * pi * i / _entries.length) * _wheelAnim.value - 37,
                          child: Opacity(
                            opacity: _wheelAnim.value,
                            child: _WheelCard(
                              arcano: _entries[i].arcano,
                              memberName: _entries[i].memberName,
                              posicion: _entries[i].posicion,
                              relacion: _entries[i].relacion,
                            ),
                          ),
                        ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.purplePrimary, AppTheme.purpleDark],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.purplePrimary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            color: AppTheme.goldAccent,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
          if (_constelado) ...[
            StaggeredFadeIn(
              index: 8,
              child: const Text(
                'Toca una carta para ver su mensaje',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _guardarSesion,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Sesion'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cargandoIa ? null : _interpretarConIA,
                    icon: _cargandoIa
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('Interpretar con IA'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WheelLinesPainter extends CustomPainter {
  final int count;
  final double progress;

  _WheelLinesPainter({required this.count, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.purplePrimary.withValues(alpha: 0.15 * progress)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = 120 * progress;

    canvas.drawCircle(Offset(cx, cy), r, paint);

    for (int i = 0; i < count; i++) {
      final angle = 2 * pi * i / count;
      final dx = cx + r * cos(angle);
      final dy = cy + r * sin(angle);
      canvas.drawLine(Offset(cx, cy), Offset(dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(_WheelLinesPainter old) =>
      old.count != count || old.progress != progress;
}

class _WheelCard extends StatefulWidget {
  final Arcano arcano;
  final String memberName;
  final String posicion;
  final String relacion;

  const _WheelCard({
    required this.arcano,
    required this.memberName,
    required this.posicion,
    required this.relacion,
  });

  @override
  State<_WheelCard> createState() => _WheelCardState();
}

class _WheelCardState extends State<_WheelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverAc;
  late Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _hoverAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnim = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _hoverAc, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showInfo(context),
      onTapDown: (_) => _hoverAc.forward(),
      onTapUp: (_) => _hoverAc.reverse(),
      onTapCancel: () => _hoverAc.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnim,
        builder: (context, _) {
          return Transform.scale(
            scale: _hoverAnim.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/cards/arcano_${widget.arcano.numero}.jpg',
                    width: 55,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 55,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.purplePrimary, AppTheme.purpleDark],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.goldAccent.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.arcano.nombreRomano,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.goldAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.posicion,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInfo(BuildContext c) {
    final a = widget.arcano;
    showDialog(
      context: c,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          a.nombreCompleto,
          style: const TextStyle(color: AppTheme.purplePrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.purplePrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posicion: ${widget.posicion}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.purplePrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Miembro: ${widget.memberName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (widget.relacion.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Relacion: ${widget.relacion}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                a.leyEspiritual,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      a.leccionVida,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.psychology, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Miedo: ${a.miedoAsociado}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
