import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'services/theme_provider.dart';

class PsicoTarotApp extends StatelessWidget {
  const PsicoTarotApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'PsicoTarot - Arcanos Mayores',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeFor(themeProvider.palette, ThemeMode.light),
      darkTheme: AppTheme.themeFor(themeProvider.palette, ThemeMode.dark),
      themeMode: themeProvider.mode,
      home: const SplashScreen(),
    );
  }
}
