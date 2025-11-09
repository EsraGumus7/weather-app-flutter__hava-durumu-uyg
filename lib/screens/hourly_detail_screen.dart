import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hourly_forecast_model.dart';

class HourlyDetailScreen extends StatelessWidget {
  final String cityName;
  final List<HourlyForecastModel> hourlyForecasts;

  const HourlyDetailScreen({
    super.key,
    required this.cityName,
    required this.hourlyForecasts,
  });

  String _getWindDirectionText(String direction) {
    final directions = {
      'N': 'Kuzey',
      'NE': 'Kuzeydoğu',
      'E': 'Doğu',
      'SE': 'Güneydoğu',
      'S': 'Güney',
      'SW': 'Güneybatı',
      'W': 'Batı',
      'NW': 'Kuzeybatı',
    };
    return directions[direction] ?? direction;
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
          cityName.contains(' - ') ? cityName : '$cityName - Saatlik Tahmin',
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
      body: hourlyForecasts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Saatlik veri bulunamadı',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hourlyForecasts.length,
              itemBuilder: (context, index) {
                final hourly = hourlyForecasts[index];
                final isToday = hourly.dateTime.day == DateTime.now().day;
                
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
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardColor.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: textColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Tarih ve Saat
                      SizedBox(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isToday) ...[
                              Text(
                                DateFormat('d MMM', 'tr_TR').format(hourly.dateTime),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              DateFormat('HH:mm').format(hourly.dateTime),
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // İkon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          hourly.icon,
                          width: 48,
                          height: 48,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.wb_sunny, color: textColor, size: 48);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Açıklama ve Detaylar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hourly.description,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.air, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${hourly.windSpeed.toStringAsFixed(1)} m/s ${_getWindDirectionText(hourly.windDirection)}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (hourly.chanceOfRain != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.water_drop, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '%${hourly.chanceOfRain!.round()}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.water_drop_outlined, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '%${hourly.humidity}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sıcaklık
                      Text(
                        '${hourly.temperature.round()}°',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

