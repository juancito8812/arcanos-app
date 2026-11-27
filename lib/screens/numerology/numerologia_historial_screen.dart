import 'package:flutter/material.dart';

import 'package:arcanos_mayores/services/database_service.dart';
import 'package:arcanos_mayores/services/pdf_export_service.dart';

/// Historial de consultas de numerologia guardadas en la BD.
/// Tap en una consulta -> vuelve a generar y compartir su PDF.
class NumerologiaHistorialScreen extends StatefulWidget {
  const NumerologiaHistorialScreen({super.key});

  @override
  State<NumerologiaHistorialScreen> createState() => _NumerologiaHistorialScreenState();
}

class _NumerologiaHistorialScreenState extends State<NumerologiaHistorialScreen> {
  bool _cargando = true;
  bool _exportando = false;
  List<Map<String, dynamic>> _consultas = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final consultas = await DatabaseService.obtenerConsultasNumerologia();
    if (!mounted) return;
    setState(() { _consultas = consultas; _cargando = false; });
  }

  String _fechaCorta(String iso) {
    final f = DateTime.parse(iso);
    return '${f.day}/${f.month}/${f.year}';
  }

  Future<void> _compartir(Map<String, dynamic> consulta) async {
    if (_exportando) return;
    setState(() => _exportando = true);
    try {
      await PdfExportService.sharePersonalNumbersPdf(
        nombreCompleto: consulta['nombre'] as String,
        fechaNacimiento: DateTime.parse(consulta['fechaNacimiento'] as String),
        fechaConsulta: DateTime.parse(consulta['fechaConsulta'] as String),
        numeroVida: consulta['numeroVida'] as int,
        anoPersonal: consulta['anoPersonal'] as int,
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultas guardadas')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _consultas.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aún no hay consultas guardadas.\nGenera un PDF de Numerología Personal y quedará aquí.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    itemCount: _consultas.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = _consultas[i];
                      return ListTile(
                        leading: const Icon(Icons.description, color: Colors.purple),
                        title: Text(c['nombre'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Nace: ${_fechaCorta(c['fechaNacimiento'] as String)}  ·  '
                            'Vida ${c['numeroVida']}  ·  Año ${c['anoPersonal']}\n'
                            'Consultado: ${_fechaCorta(c['fechaConsulta'] as String)}'),
                        isThreeLine: true,
                        trailing: _exportando
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.ios_share),
                        onTap: () => _compartir(c),
                      );
                    },
                  ),
                ),
    );
  }
}
