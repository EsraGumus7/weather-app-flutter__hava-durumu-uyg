import '../utils/constants.dart';

class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String mainDescription;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final int pressure;
  final String icon;
  final DateTime dateTime;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.mainDescription,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.pressure,
    required this.icon,
    required this.dateTime,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // OpenWeatherMap formatı
    final weather = (json['weather'] as List?)?[0] ?? {};
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    
    // API'den gelen güncel zamanı kullan (Unix timestamp)
    DateTime dateTime;
    try {
      if (json['dt'] != null) {
        dateTime = DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000);
      } else {
        dateTime = DateTime.now();
      }
    } catch (e) {
      dateTime = DateTime.now();
    }
    
    // API'den gelen şehir adını Türkçe karakterlere çevir
    final apiCityName = json['name'] ?? '';
    final turkishCityName = Constants.convertCityNameToTurkish(apiCityName);
    
    // Icon URL'i oluştur
    final iconCode = weather['icon'] ?? '01d';
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
    
    return WeatherModel(
      cityName: turkishCityName,
      temperature: (main['temp'] ?? 0).toDouble(),
      description: weather['description'] ?? '',
      mainDescription: weather['main'] ?? '',
      feelsLike: (main['feels_like'] ?? 0).toDouble(),
      humidity: main['humidity'] ?? 0,
      windSpeed: (wind['speed'] ?? 0).toDouble(), // m/s zaten
      visibility: json['visibility'] != null 
          ? (json['visibility'] as int) ~/ 1000 // metre'den km'ye çevir
          : 0,
      pressure: main['pressure']?.round() ?? 0, // hPa zaten
      icon: iconUrl,
      dateTime: dateTime,
    );
  }
}
