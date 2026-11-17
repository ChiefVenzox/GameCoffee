import 'dart:math';

class MysteryChoice {
  final String label;
  final String description;
  final int coinCost;
  final int coinReward;
  final int xpReward;
  final int heartDelta; // +1 or -1
  final String? grantRelicId;
  final String outcomeText;

  const MysteryChoice({
    required this.label,
    required this.description,
    this.coinCost = 0,
    this.coinReward = 0,
    this.xpReward = 0,
    this.heartDelta = 0,
    this.grantRelicId,
    required this.outcomeText,
  });
}

class MysteryEvent {
  final String id;
  final String title;
  final String subtitle;
  final String narrative;
  final String avatar;
  final List<MysteryChoice> choices;

  const MysteryEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.narrative,
    required this.avatar,
    required this.choices,
  });

  static final List<MysteryEvent> allEvents = [
    MysteryEvent(
      id: 'traveler_hitchhiker',
      title: 'Yol Kenarında Yorgun Bir Gezgin',
      subtitle: 'Tozlu Patika Kavşağı',
      narrative: 'Sırt çantalı yaşlı bir gezgin karavanınızın önünde durup el sallıyor: "Saatlerdir yürüyorum evlat. Karavanından gelen o taze kahve kokusu bana hayat verdi. Bir yudum sıcak kahven var mıdır?"',
      avatar: '🧳',
      choices: [
        MysteryChoice(
          label: 'Sıcak Özel Kahve İkram Et',
          description: 'Biraz kahve stoğu harca (15 Altın değerinde).',
          coinCost: 15,
          xpReward: 60,
          grantRelicId: 'relic_succulent',
          outcomeText: 'Gezgin gözleri parlayarak kahvesini yudumladı: "Bu hayatımda içtiğim en samimi kahveydi evlat! Yol boyunca yanımda taşıdığım bu şanslı sukulenti karavanına hediye ediyorum."',
        ),
        MysteryChoice(
          label: 'Samimi Bir Sohbet Et ve Yol Tarifi Ver',
          description: 'Sıcak bir çay ikram et ve deneyim kazan.',
          xpReward: 40,
          outcomeText: 'Gezgin yol anılarını ve eski dağ baristalarının hikayelerini paylaştı. Yeni teknikler öğrendiniz!',
        ),
        MysteryChoice(
          label: 'Vaktim Yok, Aceleyle Yola Devam Et',
          description: 'Hiçbir şey harcamadan yola devam et.',
          outcomeText: 'Gezgine kibarca selam verip gaza bastınız ve bir sonraki durağa doğru ilerlediniz.',
        ),
      ],
    ),

    MysteryEvent(
      id: 'mountain_farmer',
      title: 'Yaylalı Kahve Çiftçisi',
      subtitle: 'Verimli Yamaç Terasları',
      narrative: 'Yol kenarındaki ahşap kulübesinde taze kavrulmuş çekirdek torbalarını düzenleyen neşeli bir çiftçiyle karşılaştınız: "Bu senenin ilk mahsulü! Şehir tüccarları gelmeden önce karavanına toptan fiyata bırakabilirim."',
      avatar: '👨‍🌾',
      choices: [
        MysteryChoice(
          label: 'Özel Hasat Çuvalını Satın Al (50 Altın)',
          description: '50 Altın ödeyerek efsanevi hasat relic\'ini kazan.',
          coinCost: 50,
          grantRelicId: 'relic_beans_sack',
          outcomeText: 'Çiftçi çuvalı karavanınızın bagajına yükledi: "Bereketini gör evlat! Bu çekirdeklerin aroması her durakta sana bol kazanç getirecek!"',
        ),
        MysteryChoice(
          label: 'Tadım Yapıp Küçük Bir İpucu İste',
          description: 'Ücretsiz tadım yap ve tecrübe edin.',
          xpReward: 50,
          outcomeText: 'Çiftçi çekirdeklerin doğru kavurma derecelerini gösterdi. Barista bilginiz arttı!',
        ),
      ],
    ),

    MysteryEvent(
      id: 'sudden_rainstorm',
      title: 'Dağda Ani Yağmur Fırtınası',
      subtitle: 'Gök Gürültüsü ve Sis',
      narrative: 'Gökyüzü aniden karardı ve sağanak yağmur karavanın tentesini dövmeye başladı. Yolda mahsur kalan birkaç köylü karavanınızın tentesi altına sığındı.',
      avatar: '🌧️',
      choices: [
        MysteryChoice(
          label: 'Herkese Buharda Isıtılmış Sütlü Kahve Dağıt',
          description: 'Gönülleri fethet ve karavan itibarını tazele (+1 Kalp).',
          coinCost: 25,
          heartDelta: 1,
          outcomeText: 'Köylüler sıcacık bardaklarla ısındı ve minnet dolu dualarla karavanınızın itibarını zirveye taşıdı! (+1 İtibar Kalbi)',
        ),
        MysteryChoice(
          label: 'Tente Altında Kahve Satışı Yap',
          description: 'Fırsatı değerlendirip sıcak kahveleri parayla sat (+60 Altın).',
          coinReward: 60,
          outcomeText: 'Yağmurda mahsur kalanlar kapış kapış kahve aldı! Kasanıza güzel bir gelir eklendi.',
        ),
      ],
    ),

    MysteryEvent(
      id: 'street_musician',
      title: 'Seyyar Sokak Akordeoncusu',
      subtitle: 'Kasaba Meydanı Çıkışı',
      narrative: 'Kaldırımda eski bir akordeon çalan müzisyen karavanınıza bakıp gülümsedi: "Müziğin ritmi ile kahvenin buharı birbirine çok yakışıyor usta!"',
      avatar: '🪗',
      choices: [
        MysteryChoice(
          label: 'Müzisyene Bahşiş Ver ve Karavan Önünde Çalmasını İste (30 Altın)',
          description: 'Nostaljik radyo relic\'ini kazan.',
          coinCost: 30,
          grantRelicId: 'relic_radio',
          outcomeText: 'Müzisyen neşeyle çaldı ve giderken sana eski bir nostaljik ahşap radyo bıraktı! Artık müşteriler daha çok bahşiş veriyor.',
        ),
        MysteryChoice(
          label: 'Birlikte Bir Parça Çal / Dinle',
          description: 'Huzur dolu bir mola ver (+1 Kalp).',
          heartDelta: 1,
          outcomeText: 'Akordeonun huzurlu melodileri karavanın yorgunluğunu unutturdu. Enerjiniz ve itibarınız tazelendi!',
        ),
      ],
    ),
  ];

  static MysteryEvent getRandom() {
    final rand = Random();
    return allEvents[rand.nextInt(allEvents.length)];
  }
}
