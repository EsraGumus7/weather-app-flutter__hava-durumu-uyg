import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import 'search_screen.dart';
import 'city_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Uygulama açıldığında popüler şehirlerin hava durumunu yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('HomeScreen: loadPopularCitiesWeather çağrılıyor');
      final provider = context.read<WeatherProvider>();
      // Eğer konum loading durumunda takılı kalmışsa sıfırla
      provider.resetLocationLoading();
      provider.loadPopularCitiesWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Hava Durumu',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.my_location, color: Colors.black87),
                    if (provider.isLoadingLocation)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: provider.isLoadingLocation ? null : () async {
                  try {
                    await provider.getWeatherByLocation();
                    if (provider.currentWeather != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CityDetailScreen(
                            cityName: provider.currentWeather!.cityName,
                            initialWeather: provider.currentWeather!,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Konum alınamadı: ${e.toString().replaceAll('Exception: ', '')}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          // Popüler şehirler listesi
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadPopularCitiesWeather();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Konum kartı
                  _buildLocationCard(provider),
                  const SizedBox(height: 24),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Şehirler',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Loading durumu
                  if (provider.isLoadingPopular && provider.popularCitiesWeather.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  // Popüler şehirler listesi
                  else if (provider.popularCitiesWeather.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Hava durumu yükleniyor...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...provider.popularCitiesWeather.entries.map((entry) {
                      return _buildCityCard(entry.value, provider);
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationCard(WeatherProvider provider) {
    // Konum butonu
    return InkWell(
      onTap: provider.isLoadingLocation ? null : () async {
        try {
          await provider.getWeatherByLocation();
          if (provider.currentWeather != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CityDetailScreen(
                  cityName: provider.currentWeather!.cityName,
                  initialWeather: provider.currentWeather!,
                ),
              ),
            );
          } else if (provider.errorMessage != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Konum alınamadı: ${e.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: provider.isLoadingLocation
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.isLoadingLocation ? 'Konum alınıyor...' : 'Konumumu Göster',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    provider.isLoadingLocation
                        ? 'Lütfen bekleyin...'
                        : 'Bulunduğunuz konumun hava durumunu görüntüleyin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (!provider.isLoadingLocation)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityCard(WeatherModel weather, WeatherProvider provider, {bool isLocation = false}) {
    // Sıcaklığa göre gradyan renkleri belirle
    final temp = weather.temperature;
    Color startColor;
    Color endColor;
    
    if (temp >= 30) {
      // Çok sıcak - canlı turuncu/kırmızı
      startColor = const Color(0xFFFF4757);
      endColor = const Color(0xFFFF6348);
    } else if (temp >= 20) {
      // Sıcak - canlı sarı/turuncu
      startColor = const Color(0xFFFFC312);
      endColor = const Color(0xFFFF6348);
    } else if (temp >= 10) {
      // Ilık - canlı yeşil/mavi
      startColor = const Color(0xFF2ED573);
      endColor = const Color(0xFF1E90FF);
    } else if (temp >= 0) {
      // Serin - canlı mavi
      startColor = const Color(0xFF1E90FF);
      endColor = const Color(0xFF5F27CD);
    } else {
      // Soğuk - canlı mor/mavi
      startColor = const Color(0xFF5F27CD);
      endColor = const Color(0xFF341F97);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Şehre tıklanınca detay sayfasına git
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CityDetailScreen(
                  cityName: weather.cityName,
                  initialWeather: weather,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [startColor, endColor],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // İkon - beyaz arka planlı
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    weather.icon,
                    width: 56,
                    height: 56,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.wb_sunny,
                        size: 56,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                
                // Şehir adı ve açıklama
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isLocation) ...[
                            const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            weather.cityName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weather.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.air,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${weather.windSpeed.toStringAsFixed(1)} m/s',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.water_drop,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '%${weather.humidity}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Sıcaklık
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hissedilen ${weather.feelsLike.round()}°',
                      style: TextStyle(
                        fontSize: 13,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

}
