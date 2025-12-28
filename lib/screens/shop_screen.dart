import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/upgrade.dart';

/// Экран магазина улучшений
class ShopScreen extends StatelessWidget {
  final GameState gameState;

  const ShopScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, child) {
        final filteredUpgrades = gameState.getFilteredUpgrades();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Магазин (${filteredUpgrades.length})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            actions: [
              // Кнопка фильтров с отступом справа
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () async {
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject()
                                as RenderBox;
                        final Offset position = button.localToGlobal(
                          Offset.zero,
                          ancestor: overlay,
                        );

                        await showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) {
                            return Stack(
                              children: [
                                Positioned(
                                  right:
                                      MediaQuery.of(context).size.width -
                                      position.dx -
                                      button.size.width,
                                  top: position.dy + button.size.height,
                                  child: ListenableBuilder(
                                    listenable: gameState,
                                    builder: (context, child) => Material(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildFilterMenuItem(
                                            context,
                                            label: 'Только купленные',
                                            icon: gameState.showOnlyPurchased
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            onTap: () {
                                              gameState.togglePurchasedFilter();
                                            },
                                          ),
                                          _buildFilterMenuItem(
                                            context,
                                            label: 'Только доступные',
                                            icon: gameState.showOnlyAffordable
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            onTap: () {
                                              gameState
                                                  .toggleAffordableFilter();
                                            },
                                          ),
                                          _buildFilterMenuItem(
                                            context,
                                            label: 'Сбросить фильтры',
                                            icon: Icons.clear,
                                            onTap: () {
                                              gameState.clearFilters();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Индикаторы активных фильтров
              if (gameState.showOnlyPurchased || gameState.showOnlyAffordable)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (gameState.showOnlyPurchased)
                        _buildFilterChip(
                          context,
                          'Купленные',
                          Icons.shopping_bag,
                        ),
                      if (gameState.showOnlyAffordable)
                        _buildFilterChip(
                          context,
                          'Доступные',
                          Icons.monetization_on,
                        ),
                    ],
                  ),
                ),

              // Список улучшений
              Expanded(
                child: filteredUpgrades.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUpgrades.length,
                        itemBuilder: (context, index) {
                          return _buildUpgradeCard(
                            context,
                            filteredUpgrades[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛍️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Нет улучшений',
            style: TextStyle(
              color: colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить фильтры',
            style: TextStyle(
              color: colorScheme.onBackground.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context, Upgrade upgrade) {
    final canAfford = gameState.points >= upgrade.currentPrice;
    final isAvailable = !upgrade.isPurchased && canAfford;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: upgrade.isPurchased
            ? colorScheme.primary.withOpacity(0.1)
            : canAfford
            ? colorScheme.surface
            : colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: upgrade.isPurchased
              ? colorScheme.primary.withOpacity(0.5)
              : isAvailable
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.3),
          width: upgrade.isPurchased ? 2 : 1,
        ),
        boxShadow: isAvailable
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.18),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isAvailable ? () => _purchaseUpgrade(context, upgrade) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка улучшения
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getTypeColor(upgrade.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      upgrade.iconData,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Информация об улучшении
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название и статус
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              upgrade.name,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: upgrade.isPurchased
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (upgrade.isPurchased)
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Описание
                      Text(
                        upgrade.description,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Эффект и цена
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(upgrade.type),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              upgrade.getEffectDescription(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!upgrade.isPurchased)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: canAfford
                                    ? colorScheme.primaryContainer
                                    : colorScheme.onSurface.withOpacity(0.28),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '💎',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatNumber(upgrade.currentPrice),
                                    style: TextStyle(
                                      color: canAfford
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _purchaseUpgrade(BuildContext context, Upgrade upgrade) {
    HapticFeedback.selectionClick();
    final colorScheme = Theme.of(context).colorScheme;

    final success = gameState.purchaseUpgrade(upgrade.id);

    if (success) {
      // Показываем уведомление об успешной покупке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  upgrade.iconData,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Куплено: ${upgrade.name}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: colorScheme.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.onSurface.withOpacity(0.12)),
          ),
          margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getTypeColor(UpgradeType type) {
    switch (type) {
      case UpgradeType.clickPower:
        return const Color(0xFFE36414); // глубокий оранжевый
      case UpgradeType.passive:
        return const Color(0xFFD97706); // тёмный янтарный
      case UpgradeType.multiplier:
        return const Color(0xFFB3475D); // тёплый бордово-терракотовый
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildFilterMenuItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
