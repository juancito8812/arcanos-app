import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/database_service.dart';
import 'services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.database;
  final themeProvider = ThemeProvider();
  await themeProvider.load();
  runApp(
    ChangeNotifierProvider.value(value: themeProvider, child: const PsicoTarotApp()),
  );
}
