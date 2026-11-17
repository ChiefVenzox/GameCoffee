# 🚐 Coffee Caravan: Kahve Karavanı (Cozy Roguelite Cafe Management)

Steam'deki popüler **Coffee Caravan** tarzında geliştirilmiş; sevimli karavanınızla kasaba kasaba dolaştığınız, prosedürel haritada rotanızı çizdiğiniz, tezgahta kahve demleyip bulaşık yıkadığınız ve festivallere katıldığınız **Flutter tabanlı cozy roguelite kafe yönetim simülasyonu**.

---

## 🎮 Coffee Caravan Tarzı Temel Mekanikler

### 1. 🗺️ Prosedürel Sefer Haritası (Roguelite Expedition Map - Slay the Spire / FTL Tarzı)
- **Dallanan Yol Haritası**: Her seferde rastgele üretilen scenic yol haritasında karavanınızı sürün.
- **Farklı Durak Türleri**:
  - ☕ **Kahve Molası (Serving Day)**: Yol üstü kasaba halkına sakin servis (3-5 müşteri).
  - 🔥 **Yoğun Saat (Rush Hour)**: Sabırsız ve hızlı kalabalık, yüksek tempo, çift bahşiş ve itibar riski!
  - ❓ **Gizemli Yol Hikayeleri (Mystery Events)**: Yolda karşılaşılan otostopçu gezginler, dağ çiftçileri, ani fırtınalar ve seçimlere bağlı ödüller/yadigarlar.
  - 🛒 **Karavan Pazarı & Mola**: Karavan itibarını onarma (💖 kalp yenileme), yeni yadigarlar (relics) ve yeni kahve tarifleri satın alma.
  - 🎁 **Tedarik Sandığı (Treasure Drop)**: Yol kenarında bırakılmış sandıktan 3 güçlü lütuftan birini seçme.
  - 🏆 **Bölge Kahve Festivali (Boss Peak Challenge)**: Michelin jürisi gurme eleştirmenlerin katıldığı büyük final festivali! Kazanıldığında sefer zaferle biter ve yeni bölgelerin kilidi açılır.

### 2. 📋 Günün Karavan Menüsü (Daily Chalkboard Menu)
- Karavan kepenklerini açmadan önce günün menüsünde sunulacak kahveleri seçin (Espresso, Latte, Türk Kahvesi, Cappuccino, V60 Filtre, Buzlu Latte, Mocha vb.).
- Müşteriler sadece karatahtada yazılı kahveleri sipariş eder! Menü çeşitliliği kazancı artırırken servis temposunu zorlaştırır.

### 3. 🚰 Tezgah & Bulaşık Yıkama Döngüsü (The Dishwashing Loop)
- **Temiz Fincan Stoğu**: Karavanınızın fincan kapasitesi sınırlıdır (örn. Kır Karavanında 4 fincan). Kahve hazırlandığında 1 temiz fincan harcanır.
- **Kirli Fincanlar & Lavabo**: Müşteriler kahvelerini içtikten sonra kirli fincan bırakırlar. Temiz fincan bittiğinde kahve demlenemez!
- **Tatmin Edici Bulaşık Yıkama**: Lavaboya dokunarak fincanları yıkayın ve rafa geri dizin (Hızlı yıkama süngeri ile %50 daha hızlı!).

### 4. ❤️ Müşteri Sabrı & İtibar Kalpleri (Reputation Hearts)
- Her müşterinin sipariş balonu üzerinde gerçek zamanlı sabır çubuğu geri sayar.
- Müşteri beklemekten sıkılıp kızgın ayrılırsa karavanınız 1 İtibar Kalbi (❤️) kaybeder.
- 3 kalp de tükenirse karavan yolda kalır (sefer sona erer), ancak kazanılan tecrübe ve altınlar kalıcı garage hesabınıza aktarılır.

### 5. 🚐 Karavan Garajı & Filo Geliştirmeleri (Fleet Upgrades)
- **🚐 Kır Karavanı (Nomad Camper)**: Kompakt 4 fincan kapasiteli başlangıç karavanı.
- **🚚 Retro Kahve Kamyoneti (Vintage Van)**: 5 fincan kapasitesi, +%15 demleme hızı, +%25 bahşiş bonusu.
- **🌟 Gurme Kahve Treyleri (Artisan Trailer)**: 6 fincan kapasitesi, çift kazanlı yüksek basınç, +%35 bahşiş.
- **👑 Kraliyet Barista Karavanı (Grand Cruiser)**: 8 fincan kapasitesi, +%50 demleme hızı, otomatik durulama.

