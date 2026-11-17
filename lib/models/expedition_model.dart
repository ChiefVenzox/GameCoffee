import 'dart:math';
import 'package:flutter/foundation.dart';
import 'caravan_model.dart';

enum MapNodeType {
  servingDay,
  rushHour,
  mysteryEvent,
  caravanShop,
  treasure,
  bossFestival,
}

extension MapNodeTypeExt on MapNodeType {
  String get title {
    switch (this) {
      case MapNodeType.servingDay:
        return 'Kahve Molası';
      case MapNodeType.rushHour:
        return 'Yoğun Saat (Rush Hour)';
      case MapNodeType.mysteryEvent:
        return 'Gizemli Yol Olayı';
      case MapNodeType.caravanShop:
        return 'Karavan Pazarı & Mola';
      case MapNodeType.treasure:
        return 'Tedarik Sandığı';
      case MapNodeType.bossFestival:
        return 'Bölge Kahve Festivali';
    }
  }

  String get icon {
    switch (this) {
      case MapNodeType.servingDay:
        return '☕';
      case MapNodeType.rushHour:
        return '🔥';
      case MapNodeType.mysteryEvent:
        return '❓';
      case MapNodeType.caravanShop:
        return '🛒';
      case MapNodeType.treasure:
        return '🎁';
      case MapNodeType.bossFestival:
        return '🏆';
    }
  }

  String get shortDesc {
    switch (this) {
      case MapNodeType.servingDay:
        return 'Günün menüsünü hazırla ve 3-4 kasaba müşterisine servis yap.';
      case MapNodeType.rushHour:
        return 'Hızlı ve sabırsız kalabalık! Çift bahşiş, yüksek heyecan.';
      case MapNodeType.mysteryEvent:
        return 'Yolda beklenmedik bir hikaye, seçimler ve ödüller.';
      case MapNodeType.caravanShop:
        return 'Karavanını tamir et, yeni ekipman ve dekoratif eşyalar satın al.';
      case MapNodeType.treasure:
        return 'Yol kenarında bırakılmış özel bir barista sandığı.';
      case MapNodeType.bossFestival:
        return 'Bölgenin en büyük kahve festivali! Gurme eleştirmenleri etkile.';
    }
  }
}

class MapNode {
  final String id;
  final int layer; // 0 to 5
  final int lane;  // 0, 1, 2
  final MapNodeType type;
  final List<String> nextNodeIds;
  bool isCompleted;
  bool isAvailable;

  MapNode({
    required this.id,
    required this.layer,
    required this.lane,
    required this.type,
    required this.nextNodeIds,
    this.isCompleted = false,
    this.isAvailable = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'layer': layer,
    'lane': lane,
    'type': type.name,
    'nextNodeIds': nextNodeIds,
    'isCompleted': isCompleted,
    'isAvailable': isAvailable,
  };

  factory MapNode.fromJson(Map<String, dynamic> json) => MapNode(
    id: json['id'] as String,
    layer: json['layer'] as int,
    lane: json['lane'] as int,
    type: MapNodeType.values.firstWhere((t) => t.name == json['type']),
    nextNodeIds: List<String>.from(json['nextNodeIds'] as List),
    isCompleted: json['isCompleted'] as bool? ?? false,
    isAvailable: json['isAvailable'] as bool? ?? false,
  );
}

class ExpeditionState extends ChangeNotifier {
  static final ExpeditionState _instance = ExpeditionState._internal();
  factory ExpeditionState() => _instance;
  ExpeditionState._internal();

  bool _isRunActive = false;
  bool _isRunCompleted = false;
  bool _isGameOver = false;

  int _reputationHearts = 3;
  static const int maxHearts = 3;

  int _runCoins = 50;
  int _currentLayer = 0;
  String? _currentNodeId;
  String _regionId = 'valley';
  CaravanTierId _caravanTierId = CaravanTierId.nomad;

  List<String> _activeMenu = ['espresso', 'latte', 'turkish_coffee'];
  List<String> _activeRelicIds = [];
  final Map<String, MapNode> _nodes = {};

  // Getters
  bool get isRunActive => _isRunActive;
  bool get isRunCompleted => _isRunCompleted;
  bool get isGameOver => _isGameOver;
  int get reputationHearts => _reputationHearts;
  int get runCoins => _runCoins;
  int get currentLayer => _currentLayer;
  String? get currentNodeId => _currentNodeId;
  String get regionId => _regionId;
  CaravanRegion get currentRegion => CaravanRegion.getById(_regionId);
  CaravanTier get currentCaravan => CaravanTier.getById(_caravanTierId);
  CaravanTierId get caravanTierId => _caravanTierId;
  List<String> get activeMenu => List.unmodifiable(_activeMenu);
  List<String> get activeRelicIds => List.unmodifiable(_activeRelicIds);
  Map<String, MapNode> get nodes => _nodes;
  MapNode? get currentNode => _currentNodeId != null ? _nodes[_currentNodeId] : null;

