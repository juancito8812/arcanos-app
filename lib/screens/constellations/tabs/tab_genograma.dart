import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../models/family_member.dart';
import '../../../services/constellation_service.dart';
import '../../../utils/animated_widgets.dart';

class TabGenograma extends StatefulWidget {
  const TabGenograma({super.key});
  @override
  State<TabGenograma> createState() => _TabGenogramaState();
}

class _TabGenogramaState extends State<TabGenograma> {
  List<FamilyMember> _miembros = [];
  bool _loading = true;

  static const _eventosDisponibles = [
    'Muerte', 'Divorcio', 'Migracion', 'Abandono',
    'Enfermedad', 'Guerra', 'Exito', 'Otro',
  ];

  static const _relaciones = [
    'Padre', 'Madre', 'Hermano/a', 'Abuelo/a', 'Tio/a', 'Primo/a', 'Otro',
  ];

  static const _generaciones = ['Abuelos', 'Padres', 'Tu Generacion'];

  static const _generacionColores = [
    AppTheme.purpleDark,
    AppTheme.purplePrimary,
    AppTheme.purpleLight,
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final miembros = await ConstellationService.cargarMiembros();
    if (!mounted) return;
    setState(() {
      _miembros = miembros;
      _loading = false;
    });
  }

  Future<void> _guardarTodo() async {
    setState(() => _loading = true);
    await _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados'),
        backgroundColor: AppTheme.purplePrimary,
      ),
    );
  }

  Future<void> _mostrarDialogo({FamilyMember? miembro}) async {
    final esEdicion = miembro != null;
    final nombreCtrl = TextEditingController(text: miembro?.nombre ?? '');
    final fechaNacCtrl = TextEditingController(text: miembro?.fechaNacimiento ?? '');
    final fechaEventCtrl = TextEditingController(text: miembro?.fechaEvento ?? '');
    int generacion = miembro?.generacion ?? 2;
    String relacion = miembro?.relacion ?? 'Padre';
    List<String> eventos = miembro?.eventos ?? [];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            esEdicion ? 'Editar miembro' : 'Agregar miembro',
            style: const TextStyle(color: AppTheme.purplePrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _relaciones.contains(relacion) ? relacion : 'Otro',
                  decoration: const InputDecoration(
                    labelText: 'Relacion',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  items: _relaciones.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setDialogState(() => relacion = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: generacion,
                  decoration: const InputDecoration(
                    labelText: 'Generacion',
                    prefixIcon: Icon(Icons.account_tree),
                  ),
                  items: List.generate(3, (i) => DropdownMenuItem(
                    value: i,
                    child: Text('${_generaciones[i]} (G$i)'),
                  )),
                  onChanged: (v) => setDialogState(() => generacion = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fechaNacCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento (opcional)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fechaEventCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de evento (opcional)',
                    prefixIcon: Icon(Icons.event),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Eventos',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 4),
                ..._eventosDisponibles.map((e) => CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(e, style: const TextStyle(fontSize: 13)),
                  value: eventos.contains(e),
                  activeColor: AppTheme.purplePrimary,
                  onChanged: (_) => setDialogState(() {
                    if (eventos.contains(e)) {
                      eventos.remove(e);
                    } else {
                      eventos.add(e);
                    }
                  }),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {
                'nombre': nombreCtrl.text.trim(),
                'relacion': relacion,
                'generacion': generacion,
                'eventos': eventos,
                'fechaNacimiento': fechaNacCtrl.text.trim().isEmpty ? null : fechaNacCtrl.text.trim(),
                'fechaEvento': fechaEventCtrl.text.trim().isEmpty ? null : fechaEventCtrl.text.trim(),
              }),
              child: Text(esEdicion ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );

    if (result == null || result['nombre'].isEmpty) return;

    final member = FamilyMember(
      id: miembro?.id,
      nombre: result['nombre'],
      relacion: result['relacion'],
      generacion: result['generacion'],
      eventos: List<String>.from(result['eventos']),
      fechaNacimiento: result['fechaNacimiento'],
      fechaEvento: result['fechaEvento'],
    );

    await ConstellationService.guardarMiembro(member);
    await _cargar();
  }

  Future<void> _confirmarEliminar(FamilyMember m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar miembro'),
        content: Text('Eliminar a ${m.nombre} del arbol familiar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && m.id != null) {
      await ConstellationService.eliminarMiembro(m.id!);
      await _cargar();
    }
  }

  void _mostrarOpciones(FamilyMember m) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.purplePrimary),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(ctx);
                  _mostrarDialogo(miembro: m);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmarEliminar(m);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _miembros.isEmpty ? _buildEmpty() : _buildTree(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogo(),
        backgroundColor: AppTheme.purplePrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.family_restroom,
              size: 80,
              color: AppTheme.purplePrimary.withAlpha(60),
            ),
            const SizedBox(height: 16),
            const Text(
              'Agrega miembros de tu familia para construir tu arbol genealogico',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogo(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar miembro'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTree() {
    final agrupados = <int, List<FamilyMember>>{};
    for (final m in _miembros) {
      agrupados.putIfAbsent(m.generacion, () => []);
      agrupados[m.generacion]!.add(m);
    }
    for (int g = 0; g < 3; g++) {
      agrupados.putIfAbsent(g, () => []);
      agrupados[g]!.sort((a, b) => a.nombre.compareTo(b.nombre));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardarTodo,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purplePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: 3,
            itemBuilder: (context, g) => _buildGeneracion(g, agrupados[g]!),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneracion(int g, List<FamilyMember> miembros) {
    return StaggeredFadeIn(
      index: g,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _generacionColores[g],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_generaciones[g]} (G$g)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _generacionColores[g],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _generacionColores[g].withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${miembros.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _generacionColores[g],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...miembros.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;
            return StaggeredFadeIn(
              index: i,
              child: _MiembroCard(
                miembro: m,
                color: _generacionColores[g],
                onLongPress: () => _mostrarOpciones(m),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MiembroCard extends StatelessWidget {
  final FamilyMember miembro;
  final Color color;
  final VoidCallback onLongPress;

  const _MiembroCard({
    required this.miembro,
    required this.color,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(40)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            miembro.nombre,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      miembro.relacion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (miembro.eventos.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: miembro.eventos.map((e) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withAlpha(60)),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                    if (miembro.fechaNacimiento != null || miembro.fechaEvento != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (miembro.fechaNacimiento != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                'N: ${miembro.fechaNacimiento}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (miembro.fechaEvento != null)
                            Text(
                              'E: ${miembro.fechaEvento}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.more_vert, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