### 6. 🪴 Karavan Yadigarları (Relics & Trinkets)
- **🪴 Sukulent Saksısı**: Müşteri sabrını %20 artırır.
- **📻 Nostaljik Akustik Radyo**: Caz melodileri ile bahşiş gelirini %25 artırır.
- **🧽 Sihirli Yıkama Süngeri**: Bulaşık yıkama hızını 2 katına çıkarır.
- **⚡ Termal Kahve Pompası**: Demleme hazırlığını hızlandırır.
- **🌾 Efsanevi Hasat Çuvalı**: Her servis gününde kasaya ekstra altın kazandırır.
- **✨ Sıcak Peri Işıkları**: Karavan akşam aydınlatması ile hem sabır hem bahşiş bonusu.

### 7. ☕ İnteraktif Barista Demleme Deneyimi
- **Hızlı Demleme**: Servis esnasında tek tıkla otomatik akış.
- **Hassas Barista İstasyonu**: Çekirdek seçimi, ibreli hassas öğütme mini-oyunu (sweet spot), portafiltre sıkıştırma (tamping), közde Türk kahvesi köpürme kontrolü, V60 döküşü ve serbest dokunmatik Latte Art çizim tuvali.

---

## 🛠️ Proje Dizin Yapısı

```
lib/
├── main.dart                          # Uygulama başlangıcı ve tema
├── models/
│   ├── caravan_model.dart             # Karavan modelleri, yadigarlar (relics), bölgeler
│   ├── expedition_model.dart          # Prosedürel harita üretimi, düğümler, sefer durumu
│   ├── mystery_event.dart             # Rastgele yol olayları ve interaktif seçimler
│   ├── coffee_recipe.dart             # Kahve tarifleri, puanlama algoritması, çekirdek/öğütme
│   ├── customer_order.dart            # Müşteri diyalogları ve sabır havuzu
│   ├── game_state.dart                # Kalıcı kayıt, garaj kilidi açma, seviye ve unvan
│   └── shop_item.dart                 # Kalıcı mağaza ekipmanları ve fincanlar
├── screens/
│   ├── home_screen.dart               # Coffee Caravan ana lobi ve sefer başlatma kartı
│   ├── caravan_map_screen.dart        # İnteraktif dallanan yolculuk haritası
│   ├── caravan_shift_screen.dart      # Karavan tezgahı, müşteri kuyruğu ve bulaşık lavabosu
│   ├── daily_menu_dialog.dart         # Günün menüsü karatahta planlayıcısı
│   ├── caravan_garage_screen.dart     # Karavan filosu ve model yükseltmeleri
│   ├── caravan_shop_screen.dart       # Sefer içi mola pazarı (relic & tarifler)
│   ├── mystery_event_screen.dart      # Yol karşılaşmaları hikaye ekranı
│   ├── treasure_screen.dart           # Tedarik sandığı ödül seçimi
│   ├── brewing_station_screen.dart    # 5 adımlı detaylı demleme ve öğütme istasyonu
│   ├── latte_art_screen.dart          # Dokunmatik Latte Art tuvali
│   ├── order_result_screen.dart       # Yıldız değerlendirmesi ve bahşiş dökümü
│   ├── recipe_book_screen.dart        # Kahve ansiklopedisi ve eğitim rehberi
│   └── settings_screen.dart           # Ses, titreşim ve kontrol ayarları
├── utils/
│   ├── app_colors.dart                # Sıcak kahve tonları, pastel yeşil ve karavan paleti
│   └── app_theme.dart                 # Material 3 koyu tema
└── widgets/
    ├── caravan_map_painter.dart       # Prosedürel harita yol çizimi CustomPainter
    ├── coffee_cup_painter.dart        # Dinamik fincan ve krema CustomPainter
    ├── coffee_machine_widget.dart     # Espresso, Türk cezvesi ve V60 widget'ı
    ├── grinder_widget.dart            # İbreli öğütme sweet spot mini-oyunu
    ├── customer_dialogue_widget.dart  # Müşteri avatarı ve sayaç
    ├── sound_service.dart             # Titreşim (haptic) ve ses efektleri
    └── steam_animation.dart           # Yükselen duman ve buhar animasyonu
```

---

## 🚀 Çalıştırma ve Test

```bash
# Bağımlılıkları yükle
flutter pub get

# Kod analizini çalıştır (0 hata / 0 uyarı)
flutter analyze

# Birim ve widget testlerini çalıştır
flutter test
```
