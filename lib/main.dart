import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.database;
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  await _prepararNotificaciones();

  runApp(
    ChangeNotifierProvider.value(value: themeProvider, child: const PsicoTarotApp()),
  );
}

/// Inicializa el plugin y reinstala el recordatorio diario si esta activo.
/// Antes `NotificationService.initialize()` no se llamaba nunca: el toggle de
/// Ajustes programaba sobre un plugin sin inicializar y no sonaba nada.
Future<void> _prepararNotificaciones() async {
  try {
    await NotificationService.initialize();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('notifications_enabled') ?? true) {
      await NotificationService.scheduleDailyCard();
    }
  } catch (e) {
    debugPrint('main: notificaciones no disponibles ($e)');
  }
}
