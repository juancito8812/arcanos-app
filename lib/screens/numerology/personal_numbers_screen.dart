import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arcanos_mayores/services/database_service.dart';
import 'package:arcanos_mayores/services/personal_numbers.dart';
import 'package:arcanos_mayores/data/personal_numbers_data.dart';
import 'package:arcanos_mayores/services/pdf_export_service.dart';
import 'package:arcanos_mayores/screens/numerology/numerologia_historial_screen.dart';
import 'package:arcanos_mayores/theme.dart';

/// Módulo Números Personales (numerología clásica), independiente de la
/// Matriz del Destino. Dos cifras: Número de Vida (fijo de nacimiento) y
/// Año Personal (del año en curso, según el método del dueño).
class PersonalNumbersScreen extends StatefulWidget {
  const PersonalNumbersScreen({super.key});

  @override
  State<PersonalNumbersScreen> createState() => _PersonalNumbersScreenState();
}

class _PersonalNumbersScreenState extends State<PersonalNumbersScreen> {
  DateTime? _fecha; // fecha activa: perfil guardado o elegida a mano

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final perfiles = await DatabaseService.obtenerPerfiles();
    if (!mounted) return;
    setState(() {
      if (perfiles.isNotEmpty) {
        _fecha = DateTime.parse(perfiles.first['fechaNacimiento'] as String);
      }
    });
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Fecha de nacimiento',
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  bool _exportando = false;

  Future<void> _exportarPdf() async {
    // Diálogo: nombre y apellidos de la persona consultada
    final nombreController = TextEditingController(
      text: await DatabaseService.obtenerPerfiles().then((p) => p.isNotEmpty ? (p.first['nombre'] as String? ?? '') : ''));
    final apellidosController = TextEditingController();
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Datos de la persona'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apellidosController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Apellidos', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            if (nombreController.text.trim().isEmpty) return;
            Navigator.pop(ctx, true);
          }, child: const Text('Generar PDF')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final nombreCompleto =
        '${nombreController.text.trim()} ${apellidosController.text.trim()}'.trim();

    setState(() => _exportando = true);
    try {
      final hoy = DateTime.now();
      final numeroVida = PersonalNumbers.numeroDeVida(_fecha!);
      final anoPersonal = PersonalNumbers.anoPersonal(_fecha!, hoy);

      // Queda guardada para revisarla luego
      await DatabaseService.guardarConsultaNumerologia({
        'nombre': nombreCompleto,
        'fechaNacimiento': _fecha!.toIso8601String(),
        'numeroVida': numeroVida,
        'anoPersonal': anoPersonal,
        'fechaConsulta': hoy.toIso8601String(),
      });

      await PdfExportService.sharePersonalNumbersPdf(
        nombreCompleto: nombreCompleto,
        fechaNacimiento: _fecha!,
        fechaConsulta: hoy,
        numeroVida: numeroVida,
        anoPersonal: anoPersonal,
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Números Personales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Consultas guardadas',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const NumerologiaHistorialScreen())),
          ),
        ],
      ),
      body: _fecha == null
          ? _SinPerfil(onElegirFecha: _elegirFecha)
          : RefreshIndicator(
              onRefresh: _cargarPerfil,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Nacido el ${DateFormat('dd/MM/yyyy').format(_fecha!)}',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 16),
                  _NumeroCard(
                    titulo: 'NÚMERO DE VIDA PERSONAL',
                    numero: PersonalNumbers.numeroDeVida(_fecha!),
                    desglose: 'Nacimiento: ${PersonalNumbers.desgloseVida(_fecha!)}',
                    pie: 'Fijo de nacimiento',
                    esVida: true,
                  ),
                  const SizedBox(height: 16),
                  _NumeroCard(
                    titulo: 'AÑO PERSONAL',
                    numero: PersonalNumbers.anoPersonal(_fecha!, hoy),
                    desglose: 'Ciclo ${hoy.year}: ${PersonalNumbers.desgloseAno(_fecha!, hoy)}',
                    pie: 'Cambia cada 1 de enero',
                    esVida: false,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _exportando ? null : _exportarPdf,
                    icon: _exportando
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(_exportando ? 'Generando PDF...' : 'Compartir PDF entregable'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _elegirFecha,
                    icon: const Icon(Icons.event),
                    label: const Text('Calcular con otra fecha'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SinPerfil extends StatelessWidget {
  final VoidCallback onElegirFecha;
  const _SinPerfil({required this.onElegirFecha});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined, size: 64, color: AppTheme.goldAccent),
            const SizedBox(height: 16),
            const Text('Elige tu fecha de nacimiento',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Para calcular tu Número de Vida y tu Año Personal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onElegirFecha,
              icon: const Icon(Icons.event),
              label: const Text('Elegir fecha'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumeroCard extends StatelessWidget {
  final String titulo;
  final int numero;
  final String desglose;
  final String pie;
  final bool esVida; // true = Número de Vida, false = Año Personal

  const _NumeroCard({
    required this.titulo,
    required this.numero,
    required this.desglose,
    required this.pie,
    required this.esVida,
  });

  @override
  Widget build(BuildContext context) {
    final NumeroVidaInfo? vida = esVida ? vidaInfo[numero] : null;
    final AnoPersonalInfo? ano = esVida ? null : anoInfo[numero];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              width: 72, height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purplePrimary,
              ),
              child: Text('$numero',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(PersonalNumbers.significado(numero),
                style: const TextStyle(fontSize: 15, height: 1.3)),
            ),
          ]),
          const SizedBox(height: 12),
          Text(desglose,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(pie,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          const Divider(height: 28, color: AppTheme.goldAccent),
          if (esVida) ...[
            _Seccion(icono: Icons.auto_awesome_outlined, titulo: 'Esencia', texto: vida!.esencia),
            _Seccion(icono: Icons.stars_outlined, titulo: 'Dones y habilidades', texto: vida.dones),
            _Seccion(icono: Icons.nights_stay_outlined, titulo: 'Sombras y debilidades', texto: vida.sombras),
            _Seccion(icono: Icons.all_inclusive_outlined, titulo: 'Lección kármica', texto: vida.karma),
            _Seccion(icono: Icons.lightbulb_outline, titulo: 'Recomendación', texto: vida.recomendacion),
          ] else ...[
            _Seccion(icono: Icons.wb_sunny_outlined, titulo: 'Lo positivo del año', texto: ano!.positivo),
            _Seccion(icono: Icons.cloud_outlined, titulo: 'Lo negativo del año', texto: ano.negativo),
            _Seccion(icono: Icons.lightbulb_outline, titulo: 'Recomendación', texto: ano.recomendacion),
          ],
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;

  const _Seccion({required this.icono, required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icono, size: 16, color: AppTheme.goldAccent),
            const SizedBox(width: 6),
            Text(titulo,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.goldAccent)),
          ]),
          const SizedBox(height: 4),
          Text(texto, style: const TextStyle(fontSize: 14, height: 1.35)),
        ],
      ),
    );
  }
}
