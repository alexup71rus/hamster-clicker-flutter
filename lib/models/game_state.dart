import 'package:flutter/foundation.dart';
import 'upgrade.dart';

/// Главный класс состояния игры
class GameState extends ChangeNotifier {
  // Основной счетчик очков
  int _points = 0;

  // Очки в секунду (пассивный доход)
  double _pointsPerSecond = 0.0;

  // Очки за клик
  int _pointsPerClick = 1;

  // Список всех улучшений
  final List<Upgrade> _upgrades = [];

  // Фильтры для магазина
  bool _showOnlyPurchased = false;
  bool _showOnlyAffordable = false;

  // Накопленные дробные очки
  double _accumulatedPoints = 0.0;

  // Геттеры для доступа к данным
  int get points => _points;
  double get pointsPerSecond => _pointsPerSecond;
  int get pointsPerClick => _pointsPerClick;
  List<Upgrade> get upgrades => List.unmodifiable(_upgrades);
  bool get showOnlyPurchased => _showOnlyPurchased;
  bool get showOnlyAffordable => _showOnlyAffordable;

  /// Конструктор - инициализируем начальные улучшения
  GameState() {
    _initializeUpgrades();
  }

  /// Метод для клика - добавляет очки
  void click() {
    _points += _pointsPerClick;
    notifyListeners();
  }

  /// Покупка улучшения
  bool purchaseUpgrade(String upgradeId) {
    final upgrade = _upgrades.firstWhere(
      (u) => u.id == upgradeId,
      orElse: () => throw ArgumentError('Upgrade not found: $upgradeId'),
    );

    // Проверяем, можем ли купить
    if (_points < upgrade.currentPrice || upgrade.isPurchased) {
      return false;
    }

    // Покупаем
    _points -= upgrade.currentPrice;
    upgrade.purchase();

    // Пересчитываем характеристики
    _recalculateStats();

    notifyListeners();
    return true;
  }

  /// Получить отфильтрованный список улучшений
  List<Upgrade> getFilteredUpgrades() {
    List<Upgrade> filtered = List.from(_upgrades);

    if (_showOnlyPurchased && _showOnlyAffordable) {
      // Если оба фильтра активны, скрываем недоступные
      filtered = filtered
          .where(
            (u) =>
                u.isPurchased || (_points >= u.currentPrice && !u.isPurchased),
          )
          .toList();
      return filtered;
    } else {
      if (_showOnlyPurchased) {
        filtered = filtered.where((u) => u.isPurchased).toList();
      }
      if (_showOnlyAffordable) {
        filtered = filtered
            .where((u) => _points >= u.currentPrice && !u.isPurchased)
            .toList();
      }
    }

    return filtered;
  }

  /// Переключить фильтр "только купленные"
  void togglePurchasedFilter() {
    _showOnlyPurchased = !_showOnlyPurchased;
    notifyListeners();
  }

  /// Переключить фильтр "только доступные"
  void toggleAffordableFilter() {
    _showOnlyAffordable = !_showOnlyAffordable;
    notifyListeners();
  }

  /// Сброс всех фильтров
  void clearFilters() {
    _showOnlyPurchased = false;
    _showOnlyAffordable = false;
    notifyListeners();
  }

  /// Инициализация улучшений
  void _initializeUpgrades() {
    _upgrades.addAll([
      // Улучшения клика
      Upgrade(
        id: 'click_power_1',
        name: 'Лучший клик',
        description: 'Увеличивает силу клика на 1',
        basePrice: 10,
        type: UpgradeType.clickPower,
        value: 1,
        iconData: '💪',
      ),
      Upgrade(
        id: 'click_power_2',
        name: 'Мощный клик',
        description: 'Увеличивает силу клика на 3',
        basePrice: 50,
        type: UpgradeType.clickPower,
        value: 3,
        iconData: '🔥',
      ),
      Upgrade(
        id: 'click_power_3',
        name: 'Супер клик',
        description: 'Увеличивает силу клика на 10',
        basePrice: 200,
        type: UpgradeType.clickPower,
        value: 10,
        iconData: '⚡',
      ),

      // Пассивные улучшения
      Upgrade(
        id: 'auto_clicker_1',
        name: 'Авто-кликер',
        description: 'Дает 1 очко в секунду',
        basePrice: 100,
        type: UpgradeType.passive,
        value: 1,
        iconData: '🤖',
      ),
      Upgrade(
        id: 'factory_1',
        name: 'Мини-фабрика',
        description: 'Дает 5 очков в секунду',
        basePrice: 500,
        type: UpgradeType.passive,
        value: 5,
        iconData: '🏭',
      ),
      Upgrade(
        id: 'factory_2',
        name: 'Супер-фабрика',
        description: 'Дает 25 очков в секунду',
        basePrice: 2500,
        type: UpgradeType.passive,
        value: 25,
        iconData: '🏗️',
      ),

      // Специальные улучшения
      Upgrade(
        id: 'multiplier_1',
        name: 'Удачливый клик',
        description: 'Умножает все доходы на 2',
        basePrice: 1000,
        type: UpgradeType.multiplier,
        value: 2,
        iconData: '🍀',
      ),
      Upgrade(
        id: 'multiplier_2',
        name: 'Золотой клик',
        description: 'Умножает все доходы на 3',
        basePrice: 10000,
        type: UpgradeType.multiplier,
        value: 3,
        iconData: '🌟',
      ),
    ]);
  }

  /// Пересчет всех характеристик на основе купленных улучшений
  void _recalculateStats() {
    _pointsPerClick = 1;
    _pointsPerSecond = 0.0;
    double totalMultiplier = 1.0;

    for (final upgrade in _upgrades.where((u) => u.isPurchased)) {
      switch (upgrade.type) {
        case UpgradeType.clickPower:
          _pointsPerClick += upgrade.value.toInt();
          break;
        case UpgradeType.passive:
          _pointsPerSecond += upgrade.value;
          break;
        case UpgradeType.multiplier:
          totalMultiplier *= upgrade.value;
          break;
      }
    }

    // Применяем множители
    _pointsPerClick = (_pointsPerClick * totalMultiplier).round();
    _pointsPerSecond = _pointsPerSecond * totalMultiplier;
  }

  /// Добавляем пассивные очки (вызывается по таймеру)
  void addPassivePoints(double deltaTime) {
    if (_pointsPerSecond > 0) {
      // Накапливаем дробные очки
      _accumulatedPoints += _pointsPerSecond * deltaTime;

      // Добавляем целую часть к основным очкам
      final pointsToAdd = _accumulatedPoints.floor();
      if (pointsToAdd > 0) {
        _points += pointsToAdd;
        _accumulatedPoints -= pointsToAdd; // Оставляем дробную часть
        notifyListeners();
      }
    }
  }
}
