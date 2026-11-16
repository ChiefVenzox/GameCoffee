import 'package:flutter/material.dart';

enum BrewMethod {
  espresso,
  turkish,
  pourOver,
  coldBrew;

  String get displayName {
    switch (this) {
      case BrewMethod.espresso:
        return 'Espresso Makinesi';
      case BrewMethod.turkish:
        return 'Közde Türk Kahvesi';
      case BrewMethod.pourOver:
        return 'V60 Manuel Demleme';
      case BrewMethod.coldBrew:
        return 'Buzlu & Cold Brew';
    }
  }

  String get iconEmoji {
    switch (this) {
      case BrewMethod.espresso:
        return '☕';
      case BrewMethod.turkish:
        return '🫖';
      case BrewMethod.pourOver:
        return '⏳';
      case BrewMethod.coldBrew:
        return '🧊';
    }
  }
}

enum BeanType {
  arabica,
  robusta,
  ethiopia,
  colombia,
  turkishRoast;

  String get displayName {
    switch (this) {
      case BeanType.arabica:
        return 'Arabica (Dengeli & Çiçeksi)';
      case BeanType.robusta:
        return 'Robusta (Sert & Yoğun Gövde)';
      case BeanType.ethiopia:
        return 'Etiyopya Yirgacheffe (Meyvemsi)';
      case BeanType.colombia:
        return 'Kolombiya Supremo (Karamel & Fındık)';
      case BeanType.turkishRoast:
        return 'Geleneksel Türk Kahvesi Çekirdeği';
    }
  }

  Color get color {
    switch (this) {
      case BeanType.arabica:
        return const Color(0xFF5A3825);
      case BeanType.robusta:
        return const Color(0xFF381F12);
      case BeanType.ethiopia:
        return const Color(0xFF6B4423);
      case BeanType.colombia:
        return const Color(0xFF4E2E1B);
      case BeanType.turkishRoast:
        return const Color(0xFF2C160B);
    }
  }
}

enum GrindLevel {
  extraFine, // Türk Kahvesi
  fine,      // Espresso
  medium,    // V60 / Filtre
  coarse;    // Cold Brew / French Press

  String get displayName {
    switch (this) {
      case GrindLevel.extraFine:
        return 'Çok İnce (Pudra - Türk Kahvesi)';
      case GrindLevel.fine:
        return 'İnce (Espresso)';
      case GrindLevel.medium:
        return 'Orta (V60 Filtre)';
      case GrindLevel.coarse:
        return 'Kalın (Cold Brew)';
    }
  }
}

enum MilkType {
  none,
  whole,
  oat,
  almond,
  soy;

  String get displayName {
    switch (this) {
      case MilkType.none:
        return 'Sütsüz / Sade';
      case MilkType.whole:
        return 'Tam Yağlı İnek Sütü';
      case MilkType.oat:
        return 'Yulaf Sütü (Barista Oat)';
      case MilkType.almond:
        return 'Badem Sütü';
      case MilkType.soy:
        return 'Soya Sütü';
    }
  }
}

enum FoamLevel {
  none,
  light,
  medium,
  dense;

  String get displayName {
    switch (this) {
      case FoamLevel.none:
        return 'Köpüksüz';
      case FoamLevel.light:
        return 'Az Köpük (Flat White)';
      case FoamLevel.medium:
        return 'İpeksi Mikro Köpük (Latte)';
      case FoamLevel.dense:
        return 'Yoğun Kadife Köpük (Cappuccino)';
    }
  }
}

enum SyrupType {
  none,
  vanilla,
  caramel,
  hazelnut,
  chocolate,
  strawberry;

  String get displayName {
    switch (this) {
      case SyrupType.none:
        return 'Şurupsuz';
      case SyrupType.vanilla:
        return 'Vanilya Şurubu';
      case SyrupType.caramel:
        return 'Tuzlu Karamel';
      case SyrupType.hazelnut:
        return 'Kavrulmuş Fındık';
      case SyrupType.chocolate:
        return 'Belçika Çikolatası';
      case SyrupType.strawberry:
        return 'Çilek Püresi';
    }
  }

