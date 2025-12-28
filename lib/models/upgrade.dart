/// Типы улучшений
enum UpgradeType {
  clickPower, // Увеличивает очки за клик
  passive, // Пассивный доход очков в секунду
  multiplier, // Умножает все доходы
}

/// Класс для представления улучшения в магазине
class Upgrade {
  final String id; // Уникальный идентификатор
  final String name; // Название
  final String description; // Описание
  final int basePrice; // Базовая цена
  final UpgradeType type; // Тип улучшения
  final double value; // Значение эффекта
  final String iconData; // Иконка (эмодзи)

  bool _isPurchased = false; // Куплено ли улучшение

  /// Геттеры
  bool get isPurchased => _isPurchased;

  /// Текущая цена (может изменяться в зависимости от купленных улучшений)
  int get currentPrice => basePrice;

  /// Конструктор
  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.type,
    required this.value,
    required this.iconData,
  });

  /// Покупка улучшения
  void purchase() {
    _isPurchased = true;
  }

  /// Сброс улучшения (для отладки)
  void reset() {
    _isPurchased = false;
  }

  /// Получить описание эффекта для UI
  String getEffectDescription() {
    switch (type) {
      case UpgradeType.clickPower:
        return '+${value.toInt()} очков за клик';
      case UpgradeType.passive:
        return '+${value} очков/сек';
      case UpgradeType.multiplier:
        return '×${value} ко всем доходам';
    }
  }

  /// Получить цветовую схему в зависимости от типа
  String getTypeColor() {
    switch (type) {
      case UpgradeType.clickPower:
        return '#FF5722'; // Оранжевый
      case UpgradeType.passive:
        return '#4CAF50'; // Зелёный
      case UpgradeType.multiplier:
        return '#9C27B0'; // Фиолетовый
    }
  }

  @override
  String toString() {
    return 'Upgrade{id: $id, name: $name, isPurchased: $_isPurchased}';
  }
}
