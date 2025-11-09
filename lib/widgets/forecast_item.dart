import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';

class ForecastItem extends StatelessWidget {
  final ForecastModel forecast;

  const ForecastItem({super.key, required this.forecast});

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(date.year, date.month, date.day);
    
    if (forecastDate == today) {
      return 'Bugün';
    } else if (forecastDate == today.add(const Duration(days: 1))) {
      return 'Yarın';
    } else {
      return DateFormat('EEEE', 'tr_TR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Gün adı
            Expanded(
              flex: 2,
              child: Text(
                _getDayName(forecast.dateTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // İkon
            Image.network(
              forecast.icon,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.wb_sunny, size: 50);
              },
            ),
            
            const SizedBox(width: 16),
            
            // Sıcaklık
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${forecast.minTemp.round()}°',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${forecast.maxTemp.round()}°',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

