import 'package:flutter/material.dart';

enum CaravanTierId {
  nomad,
  vintageTruck,
  artisanTrailer,
  royalCruiser,
}

class CaravanTier {
  final CaravanTierId id;
  final String name;
  final String title;
  final String description;
  final int maxCleanCups;
  final double brewSpeedMultiplier;
  final double tipBonusMultiplier;
  final double patienceBonusMultiplier;
  final int unlockPrice;
  final String icon;
  final Color primaryColor;
  final Color accentColor;

  const CaravanTier({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.maxCleanCups,
    this.brewSpeedMultiplier = 1.0,
    this.tipBonusMultiplier = 1.0,
    this.patienceBonusMultiplier = 1.0,
    required this.unlockPrice,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
  });

  static const List<CaravanTier> allTiers = [
    CaravanTier(
      id: CaravanTierId.nomad,
      name: 'Kır Karavanı (Nomad Camper)',
      title: 'Kompakt & Samimi Başlangıç Karavanı',
      description: 'Yollara yeni çıkan baristalar için hafif, şirin ve kullanışlı ahşap detaylı campervan.',
      maxCleanCups: 4,
      brewSpeedMultiplier: 1.0,
      tipBonusMultiplier: 1.0,
      patienceBonusMultiplier: 1.0,
      unlockPrice: 0,
      icon: '🚐',
      primaryColor: Color(0xFF4E7A58),
      accentColor: Color(0xFFFCD34D),
    ),
    CaravanTier(
      id: CaravanTierId.vintageTruck,
      name: 'Retro Kahve Kamyoneti (Vintage Van)',
      title: 'Klasik Çelik Gövde & Geniş Servis Tezgahı',
      description: 'Daha geniş fincan rafı ve retro tarzıyla müşterilerin ilgisini çeker, bahşişleri artırır.',
      maxCleanCups: 5,
      brewSpeedMultiplier: 1.15,
      tipBonusMultiplier: 1.25,
      patienceBonusMultiplier: 1.1,
      unlockPrice: 350,
      icon: '🚚',
      primaryColor: Color(0xFF2C6B74),
      accentColor: Color(0xFFF59E0B),
    ),
    CaravanTier(
      id: CaravanTierId.artisanTrailer,
      name: 'Gurme Kahve Treyleri (Artisan Trailer)',
      title: 'Çift Kazanlı Yüksek Basınç İstasyonu',
      description: 'Paslanmaz çelik İtalyan espresso makineleri ve hızlı lavabo düzeneği ile profesyonel bir güç.',
      maxCleanCups: 6,
      brewSpeedMultiplier: 1.3,
      tipBonusMultiplier: 1.35,
      patienceBonusMultiplier: 1.25,
      unlockPrice: 750,
      icon: '🌟',
      primaryColor: Color(0xFFC86432),
      accentColor: Color(0xFFFFFBEB),
    ),
    CaravanTier(
      id: CaravanTierId.royalCruiser,
      name: 'Kraliyet Barista Karavanı (Grand Cruiser)',
      title: 'Efsanevi Mobil Kahve Sarayı',
      description: 'Otomatik fincan durulama, panoramik vitrin ve lüks ambiyansıyla en zorlu festivalleri fetheder.',
      maxCleanCups: 8,
      brewSpeedMultiplier: 1.5,
      tipBonusMultiplier: 1.5,
      patienceBonusMultiplier: 1.4,
      unlockPrice: 1500,
      icon: '👑',
      primaryColor: Color(0xFF2E1A47),
      accentColor: Color(0xFFFCD34D),
    ),
  ];

  static CaravanTier getById(CaravanTierId id) {
    return allTiers.firstWhere((t) => t.id == id, orElse: () => allTiers.first);
  }
}

class CaravanRelic {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int shopPrice;
  final double patienceBoost;
  final double tipBoost;
  final double washSpeedBoost;
  final double brewSpeedBoost;
  final int bonusGoldPerDay;