  Color get color {
    switch (this) {
      case SyrupType.none:
        return Colors.transparent;
      case SyrupType.vanilla:
        return const Color(0xFFF3E5AB);
      case SyrupType.caramel:
        return const Color(0xFFD97706);
      case SyrupType.hazelnut:
        return const Color(0xFF8B5A2B);
      case SyrupType.chocolate:
        return const Color(0xFF3E2723);
      case SyrupType.strawberry:
        return const Color(0xFFE11D48);
    }
  }
}

enum ToppingType {
  none,
  cinnamon,
  cocoa,
  chocolateDrizzle,
  whippedCream,
  marshmallows;

  String get displayName {
    switch (this) {
      case ToppingType.none:
        return 'Süslemesiz';
      case ToppingType.cinnamon:
        return 'Seylan Tarçını';
      case ToppingType.cocoa:
        return 'Kakao Tozu';
      case ToppingType.chocolateDrizzle:
        return 'Çikolata Sosu';
      case ToppingType.whippedCream:
        return 'Krem Şanti (Whipped Cream)';
      case ToppingType.marshmallows:
        return 'Mini Renkli Marshmallow';
    }
  }
}

enum CupType {
  espressoCup,
  turkishCup,
  latteGlass,
  takeawayCup,
  icedTallGlass;

  String get displayName {
    switch (this) {
      case CupType.espressoCup:
        return 'Mini Espresso Fincanı';
      case CupType.turkishCup:
        return 'Klasik Türk Kahvesi Fincanı';
      case CupType.latteGlass:
        return 'Geniş Seramik Latte Kupası';
      case CupType.takeawayCup:
        return 'Karton Takeaway Bardak';
      case CupType.icedTallGlass:
        return 'Buzlu Uzun Cam Bardak';
    }
  }
}

class CoffeeRecipe {
  final String id;
  final String name;
  final String turkishName;
  final String description;
  final BrewMethod brewMethod;
  final BeanType defaultBean;
  final GrindLevel idealGrind;
  final MilkType idealMilk;
  final FoamLevel idealFoam;
  final SyrupType idealSyrup;
  final ToppingType idealTopping;
  final CupType cupType;
  final int basePrice;
  final String emoji;
  final bool isCold;

  const CoffeeRecipe({
    required this.id,
    required this.name,
    required this.turkishName,
    required this.description,
    required this.brewMethod,
    required this.defaultBean,
    required this.idealGrind,
    this.idealMilk = MilkType.none,
    this.idealFoam = FoamLevel.none,
    this.idealSyrup = SyrupType.none,
    this.idealTopping = ToppingType.none,
    required this.cupType,
    required this.basePrice,
    required this.emoji,
    this.isCold = false,
  });

