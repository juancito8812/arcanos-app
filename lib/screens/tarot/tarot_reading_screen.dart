import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/arcanos_data.dart';
import '../../models/tarot_spread.dart';
import '../../models/arcano.dart';

class TarotReadingScreen extends StatefulWidget {
  final TarotSpread spread;
  const TarotReadingScreen({super.key, required this.spread});
  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen>
    with TickerProviderStateMixin {
  List<Arcano>? _cards;
  bool _shuffling = false;

  // Shuffle animation
  late AnimationController _shuffleAc;
  late Animation<double> _shuffleRotate;
  late Animation<double> _glowPulse;

  // Card reveal animations
  late AnimationController _revealAc;
  late Animation<double> _revealAnim;

  @override
  void initState() {
    super.initState();

    _shuffleAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shuffleRotate = Tween<double>(begin: 0, end: 2 * pi * 3).animate(
      CurvedAnimation(parent: _shuffleAc, curve: Curves.easeInOut),
    );
    _glowPulse = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _shuffleAc, curve: Curves.easeInOut),
    );

    _revealAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealAnim = CurvedAnimation(
      parent: _revealAc,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _shuffleAc.dispose();
    _revealAc.dispose();
    super.dispose();
  }

  void _shuffle() async {
    setState(() => _shuffling = true);
    _cards = null;
    _shuffleAc.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;
    final s = List<Arcano>.from(allArcanos)..shuffle(Random());
    setState(() {
      _cards = s.take(widget.spread.numCartas).toList();
      _shuffling = false;
    });
    _shuffleAc.reset();
    _revealAc.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.spread.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Shuffle button
          _ShuffleButton(
            shuffling: _shuffling,
            hasCards: _cards != null,
            onPressed: _shuffle,
            rotateAnim: _shuffleRotate,
          ),
          const SizedBox(height: 20),
          // Content
          if (_shuffling)
            _ShufflingState(glowPulse: _glowPulse, rotateAnim: _shuffleRotate)
          else if (_cards != null)
            ..._cards!.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CardWidget(
                    position: e.key,
                    posName: widget.spread.posiciones[e.key],
                    arcano: e.value,
                    index: e.key,
                    revealAnim: _revealAnim,
                  ),
                )),
        ]),
      ),
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  final bool shuffling;
  final bool hasCards;
  final VoidCallback onPressed;
  final Animation<double> rotateAnim;

  const _ShuffleButton({
    required this.shuffling,
    required this.hasCards,
    required this.onPressed,
    required this.rotateAnim,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedBuilder(
        animation: rotateAnim,
        builder: (context, _) {
          return ElevatedButton.icon(
            onPressed: shuffling ? null : onPressed,
            icon: shuffling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Transform.rotate(
                    angle: rotateAnim.value,
                    child: const Icon(Icons.shuffle),
                  ),
            label: Text(
              shuffling
                  ? 'Barajando...'
                  : (hasCards ? 'Volver a Tirar' : 'Barajar y Tirar'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.purplePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: shuffling ? 2 : 6,
              shadowColor: AppTheme.purplePrimary.withValues(alpha: 0.4),
            ),
          );
        },
      ),
    );
  }
}

class _ShufflingState extends StatelessWidget {
  final Animation<double> glowPulse;
  final Animation<double> rotateAnim;

  const _ShufflingState({
    required this.glowPulse,
    required this.rotateAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 30),
      AnimatedBuilder(
        animation: glowPulse,
        builder: (context, _) {
          return Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldAccent.withValues(
                    alpha: glowPulse.value * 0.25,
                  ),
                  blurRadius: 60 + glowPulse.value * 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: rotateAnim.value,
                child: const Icon(
                  Icons.auto_awesome,
                  size: 72,
                  color: AppTheme.purplePrimary,
                ),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 20),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, _) {
          return Opacity(
            opacity: value,
            child: Column(children: [
              const Text(
                'Concentra tu intención...',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    color: AppTheme.purplePrimary,
                    backgroundColor: AppTheme.purpleLight.withValues(alpha: 0.3),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Las cartas se están alineando con tu energía...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ]),
          );
        },
      ),
    ]);
  }
}

class _CardWidget extends StatefulWidget {
  final int position;
  final String posName;
  final Arcano arcano;
  final int index;
  final Animation<double> revealAnim;

  const _CardWidget({
    required this.position,
    required this.posName,
    required this.arcano,
    required this.index,
    required this.revealAnim,
  });

  @override
  State<_CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<_CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverAc;
  late Animation<double> _hoverScale;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _hoverAc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverScale = Tween<double>(begin: 1, end: 1.02).animate(
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
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      onTapDown: (_) => _hoverAc.forward(),
      onTapUp: (_) => _hoverAc.reverse(),
      onTapCancel: () => _hoverAc.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverScale, widget.revealAnim]),
        builder: (context, _) {
          final scale = _hoverScale.value;
          final revealVal = widget.revealAnim.value;
          final delay = 0.05 * widget.index;
          final localReveal = ((revealVal - delay) / (1 - delay)).clamp(0.0, 1.0);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: localReveal,
              child: Card(
                elevation: _isExpanded ? 6 : 3,
                shadowColor: AppTheme.purplePrimary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Position header
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.purplePrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pos. ${widget.position + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.purplePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.posName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.purplePrimary,
                            ),
                          ),
                        ),
                        // Expand indicator
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            size: 20,
                            color: AppTheme.purplePrimary.withValues(alpha: 0.6),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      // Card image + info row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card image with flip effect
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/cards/arcano_${widget.arcano.numero}.jpg',
                              width: 65,
                              height: 95,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 65,
                                height: 95,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.purplePrimary,
                                      AppTheme.purpleDark,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.arcano.nombreRomano,
                                    style: const TextStyle(
                                      color: AppTheme.goldAccent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Card info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.arcano.nombreCompleto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.purplePrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedCrossFade(
                                  firstChild: Text(
                                    widget.arcano.leyEspiritual,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  secondChild: Text(
                                    widget.arcano.leyEspiritual,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  crossFadeState: _isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 200),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Reflection - always visible
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.goldLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppTheme.goldAccent.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _reflexion(widget.arcano.numero),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _reflexion(int n) {
    switch (n) {
      case 0: return 'Que nuevo comienzo llama a tu puerta?';
      case 1: return 'Que estas creando con tus pensamientos?';
      case 2: return 'Que recuerdos necesitan ser comprendidos?';
      case 3: return 'Que debes nutrir y hacer crecer?';
      case 4: return 'Donde necesitas poner orden?';
      case 5: return 'Que ensenanza trae esta circunstancia?';
      case 6: return 'Que decisiones del corazon evitas?';
      case 7: return 'Hacia donde te impulsa tu voluntad?';
      case 8: return 'Que consecuencias debes reconocer?';
      case 9: return 'Que sabiduria encuentras en el silencio?';
      case 10: return 'Que ciclo esta terminando?';
      case 11: return 'Donde encuentras fuerza interior?';
      case 12: return 'A que debes rendirte?';
      case 13: return 'Que transformacion ocurre?';
      case 14: return 'Como encuentras equilibrio?';
      case 15: return 'Que ataduras reconoces?';
      case 16: return 'Que estructuras se derrumban?';
      case 17: return 'Por que sientes gratitud?';
      case 18: return 'Que miedos emergen?';
      case 19: return 'Como conectas con tu alegria?';
      case 20: return 'A que despertar eres llamado?';
      case 21: return 'Que completitud buscas?';
      default: return 'Que mensaje trae esta carta?';
    }
  }
}
