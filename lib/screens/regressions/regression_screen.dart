import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/animated_widgets.dart';

class RegressionScreen extends StatefulWidget {
  const RegressionScreen({super.key});
  @override
  State<RegressionScreen> createState() => _RegressionScreenState();
}

class _RegressionScreenState extends State<RegressionScreen> {
  int _type = 0;
  final ScrollController _scrollController = ScrollController();

  static const List<_Type> _types = [
    _Type('Edad Temprana', Icons.child_care, 'Accede a recuerdos de la infancia para identificar patrones, traumas y bloqueos.'),
    _Type('Vidas Pasadas', Icons.history, 'Explora encarnaciones anteriores para comprender relaciones y miedos.'),
    _Type('Espacio entre Vidas', Icons.stars, 'Conecta con el propósito del alma y acuerdos prenatales.'),
  ];

  void _onTypeChanged(int index) {
    setState(() => _type = index);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Regresiones Guiadas')),
      body: Column(children: [
        SizedBox(height: 120, child: ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(12),
          itemCount: _types.length,
          itemBuilder: (context, i) {
            final sel = _type == i;
            return StaggeredFadeIn(
              index: i,
              child: GestureDetector(onTap: () => _onTypeChanged(i), child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 150, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.purplePrimary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: sel ? AppTheme.purplePrimary : AppTheme.purplePrimary.withValues(alpha: 0.16)),
                  boxShadow: sel ? [BoxShadow(color: AppTheme.purplePrimary.withAlpha(50), blurRadius: 8, offset: const Offset(0, 4))] : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_types[i].icon, color: sel ? Colors.white : AppTheme.purplePrimary, size: 28),
                  const SizedBox(height: 8),
                  Text(_types[i].title, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.purplePrimary)),
                ]),
              )),
            );
          },
        )),
        Expanded(child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StaggeredFadeIn(index: 0, child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: Text(_types[_type].desc, key: ValueKey(_type),
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
          )),
          const SizedBox(height: 20),
          StaggeredFadeIn(index: 1, child: const Text('Guía de Regresión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))),
          const SizedBox(height: 16),
          StaggeredFadeIn(index: 2, child: _Paso(1, 'Preparación', 'Busca un lugar tranquilo. Siéntate cómodamente. Cierra los ojos y respira profundamente 3 veces.')),
          StaggeredFadeIn(index: 3, child: _Paso(2, 'Relajación', 'Inhala profundamente, exhala lentamente. Relaja cada parte de tu cuerpo, desde los pies hasta la cabeza.')),
          StaggeredFadeIn(index: 4, child: _Paso(3, 'Visualización', 'Imagina un túnel de luz. La luz te envuelve y te lleva a un espacio seguro.')),
          StaggeredFadeIn(index: 5, child: _Paso(4, 'Exploración', '¿Qué ves? ¿Qué colores o personas están presentes? ¿Qué emociones surgen?')),
          StaggeredFadeIn(index: 6, child: _Paso(5, 'Integración', 'Pregunta: ¿Qué mensaje trae esta experiencia? Agradece y regresa contando del 1 al 5.')),
        ]))),
      ]),
    );
  }
}

class _Type { final String title; final IconData icon; final String desc; const _Type(this.title, this.icon, this.desc); }

class _Paso extends StatefulWidget {
  final int n; final String t; final String d;
  const _Paso(this.n, this.t, this.d);
  @override
  State<_Paso> createState() => _PasoState();
}

class _PasoState extends State<_Paso> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ac.forward(),
      onTapUp: (_) => _ac.reverse(),
      onTapCancel: () => _ac.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppTheme.purplePrimary, shape: BoxShape.circle),
                child: Center(child: Text('${widget.n}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.purplePrimary)),
                Text(widget.d, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}
