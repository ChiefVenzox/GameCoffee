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
  List<String> _unlockedCaravanTierIds = ['nomad'];
  String _activeCaravanTierId = 'nomad';
  List<String> _unlockedRecipeIds = [
    'turkish_coffee',
    'espresso',
    'latte',
    'cappuccino',
  ];
  int _totalExpeditionsWon = 0;
  int _bestExpeditionScore = 0;

  int get coins => _coins;
  int get xp => _xp;
  int get level => _level;
  int get totalCoffeesServed => _totalCoffeesServed;
  int get fiveStarCount => _fiveStarCount;
  int get totalExpeditionsWon => _totalExpeditionsWon;
  int get bestExpeditionScore => _bestExpeditionScore;
  List<String> get unlockedItemIds => List.unmodifiable(_unlockedItemIds);
  List<String> get unlockedCaravanTierIds => List.unmodifiable(_unlockedCaravanTierIds);
  String get activeCaravanTierId => _activeCaravanTierId;
  List<String> get unlockedRecipeIds => List.unmodifiable(_unlockedRecipeIds);

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
      _totalExpeditionsWon = prefs.getInt('expeditions_won') ?? 0;
      _bestExpeditionScore = prefs.getInt('best_score') ?? 0;
      _activeCaravanTierId = prefs.getString('active_caravan') ?? 'nomad';

      final savedUnlocked = prefs.getStringList('unlocked_items');
      if (savedUnlocked != null && savedUnlocked.isNotEmpty) {
        _unlockedItemIds = savedUnlocked;
      }
      final savedCaravans = prefs.getStringList('unlocked_caravans');
      if (savedCaravans != null && savedCaravans.isNotEmpty) {
        _unlockedCaravanTierIds = savedCaravans;
      }
      final savedRecipes = prefs.getStringList('unlocked_recipes');
      if (savedRecipes != null && savedRecipes.isNotEmpty) {
        _unlockedRecipeIds = savedRecipes;
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
      await prefs.setInt('expeditions_won', _totalExpeditionsWon);
      await prefs.setInt('best_score', _bestExpeditionScore);
      await prefs.setString('active_caravan', _activeCaravanTierId);
      await prefs.setStringList('unlocked_items', _unlockedItemIds);
      await prefs.setStringList('unlocked_caravans', _unlockedCaravanTierIds);
      await prefs.setStringList('unlocked_recipes', _unlockedRecipeIds);
    } catch (_) {}
  }

  void addReward({required int earnedCoins, required int earnedXp, required int stars}) {
    _coins += earnedCoins;
    _xp += earnedXp;
    _totalCoffeesServed++;
    if (stars == 5) {
      _fiveStarCount++;
    }

    final newLevel = (_xp ~/ 200) + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }

    _save();
    notifyListeners();
  }

  void recordExpeditionFinished({required int earnedCoins, required int earnedXp, required bool won}) {
    _coins += earnedCoins;
    _xp += earnedXp;
    if (won) {
      _totalExpeditionsWon++;
    }
    if (earnedCoins > _bestExpeditionScore) {
      _bestExpeditionScore = earnedCoins;
    }
    final newLevel = (_xp ~/ 200) + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }
    _save();
    notifyListeners();
  }

  bool unlockCaravan(String tierId, int price) {
    if (_coins < price || _unlockedCaravanTierIds.contains(tierId)) {
      return false;
    }
    _coins -= price;
    _unlockedCaravanTierIds.add(tierId);
    _activeCaravanTierId = tierId;
    _save();
    notifyListeners();
    return true;
  }

  void setActiveCaravan(String tierId) {
    if (_unlockedCaravanTierIds.contains(tierId)) {
      _activeCaravanTierId = tierId;
      _save();
      notifyListeners();
    }
  }

  bool unlockRecipe(String recipeId, int price) {
    if (_coins < price || _unlockedRecipeIds.contains(recipeId)) {
      return false;
    }
    _coins -= price;
    _unlockedRecipeIds.add(recipeId);
    _save();
    notifyListeners();
    return true;
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

  bool isRecipeUnlocked(String recipeId) {
    return _unlockedRecipeIds.contains(recipeId);
  }

  void resetProgress() {
    _coins = 120;
    _xp = 0;
    _level = 1;
    _totalCoffeesServed = 0;
    _fiveStarCount = 0;
    _totalExpeditionsWon = 0;
    _bestExpeditionScore = 0;
    _activeCaravanTierId = 'nomad';
    _unlockedCaravanTierIds = ['nomad'];
    _unlockedRecipeIds = [
      'turkish_coffee',
      'espresso',
      'latte',
      'cappuccino',
    ];
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
