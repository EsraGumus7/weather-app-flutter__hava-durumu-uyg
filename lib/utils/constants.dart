import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class Constants {
  // OpenWeatherMap API Key - .env dosyasından alınır
  static String get apiKey {
    final key = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('❌ UYARI: OpenWeatherMap API anahtarı bulunamadı! .env dosyasını kontrol edin.');
      debugPrint('   Aranan key: OPENWEATHER_API_KEY');
      debugPrint('   Mevcut env keys: ${dotenv.env.keys.toList()}');
    } else {
      debugPrint('✅ OpenWeatherMap API key yüklendi');
      debugPrint('   Key uzunluğu: ${key.length} karakter');
      debugPrint('   Key (ilk 8): ${key.length > 8 ? key.substring(0, 8) : key}...');
      debugPrint('   Key (son 4): ...${key.length > 4 ? key.substring(key.length - 4) : key}');
    }
    return key;
  }
  static String get baseUrl => dotenv.env['OPENWEATHER_API_URL'] ?? 'https://api.openweathermap.org/data/2.5';
  
  // API'den gelen şehir adlarını Türkçe karakterlere çevir
  static String _convertToTurkishCharacters(String cityName) {
    // Yaygın Türk şehirlerinin mapping'i
    final Map<String, String> cityMapping = {
      'Gumushane': 'Gümüşhane',
      'Izmir': 'İzmir',
      'Istanbul': 'İstanbul',
      'Canakkale': 'Çanakkale',
      'Corum': 'Çorum',
      'Sanliurfa': 'Şanlıurfa',
      'Sirnak': 'Şırnak',
      'Mugla': 'Muğla',
      'Agri': 'Ağrı',
      'Batman': 'Batman', // Zaten doğru
      'Bingol': 'Bingöl',
      'Bitlis': 'Bitlis', // Zaten doğru
      'Diyarbakir': 'Diyarbakır',
      'Elazig': 'Elazığ',
      'Erzincan': 'Erzincan', // Zaten doğru
      'Erzurum': 'Erzurum', // Zaten doğru
      'Gaziantep': 'Gaziantep', // Zaten doğru
      'Giresun': 'Giresun', // Zaten doğru
      'Hakkari': 'Hakkari', // Zaten doğru
      'Hatay': 'Hatay', // Zaten doğru
      'Igdir': 'Iğdır',
      'Kars': 'Kars', // Zaten doğru
      'Kastamonu': 'Kastamonu', // Zaten doğru
      'Kayseri': 'Kayseri', // Zaten doğru
      'Kirsehir': 'Kırşehir',
      'Kocaeli': 'Kocaeli', // Zaten doğru
      'Malatya': 'Malatya', // Zaten doğru
      'Mardin': 'Mardin', // Zaten doğru
      'Mus': 'Muş',
      'Nevsehir': 'Nevşehir',
      'Nigde': 'Niğde',
      'Ordu': 'Ordu', // Zaten doğru
      'Rize': 'Rize', // Zaten doğru
      'Sakarya': 'Sakarya', // Zaten doğru
      'Samsun': 'Samsun', // Zaten doğru
      'Siirt': 'Siirt', // Zaten doğru
      'Sinop': 'Sinop', // Zaten doğru
      'Sivas': 'Sivas', // Zaten doğru
      'Tekirdag': 'Tekirdağ',
      'Tokat': 'Tokat', // Zaten doğru
      'Trabzon': 'Trabzon', // Zaten doğru
      'Tunceli': 'Tunceli', // Zaten doğru
      'Usak': 'Uşak',
      'Van': 'Van', // Zaten doğru
      'Yozgat': 'Yozgat', // Zaten doğru
      'Zonguldak': 'Zonguldak', // Zaten doğru
      'Adana': 'Adana', // Zaten doğru
      'Adiyaman': 'Adıyaman',
      'Afyonkarahisar': 'Afyonkarahisar', // Zaten doğru
      'Aksaray': 'Aksaray', // Zaten doğru
      'Amasya': 'Amasya', // Zaten doğru
      'Ankara': 'Ankara', // Zaten doğru
      'Antalya': 'Antalya', // Zaten doğru
      'Ardahan': 'Ardahan', // Zaten doğru
      'Artvin': 'Artvin', // Zaten doğru
      'Aydin': 'Aydın',
      'Balikesir': 'Balıkesir',
      'Bartin': 'Bartın',
      'Bayburt': 'Bayburt', // Zaten doğru
      'Bilecik': 'Bilecik', // Zaten doğru
      'Bolu': 'Bolu', // Zaten doğru
      'Burdur': 'Burdur', // Zaten doğru
      'Bursa': 'Bursa', // Zaten doğru
      'Denizli': 'Denizli', // Zaten doğru
      'Duzce': 'Düzce',
      'Edirne': 'Edirne', // Zaten doğru
      'Karabuk': 'Karabük',
      'Karaman': 'Karaman', // Zaten doğru
      'Kilis': 'Kilis', // Zaten doğru
      'Kirklareli': 'Kırklareli',
      'Konya': 'Konya', // Zaten doğru
      'Kutahya': 'Kütahya',
      'Manisa': 'Manisa', // Zaten doğru
      'Mersin': 'Mersin', // Zaten doğru
      'Osmaniye': 'Osmaniye', // Zaten doğru
    };
    
    // Önce mapping'de var mı kontrol et
    if (cityMapping.containsKey(cityName)) {
      return cityMapping[cityName]!;
    }
    
    // Mapping'de yoksa genel dönüşüm yap
    String result = cityName;
    
    // Genel Türkçe karakter dönüşümleri (kelime başlarında)
    result = result.replaceAllMapped(RegExp(r'\b([Ii])zmir\b'), (match) => 'İzmir');
    result = result.replaceAllMapped(RegExp(r'\b([Ii])stanbul\b'), (match) => 'İstanbul');
    result = result.replaceAllMapped(RegExp(r'\b([Cc])anakkale\b'), (match) => 'Çanakkale');
    result = result.replaceAllMapped(RegExp(r'\b([Cc])orum\b'), (match) => 'Çorum');
    result = result.replaceAllMapped(RegExp(r'\b([Ss])anliurfa\b'), (match) => 'Şanlıurfa');
    result = result.replaceAllMapped(RegExp(r'\b([Ss])irnak\b'), (match) => 'Şırnak');
    result = result.replaceAllMapped(RegExp(r'\b([Gg])umushane\b'), (match) => 'Gümüşhane');
    result = result.replaceAllMapped(RegExp(r'\b([Mm])ugla\b'), (match) => 'Muğla');
    result = result.replaceAllMapped(RegExp(r'\b([Aa])gri\b'), (match) => 'Ağrı');
    result = result.replaceAllMapped(RegExp(r'\b([Bb])ingol\b'), (match) => 'Bingöl');
    result = result.replaceAllMapped(RegExp(r'\b([Dd])iyarbakir\b'), (match) => 'Diyarbakır');
    result = result.replaceAllMapped(RegExp(r'\b([Ee])lazig\b'), (match) => 'Elazığ');
    result = result.replaceAllMapped(RegExp(r'\b([Ii])gdir\b'), (match) => 'Iğdır');
    result = result.replaceAllMapped(RegExp(r'\b([Kk])irsehir\b'), (match) => 'Kırşehir');
    result = result.replaceAllMapped(RegExp(r'\b([Mm])us\b'), (match) => 'Muş');
    result = result.replaceAllMapped(RegExp(r'\b([Nn])evsehir\b'), (match) => 'Nevşehir');
    result = result.replaceAllMapped(RegExp(r'\b([Nn])igde\b'), (match) => 'Niğde');
    result = result.replaceAllMapped(RegExp(r'\b([Tt])ekirdag\b'), (match) => 'Tekirdağ');
    result = result.replaceAllMapped(RegExp(r'\b([Uu])sak\b'), (match) => 'Uşak');
    result = result.replaceAllMapped(RegExp(r'\b([Aa])diyaman\b'), (match) => 'Adıyaman');
    result = result.replaceAllMapped(RegExp(r'\b([Aa])ydin\b'), (match) => 'Aydın');
    result = result.replaceAllMapped(RegExp(r'\b([Bb])alikesir\b'), (match) => 'Balıkesir');
    result = result.replaceAllMapped(RegExp(r'\b([Bb])artin\b'), (match) => 'Bartın');
    result = result.replaceAllMapped(RegExp(r'\b([Dd])uzce\b'), (match) => 'Düzce');
    result = result.replaceAllMapped(RegExp(r'\b([Kk])arabuk\b'), (match) => 'Karabük');
    result = result.replaceAllMapped(RegExp(r'\b([Kk])irklareli\b'), (match) => 'Kırklareli');
    result = result.replaceAllMapped(RegExp(r'\b([Kk])utahya\b'), (match) => 'Kütahya');
    
    return result;
  }
  
  // Şehir adını Türkiye'ye özelleştir - daha doğru sonuç için
  // OpenWeatherMap için şehir adına ",TR" ekle
  static String _formatCityForTurkey(String city) {
    final trimmedCity = city.trim();
    // Eğer zaten ülke kodu varsa (virgül içeriyorsa), olduğu gibi döndür
    if (trimmedCity.contains(',')) {
      return trimmedCity;
    }
    // Türk şehirleri için otomatik olarak ",TR" ekle (ISO 3166-1 alpha-2)
    return '$trimmedCity,TR';
  }
  
  // API Endpoints - OpenWeatherMap formatı
  static String weatherUrl(String city) {
    final formattedCity = _formatCityForTurkey(city);
    return '$baseUrl/weather?q=$formattedCity&appid=$apiKey&units=metric&lang=tr';
  }
  
  static String weatherByLocationUrl(double lat, double lon) => 
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=tr';
  
  static String forecastUrl(String city, {int days = 5}) {
    final formattedCity = _formatCityForTurkey(city);
    // OpenWeatherMap forecast 5 güne kadar ücretsiz (40 saatlik veri, 3 saatlik aralıklarla)
    return '$baseUrl/forecast?q=$formattedCity&appid=$apiKey&units=metric&lang=tr';
  }
  
  static String forecastByLocationUrl(double lat, double lon, {int days = 5}) => 
      '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=tr';
  
  // API'den gelen şehir adını Türkçe karakterlere çevir (public method)
  static String convertCityNameToTurkish(String cityName) {
    return _convertToTurkishCharacters(cityName);
  }
}
