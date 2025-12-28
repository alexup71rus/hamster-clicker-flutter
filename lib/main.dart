import 'package:flutter/material.dart';
import 'dart:async';
import 'models/game_state.dart';
import 'screens/game_screen.dart';
import 'screens/shop_screen.dart';

void main() {
  runApp(const ClickerApp());
}

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clicker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Главный экран приложения с навигацией между игрой и магазином
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late GameState gameState;
  Timer? passiveIncomeTimer;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    gameState = GameState();

    passiveIncomeTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      gameState.addPassivePoints(0.1); // 0.1 секунды
    });
  }

  @override
  void dispose() {
    passiveIncomeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          GameScreen(gameState: gameState),
          ShopScreen(gameState: gameState),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.touch_app),
            selectedIcon: Icon(Icons.touch_app),
            label: 'Игра',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Магазин',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
