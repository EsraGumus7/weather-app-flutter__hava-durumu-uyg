# 🌤️ Hava Durumu Uygulaması

Modern ve kullanıcı dostu bir Flutter hava durumu uygulaması. Türkiye'nin tüm şehirleri için güncel hava durumu bilgileri, konum bazlı hava durumu, günlük ve saatlik tahminler sunar.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## 💡 Bu Projede Edinilen Beceriler

- **Flutter & Dart**: Mobil uygulama geliştirme
- **State Management**: Provider pattern ile state yönetimi
- **API Entegrasyonu**: RESTful API kullanımı ve veri işleme
- **Konum Servisleri**: GPS entegrasyonu ve izin yönetimi
- **UI/UX Tasarım**: Modern arayüz tasarımı ve animasyonlar
- **Yazılım Mimarisi**: Temiz kod ve modüler yapı
- **Git/GitHub**: Versiyon kontrolü ve proje yönetimi

## 📸 Ekran Görüntüleri

<div align="center">
  <img src="images/hava1.png" alt="Ana Ekran" width="200"/>
  <img src="images/hava2.png" alt="Şehir Detay" width="200"/>
  <img src="images/hava3.png" alt="Saatlik Tahmin" width="200"/>
  <img src="images/hava4.png" alt="Günlük Tahmin" width="200"/>
</div>

## ✨ Özellikler

### 🎯 Temel Özellikler
- **Konum Bazlı Hava Durumu**: GPS ile otomatik konum tespiti ve hava durumu gösterimi
- **Şehir Arama**: Türkiye'nin tüm şehirlerinde arama yapabilme
- **Popüler Şehirler**: Hızlı erişim için popüler şehirlerin listesi
- **Günlük Tahmin**: 6 günlük detaylı hava durumu tahmini
- **Saatlik Tahmin**: 24 saatlik saatlik hava durumu tahmini
- **Detaylı Bilgiler**: Rüzgar hızı, nem oranı, görüş mesafesi, hissedilen sıcaklık

### 🎨 Kullanıcı Arayüzü
- **Modern Tasarım**: Material Design 3 ile modern ve şık arayüz
- **Dinamik Renkler**: Sıcaklığa göre değişen gradient arka planlar
- **Türkçe Dil Desteği**: Tam Türkçe arayüz ve tarih formatları
- **Responsive Tasarım**: Tüm ekran boyutlarına uyumlu
- **Smooth Animations**: Akıcı geçişler ve animasyonlar

### 🔧 Teknik Özellikler
- **State Management**: Provider pattern ile merkezi state yönetimi
- **API Integration**: OpenWeatherMap API entegrasyonu
- **Location Services**: Geolocator ile konum servisleri
- **Error Handling**: Kapsamlı hata yönetimi ve kullanıcı bildirimleri
- **Environment Variables**: Güvenli API key yönetimi

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.9.2 veya üzeri
- Dart SDK 3.9.2 veya üzeri
- Android Studio / VS Code
- Android SDK (Android geliştirme için)
- Xcode (iOS geliştirme için - sadece macOS)

### Adım 1: Projeyi Klonlayın
```bash
git clone https://github.com/kullaniciadi/hava-durumu.git
cd hava-durumu
```

### Adım 2: Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### Adım 3: API Key Yapılandırması

1. `.env` dosyası oluşturun:
```bash
cp env.example .env
```

2. `.env` dosyasını düzenleyin ve OpenWeatherMap API key'inizi ekleyin:
```env
OPENWEATHER_API_KEY=your_api_key_here
OPENWEATHER_API_URL=https://api.openweathermap.org/data/2.5
```

