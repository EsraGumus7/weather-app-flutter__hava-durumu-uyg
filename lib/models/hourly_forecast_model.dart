class HourlyForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final double windSpeed;
  final String windDirection;
  final int humidity;
  final double? chanceOfRain;

  HourlyForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    this.chanceOfRain,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List?)?[0] ?? {};
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    
    // DateTime parse - Unix timestamp veya dt_txt
    DateTime dateTime;
    try {
      if (json['dt'] != null) {
        dateTime = DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000);
      } else if (json['dt_txt'] != null) {
        dateTime = DateTime.parse(json['dt_txt']);
      } else {
        dateTime = DateTime.now();
      }
    } catch (e) {
      dateTime = DateTime.now();
    }
    
    // Rüzgar yönünü dereceden yöne çevir
    String windDirection = '';
    if (wind['deg'] != null) {
      final deg = wind['deg'] as int;
      if (deg >= 337.5 || deg < 22.5) windDirection = 'N';
      else if (deg >= 22.5 && deg < 67.5) windDirection = 'NE';
      else if (deg >= 67.5 && deg < 112.5) windDirection = 'E';
      else if (deg >= 112.5 && deg < 157.5) windDirection = 'SE';
      else if (deg >= 157.5 && deg < 202.5) windDirection = 'S';
      else if (deg >= 202.5 && deg < 247.5) windDirection = 'SW';
      else if (deg >= 247.5 && deg < 292.5) windDirection = 'W';
      else if (deg >= 292.5 && deg < 337.5) windDirection = 'NW';
    }
    
    // Icon URL'i oluştur
    final iconCode = weather['icon'] ?? '01d';
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
    
    return HourlyForecastModel(
      dateTime: dateTime,
      temperature: (main['temp'] ?? 0).toDouble(),
      description: weather['description'] ?? '',
      icon: iconUrl,
      windSpeed: (wind['speed'] ?? 0).toDouble(), // m/s zaten
      windDirection: windDirection,
      humidity: main['humidity'] ?? 0,
      chanceOfRain: json['pop']?.toDouble(), // probability of precipitation (0-1)
    );
  }
}

