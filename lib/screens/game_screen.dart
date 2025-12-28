import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';

/// Виджет главного экрана игры с кликером
class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _clickAnimationController;
  late Animation<double> _clickAnimation;

  @override
  void initState() {
    super.initState();

    // Инициализация анимации для клика
    _clickAnimationController = AnimationController(
      duration: const Duration(milliseconds: 30),
      vsync: this,
    );

    _clickAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _clickAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _clickAnimationController.dispose();
    super.dispose();
  }

  void _onButtonClick() {
    // Анимация нажатия
    _clickAnimationController.forward().then((_) {
      _clickAnimationController.reverse();
    });

    // Вибрация
    HapticFeedback.lightImpact();

    // Логика игры
    widget.gameState.click();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, child) {
        final backgroundAsset = _getBackgroundAsset();
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(backgroundAsset, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Общие очки
                      _buildStatCard(
                        icon: '💎',
                        label: 'Очки',
                        value: _formatNumber(widget.gameState.points),
                      ),
                      // Очки в секунду
                      _buildStatCard(
                        icon: '⚡',
                        label: 'в сек',
                        value: widget.gameState.pointsPerSecond.toStringAsFixed(
                          1,
                        ),
                      ),
                      // Очки за клик
                      _buildStatCard(
                        icon: '👆',
                        label: 'за клик',
                        value: widget.gameState.pointsPerClick.toString(),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(80.0),
                    child: _buildProgressToNextUpgrade(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: ScaleTransition(
                        scale: _clickAnimation,
                        child: GestureDetector(
                          onTap: _onButtonClick,
                          child: ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              width: 350,
                              height: 350,
                              child: Image.asset(
                                'assets/images/main_screen/hamster_1.png',
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressToNextUpgrade() {
    final affordableUpgrades =
        widget.gameState.upgrades
            .where(
              (u) => !u.isPurchased && widget.gameState.points < u.currentPrice,
            )
            .toList()
          ..sort((a, b) => a.currentPrice.compareTo(b.currentPrice));

    if (affordableUpgrades.isEmpty) {
      return const SizedBox.shrink();
    }

    final nextUpgrade = affordableUpgrades.first;
    final progress = widget.gameState.points / nextUpgrade.currentPrice;
    final remaining = nextUpgrade.currentPrice - widget.gameState.points;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    nextUpgrade.iconData,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextUpgrade.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Нужно ещё: ${_formatNumber(remaining)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF0F1F0F),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFC4F169),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBackgroundAsset() {
    final purchasedCount = widget.gameState.upgrades
        .where((u) => u.isPurchased)
        .length;

    if (purchasedCount >= 5) {
      return 'assets/images/main_screen/screen_3.png';
    } else if (purchasedCount >= 2) {
      return 'assets/images/main_screen/screen_2.png';
    }
    return 'assets/images/main_screen/screen_1.png';
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
