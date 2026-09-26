import 'package:flutter/material.dart';
import 'routing/router.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const GoRushApp());
}

class GoRushApp extends StatelessWidget {
  const GoRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoRush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}
