import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/animated_widgets.dart';
import 'tabs/tab_genograma.dart';
import 'tabs/tab_rueda.dart';
import 'tabs/tab_frases.dart';
import 'tabs/tab_patrones.dart';

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
  final tabs = ['Que es?', '3 Leyes', 'Genograma', 'Rueda', 'Frases', 'Patrones'];

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
      case 2: return const TabGenograma();
      case 3: return const TabRueda();
      case 4: return const TabFrases();
      case 5: return const TabPatrones();
      default: return const SizedBox();
    }
  }
}

class _TabChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.selected, required this.onTap});
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
                              Text(t, style: const TextStyle(fontSize: 14)),
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
                'Todos los miembros tienen el mismo derecho a pertenecer. Nadie puede ser excluido del sistema familiar, sin importar lo que haya hecho. Los olvidados, los secretos, los excluidos generan un vacio que un descendiente, por lealtad ciega, intentara llenar repitiendo su destino.',
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
                'Los que llegaron antes tienen prioridad sobre los que llegaron despues. Padres antes que hijos, primera pareja antes que segunda. Cuando un hijo actua como padre de sus padres, se invierte el orden y el sistema se desequilibra. Cada cual en su lugar.',
            icon: Icons.account_tree,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        StaggeredFadeIn(
          index: 2,
          child: _LeyCard(
            numero: '3',
            titulo: 'Equilibrio entre Dar y Recibir',
            descripcion:
                'Entre iguales debe haber un intercambio equilibrado. Si uno solo da y el otro solo recibe, la relacion se rompe. Entre padres e hijos el flujo es diferente: los padres dan la vida y los hijos la toman y la pasan hacia adelante, a la siguiente generacion.',
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