  /// Evaluates user brew attempt against this recipe
  BrewScore evaluate({
    required BeanType selectedBean,
    required GrindLevel selectedGrind,
    required double extractionAccuracy, // 0.0 to 1.0 (closeness to target)
    required MilkType selectedMilk,
    required FoamLevel selectedFoam,
    required SyrupType selectedSyrup,
    required ToppingType selectedTopping,
    required CupType selectedCup,
  }) {
    int score = 0;
    final List<String> feedback = [];

    // 1. Bean check (15 pts)
    if (selectedBean == defaultBean) {
      score += 15;
    } else {
      score += 8;
      feedback.add('Çekirdek seçimi farklıydı ama fena olmadı.');
    }

    // 2. Grind level check (20 pts)
    if (selectedGrind == idealGrind) {
      score += 20;
    } else {
      score += 5;
      feedback.add('Öğütme derecesi ideale tam uymadı.');
    }

    // 3. Extraction / Brewing accuracy (25 pts)
    int extPts = (extractionAccuracy * 25).round();
    score += extPts;
    if (extractionAccuracy >= 0.85) {
      feedback.add('Demleme ve kıvam harika bir dengedeydi!');
    } else if (extractionAccuracy >= 0.6) {
      feedback.add('Demleme süresi fena değildi.');
    } else {
      feedback.add('Demleme süresi / sıcaklığı kaçırıldı.');
    }

    // 4. Milk & Foam (20 pts)
    if (idealMilk == MilkType.none) {
      if (selectedMilk == MilkType.none) {
        score += 20;
      } else {
        feedback.add('Müşteri sade istemişti, süt eklendi.');
      }
    } else {
      if (selectedMilk == idealMilk) {
        score += 10;
      } else if (selectedMilk != MilkType.none) {
        score += 6;
        feedback.add('Farklı bir süt türü kullanıldı.');
      }
      if (selectedFoam == idealFoam) {
        score += 10;
      } else {
        score += 4;
        feedback.add('Köpük yoğunluğu biraz farklıydı.');
      }
    }

    // 5. Syrup & Toppings (10 pts)
    if (selectedSyrup == idealSyrup) {
      score += 5;
    } else if (idealSyrup != SyrupType.none) {
      feedback.add('İstenen şurup eksik veya yanlıştı.');
    }

    if (selectedTopping == idealTopping) {
      score += 5;
    }

    // 6. Cup choice (10 pts)
    if (selectedCup == cupType) {
      score += 10;
    } else {
      score += 4;
      feedback.add('Fincan sunumu farklı bir boyuttaydı.');
    }

    score = score.clamp(0, 100);

    int stars;
    if (score >= 90) {
      stars = 5;
    } else if (score >= 75) {
      stars = 4;
    } else if (score >= 60) {
      stars = 3;
    } else if (score >= 40) {
      stars = 2;
    } else {
      stars = 1;
    }

    return BrewScore(
      totalScore: score,
      stars: stars,
      feedback: feedback.isEmpty ? ['Kusursuz bir fincan kahve!'] : feedback,
    );
  }

