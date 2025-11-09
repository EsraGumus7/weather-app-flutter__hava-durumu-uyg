import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/hourly_forecast_model.dart';
import '../services/weather_service.dart';
import 'hourly_detail_screen.dart';

class CityDetailScreen extends StatefulWidget {
  final String cityName;
  final WeatherModel initialWeather;

  const CityDetailScreen({
    super.key,
    required this.cityName,
    required this.initialWeather,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  final WeatherService _weatherService = WeatherService();
  List<HourlyForecastModel> _hourlyForecasts = [];
  List<ForecastModel> _dailyForecasts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoading = true);
    try {
      // 10 günlük tahmin al (içinde saatlik veriler de var)
      final response = await _weatherService.getForecastByCity(widget.cityName, days: 10);
      setState(() {
        _dailyForecasts = response;
        _isLoading = false;
      });
      
      // İlk günün saatlik verilerini al
      await _loadHourlyData();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hava durumu yüklenemedi: $e')),
        );
      }
    }
  }

  Future<void> _loadHourlyData() async {
    try {
      final hourlyData = await _weatherService.getHourlyForecastByCity(widget.cityName);
      if (mounted) {
        setState(() {
          _hourlyForecasts = hourlyData;
        });
      }
    } catch (e) {
      // Hata olsa bile boş liste göster
      if (mounted) {
        setState(() {
          _hourlyForecasts = [];
        });
      }
    }
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(date.year, date.month, date.day);
    
    if (forecastDate == today) {
      return 'Bugün';
    } else if (forecastDate == today.add(const Duration(days: 1))) {
      return 'Yarın';
    } else {
      final weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
      return weekdays[date.weekday - 1];
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM', 'tr_TR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.cityName,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genel Hava Durumu Kartı
                  _buildCurrentWeatherCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Saatlik Tahmin Bölümü
                  _buildHourlySection(),
                  
                  const SizedBox(height: 16),
                  
                  // 10 Günlük Tahmin Bölümü
                  _buildDailyForecastSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    // Sıcaklığa göre gradyan renkleri belirle (ana ekran ile aynı)
    final temp = widget.initialWeather.temperature;
    Color startColor;
    Color endColor;
    
    if (temp >= 30) {
      startColor = const Color(0xFFFF4757);
      endColor = const Color(0xFFFF6348);
    } else if (temp >= 20) {
      startColor = const Color(0xFFFFC312);
      endColor = const Color(0xFFFF6348);
    } else if (temp >= 10) {
      startColor = const Color(0xFF2ED573);
      endColor = const Color(0xFF1E90FF);
    } else if (temp >= 0) {
      startColor = const Color(0xFF1E90FF);
      endColor = const Color(0xFF5F27CD);
    } else {
      startColor = const Color(0xFF5F27CD);
      endColor = const Color(0xFF341F97);
    }
    
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(Colors.white.withOpacity(0.15), startColor, 0.85) ?? startColor,
              endColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: startColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım: Açıklama
            Text(
              widget.initialWeather.description.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 0),
            // Orta kısım: İkon (sol) ve Sıcaklık (sağ) aynı hizada
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Image.network(
                    widget.initialWeather.icon,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.wb_sunny, size: 120, color: Colors.white);
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.initialWeather.temperature.round()}°',
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -3,
                        height: 0.9,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hissedilen',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      Text(
                        '${widget.initialWeather.feelsLike.round()}°',
                        style: TextStyle(
                          fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Alt kısım: Detaylar Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.air,
                    '${widget.initialWeather.windSpeed.toStringAsFixed(1)} m/s',
                    'Rüzgar',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailItem(
                    Icons.water_drop,
                    '%${widget.initialWeather.humidity}',
                    'Nem',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.visibility,
                    '${widget.initialWeather.visibility} km',
                    'Görüş',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailItem(
                    Icons.access_time,
                    DateFormat('HH:mm', 'tr_TR').format(widget.initialWeather.dateTime),
                    'Güncelleme',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlySection() {
    // Eğer veri yükleniyorsa loading göster
    if (_isLoading && _hourlyForecasts.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Eğer veri yoksa hiçbir şey gösterme
    if (_hourlyForecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        // Saatlik detay sayfasına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HourlyDetailScreen(
              cityName: widget.cityName,
              hourlyForecasts: _hourlyForecasts,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saatlik Tahmin',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _hourlyForecasts.length > 12 ? 12 : _hourlyForecasts.length,
                itemBuilder: (context, index) {
                  final hourly = _hourlyForecasts[index];
                  
                  // Sıcaklığa göre renk belirle
                  final temp = hourly.temperature;
                  Color cardColor;
                  Color textColor;
                  
                  if (temp >= 25) {
                    cardColor = const Color(0xFFFFF5E6);
                    textColor = const Color(0xFFFF6348);
                  } else if (temp >= 15) {
                    cardColor = const Color(0xFFE8F5E9);
                    textColor = const Color(0xFF2ED573);
                  } else if (temp >= 5) {
                    cardColor = const Color(0xFFE3F2FD);
                    textColor = const Color(0xFF1E90FF);
                  } else {
                    cardColor = const Color(0xFFF3E5F5);
                    textColor = const Color(0xFF5F27CD);
                  }
                  
                  return Container(
                    width: 85,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: textColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            DateFormat('HH:mm').format(hourly.dateTime),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.network(
                            hourly.icon,
                            width: 36,
                            height: 36,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.wb_sunny, color: textColor, size: 36);
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: Text(
                            '${hourly.temperature.round()}°',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecastSection() {
    if (_dailyForecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '6 Günlük Tahmin',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._dailyForecasts.map((forecast) => _buildDailyForecastItem(forecast)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastItem(ForecastModel forecast) {
    return GestureDetector(
      onTap: () async {
        // Bu günün saatlik verilerini yükle ve göster
        try {
          final hourlyData = await _weatherService.getHourlyForecastByDate(
            widget.cityName,
            forecast.dateTime,
          );
          
          if (hourlyData.isNotEmpty && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HourlyDetailScreen(
                  cityName: '${widget.cityName} - ${_getDayName(forecast.dateTime)}',
                  hourlyForecasts: hourlyData,
                ),
              ),
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bu gün için saatlik veri bulunamadı'),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saatlik veri yüklenemedi: $e'),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tarih
            SizedBox(
              width: 85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDayName(forecast.dateTime),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(forecast.dateTime),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // İkon
            Image.network(
              forecast.icon,
              width: 44,
              height: 44,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.wb_sunny, color: Colors.orange[300], size: 44);
              },
            ),
            const SizedBox(width: 12),
            // Açıklama
            Expanded(
              child: Text(
                forecast.description,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Sıcaklık
            Row(
              children: [
                Text(
                  '${forecast.maxTemp.round()}°',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  ' / ${forecast.minTemp.round()}°',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