  int get maxCleanCups => currentCaravan.maxCleanCups;

  /// Total layers in an expedition (0 to 5, total 6 days with Boss Festival at layer 5)
  static const int totalLayers = 6;

  /// Start a new Roguelite Expedition Run
  void startNewRun({
    String regionId = 'valley',
    CaravanTierId tierId = CaravanTierId.nomad,
    List<String>? initialUnlockedRecipes,
  }) {
    _isRunActive = true;
    _isRunCompleted = false;
    _isGameOver = false;
    _reputationHearts = 3;
    _runCoins = 50;
    _currentLayer = 0;
    _currentNodeId = null;
    _regionId = regionId;
    _caravanTierId = tierId;
    _activeRelicIds = [];

    // Ensure initial menu has up to 3 recipes
    if (initialUnlockedRecipes != null && initialUnlockedRecipes.isNotEmpty) {
      _activeMenu = initialUnlockedRecipes.take(3).toList();
    } else {
      _activeMenu = ['espresso', 'latte', 'turkish_coffee'];
    }

    _generateProceduralMap();
    notifyListeners();
  }

  void _generateProceduralMap() {
    _nodes.clear();
    final random = Random();

    // Layers:
    // Layer 0: Day 1 (2 nodes, Serving Day)
    // Layer 1: Day 2 (3 nodes: Serving, Mystery, Rush)
    // Layer 2: Day 3 (2 nodes: Treasure / Serving)
    // Layer 3: Day 4 (3 nodes: Mystery, Shop, Rush)
    // Layer 4: Day 5 (2 nodes: Shop / Serving)
    // Layer 5: Day 6 (1 node: Boss Festival)

    final Map<int, List<MapNode>> layerNodes = {};

    for (int l = 0; l < totalLayers; l++) {
      layerNodes[l] = [];
      if (l == 0) {
        // Start layer: 2 nodes
        for (int lane = 0; lane < 2; lane++) {
          final id = 'node_${l}_$lane';
          layerNodes[l]!.add(
            MapNode(
              id: id,
              layer: l,
              lane: lane == 0 ? 0 : 2,
              type: MapNodeType.servingDay,
              nextNodeIds: [],
              isAvailable: true, // First layer is available immediately
            ),
          );
        }
      } else if (l == totalLayers - 1) {
        // Boss Festival layer: 1 node in middle
        final id = 'node_${l}_1';
        layerNodes[l]!.add(
          MapNode(
            id: id,
            layer: l,
            lane: 1,
            type: MapNodeType.bossFestival,
            nextNodeIds: [],
          ),
        );
      } else if (l == 2) {
        // Treasure layer: 2 nodes
        for (int lane = 0; lane < 2; lane++) {
          final id = 'node_${l}_$lane';
          layerNodes[l]!.add(
            MapNode(
              id: id,
              layer: l,
              lane: lane == 0 ? 0 : 2,
              type: lane == 0 ? MapNodeType.treasure : MapNodeType.mysteryEvent,
              nextNodeIds: [],
            ),
          );
        }
      } else if (l == 4) {
        // Pre-boss rest layer: Shop + Serving
        for (int lane = 0; lane < 2; lane++) {
          final id = 'node_${l}_$lane';
          layerNodes[l]!.add(
            MapNode(
              id: id,
              layer: l,
              lane: lane == 0 ? 0 : 2,
              type: lane == 0 ? MapNodeType.caravanShop : MapNodeType.servingDay,
              nextNodeIds: [],
            ),
          );
        }
      } else {
        // Middle layers (1 & 3): 3 lanes
        final pool = [
          MapNodeType.servingDay,
          MapNodeType.rushHour,
          MapNodeType.mysteryEvent,
          MapNodeType.caravanShop,
        ];
        pool.shuffle(random);

        for (int lane = 0; lane < 3; lane++) {
          final id = 'node_${l}_$lane';
          layerNodes[l]!.add(
            MapNode(
              id: id,
              layer: l,
              lane: lane,
              type: pool[lane % pool.length],
              nextNodeIds: [],
            ),
          );
        }
      }
    }

    // Connect layers forward
    for (int l = 0; l < totalLayers - 1; l++) {
      final currentLayerList = layerNodes[l]!;
      final nextLayerList = layerNodes[l + 1]!;

      for (var curr in currentLayerList) {
        if (nextLayerList.length == 1) {
          curr.nextNodeIds.add(nextLayerList.first.id);
        } else {
          // Connect to closest lanes
          for (var next in nextLayerList) {
            if ((curr.lane - next.lane).abs() <= 1 || currentLayerList.length != nextLayerList.length) {
              curr.nextNodeIds.add(next.id);
            }
          }
          // Fallback if no connection
          if (curr.nextNodeIds.isEmpty) {
            curr.nextNodeIds.add(nextLayerList.first.id);
          }
        }
      }
    }

    // Populate lookup map
    for (var list in layerNodes.values) {
      for (var node in list) {
        _nodes[node.id] = node;
      }
    }
  }

