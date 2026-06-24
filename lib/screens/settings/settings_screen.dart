import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:arcanos_mayores/services/notification_service.dart';
import '../../theme.dart';
import '../../services/database_service.dart';
import '../../services/update_service.dart';
import '../../services/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UpdateStatus _updateStatus = UpdateStatus.idle;
  UpdateInfo? _updateInfo;
  double _downloadProgress = 0;
  final _apiKeyController = TextEditingController();
  bool _notificationsEnabled = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKeyController.text = prefs.getString('arcano_ai_key') ?? '';
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.purplePrimary, AppTheme.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 40),
            const SizedBox(height: 8),
            Text('PsicoTarot v$_appVersion', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Arcanos Mayores', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ])),
        const SizedBox(height: 20),
        _Card(title: 'Apariencia', icon: Icons.palette_outlined,
          child: _buildThemeSelector()),
        const SizedBox(height: 12),
        _Card(title: 'Carta del Dia', icon: Icons.notifications_outlined,
          child: _buildNotificationToggle()),
        const SizedBox(height: 12),
        _Card(title: 'Clave API (NVIDIA)', icon: Icons.key,
          child: _buildApiKeyField()),
        const SizedBox(height: 12),
        _Card(title: 'Acerca de', icon: Icons.info_outline,
          child: const Text('Herramienta terapeutica basada en PsicoTarot, Linea de Vida, Regresiones y Constelaciones Familiares.')),
        const SizedBox(height: 12),
        _Card(title: 'Privacidad', icon: Icons.security,
          child: const Text('Todos tus datos se almacenan localmente. No se comparte informacion personal.')),
        const SizedBox(height: 12),
        _Card(title: 'Actualizaciones', icon: Icons.system_update,
          child: _buildUpdateSection()),
        const SizedBox(height: 12),
        _Card(title: 'Gestion de Datos', icon: Icons.storage,
          child: TextButton.icon(onPressed: () => _borrar(context), icon: const Icon(Icons.delete_forever, color: Colors.red), label: const Text('Limpiar datos', style: TextStyle(color: Colors.red)))),
      ]),
    );
  }

  Widget _buildThemeSelector() {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Claro')),
          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Oscuro')),
        ],
        selected: {themeProvider.mode},
        onSelectionChanged: (mode) => themeProvider.setMode(mode.first),
      ),
    ]);
  }

  Widget _buildNotificationToggle() {
    return SwitchListTile(
      title: const Text('Recordatorio diario'),
      subtitle: const Text('Notificacion cada manana con tu carta del dia'),
      value: _notificationsEnabled,
      onChanged: (v) async {
        setState(() => _notificationsEnabled = v);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled', v);
        if (v) {
          await NotificationService.scheduleDailyCard();
        } else {
          await NotificationService.cancelScheduled();
        }
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildApiKeyField() {
    return TextField(
      controller: _apiKeyController,
      decoration: const InputDecoration(
        hintText: 'Ingresa tu API key de NVIDIA',
        isDense: true,
      ),
      onSubmitted: (v) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('arcano_ai_key', v);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API key guardada')),
          );
        }
      },
    );
  }

  Widget _buildUpdateSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_updateStatus == UpdateStatus.idle)
        TextButton.icon(
          onPressed: _checkForUpdates,
          icon: const Icon(Icons.search, color: AppTheme.purplePrimary),
          label: const Text('Buscar actualizaciones', style: TextStyle(color: AppTheme.purplePrimary)),
        ),
      if (_updateStatus == UpdateStatus.checking)
        const Row(children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('Buscando actualizaciones...'),
        ]),
      if (_updateStatus == UpdateStatus.upToDate)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            SizedBox(width: 6),
            Text('Ya tienes la ultima version', style: TextStyle(color: Colors.green)),
          ]),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: _checkForUpdates,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Verificar de nuevo'),
          ),
        ]),
      if (_updateStatus == UpdateStatus.available)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.system_update, color: AppTheme.goldAccent, size: 18),
            SizedBox(width: 6),
            Text('Nueva version disponible', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _downloadAndInstall,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Descargar e instalar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purplePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      if (_updateStatus == UpdateStatus.downloading)
        Column(children: [
          LinearProgressIndicator(
            value: _downloadProgress,
            backgroundColor: Colors.grey[300],
            color: AppTheme.purplePrimary,
          ),
          const SizedBox(height: 6),
          Text('Descargando... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      if (_updateStatus == UpdateStatus.error)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.error_outline, color: Colors.red, size: 18),
            SizedBox(width: 6),
            Text('Error al buscar actualizacion', style: TextStyle(color: Colors.red)),
          ]),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: _checkForUpdates,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Intentar de nuevo'),
          ),
        ]),
      if (_updateStatus == UpdateStatus.installing)
        const Row(children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('Instalando...'),
        ]),
    ]);
  }

  Future<void> _checkForUpdates() async {
    setState(() => _updateStatus = UpdateStatus.checking);

    final info = await UpdateService.checkForUpdate();

    if (!mounted) return;

    if (info == null) {
      setState(() {
        _updateStatus = UpdateStatus.error;
        _updateInfo = null;
      });
    } else if (!info.isNewer) {
      setState(() {
        _updateStatus = UpdateStatus.upToDate;
        _updateInfo = null;
      });
    } else {
      setState(() {
        _updateStatus = UpdateStatus.available;
        _updateInfo = info;
      });
    }
  }

  Future<void> _downloadAndInstall() async {
    if (_updateInfo == null) return;

    setState(() {
      _updateStatus = UpdateStatus.downloading;
      _downloadProgress = 0;
    });

    final file = await UpdateService.downloadApk(
      _updateInfo!.downloadUrl,
      onProgress: (progress) {
        if (mounted) setState(() => _downloadProgress = progress);
      },
    );

    if (file == null || !mounted) {
      setState(() {
        _updateStatus = UpdateStatus.error;
        _updateInfo = null;
      });
      return;
    }

    setState(() => _updateStatus = UpdateStatus.installing);
    await UpdateService.installApk(file.path);
  }

  void _borrar(BuildContext c) {
    showDialog(context: c, builder: (ctx) => AlertDialog(
      title: const Text('Limpiar Datos'),
      content: const Text('Se eliminaran todos los datos almacenados.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        TextButton(onPressed: () async {
          Navigator.pop(ctx);
          await DatabaseService.deleteDatabase();
          if (c.mounted) {
            ScaffoldMessenger.of(c).showSnackBar(
              const SnackBar(content: Text('Datos eliminados correctamente')),
            );
          }
        }, child: const Text('Eliminar', style: TextStyle(color: Colors.red)))],
    ));
  }
}

enum UpdateStatus { idle, checking, upToDate, available, downloading, installing, error }

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
