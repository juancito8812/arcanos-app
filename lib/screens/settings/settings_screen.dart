import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
          child: const Column(children: [
            Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 40),
            SizedBox(height: 8),
            Text('PsicoTarot v1.0.0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Arcanos Mayores', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ])),
        const SizedBox(height: 20),
        _Card(title: 'Acerca de', icon: Icons.info_outline,
          child: const Text('Herramienta terapeutica basada en PsicoTarot, Linea de Vida, Regresiones y Constelaciones Familiares.')),
        const SizedBox(height: 12),
        _Card(title: 'Privacidad', icon: Icons.security,
          child: const Text('Todos tus datos se almacenan localmente. No se comparte informacion personal.')),
        const SizedBox(height: 12),
        _Card(title: 'Gestion de Datos', icon: Icons.storage,
          child: TextButton.icon(onPressed: () => _borrar(context), icon: const Icon(Icons.delete_forever, color: Colors.red), label: const Text('Limpiar datos', style: TextStyle(color: Colors.red)))),
        const SizedBox(height: 12),
        _Card(title: 'Creditos', icon: Icons.favorite,
          child: const Text('(c) Psic. Blanca E. Siso M. - Bienestar Integral y Crecimiento Personal', textAlign: TextAlign.center)),
      ]),
    );
  }

  void _borrar(BuildContext c) {
    showDialog(context: c, builder: (ctx) => AlertDialog(
      title: const Text('Limpiar Datos'),
      content: const Text('Se eliminaran todos los datos almacenados.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        TextButton(onPressed: () async { await DatabaseService.deleteDatabase(); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text('Eliminar', style: TextStyle(color: Colors.red)))],
    ));
  }
}

class _Card extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _Card({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: AppTheme.purplePrimary, size: 22), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary))]),
      const SizedBox(height: 12), child,
    ])));
  }
}
