import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/game_state.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI styling for Android & iOS status/navigation bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF160E08),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize GameState with saved persistent data
  await GameState().init();

  runApp(const GameCoffeeApp());
}

class GameCoffeeApp extends StatelessWidget {
  const GameCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barista Master: Kahve Dükkanı',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
