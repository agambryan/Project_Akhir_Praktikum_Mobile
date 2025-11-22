import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/earthquake_provider.dart';
import '../services/permission_service.dart';
import '../services/preferences_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final useGPS = PreferencesService.getUseGPS();
    if (useGPS) {
      final hasPermission = await LocationService.isLocationPermissionGranted();
      if (!hasPermission) {
        await LocationService.requestLocationPermission();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<WeatherProvider>().refresh(),
            context.read<EarthquakeProvider>().refresh(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildWeatherSummary(),
              const SizedBox(height: 16),
              _buildEarthquakeSummary(),
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Saat Ini',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weatherProvider.selectedLocation,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                            .format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_location),
                  onPressed: () => _showLocationDialog(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherSummary() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 200,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final temperature = weatherProvider.getCurrentTemperature();
        final condition = weatherProvider.getCurrentWeatherCondition();

        return Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cuaca Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temperature != null
                          ? '${temperature.toStringAsFixed(0)}°'
                          : '--°',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            condition ?? 'Memuat...',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weatherProvider.selectedLocation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEarthquakeSummary() {
    return Consumer<EarthquakeProvider>(
      builder: (context, earthquakeProvider, child) {
        if (earthquakeProvider.isLoading) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 150,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final latestEarthquake = earthquakeProvider.latestEarthquakes.isNotEmpty
            ? earthquakeProvider.latestEarthquakes.first
            : null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gempa Terkini',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Icon(
                      Icons.warning_amber_rounded,
                      color: latestEarthquake != null &&
                              latestEarthquake.magnitude != null &&
                              latestEarthquake.magnitude! >= 5.0
                          ? Colors.orange
                          : Colors.grey,
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (latestEarthquake != null) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getMagnitudeColor(latestEarthquake.magnitude),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'M ${latestEarthquake.magnitude?.toStringAsFixed(1) ?? '-'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              latestEarthquake.region ?? 'Tidak diketahui',
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${latestEarthquake.date} ${latestEarthquake.time}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Center(
                    child: Text(
                      'Tidak ada data gempa terkini',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akses Cepat',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              icon: Icons.cloud_queue,
              title: 'Prakiraan Cuaca',
              color: Colors.blue,
              onTap: () {
                // Navigate to weather screen
              },
            ),
            _buildQuickActionCard(
              icon: Icons.terrain,
              title: 'Info Gempa',
              color: Colors.orange,
              onTap: () {
                // Navigate to earthquake screen
              },
            ),
            _buildQuickActionCard(
              icon: Icons.air,
              title: 'Kualitas Udara',
              color: Colors.green,
              onTap: () {
                // Navigate to air quality screen
              },
            ),
            _buildQuickActionCard(
              icon: Icons.settings,
              title: 'Pengaturan',
              color: Colors.grey,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMagnitudeColor(double? magnitude) {
    if (magnitude == null) return Colors.grey;
    if (magnitude < 3.0) return Colors.green;
    if (magnitude < 5.0) return Colors.yellow.shade700;
    if (magnitude < 7.0) return Colors.orange;
    return Colors.red;
  }

  void _showLocationDialog() {
    final cities = [
      'Jakarta',
      'Yogyakarta',
      'Bandung',
      'Surabaya',
      'Semarang',
      'Medan',
      'Palembang',
      'Makassar',
      'Denpasar',
      'Malang',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Lokasi'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cities[index]),
                  onTap: () {
                    context
                        .read<WeatherProvider>()
                        .changeLocation(cities[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
