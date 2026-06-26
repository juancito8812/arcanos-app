import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/arcano_menor.dart';

class ArcanoMenorDetailScreen extends StatelessWidget {
  final ArcanoMenor arcano;
  const ArcanoMenorDetailScreen({super.key, required this.arcano});


  Color _paloColor(String palo) {
    switch (palo.toLowerCase()) {
      case 'copas': return Colors.blue;
      case 'bastos': return Colors.deepOrange;
      case 'espadas': return Colors.blueGrey;
      case 'oros': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _paloIcon(String palo) {
    switch (palo.toLowerCase()) {
      case 'copas': return Icons.local_drink;
      case 'bastos': return Icons.whatshot;
      case 'espadas': return Icons.content_cut;
      case 'oros': return Icons.monetization_on;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(arcano.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/cards/arcano_${arcano.imagenNumero}.jpg',
                  width: 200, height: 286, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 200, height: 286,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_paloColor(arcano.palo), AppTheme.purpleDark]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: Text(arcano.nombre,
                      style: const TextStyle(color: AppTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(arcano.nombre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _paloColor(arcano.palo).withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _paloColor(arcano.palo).withAlpha(60)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_paloIcon(arcano.palo), size: 16, color: _paloColor(arcano.palo)),
                  const SizedBox(width: 6),
                  Text('${arcano.palo} - ${arcano.elemento}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _paloColor(arcano.palo))),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          const Text('SIGNIFICADO',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.purplePrimary.withAlpha(8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.purplePrimary.withAlpha(20)),
            ),
            child: Text(arcano.significado,
              style: const TextStyle(fontSize: 15, height: 1.6)),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _infoChip('Rango', arcano.rangoRomano),
            const SizedBox(width: 12),
            _infoChip('Palo', arcano.palo),
            const SizedBox(width: 12),
            _infoChip('Elemento', arcano.elemento),
          ]),
        ]),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.purplePrimary.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.goldAccent, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.purplePrimary)),
      ]),
    );
  }
}