  static const List<CoffeeRecipe> allRecipes = [
    // 1. Türk Kahvesi
    CoffeeRecipe(
      id: 'turkish_coffee',
      name: 'Turkish Coffee',
      turkishName: 'Közde Türk Kahvesi',
      description: 'Pudra inceliğinde çekilmiş çekirdeklerin bakır cezvede köpürene kadar pişirilmesiyle yapılan kadim lezzet.',
      brewMethod: BrewMethod.turkish,
      defaultBean: BeanType.turkishRoast,
      idealGrind: GrindLevel.extraFine,
      cupType: CupType.turkishCup,
      basePrice: 35,
      emoji: '🫖',
    ),

    // 2. Espresso
    CoffeeRecipe(
      id: 'espresso',
      name: 'Espresso',
      turkishName: 'Single Shot Espresso',
      description: '9 bar yüksek basınç altında 25-30 saniyede ekstrakte edilen altın renkli kremalı yoğun kahve.',
      brewMethod: BrewMethod.espresso,
      defaultBean: BeanType.arabica,
      idealGrind: GrindLevel.fine,
      cupType: CupType.espressoCup,
      basePrice: 30,
      emoji: '☕',
    ),

    // 3. Caffe Latte
    CoffeeRecipe(
      id: 'latte',
      name: 'Caffè Latte',
      turkishName: 'Klasik Latte',
      description: 'Taze espresso üzerine ipeksi kadife mikro köpüklü buharda ısıtılmış süt.',
      brewMethod: BrewMethod.espresso,
      defaultBean: BeanType.arabica,
      idealGrind: GrindLevel.fine,
      idealMilk: MilkType.whole,
      idealFoam: FoamLevel.medium,
      cupType: CupType.latteGlass,
      basePrice: 50,
      emoji: '🥛',
    ),

    // 4. Cappuccino
    CoffeeRecipe(
      id: 'cappuccino',
      name: 'Cappuccino',
      turkishName: 'İtalyan Cappuccino',
      description: 'Eşit oranda espresso, sıcak süt ve yoğun bulutsu süt köpüğünün üzerine kakao serpiştirilmiş hali.',
      brewMethod: BrewMethod.espresso,
      defaultBean: BeanType.colombia,
      idealGrind: GrindLevel.fine,
      idealMilk: MilkType.whole,
      idealFoam: FoamLevel.dense,
      idealTopping: ToppingType.cocoa,
      cupType: CupType.latteGlass,
      basePrice: 55,
      emoji: '☕',
    ),

    // 5. Caramel Macchiato
    CoffeeRecipe(
      id: 'caramel_macchiato',
      name: 'Caramel Macchiato',
      turkishName: 'Karamel Macchiato',
      description: 'Vanilya şurubu ile tatlandırılmış sıcak sütün üzerine dökülen espresso ve altın karamel sosu.',
      brewMethod: BrewMethod.espresso,
      defaultBean: BeanType.colombia,
      idealGrind: GrindLevel.fine,
      idealMilk: MilkType.whole,
      idealFoam: FoamLevel.medium,
      idealSyrup: SyrupType.vanilla,
      idealTopping: ToppingType.chocolateDrizzle,
      cupType: CupType.takeawayCup,
      basePrice: 65,
      emoji: '🍯',
    ),

    // 6. V60 Pour-over
    CoffeeRecipe(
      id: 'v60_filter',
      name: 'V60 Pour Over',
      turkishName: 'V60 Nitelikli Filtre Kahve',
      description: 'Etiyopya çekirdeklerinin spiral su döküşü ile damla damla süzülerek aromatik notalarının açığa çıkarılması.',
      brewMethod: BrewMethod.pourOver,
      defaultBean: BeanType.ethiopia,
      idealGrind: GrindLevel.medium,
      cupType: CupType.latteGlass,
      basePrice: 60,
      emoji: '⏳',
    ),

    // 7. Iced Vanilla Latte
    CoffeeRecipe(
      id: 'iced_vanilla_latte',
      name: 'Iced Vanilla Latte',
      turkishName: 'Buzlu Vanilyalı Latte',
      description: 'Buz küpleri, soğuk süt, Madagascar vanilya şurubu ve üstten süzülen taze çift espresso.',
      brewMethod: BrewMethod.coldBrew,
      defaultBean: BeanType.arabica,
      idealGrind: GrindLevel.fine,
      idealMilk: MilkType.oat,
      idealFoam: FoamLevel.light,
      idealSyrup: SyrupType.vanilla,
      cupType: CupType.icedTallGlass,
      basePrice: 60,
      emoji: '🧊',
      isCold: true,
    ),

    // 8. Caffe Mocha
    CoffeeRecipe(
      id: 'caffe_mocha',
      name: 'Caffè Mocha',
      turkishName: 'Çikolatalı Mocha',
      description: 'Zengin espresso, Belçika çikolatası, buharda ısıtılmış süt ve üzerinde lezzetli krema şanti.',
      brewMethod: BrewMethod.espresso,
      defaultBean: BeanType.robusta,
      idealGrind: GrindLevel.fine,
      idealMilk: MilkType.whole,
      idealFoam: FoamLevel.light,
      idealSyrup: SyrupType.chocolate,
      idealTopping: ToppingType.whippedCream,
      cupType: CupType.takeawayCup,
      basePrice: 70,
      emoji: '🍫',
    ),
  ];
}

class BrewScore {
  final int totalScore; // 0-100
  final int stars;      // 1-5
  final List<String> feedback;

  const BrewScore({
    required this.totalScore,
    required this.stars,
    required this.feedback,
  });
}
