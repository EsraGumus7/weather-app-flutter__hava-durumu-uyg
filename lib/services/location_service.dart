import 'package:geolocator/geolocator.dart';

class LocationService {
  // Konum izni kontrolü ve alma
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisleri kapalı. Lütfen açın.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan açın.',
      );
    }

    return true;
  }

  // Mevcut konumu al
  Future<Position> getCurrentLocation() async {
    try {
      await requestPermission();
      
      // Önce son bilinen konumu kontrol et (emülatör için önemli)
      // Emülatörde getCurrentPosition çalışmayabilir, bu yüzden önce getLastKnownPosition dene
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      
      // Eğer son bilinen konum varsa, direkt kullan (ne kadar eski olursa olsun)
      // Emülatörde genellikle son bilinen konum daha güvenilir
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }
      
      // Son bilinen konum yoksa yeni konum almayı dene
      // Emülatör için düşük doğruluk kullan (daha hızlı)
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low, // Emülatör için daha hızlı
          timeLimit: const Duration(seconds: 10), // Daha kısa timeout
        );
      } catch (timeoutError) {
        // Timeout olursa, son bilinen konumu tekrar dene
        // (bazen getCurrentPosition çağrısı son bilinen konumu güncelleyebilir)
        Position? retryLastKnown = await Geolocator.getLastKnownPosition();
        if (retryLastKnown != null) {
          return retryLastKnown;
        }
        // Eğer hala yoksa, emülatörde konum ayarlanmamış olabilir
        throw Exception('Konum alınamadı. Emülatörde konum ayarlandığından emin olun.');
      }
    } catch (e) {
      // Son bir kez daha getLastKnownPosition dene
      try {
        Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          return lastKnownPosition;
        }
      } catch (_) {
        // Son bilinen konum da yoksa hata fırlat
      }
      throw Exception('Konum alınamadı: ${e.toString()}');
    }
  }
}

