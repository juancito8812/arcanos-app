import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';
import '../../models/arcano.dart';
import '../../utils/animated_widgets.dart';

class ConstellationScreen extends StatefulWidget {
  const ConstellationScreen({super.key});
  @override
  State<ConstellationScreen> createState() => _ConstellationScreenState();
}

class _ConstellationScreenState extends State<ConstellationScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _tabAc;
  late Animation<double> _tabAnim;
  late AnimationController _headerPulse;
  late Animation<double> _headerGlowAnim;
  final tabs = ['Que es?', '3 Leyes', 'Rueda', 'Frases', 'Secretos'];

  @override
  void initState() {
    super.initState();
    _tabAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _tabAnim = CurvedAnimation(parent: _tabAc, curve: Curves.easeOutCubic);
    _tabAc.forward();

    _headerPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _headerGlowAnim = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _headerPulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabAc.dispose();
    _headerPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Constelaciones Familiares')),
      body: Column(children: [
        // Animated header
        AnimatedBuilder(
          animation: _headerGlowAnim,
          builder: (context, _) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.purplePrimary.withValues(
                      alpha: 0.08 + _headerGlowAnim.value * 0.04,
                    ),
                    AppTheme.purpleDark.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups,
                      size: 20,
                      color: AppTheme.purplePrimary.withValues(
                        alpha: _headerGlowAnim.value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Explora las dinamicas de tu sistema familiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Tabs with press animation
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: tabs.length,
                    itemBuilder: (context, i) => _TabChip(
                      label: tabs[i],
                      selected: _tab == i,
                      onTap: () => setState(() {
                        _tab = i;
                        _tabAc.reset();
                        _tabAc.forward();
                      }),
                    ),
                  ),
                ),
              ]),
            );
          },
        ),
        // Content area
        Expanded(
          child: FadeTransition(
            opacity: _tabAnim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(_tabAnim),
              child: _buildContent(),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent() {
    switch (_tab) {
      case 0: return _Info();
      case 1: return _Leyes();
      case 2: return _Rueda();
      case 3: return _Frases();
      case 4: return _Secretos();
      default: return const SizedBox();
    }
  }
}

class _TabChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressAc;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _pressAc, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressAc.forward(),
      onTapUp: (_) {
        _pressAc.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressAc.reverse(),
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (context, _) {
          return Transform.scale(
            scale: _pressAnim.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(
                label: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: widget.selected,
                selectedColor: AppTheme.purplePrimary,
                labelStyle: TextStyle(
                  color: widget.selected ? Colors.white : AppTheme.purplePrimary,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: widget.selected
                      ? AppTheme.purplePrimary
                      : AppTheme.purplePrimary.withValues(alpha: 0.2),
                ),
                elevation: widget.selected ? 4 : 0,
                shadowColor: AppTheme.purplePrimary.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        StaggeredFadeIn(
          index: 0,
          child: _GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.groups, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Constelaciones Familiares',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(
                  'Terapia que permite observar y sanar esquemas afectivos y cognitivos que afectan la cotidianidad. Busca ordenar el sistema familiar, dando lugar a todos los miembros, especialmente a los excluidos.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        StaggeredFadeIn(
          index: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bases Teoricas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.purplePrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...['Virginia Satir', 'Fenomenologia de Husserl', 'P.N.L.',
                      'Gestalt', 'Psicodrama', 'Hipnosis Ericksoniana']
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.purplePrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                t,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ]),
                          )),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _GradientCard extends StatelessWidget {
  final Widget child;
  const _GradientCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.purplePrimary, AppTheme.purpleDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purplePrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Leyes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StaggeredFadeIn(
          index: 0,
          child: _LeyCard(
            numero: '1',
            titulo: 'Pertenencia',
            descripcion:
                'El sistema llena los vacios. Todos tienen derecho a pertenecer.',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        StaggeredFadeIn(
          index: 1,
          child: _LeyCard(
            numero: '2',
            titulo: 'Orden y Jerarquia',
            descripcion:
                'Saber quien llega primero y respetarlo. Cada miembro en su lugar.',
            icon: Icons.account_tree,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        StaggeredFadeIn(
          index: 2,
          child: _LeyCard(
            numero: '3',
            titulo: 'Equilibrio',
            descripcion:
                'Importante saber recibir y dar siempre un poco mas.',
            icon: Icons.balance,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _LeyCard extends StatelessWidget {
  final String numero;
  final String titulo;
  final String descripcion;
  final IconData icon;
  final Color color;

  const _LeyCard({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ley $numero',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.purplePrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rueda extends StatefulWidget {
  @override
  State<_Rueda> createState() => _RuedaState();
}

class _RuedaState extends State<_Rueda> with TickerProviderStateMixin {
  List<Arcano> _cards = [];
  late AnimationController _wheelAc;
  late Animation<double> _wheelAnim;
  late AnimationController _glowAc;
  late Animation<double> _glowAnim;

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
  }

  @override
  void dispose() {
    _wheelAc.dispose();
    _glowAc.dispose();
    super.dispose();
  }

  void _pick() {
    final s = List<Arcano>.from(allArcanos)..shuffle();
    setState(() => _cards = s.take(7).toList());
    _wheelAc.reset();
    _wheelAc.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          StaggeredFadeIn(
            index: 0,
            child: _GradientCard(
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Las Constelaciones Familiares revelan dinamicas ocultas del sistema familiar.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          StaggeredFadeIn(
            index: 1,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _pick,
                icon: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (context, _) {
                    return Icon(
                      Icons.shuffle,
                      color: Colors.white.withValues(
                        alpha: 0.7 + _glowAnim.value * 0.3,
                      ),
                    );
                  },
                ),
                label: const Text('Seleccionar Cartas'),
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
          ),
          const SizedBox(height: 16),
          // Wheel
          if (_cards.isNotEmpty)
            AnimatedBuilder(
              animation: Listenable.merge([_wheelAnim, _glowAnim]),
              builder: (context, _) {
                return SizedBox(
                  width: 350,
                  height: 350,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing glow behind the wheel
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.goldAccent.withValues(
                                alpha: _glowAnim.value * 0.15,
                              ),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      // Connecting lines
                      CustomPaint(
                        size: const Size(350, 350),
                        painter: _WheelLinesPainter(
                          count: _cards.length,
                          progress: _wheelAnim.value,
                        ),
                      ),
                      // Cards in wheel formation
                      for (int i = 0; i < _cards.length; i++)
                        Positioned(
                          left: 175 +
                              120 * cos(2 * pi * i / _cards.length) *
                                  _wheelAnim.value -
                              27,
                          top: 175 +
                              120 * sin(2 * pi * i / _cards.length) *
                                  _wheelAnim.value -
                              37,
                          child: Opacity(
                            opacity: _wheelAnim.value,
                            child: _WheelCard(arcano: _cards[i]),
                          ),
                        ),
                      // Center circle
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
          if (_cards.isNotEmpty)
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

    // Draw circle
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Draw radial lines
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
  const _WheelCard({required this.arcano});

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
    return GestureDetector(
      onTap: () => _showInfo(context, widget.arcano),
      onTapDown: (_) => _hoverAc.forward(),
      onTapUp: (_) => _hoverAc.reverse(),
      onTapCancel: () => _hoverAc.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnim,
        builder: (context, _) {
          return Transform.scale(
            scale: _hoverAnim.value,
            child: Container(
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
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purplePrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
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
          );
        },
      ),
    );
  }

  void _showInfo(BuildContext c, Arcano a) {
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
                child: Text(
                  a.leyEspiritual,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.lightbulb_outline,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    a.leccionVida,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
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
              ]),
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

class _Frases extends StatelessWidget {
  final frases = [
    'Te veo. Te tomo como eres.',
    'Tu eres el mayor, yo soy el menor.',
    'Por favor, bendiceme.',
    'Lo siento. Gracias. Te amo.',
    'Confio en la vida.',
    'Acepto mi origen.',
    'Gracias por la vida.',
    'Paz entre nosotros.',
  ];

  final iconColors = [
    Colors.pink,
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: frases.asMap().entries.map((e) {
        final i = e.key;
        final frase = e.value;
        return StaggeredFadeIn(
          index: i,
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColors[i].withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.favorite,
                  color: iconColors[i].withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
              title: Text(
                frase,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
              trailing: Icon(
                Icons.format_quote,
                color: iconColors[i].withValues(alpha: 0.3),
                size: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Secretos extends StatelessWidget {
  final secrets = [
    ('Primogenito: Padre', 'El primero hereda la lealtad del padre.'),
    ('Segundo: Madre', 'El segundo carga la balanza con la madre.'),
    ('Tercero: Matrimonio', 'El tercero busca el equilibrio en la pareja.'),
    ('Cuarto: Familia', 'El cuarto restaura el orden del sistema.'),
  ];

  final iconData = [
    Icons.man,
    Icons.woman,
    Icons.favorite,
    Icons.home,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        StaggeredFadeIn(
          index: 0,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.lock_outline,
                        color: AppTheme.purplePrimary, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Los hijos reproducen los secretos familiares:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.purplePrimary,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  ...secrets.asMap().entries.map((e) {
                    final i = e.key;
                    final (title, desc) = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StaggeredFadeIn(
                        index: i + 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.purplePrimary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                iconData[i],
                                size: 18,
                                color: AppTheme.purplePrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.purplePrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    desc,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
