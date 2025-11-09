import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherModel? _currentWeather;
  List<ForecastModel> _forecasts = [];
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  String? _errorMessage;
  
  // Popüler şehirler - Her bölgeden temsilci şehirler
  static const List<String> popularCities = [
    // Marmara Bölgesi
    'İstanbul',
    'Bursa',
    'Mardin',
    'Elazığ',
    'Edirne',
    // Ege Bölgesi
    'İzmir',
    'Aydın',
    // Akdeniz Bölgesi
    'Antalya',
    'Adana',
    'Mersin',
    // İç Anadolu Bölgesi
    'Ankara',
    'Konya',
    // Karadeniz Bölgesi
    'Trabzon',
    // Doğu Anadolu Bölgesi
    'Erzurum',
    // Güneydoğu Anadolu Bölgesi
    'Gaziantep',
  ];
  
  Map<String, WeatherModel> _popularCitiesWeather = {};
  bool _isLoadingPopular = false;

  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecasts => _forecasts;
  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get errorMessage => _errorMessage;
  Map<String, WeatherModel> get popularCitiesWeather => _popularCitiesWeather;
  bool get isLoadingPopular => _isLoadingPopular;

  // Şehir adına göre hava durumu getir
  Future<void> getWeatherByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getWeatherByCity(city);
      _forecasts = await _weatherService.getForecastByCity(city);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentWeather = null;
      _forecasts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Konuma göre hava durumu getir
  Future<void> getWeatherByLocation() async {
    // Eğer zaten yükleniyorsa tekrar çağırma
    if (_isLoadingLocation) {
      debugPrint('Konum zaten yükleniyor, tekrar çağrı yapılmıyor');
      return;
    }
    
    _isLoadingLocation = true;
    _errorMessage = null;
    notifyListeners();
    
    debugPrint('Konum alınmaya başlandı...');

    try {
      final position = await _locationService.getCurrentLocation()
          .timeout(const Duration(seconds: 20), onTimeout: () {
        throw TimeoutException('Konum alınırken zaman aşımı oluştu. Lütfen tekrar deneyin.');
      });
      
      debugPrint('Konum alındı: ${position.latitude}, ${position.longitude}');
      
      _currentWeather = await _weatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      _forecasts = await _weatherService.getForecastByLocation(
        position.latitude,
        position.longitude,
      );
      _errorMessage = null;
      debugPrint('Konum hava durumu başarıyla alındı');
    } catch (e) {
      debugPrint('❌ Konum hatası: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentWeather = null;
      _forecasts = [];
    } finally {
      _isLoadingLocation = false;
      debugPrint('✅ Konum loading durumu: $_isLoadingLocation (false olmalı)');
      notifyListeners();
    }
  }

  // Popüler şehirlerin hava durumunu getir
  Future<void> loadPopularCitiesWeather() async {
    _isLoadingPopular = true;
    _popularCitiesWeather.clear();
    notifyListeners();

    for (String city in popularCities) {
      try {
        final weather = await _weatherService.getWeatherByCity(city);
        _popularCitiesWeather[city] = weather;
        notifyListeners(); // Her şehir yüklendiğinde güncelle
      } catch (e) {
        // Hata durumunda o şehri atla
      }
    }

    _isLoadingPopular = false;
    notifyListeners();
  }

  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Konum loading durumunu sıfırla (güvenlik için)
  void resetLocationLoading() {
    if (_isLoadingLocation) {
      debugPrint('⚠️ Konum loading durumu manuel olarak sıfırlanıyor');
      _isLoadingLocation = false;
      notifyListeners();
    }
  }
}