  const CaravanRelic({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.shopPrice,
    this.patienceBoost = 0.0,
    this.tipBoost = 0.0,
    this.washSpeedBoost = 0.0,
    this.brewSpeedBoost = 0.0,
    this.bonusGoldPerDay = 0,
  });

  static const List<CaravanRelic> allRelics = [
    CaravanRelic(
      id: 'relic_succulent',
      name: 'Sukulent & Kaktüs Saksısı',
      description: 'Tezgaha huzur verir; müşteriler %20 daha sabırlı bekler.',
      icon: '🪴',
      shopPrice: 110,
      patienceBoost: 0.20,
    ),
    CaravanRelic(
      id: 'relic_radio',
      name: 'Nostaljik Akustik Radyo',
      description: 'Yumuşak caz melodileri çalar; müşteriler %25 daha fazla bahşiş bırakır.',
      icon: '📻',
      shopPrice: 130,
      tipBoost: 0.25,
    ),
    CaravanRelic(
      id: 'relic_sponge',
      name: 'Sihirli Yıkama Süngeri',
      description: 'Bulaşık tezgahındaki kirli fincanları %50 daha hızlı yıkarsınız.',
      icon: '🧽',
      shopPrice: 95,
      washSpeedBoost: 0.50,
    ),
    CaravanRelic(
      id: 'relic_thermos',
      name: 'Termal Kahve Pompası',
      description: 'Kahve akışını hızlandırır; demleme hazırlığı %25 daha çabuk biter.',
      icon: '⚡',
      shopPrice: 140,
      brewSpeedBoost: 0.25,
    ),
    CaravanRelic(
      id: 'relic_beans_sack',
      name: 'Efsanevi Hasat Çuvalı',
      description: 'Her tamamlanan servis gününde kasaya ekstra +25 Altın eklenir.',
      icon: '🌾',
      shopPrice: 120,
      bonusGoldPerDay: 25,
    ),
    CaravanRelic(
      id: 'relic_fairy_lights',
      name: 'Sıcak Peri Işıkları',
      description: 'Akşam saatlerinde karavanı aydınlatır; müşteri sabrını %15 ve bahşişi %15 artırır.',
      icon: '✨',
      shopPrice: 150,
      patienceBoost: 0.15,
      tipBoost: 0.15,
    ),
  ];

  static CaravanRelic? findById(String id) {
    try {
      return allRelics.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

class CaravanRegion {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String icon;
  final Color skyColor;
  final Color groundColor;

  const CaravanRegion({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.skyColor,
    required this.groundColor,
  });

  static const List<CaravanRegion> allRegions = [
    CaravanRegion(
      id: 'valley',
      name: 'Yeşilçam Vadisi',
      subtitle: 'Bölge 1: Huzurlu Köy Yolları & Yaylalar',
      description: 'Kuş sesleri eşliğinde başlayan ilk seferiniz. Kasaba halkı samimi ve sıcak kahveye hasret.',
      icon: '🌲',
      skyColor: Color(0xFF1E3A28),
      groundColor: Color(0xFF2D4B34),
    ),
    CaravanRegion(
      id: 'coast',
      name: 'Sisli Sahil & Deniz Feneri',
      subtitle: 'Bölge 2: Serin Okyanus Esintisi',
      description: 'Martı çığlıkları ve tuzlu deniz kokusu. Soğuk demleme ve buzlu kahvelere yoğun talep var.',
      icon: '🌊',
      skyColor: Color(0xFF1E3345),
      groundColor: Color(0xFF26485E),
    ),
    CaravanRegion(
      id: 'mountain',
      name: 'Güneşli Kahve Tepeleri',
      subtitle: 'Bölge 3: Yüksek Rakım & Gurme Şefler',
      description: 'Bulutların üzerinde serin doruklar. Nitelikli çekirdekler ve usta damaklar sizi bekliyor.',
      icon: '⛰️',
      skyColor: Color(0xFF3E2723),
      groundColor: Color(0xFF4E342E),
    ),
  ];

  static CaravanRegion getById(String id) {
    return allRegions.firstWhere((r) => r.id == id, orElse: () => allRegions.first);
  }
}