#### OpenWeatherMap API Key Nasıl Alınır?
1. [OpenWeatherMap](https://openweathermap.org/) sitesine kaydolun
2. API Keys bölümüne gidin
3. Yeni bir API key oluşturun (ücretsiz plan yeterlidir)
4. API key'inizi `.env` dosyasına ekleyin

### Adım 4: Android İzinleri

Android için konum izinleri otomatik olarak yapılandırılmıştır. `AndroidManifest.xml` dosyasında şu izinler mevcuttur:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

### Adım 5: Uygulamayı Çalıştırın

```bash
# Android için
flutter run

# iOS için (sadece macOS)
flutter run

# Belirli bir cihaz için
flutter devices
flutter run -d <device_id>
```

## 📱 Kullanım

### Ana Ekran
- Uygulama açıldığında popüler şehirlerin hava durumu otomatik olarak yüklenir
- Her şehir kartına tıklayarak detaylı bilgilere ulaşabilirsiniz

### Konum Kullanımı
1. Sağ üstteki konum ikonuna tıklayın
2. Konum izni verin (ilk kullanımda)
3. Mevcut konumunuzun hava durumu otomatik olarak gösterilir

### Şehir Arama
1. Ana ekranda arama ikonuna tıklayın
2. Şehir adını yazın (Türkçe karakterler desteklenir)
3. Sonuçlardan bir şehir seçin

### Detay Ekranı
- **Mevcut Hava Durumu**: Sıcaklık, açıklama, ikon
- **Hissedilen Sıcaklık**: Rüzgar ve nem etkisiyle hissedilen sıcaklık
- **Detaylar**: Rüzgar hızı, nem oranı, görüş mesafesi
- **Saatlik Tahmin**: 24 saatlik detaylı tahmin
- **Günlük Tahmin**: 6 günlük hava durumu tahmini

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── models/                   # Veri modelleri
│   ├── weather_model.dart
│   ├── forecast_model.dart
│   └── hourly_forecast_model.dart
├── providers/                # State management
│   └── weather_provider.dart
├── screens/                  # Ekranlar
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── city_detail_screen.dart
│   └── hourly_detail_screen.dart
├── services/                 # Servisler
│   ├── weather_service.dart
│   └── location_service.dart
├── utils/                    # Yardımcı fonksiyonlar
│   ├── constants.dart
│   └── turkish_cities.dart
└── widgets/                  # Özel widget'lar
    ├── weather_card.dart
    └── forecast_item.dart
```

## 🛠️ Kullanılan Teknolojiler

### Flutter & Dart
- **Flutter 3.9.2**: Cross-platform UI framework
- **Dart 3.9.2**: Programlama dili

### Paketler
- **provider (^6.1.1)**: State management
- **http (^1.2.0)**: HTTP istekleri
- **geolocator (^11.0.0)**: Konum servisleri
- **shared_preferences (^2.2.2)**: Yerel veri saklama
- **intl (^0.19.0)**: Tarih ve sayı formatlama
- **flutter_dotenv (^5.1.0)**: Environment variables

### API
- **OpenWeatherMap API**: Hava durumu verileri

## 🔐 Güvenlik

- API key'ler `.env` dosyasında saklanır ve `.gitignore` ile korunur
- Hassas bilgiler asla kod içine yazılmaz
- `.env.example` dosyası şablon olarak kullanılabilir

## 🐛 Bilinen Sorunlar

- Emülatörde konum servisleri için manuel konum ayarı gerekebilir
- İlk konum izni isteği Android'de bazen gecikebilir

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

Bu proje Flutter ve modern yazılım geliştirme pratikleri kullanılarak geliştirilmiştir.

### Teknik Detaylar

#### State Management
- Provider pattern kullanılarak merkezi state yönetimi
- `ChangeNotifier` ile reactive programming
- Widget tree'de verimli state paylaşımı

#### API Integration
- RESTful API entegrasyonu
- Error handling ve retry mekanizmaları
- Timeout yönetimi
- Türkçe karakter desteği

#### Location Services
- GPS konum tespiti
- İzin yönetimi
- Fallback mekanizmaları (son bilinen konum)
- Emülatör desteği

#### UI/UX
- Material Design 3
- Responsive layout
- Smooth animations
- Loading states
- Error states