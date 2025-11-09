class ForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final double minTemp;
  final double maxTemp;

  ForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.minTemp,
    required this.maxTemp,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    // OpenWeatherMap formatı - günlük tahmin için gruplanmış veri
    final main = json['main'] ?? {};
    final weather = (json['weather'] as List?)?[0] ?? {};
    
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
    
    // Icon URL'i oluştur
    final iconCode = weather['icon'] ?? '01d';
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
    
    return ForecastModel(
      dateTime: dateTime,
      temperature: (main['temp'] ?? 0).toDouble(),
      description: weather['description'] ?? '',
      icon: iconUrl,
      minTemp: (main['temp_min'] ?? 0).toDouble(),
      maxTemp: (main['temp_max'] ?? 0).toDouble(),
    );
  }
}
