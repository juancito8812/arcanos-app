import 'package:flutter/material.dart';
import '../../../models/family_member.dart';
import '../../../services/database_service.dart';
import '../../../data/healing_phrases_data.dart';

class TabFrases extends StatefulWidget {
  const TabFrases({super.key});
  @override
  State<TabFrases> createState() => _TabFrasesState();
}

class _TabFrasesState extends State<TabFrases> {
  List<FamilyMember> _miembros = [];
  FamilyMember? _selectedMember;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMiembros();
  }

  Future<void> _loadMiembros() async {
    final miembros = await DatabaseService.obtenerMiembrosConstelacion();
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

  String _memberLabel() => _selectedMember?.nombre ?? 'general';

  Widget _buildLevel({
    required String titulo,
    required Color color,
    required IconData icon,
    required List<HealingPhrase> frases,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ],
        ),
        initiallyExpanded: titulo.contains('VER'),
        children: frases.map((f) {
          final texto = _selectedMember != null ? _personalizar(f) : f.texto;
          return ListTile(
            dense: true,
            leading: Icon(Icons.favorite, color: color.withAlpha(120), size: 18),
            title: Text(texto, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14)),
            subtitle: Text(f.intencion, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            trailing: Icon(Icons.format_quote, color: color.withAlpha(60), size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Frase aplicada a ${_memberLabel()}'), behavior: SnackBarBehavior.floating),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int?>(
          value: _selectedMember == null ? null : _miembros.indexOf(_selectedMember!),
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
          onChanged: (value) => setState(() => _selectedMember = value != null ? _miembros[value] : null),
        ),
        const SizedBox(height: 16),
        _buildLevel(titulo: 'NIVEL 1: VER Y RECONOCER', color: Colors.blue, icon: Icons.visibility, frases: HealingPhrasesData.nivel1Ver),
        _buildLevel(titulo: 'NIVEL 2: HONRAR Y AGRADECER', color: Colors.orange, icon: Icons.favorite, frases: HealingPhrasesData.nivel2Honrar),
        _buildLevel(titulo: 'NIVEL 3: SOLTAR Y BENDECIR', color: Colors.green, icon: Icons.spa, frases: HealingPhrasesData.nivel3Soltar),
      ],
    );
  }
}
