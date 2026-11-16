import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shop_item.dart';

class GameState extends ChangeNotifier {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int _coins = 120;
  int _xp = 0;
  int _level = 1;
  int _totalCoffeesServed = 0;
  int _fiveStarCount = 0;
  List<String> _unlockedItemIds = [
    'bean_arabica',
    'bean_turkish',
    'cup_ceramic',
    'syr_vanilla',
    'syr_caramel',
  ];

  int get coins => _coins;
  int get xp => _xp;
  int get level => _level;
  int get totalCoffeesServed => _totalCoffeesServed;
  int get fiveStarCount => _fiveStarCount;
  List<String> get unlockedItemIds => List.unmodifiable(_unlockedItemIds);

  String get baristaTitle {
    if (_level >= 5) return '👑 Kahve Efsanesi (Grand Master)';
    if (_level >= 4) return '☕ Baş Barista (Head Barista)';
    if (_level >= 3) return '🏆 Usta Barista (Senior Barista)';
    if (_level >= 2) return '✨ Kalfa Barista (Barista)';
    return '🌱 Çırak Barista (Trainee)';
  }

  int get xpForNextLevel => _level * 200;

  double get levelProgress => (_xp % 200) / 200.0;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt('coins') ?? 120;
      _xp = prefs.getInt('xp') ?? 0;
      _level = prefs.getInt('level') ?? 1;
      _totalCoffeesServed = prefs.getInt('total_served') ?? 0;
      _fiveStarCount = prefs.getInt('five_stars') ?? 0;
      final savedUnlocked = prefs.getStringList('unlocked_items');
      if (savedUnlocked != null && savedUnlocked.isNotEmpty) {
        _unlockedItemIds = savedUnlocked;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('coins', _coins);
      await prefs.setInt('xp', _xp);
      await prefs.setInt('level', _level);
      await prefs.setInt('total_served', _totalCoffeesServed);
      await prefs.setInt('five_stars', _fiveStarCount);
      await prefs.setStringList('unlocked_items', _unlockedItemIds);
    } catch (_) {}
  }

  void addReward({required int earnedCoins, required int earnedXp, required int stars}) {
    _coins += earnedCoins;
    _xp += earnedXp;
    _totalCoffeesServed++;
    if (stars == 5) {
      _fiveStarCount++;
    }

    // Check level up
    final newLevel = (_xp ~/ 200) + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }

    _save();
    notifyListeners();
  }

  bool buyItem(ShopItem item) {
    if (_coins < item.price || _unlockedItemIds.contains(item.id)) {
      return false;
    }
    _coins -= item.price;
    _unlockedItemIds.add(item.id);
    item.isUnlocked = true;
    _save();
    notifyListeners();
    return true;
  }

  bool isItemUnlocked(String itemId) {
    return _unlockedItemIds.contains(itemId);
  }

  void resetProgress() {
    _coins = 120;
    _xp = 0;
    _level = 1;
    _totalCoffeesServed = 0;
    _fiveStarCount = 0;
    _unlockedItemIds = [
      'bean_arabica',
      'bean_turkish',
      'cup_ceramic',
      'syr_vanilla',
      'syr_caramel',
    ];
    _save();
    notifyListeners();
  }
}
