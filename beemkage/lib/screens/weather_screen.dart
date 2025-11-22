import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prakiraan Cuaca'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(weatherProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => weatherProvider.refresh(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => weatherProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentWeather(context, weatherProvider),
                  const SizedBox(height: 24),
                  _buildHourlyForecast(context, weatherProvider),
                  const SizedBox(height: 24),
                  _buildTemperatureChart(context, weatherProvider),
                  const SizedBox(height: 24),
                  _buildWeeklyForecast(context, weatherProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentWeather(
    BuildContext context,
    WeatherProvider provider,
  ) {
    final temp = provider.getCurrentTemperature();
    final condition = provider.getCurrentWeatherCondition();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              provider.selectedLocation,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              temp != null
                  ? '${temp.toStringAsFixed(0)}°${provider.getTemperatureUnit()}'
                  : '--°',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              condition ?? 'Memuat...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast(
    BuildContext context,
    WeatherProvider provider,
  ) {
    final forecasts = provider.getTodayForecast();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prakiraan Per Jam',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              return Card(
                margin: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(forecast.datetime!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        forecast.getWeatherIcon(),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.getTemperature(forecast.temperature)?.toStringAsFixed(0)}°',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureChart(
    BuildContext context,
    WeatherProvider provider,
  ) {
    final forecasts = provider.getTodayForecast();
    if (forecasts.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafik Temperatur',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= forecasts.length) {
                            return const Text('');
                          }
                          final forecast = forecasts[value.toInt()];
                          return Text(
                            DateFormat('HH:mm').format(forecast.datetime!),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: forecasts.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          provider.getTemperature(entry.value.temperature) ?? 0,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast(
    BuildContext context,
    WeatherProvider provider,
  ) {
    final forecasts = provider.getWeeklyForecast();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prakiraan 7 Hari',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...forecasts.map((forecast) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Text(
                forecast.getWeatherIcon(),
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(
                DateFormat('EEEE, d MMM', 'id_ID').format(forecast.datetime!),
              ),
              subtitle: Text(forecast.weather ?? ''),
              trailing: Text(
                '${provider.getTemperature(forecast.temperature)?.toStringAsFixed(0)}°',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        }),
      ],
    );
  }
}
