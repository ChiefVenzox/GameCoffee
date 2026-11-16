enum ShopCategory {
  beans,
  equipment,
  cups,
  syrups,
  themes,
}

class ShopItem {
  final String id;
  final String name;
  final ShopCategory category;
  final int price;
  final String description;
  final String icon;
  final String bonusEffect;
  bool isUnlocked;

  ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.icon,
    required this.bonusEffect,
    this.isUnlocked = false,
  });

  static List<ShopItem> get defaultItems => [
    // Çekirdekler
    ShopItem(
      id: 'bean_arabica',
      name: 'Klasik Arabica',
      category: ShopCategory.beans,
      price: 0,
      description: 'Dengeli gövde ve yumuşak içim.',
      icon: '🫘',
      bonusEffect: 'Temel Çekirdek',
      isUnlocked: true,
    ),
    ShopItem(
      id: 'bean_ethiopia',
      name: 'Etiyopya Yirgacheffe',
      category: ShopCategory.beans,
      price: 150,
      description: 'Çiçeksi ve bergamot notalı yüksek rakım çekirdekleri.',
      icon: '✨',
      bonusEffect: '+%15 Bahşiş Bonusu',
    ),
    ShopItem(
      id: 'bean_colombia',
      name: 'Kolombiya Geisha Supremo',
      category: ShopCategory.beans,
      price: 250,
      description: 'Karamel, fındık ve narenciye tat profili.',
      icon: '🏆',
      bonusEffect: '+%20 Müşteri Memnuniyeti',
    ),
    ShopItem(
      id: 'bean_turkish',
      name: 'Özel Türk Dağ Harmanı',
      category: ShopCategory.beans,
      price: 100,
      description: 'Geleneksel közde pişirme için mükemmel kavrulmuş.',
      icon: '⛰️',
      bonusEffect: 'Geleneksel siparişlerde +25 Puan',
      isUnlocked: true,
    ),

    // Ekipmanlar
    ShopItem(
      id: 'eq_grinder_pro',
      name: 'Konik Çelik Dişli Değirmen',
      category: ShopCategory.equipment,
      price: 200,
      description: 'Daha hassas ve homojen öğütme sağlar.',
      icon: '⚙️',
      bonusEffect: 'Öğütme Sweet-Spot alanı %25 daha geniş!',
    ),
    ShopItem(
      id: 'eq_copper_cezve',
      name: 'El İşçiliği Bakır Osmanlı Cezvesi',
      category: ShopCategory.equipment,
      price: 180,
      description: 'Eşit ısı dağılımı ve ekstra yoğun köpük üretir.',
      icon: '🫖',
      bonusEffect: 'Türk Kahvesi köpürme kontrolünü kolaylaştırır.',
    ),
    ShopItem(
      id: 'eq_pro_espresso',
      name: 'İtalyan Çift Kazanlı Espresso Makinesi',
      category: ShopCategory.equipment,
      price: 350,
      description: 'Mükemmel 9-bar basınç ve anında kuru buhar.',
      icon: '☕',
      bonusEffect: 'Ekstraksiyon süresini stabilize eder.',
    ),

    // Fincanlar
    ShopItem(
      id: 'cup_ceramic',
      name: 'El Yapımı Seramik Kupa',
      category: ShopCategory.cups,
      price: 80,
      description: 'Sıcaklığı uzun süre tutan şık tasarım.',
      icon: '🍶',
      bonusEffect: 'Görsel sunum bonusu',
      isUnlocked: true,
    ),
    ShopItem(
      id: 'cup_double_wall',
      name: 'Çift Cam Yalıtımlı Bardak',
      category: ShopCategory.cups,
      price: 120,
      description: 'Kahvenin katmanlarını gösteren estetik bardak.',
      icon: '🥛',
      bonusEffect: '+10 Prestij Puanı',
    ),
    ShopItem(
      id: 'cup_gold_rim',
      name: 'Altın Varaklı Saray Fincanı',
      category: ShopCategory.cups,
      price: 220,
      description: 'Türk kahvesi sunumunu saray seviyesine taşır.',
      icon: '👑',
      bonusEffect: 'Türk kahvesi bahşişlerini ikiye katlar.',
    ),

    // Şuruplar
    ShopItem(
      id: 'syr_vanilla',
      name: 'Madagaskar Vanilya',
      category: ShopCategory.syrups,
      price: 60,
      description: 'Doğal vanilya çubuklarından elde edilmiş saf aroma.',
      icon: '🌼',
      bonusEffect: 'Latte & Macchiato çeşitleri için.',
      isUnlocked: true,
    ),
    ShopItem(
      id: 'syr_caramel',
      name: 'Tuzlu Karamel Sosu',
      category: ShopCategory.syrups,
      price: 90,
      description: 'Yoğun, tatlı-tuzlu dengeli gurme karamel.',
      icon: '🍯',
      bonusEffect: 'Tatlı kahvelerde müşteri sevgisi kazandırır.',
      isUnlocked: true,
    ),
    ShopItem(
      id: 'syr_strawberry',
      name: 'Taze Çilek & Meyve Püresi',
      category: ShopCategory.syrups,
      price: 130,
      description: 'Soğuk içecekler ve yaz menüsü için özel meyve püresi.',
      icon: '🍓',
      bonusEffect: 'Buzlu içecek puanını artırır.',
    ),
  ];
}
