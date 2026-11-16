# ☕ Barista Master: Kahve Dükkanı (Coffee Making Game)

Flutter ile sıfırdan geliştirilmiş, **hem Android hem iOS** platformlarında tam uyumlu, akıcı 60/120 FPS performanslı interaktif kahve hazırlama ve kafe simülasyon oyunu.

---

## 📱 Platform Uyumluluğu

| Platform | Desteklenen Sürüm | Yapılandırma Durumu |
| :--- | :--- | :--- |
| **Android** | Android 5.0+ (API 21 - API 35+) | `android/app/build.gradle.kts`, `AndroidManifest.xml` hazır |
| **iOS** | iOS 12.0+ (iPhone, iPad) | `ios/Runner.xcodeproj`, `Info.plist`, SafeArea/Notch hazır |
| **Web & Masaüstü** | Chrome, Safari, Edge, Linux, macOS | Hazır & Test Edildi |

---

## 🎮 Oyun Modları ve Mekanikleri

### 1. 🛎️ Müşteri & Kariyer Modu (Customer Career Mode)
- **Karakterler ve Özel İstekler**: Farklı kişiliklerde müşteriler gelir (Kod yazmaktan yorgun düşmüş yazılımcı Deniz, nostaljik mahalle sakini Mehmet Bey, kütüphaneye giden öğrenci Ayşe, Instagram için estetik arayan Zeynep vb.).
- **Sabır Zamanlayıcısı (Patience Bar)**: Müşterinin sabrı tükenmeden siparişi doğru şekilde hazırlamak gerekir.
- **5 Yıldızlı Değerlendirme & Bahşiş**: Çekirdek seçimi, öğütme hassasiyeti, demleme süresi, süt/köpük oranı ve sunum doğruluğuna göre puan ve bahşiş kazanılır.

### 2. 🎨 Serbest Barista & Yaratıcı Mod (Free Creative Brew)
- Süre kısıtlaması olmadan tüm tarifleri serbestçe deneyebilir, yeni karışımlar oluşturabilir ve latte art sanatınızı sergileyebilirsiniz.

### 3. ☕ İnteraktif Kahve Hazırlama Aşamaları
1. **Çekirdek Seçimi**: Klasik Arabica, Sert Robusta, Nitelikli Etiyopya Yirgacheffe, Kolombiya Geisha Supremo veya Özel Türk Dağ Harmanı.
2. **Hassas Öğütme Mini-Oyunu (Grinder Sweet Spot)**: Değirmeni basılı tutarak çalıştırın; ibreyi tam hedeflenen yeşil "Sweet Spot" alanında bırakarak mükemmel öğütme kıvamını yakalayın.
3. **Farklı Demleme İstasyonları**:
   - **Espresso Makinesi**: Portafiltre sıkıştırma (tamping), 9-Bar basınç ve altın crema ekstraksiyonu.
   - **Közde Bakır Cezve**: Geleneksel Türk kahvesini közde pişirme, köpük tam taşmadan önce ateşten alma mekaniği!
   - **V60 Manuel Demleme**: Spiral su döküşü ve blooming süzülme kontrolü.
   - **Buzlu & Cold Brew**: Buz küpleri ve katmanlı soğuk sunum.
4. **Süt Köpürtme & Şuruplar**: Tam yağlı, yulaf, badem, soya sütü; vanilya, tuzlu karamel, çikolata ve çilek şurupları.
5. **Latte Art Çizim Stüdyosu**: Parmağınızla fincan üzerindeki kremaya süt köpüğü ile serbest çizim yapabilir veya Kalp (Heart), Lale (Tulip), Rosetta (Fern) şablonlarını uygulayabilirsiniz!
6. **Süslemeler (Toppings)**: Seylan tarçını, Belçika kakao tozu, çikolata sosu zikzağı, krem şanti ve mini renkli marshmallowlar.

### 4. 🛍️ Barista Mağazası (Shop & Upgrades)
- Kazanılan paralarla daha profesyonel çift kazanlı espresso makineleri, el işçiliği bakır cezveler, konik çelik dişli değirmenler, saray fincanları ve egzotik çekirdeklerin kilidini açın.

### 5. 📖 Tarif Rehberi (Barista Academy)
- Gerçek hayatta Espresso, Türk Kahvesi, Latte, Cappuccino, Caramel Macchiato, Mocha, V60 ve Buzlu Latte'nin nasıl hazırlandığını gösteren eğitim defteri.

---

## 🛠️ Proje Dizin Yapısı

```
lib/
├── main.dart                          # Uygulama başlangıcı, tema ve sistem çubuğu
├── models/
│   ├── coffee_recipe.dart             # Kahve tarifleri, puanlama algoritması, çekirdek/öğütme modelleri
│   ├── customer_order.dart            # Müşteri diyalogları, sabır barı ve sipariş havuzu
│   ├── game_state.dart                # Para, XP, seviye, unvan ve kalıcı kayıt (SharedPreferences)
│   └── shop_item.dart                 # Mağaza ekipmanları, fincanlar ve geliştirmeler
├── screens/
│   ├── home_screen.dart               # Ana kafe lobisi, kariyer & serbest mod kartları
│   ├── brewing_station_screen.dart    # 5 adımlı interaktif kahve hazırlama istasyonu
│   ├── latte_art_screen.dart          # Dokunmatik Latte Art çizim tuvali
│   ├── order_result_screen.dart       # Yıldız değerlendirmesi, müşteri tepkisi ve gelir ekranı
│   ├── shop_screen.dart               # Ekipman ve çekirdek geliştirme mağazası
│   ├── recipe_book_screen.dart        # Kahve ansiklopedisi ve doğrudan demleme
│   └── settings_screen.dart           # Ses, titreşim (haptics) ve platform ayarları
├── utils/
│   ├── app_colors.dart                # Kahve tonları, kremalar, bakır cezve gradyanları
│   └── app_theme.dart                 # Material 3 koyu tema yapılandırması
└── widgets/
    ├── coffee_cup_painter.dart        # Dinamik fincan, sıvı dolumu, dalga ve köpük CustomPainter
    ├── coffee_machine_widget.dart     # Espresso, Türk cezvesi, V60 ve Buz istasyonu widget'ı
    ├── grinder_widget.dart            # İbreli öğütme mini-oyunu ve sweet spot tespiti
    ├── customer_dialogue_widget.dart  # Müşteri avatarı, konuşma balonu ve sayaç
    ├── sound_service.dart             # Mobil titreşim (haptics) ve ses efektleri
    └── steam_animation.dart           # Fincan üzerinden yükselen dalgalı duman animasyonu
```

---

## 🚀 Çalıştırma ve Derleme

### 1. Bağımlılıkları Yükleme
```bash
flutter pub get
```

### 2. Android İçin Çalıştırma / Derleme
- **Android Emülatör veya Cihazda Çalıştırma:**
  ```bash
  flutter run -d android
  ```
- **Android APK Üretme (Yükleme Paketi):**
  ```bash
  flutter build apk --release
  ```
- **Google Play Store Paketi (AAB):**
  ```bash
  flutter build appbundle --release
  ```

### 3. iOS İçin Çalıştırma / Derleme (macOS)
- **iOS Simülatöründe Çalıştırma:**
  ```bash
  open -a Simulator
  flutter run -d ios
  ```
- **App Store / TestFlight İçin IPA Üretme:**
  ```bash
  flutter build ipa --release
  ```

### 4. Testleri Çalıştırma
```bash
flutter test
```
