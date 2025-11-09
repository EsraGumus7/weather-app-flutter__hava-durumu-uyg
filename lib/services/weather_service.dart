import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/hourly_forecast_model.dart';
import '../utils/constants.dart';

class WeatherService {
  // Şehir adına göre hava durumu getir
  Future<WeatherModel> getWeatherByCity(String city) async {
    try {
      final url = Constants.weatherUrl(city);
      
      // API key kontrolü için URL'i logla (key'i gizleyerek)
      final maskedUrl = url.replaceAll(RegExp(r'appid=[^&]+'), 'appid=***');
      debugPrint('🌐 API URL: $maskedUrl');
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Şehir eşleşme kontrolü - OpenWeatherMap formatı
        final apiCityName = (jsonData['name'] ?? '').toString().trim();
        final sys = jsonData['sys'] ?? {};
        final apiCountry = (sys['country'] ?? '').toString().trim();
        final coord = jsonData['coord'] ?? {};
        final lat = (coord['lat'] ?? 0.0).toDouble();
        final lon = (coord['lon'] ?? 0.0).toDouble();
        
        final requestedCity = city.trim();
        // İstenen şehir adından ",TR" gibi ekleri temizle
        final cleanRequestedCity = requestedCity
            .replaceAll(RegExp(r',\s*TR', caseSensitive: false), '')
            .replaceAll(RegExp(r',\s*Turkey', caseSensitive: false), '')
            .replaceAll(RegExp(r',\s*Türkiye', caseSensitive: false), '')
            .trim();
        
        // Şehir adlarını normalize et (büyük/küçük harf duyarsız, Türkçe karakterleri normalize et)
        String normalizeCity(String cityName) {
          return cityName
              .toLowerCase()
              .replaceAll('ı', 'i')
              .replaceAll('ğ', 'g')
              .replaceAll('ü', 'u')
              .replaceAll('ş', 's')
              .replaceAll('ö', 'o')
              .replaceAll('ç', 'c')
              .replaceAll('İ', 'i')
              .replaceAll('Ğ', 'g')
              .replaceAll('Ü', 'u')
              .replaceAll('Ş', 's')
              .replaceAll('Ö', 'o')
              .replaceAll('Ç', 'c');
        }
        
        final normalizedRequested = normalizeCity(cleanRequestedCity);
        final normalizedApi = normalizeCity(apiCityName);
        final isCityMatch = normalizedRequested == normalizedApi || 
                           normalizedApi.contains(normalizedRequested) ||
                           normalizedRequested.contains(normalizedApi);
        final isCountryMatch = apiCountry.toUpperCase() == 'TR';
        
        // Koordinat kontrolü - Özel şehirler için kontrol
        final isGumushaneCoordinates = (lat >= 40.3 && lat <= 40.6 && lon >= 39.3 && lon <= 39.7);
        final isMusCoordinates = (lat >= 38.6 && lat <= 38.9 && lon >= 41.3 && lon <= 41.7);
        
        // Şehir adı eşleşmese bile, koordinatlar doğru şehre aitse doğru kabul et
        final isCorrectMatch = (isCityMatch && isCountryMatch) || 
                              (isGumushaneCoordinates && normalizedRequested.contains('gumushane') && isCountryMatch) ||
                              (isMusCoordinates && normalizedRequested.contains('mus') && isCountryMatch);
        
        // ÖNCE ŞEHİR EŞLEŞME KONTROLÜNÜ GÖSTER (EN ÜSTTE)
        debugPrint('');
        debugPrint('========================================================');
        debugPrint('==========  SEHIR ESLESME KONTROLU  ====================');
        debugPrint('========================================================');
        debugPrint('ISTENEN SEHIR: "$cleanRequestedCity"');
        debugPrint('API SEHIR ADI: "$apiCityName"');
        debugPrint('API ULKE: "$apiCountry"');
        debugPrint('KOORDINATLAR: $lat, $lon');
        debugPrint('--------------------------------------------------------');
        if (isCorrectMatch) {
          debugPrint('✅ [OK] DOGRU SEHIR BULUNDU! ✅');
        } else {
          debugPrint('❌ [HATA] YANLIS SEHIR BULUNDU! ❌');
          debugPrint('⚠️ UYARI: İstenen şehir ile API şehri eşleşmiyor!');
          debugPrint('  Sehir eslesmesi: ${isCityMatch ? "✅ [OK]" : "❌ [HATA]"}');
          debugPrint('  Ulke eslesmesi: ${isCountryMatch ? "✅ [OK]" : "❌ [HATA]"}');
        }
        debugPrint('========================================================');
        debugPrint('');
        
        return WeatherModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        debugPrint('WeatherService: 404 hatası - Şehir bulunamadı');
        throw Exception('Şehir bulunamadı');
      } else {
        debugPrint('WeatherService: Hata - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Hava durumu bilgisi alınamadı (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('WeatherService: Exception - $e');
      throw Exception('Hata: ${e.toString()}');
    }
  }

  // Konuma göre hava durumu getir
  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(Constants.weatherByLocationUrl(lat, lon)),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherModel.fromJson(jsonData);
      } else {
        throw Exception('Hava durumu bilgisi alınamadı');
      }
    } catch (e) {
      throw Exception('Hata: ${e.toString()}');
    }
  }

  // Şehir adına göre tahmin getir (OpenWeatherMap 5 güne kadar ücretsiz)
  Future<List<ForecastModel>> getForecastByCity(String city, {int days = 5}) async {
    try {
      final url = Constants.forecastUrl(city, days: days);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> list = jsonData['list'] ?? [];
        
        // 3 saatlik verileri günlere göre grupla
        Map<String, List<Map<String, dynamic>>> dailyGroups = {};
        
        for (var item in list) {
          final dt = item['dt'] as int;
          final dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
          final dateKey = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
          
          if (!dailyGroups.containsKey(dateKey)) {
            dailyGroups[dateKey] = [];
          }
          dailyGroups[dateKey]!.add(item);
        }
        
        // Her gün için ortalama/min/max değerleri hesapla
        List<ForecastModel> forecasts = [];
        final sortedDates = dailyGroups.keys.toList()..sort();
        
        for (var dateKey in sortedDates.take(days)) {
          final dayItems = dailyGroups[dateKey]!;
          
          // Günün ortasındaki veriyi temsili olarak kullan (12:00 civarı)
          Map<String, dynamic>? representativeItem;
          int minHour = 25;
          
          for (var item in dayItems) {
            final dt = item['dt'] as int;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
            final hour = dateTime.hour;
            
            // 12:00'e en yakın saati bul
            if ((hour - 12).abs() < minHour) {
              minHour = (hour - 12).abs();
              representativeItem = item;
            }
          }
          
          if (representativeItem != null) {
            // Min ve max sıcaklıkları hesapla
            double minTemp = double.infinity;
            double maxTemp = double.negativeInfinity;
            
            for (var item in dayItems) {
              final main = item['main'] ?? {};
              final temp = (main['temp'] ?? 0).toDouble();
              if (temp < minTemp) minTemp = temp;
              if (temp > maxTemp) maxTemp = temp;
            }
            
            // Representative item'a min/max ekle
            representativeItem['main'] ??= {};
            representativeItem['main']['temp_min'] = minTemp;
            representativeItem['main']['temp_max'] = maxTemp;
            
            forecasts.add(ForecastModel.fromJson(representativeItem));
          }
        }
        
        return forecasts;
      } else {
        throw Exception('Tahmin bilgisi alınamadı');
      }
    } catch (e) {
      throw Exception('Hata: ${e.toString()}');
    }
  }

  // Konuma göre tahmin getir (OpenWeatherMap 5 güne kadar ücretsiz)
  Future<List<ForecastModel>> getForecastByLocation(
    double lat,
    double lon, {
    int days = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(Constants.forecastByLocationUrl(lat, lon, days: days)),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> list = jsonData['list'] ?? [];
        
        // 3 saatlik verileri günlere göre grupla
        Map<String, List<Map<String, dynamic>>> dailyGroups = {};
        
        for (var item in list) {
          final dt = item['dt'] as int;
          final dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
          final dateKey = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
          
          if (!dailyGroups.containsKey(dateKey)) {
            dailyGroups[dateKey] = [];
          }
          dailyGroups[dateKey]!.add(item);
        }
        
        // Her gün için ortalama/min/max değerleri hesapla
        List<ForecastModel> forecasts = [];
        final sortedDates = dailyGroups.keys.toList()..sort();
        
        for (var dateKey in sortedDates.take(days)) {
          final dayItems = dailyGroups[dateKey]!;
          
          // Günün ortasındaki veriyi temsili olarak kullan (12:00 civarı)
          Map<String, dynamic>? representativeItem;
          int minHour = 25;
          
          for (var item in dayItems) {
            final dt = item['dt'] as int;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
            final hour = dateTime.hour;
            
            // 12:00'e en yakın saati bul
            if ((hour - 12).abs() < minHour) {
              minHour = (hour - 12).abs();
              representativeItem = item;
            }
          }
          
          if (representativeItem != null) {
            // Min ve max sıcaklıkları hesapla
            double minTemp = double.infinity;
            double maxTemp = double.negativeInfinity;
            
            for (var item in dayItems) {
              final main = item['main'] ?? {};
              final temp = (main['temp'] ?? 0).toDouble();
              if (temp < minTemp) minTemp = temp;
              if (temp > maxTemp) maxTemp = temp;
            }
            
            // Representative item'a min/max ekle
            representativeItem['main'] ??= {};
            representativeItem['main']['temp_min'] = minTemp;
            representativeItem['main']['temp_max'] = maxTemp;
            
            forecasts.add(ForecastModel.fromJson(representativeItem));
          }
        }
        
        return forecasts;
      } else {
        throw Exception('Tahmin bilgisi alınamadı');
      }
    } catch (e) {
      throw Exception('Hata: ${e.toString()}');
    }
  }

  // Şehir adına göre saatlik tahmin getir (24 saat - OpenWeatherMap 3 saatlik aralıklarla)
  Future<List<HourlyForecastModel>> getHourlyForecastByCity(String city) async {
    try {
      final url = Constants.forecastUrl(city);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> list = jsonData['list'] ?? [];
        
        List<HourlyForecastModel> hourlyForecasts = [];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        // Bugün ve yarın için tüm 3 saatlik verileri al (24 saat = 8 veri)
        for (var item in list.take(8)) {
          try {
            final dt = item['dt'] as int;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
            final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
            
            // Bugün veya yarın ise ekle
            if (itemDate == today || itemDate == today.add(const Duration(days: 1))) {
              hourlyForecasts.add(HourlyForecastModel.fromJson(item));
            }
          } catch (e) {
            // Sessizce atla
          }
        }
        
        return hourlyForecasts;
      } else {
        throw Exception('Saatlik tahmin bilgisi alınamadı (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Belirli bir günün saatlik tahminlerini getir (OpenWeatherMap 3 saatlik aralıklarla)
  Future<List<HourlyForecastModel>> getHourlyForecastByDate(String city, DateTime targetDate) async {
    try {
      final url = Constants.forecastUrl(city);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> list = jsonData['list'] ?? [];
        
        List<HourlyForecastModel> hourlyForecasts = [];
        final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
        
        // Hedef tarihe ait tüm 3 saatlik verileri bul
        for (var item in list) {
          try {
            final dt = item['dt'] as int;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
            final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
            
            if (itemDate == target) {
              hourlyForecasts.add(HourlyForecastModel.fromJson(item));
            }
          } catch (e) {
            // Sessizce atla
          }
        }
        
        return hourlyForecasts;
      } else {
        throw Exception('Saatlik tahmin bilgisi alınamadı (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}