  /// Select and move caravan to an available node
  bool selectNode(String nodeId) {
    final node = _nodes[nodeId];
    if (node == null || !node.isAvailable || node.isCompleted) {
      return false;
    }

    _currentNodeId = nodeId;
    _currentLayer = node.layer;

    // Make all other nodes unavailable while this one is in progress
    for (var n in _nodes.values) {
      n.isAvailable = false;
    }

    notifyListeners();
    return true;
  }

  /// Mark the current node completed and open paths to connected next nodes
  void completeCurrentNode({int coinsEarned = 0, int xpEarned = 0}) {
    if (_currentNodeId == null) return;
    final node = _nodes[_currentNodeId];
    if (node == null) return;

    node.isCompleted = true;
    _runCoins += coinsEarned;

    // Relic daily gold bonus
    for (var relicId in _activeRelicIds) {
      final relic = CaravanRelic.findById(relicId);
      if (relic != null && relic.bonusGoldPerDay > 0) {
        _runCoins += relic.bonusGoldPerDay;
      }
    }

    // Check if Boss Festival completed -> Win run!
    if (node.type == MapNodeType.bossFestival) {
      _isRunCompleted = true;
      _isRunActive = false;
      notifyListeners();
      return;
    }

    // Unlock next connected nodes
    for (var nextId in node.nextNodeIds) {
      if (_nodes.containsKey(nextId)) {
        _nodes[nextId]!.isAvailable = true;
      }
    }

    _currentNodeId = null;
    notifyListeners();
  }

  /// Customer patience expired or failure
  void loseHeart() {
    if (_reputationHearts > 0) {
      _reputationHearts--;
      if (_reputationHearts <= 0) {
        _isGameOver = true;
        _isRunActive = false;
      }
      notifyListeners();
    }
  }

  /// Restore reputation
  void gainHeart() {
    if (_reputationHearts < maxHearts) {
      _reputationHearts++;
      notifyListeners();
    }
  }

  void addRunCoins(int amount) {
    _runCoins += amount;
    notifyListeners();
  }

  bool spendRunCoins(int amount) {
    if (_runCoins >= amount) {
      _runCoins -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  void addRelic(String relicId) {
    if (!_activeRelicIds.contains(relicId)) {
      _activeRelicIds.add(relicId);
      notifyListeners();
    }
  }

  /// Toggle recipe on the active daily chalkboard menu
  bool toggleMenuRecipe(String recipeId) {
    if (_activeMenu.contains(recipeId)) {
      if (_activeMenu.length > 1) {
        _activeMenu.remove(recipeId);
        notifyListeners();
        return true;
      }
      return false; // Must keep at least 1 recipe
    } else {
      if (_activeMenu.length < 5) {
        _activeMenu.add(recipeId);
        notifyListeners();
        return true;
      }
      return false; // Max 5 active daily menu recipes
    }
  }

  /// Relic & Caravan calculation multipliers
  double get totalPatienceMultiplier {
    double mult = currentCaravan.patienceBonusMultiplier;
    for (var id in _activeRelicIds) {
      final relic = CaravanRelic.findById(id);
      if (relic != null) mult += relic.patienceBoost;
    }
    return mult;
  }

  double get totalTipMultiplier {
    double mult = currentCaravan.tipBonusMultiplier;
    for (var id in _activeRelicIds) {
      final relic = CaravanRelic.findById(id);
      if (relic != null) mult += relic.tipBoost;
    }
    return mult;
  }

  double get totalWashSpeedMultiplier {
    double mult = 1.0;
    for (var id in _activeRelicIds) {
      final relic = CaravanRelic.findById(id);
      if (relic != null) mult += relic.washSpeedBoost;
    }
    return mult;
  }

  double get totalBrewSpeedMultiplier {
    double mult = currentCaravan.brewSpeedMultiplier;
    for (var id in _activeRelicIds) {
      final relic = CaravanRelic.findById(id);
      if (relic != null) mult += relic.brewSpeedBoost;
    }
    return mult;
  }
}
