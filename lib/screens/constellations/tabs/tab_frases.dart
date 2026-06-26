import 'package:flutter/material.dart';
import '../../../models/family_member.dart';
import '../../../services/constellation_service.dart';
import '../../../data/healing_phrases_data.dart';
import '../../../utils/animated_widgets.dart';

class TabFrases extends StatefulWidget {
  const TabFrases({super.key});
  @override
  State<TabFrases> createState() => _TabFrasesState();
}

class _TabFrasesState extends State<TabFrases> {
  List<FamilyMember> _miembros = [];
  FamilyMember? _selectedMember;
  bool _loading = true;
  bool _expanded1 = true;
  bool _expanded2 = false;
  bool _expanded3 = false;

  @override
  void initState() {
    super.initState();
    _loadMiembros();
  }

  Future<void> _loadMiembros() async {
    final miembros = await ConstellationService.cargarMiembros();
    setState(() {
      _miembros = miembros;
      _loading = false;
    });
  }

  String _personalizar(HealingPhrase frase) {
    return HealingPhrasesData.personalizar(
      frase.texto,
      _selectedMember?.relacion,
      _selectedMember?.nombre,
    );
  }

  String _memberLabel() {
    if (_selectedMember == null) return 'general';
    return _selectedMember!.nombre;
  }

  Widget _buildSection({
    required String titulo,
    required Color color,
    required bool expanded,
    required VoidCallback onToggle,
    required List<HealingPhrase> frases,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, color: color),
                ),
              ],
            ),
          ),
        ),
        AnimatedSection(
          visible: expanded,
          child: Column(
            children: [
              const SizedBox(height: 8),
              ...frases.asMap().entries.map((entry) {
                final i = entry.key;
                final f = entry.value;
                final texto = _selectedMember != null ? _personalizar(f) : f.texto;
                return StaggeredFadeIn(
                  index: i,
                  child: Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Frase aplicada a ${_memberLabel()}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: color.withValues(alpha: 0.6),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    texto,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    f.intencion,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.format_quote,
                              color: color.withValues(alpha: 0.2),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (HealingPhrasesData.nivel1Ver.isEmpty &&
        HealingPhrasesData.nivel2Honrar.isEmpty &&
        HealingPhrasesData.nivel3Soltar.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay frases disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final idx = _selectedMember == null ? null : _miembros.indexOf(_selectedMember!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int?>(
          value: idx != null && idx >= 0 ? idx : null,
          decoration: const InputDecoration(
            labelText: 'Selecciona un miembro familiar',
            prefixIcon: Icon(Icons.person),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Frase general')),
            ..._miembros.asMap().entries.map((e) => DropdownMenuItem(
              value: e.key,
              child: Text('${e.value.nombre} (${e.value.relacion})'),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedMember = value != null ? _miembros[value] : null;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSection(
          titulo: 'NIVEL 1: VER Y RECONOCER',
          color: Colors.blue,
          expanded: _expanded1,
          onToggle: () => setState(() => _expanded1 = !_expanded1),
          frases: HealingPhrasesData.nivel1Ver,
        ),
        _buildSection(
          titulo: 'NIVEL 2: HONRAR Y AGRADECER',
          color: Colors.orange,
          expanded: _expanded2,
          onToggle: () => setState(() => _expanded2 = !_expanded2),
          frases: HealingPhrasesData.nivel2Honrar,
        ),
        _buildSection(
          titulo: 'NIVEL 3: SOLTAR Y BENDECIR',
          color: Colors.green,
          expanded: _expanded3,
          onToggle: () => setState(() => _expanded3 = !_expanded3),
          frases: HealingPhrasesData.nivel3Soltar,
        ),
      ],
    );
  }
}
