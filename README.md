# 🚐 Coffee Caravan: 3D Mobil Kafe & Roguelite Macerası

Steam'deki popüler **Coffee Caravan** (Broccoli Games) oyununun 3D izometrik görsel tarzı ve roguelite mekanikleriyle Flutter & Dart üzerinde sıfırdan geliştirilmiş **3D Cozy Kafe Yönetim Simülasyonu**.

---

## 🎮 3D Coffee Caravan Özellikleri ve Mekanikleri

### 1. 🧊 Dahili 3D Oyun Motoru (`lib/engine3d/`)
- Harici hantal C++ veya platforma özel kütüphane bağımlılığı olmadan, **saf Dart ve `vector_math`** ile geliştirilmiş akıcı 60/120 FPS 3D grafik motoru.
- **3D Kamera & Işıklandırma**: Yönlü güneş ışığı (Lambertian diffuse + ambient shading), derinlik sıralaması (Painter's algorithm) ve dinamik izometrik/perspektif kamera kontrolü.
- **Düşük Poligon (Low-Poly) 3D Modeller**:
  - 3D Karavan (hareketli tekerlekler, tentesi, bacası ve servis penceresiyle),
  - 3D Yürüyen Barista (adımlama animasyonu, aşçı şapkası, önlüğü ve fincan taşıma mekaniği),
  - 3D Müşteriler (oturan ve sipariş bekleyen 3D karakterler),
  - 3D Mutfak Ekipmanları (Espresso makinesi, kahve değirmeni, akan sulu lavabo, bistrolar ve sandalyeler).

### 2. ☕ 3D Karavan Mutfak & Kafe Simülasyonu (`lib/screens3d/caravan_3d_kitchen_screen.dart`)
- **İzometrik 3D Kontrol**: Sol alttaki sanal analog joystick ile 3D baristanızı karavan içinde ve dışındaki bistro masalarında serbestçe gezdirin.
- **Etkileşimli Tezgah Döngüsü (PlateUp / Overcooked Tarzı)**:
  1. ⚙️ **3D Değirmen**: Yanına gidip taze çekirdek öğütün.
  2. ☕ **3D Espresso Makinesi**: Fincan stoğunuzu kullanarak sıcak kahveyi demleyin.
  3. 🛎️ **3D Müşteri Servisi**: İçeceği masadaki müşteriye teslim edin; müşteri kahveyi içip para ve bahşiş bırakır.
  4. 🚰 **Kirli Bulaşık ve 3D Lavabo**: Boşalan kirli fincanı masadan alın, lavaboya götürün; su akışı animasyonuyla bulaşıkları yıkayıp temiz fincan rafını doldurun!

### 3. 🗺️ 3D Prosedürel Sefer Haritası (`lib/screens3d/caravan_3d_map_screen.dart`)
- 3D tepe ve çam ağaçlarının arasından kıvrılan yol ağı.
- Yol üzerindeki 3D sütun duraklara göre hareket eden ve tepeye (Festival Meydanı'na) doğru tırmanan 3D karavan.
- Dokunarak kamerayı 3D sahnede çevirme ve zumlama.

### 4. 🚐 3D Karavan Garajı & 360° Showroom (`lib/screens3d/caravan_3d_garage_screen.dart`)
- Karavanınızı döner ahşap platform üzerinde **360 derece parmağınızla döndürerek** inceleyin.
- 4 Farklı Karavan Modeli:
  - **🚐 Kır Karavanı (Nomad Camper)**
  - **🚚 Retro Kahve Kamyoneti (Vintage Van)**
  - **🌟 Gurme Kahve Treyleri (Artisan Trailer)**
  - **👑 Kraliyet Barista Karavanı (Grand Cruiser)**

### 5. 📋 Günün Menüsü, Yadigarlar ve İtibar Kalpleri
- 3 İtibar Kalbi (❤️❤️❤️): Sabırsız müşteri ayrıldığında kalp eksilir.
- Karatahta üzerinden aktif menüyü belirleme.
- Yadigarlar (Relics): Sukulent (+%20 sabır), Ahşap Radyo (+%25 bahşiş), Sihirli Sünger (%50 hızlı bulaşık yıkama).

---

## 🛠️ Proje Dizin Yapısı

```
lib/
├── engine3d/                          # Dahili 3D Oyun Motoru
│   ├── camera3d.dart                  # İzometrik & perspektif kamera, yörünge kontrolü
│   ├── mesh3d.dart                    # 3D tepe noktaları, poligon yüzeyler ve küp/silindir üreticileri
│   ├── models3d.dart                  # Karavan, yürüyen barista, müşteri, espresso makinesi, lavabo
│   └── renderer3d.dart                # Derinlik sıralaması (Z-sort), güneş ışıklandırması ve izdüşüm
├── screens3d/                         # 3D Oyun Ekranları
│   ├── caravan_3d_kitchen_screen.dart # İzometrik mutfak tezgahı, joystick ve bulaşık yıkama
│   ├── caravan_3d_map_screen.dart     # 3D arazide kıvrılan yol haritası ve karavan sürüşü
│   └── caravan_3d_garage_screen.dart  # 360° döner platformlu 3D karavan inceleme
├── models/
│   ├── caravan_model.dart             # Karavan modelleri, yadigarlar (relics), bölgeler
│   ├── expedition_model.dart          # Prosedürel harita üretimi, düğümler, sefer durumu
│   ├── mystery_event.dart             # Rastgele yol olayları ve interaktif seçimler
│   ├── coffee_recipe.dart             # Kahve tarifleri, puanlama algoritması, çekirdek/öğütme
│   └── game_state.dart                # Kalıcı kayıt, garaj kilidi açma, seviye ve unvan
├── screens/
│   ├── home_screen.dart               # Ana lobi, 3D sefer başlatma ve serbest 3D kafe kartı
│   ├── daily_menu_dialog.dart         # Günün menüsü karatahta planlayıcısı
│   ├── caravan_shop_screen.dart       # Sefer içi mola pazarı
│   ├── mystery_event_screen.dart      # Yol karşılaşmaları hikaye ekranı
│   ├── treasure_screen.dart           # Tedarik sandığı ödül seçimi
│   └── settings_screen.dart           # Ses ve kontrol ayarları
└── widgets/
    └── sound_service.dart             # Titreşim (haptic) ve ses efektleri
```

---

## 🚀 Çalıştırma ve Test

```bash
# Bağımlılıkları yükle
flutter pub get

# Kod analizini çalıştır (0 hata / 0 uyarı)
flutter analyze

# Birim, widget ve 3D motor testlerini çalıştır
flutter test
```
