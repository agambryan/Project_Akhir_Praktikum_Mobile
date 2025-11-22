import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/earthquake_provider.dart';
import 'earthquake_detail_screen.dart';

class EarthquakeScreen extends StatelessWidget {
  const EarthquakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Gempa Bumi'),
      ),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildTabBar(context, provider),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: _buildEarthquakeList(context, provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, EarthquakeProvider provider) {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              'Terkini',
              'latest',
              provider.selectedTab == 'latest',
              () => provider.changeTab('latest'),
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              'M ≥ 5',
              'recent',
              provider.selectedTab == 'recent',
              () => provider.changeTab('recent'),
            ),
          ),
          Expanded(
            child: _buildTab(
              context,
              'Dirasakan',
              'felt',
              provider.selectedTab == 'felt',
              () => provider.changeTab('felt'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    String tab,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildEarthquakeList(
    BuildContext context,
    EarthquakeProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final earthquakes = provider.currentList;

    if (earthquakes.isEmpty) {
      return const Center(
        child: Text('Tidak ada data gempa bumi'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: earthquakes.length,
      itemBuilder: (context, index) {
        final earthquake = earthquakes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EarthquakeDetailScreen(earthquake: earthquake),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getMagnitudeColor(earthquake.magnitude),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'M ${earthquake.magnitude?.toStringAsFixed(1) ?? '-'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              earthquake.getMagnitudeCategory(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Kedalaman: ${earthquake.depth} Km',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          earthquake.region ?? 'Tidak diketahui',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${earthquake.date} ${earthquake.time}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (earthquake.felt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.warning,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Dirasakan: ${earthquake.felt}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getMagnitudeColor(double? magnitude) {
    if (magnitude == null) return Colors.grey;
    if (magnitude < 3.0) return Colors.green;
    if (magnitude < 5.0) return Colors.yellow.shade700;
    if (magnitude < 7.0) return Colors.orange;
    return Colors.red;
  }
}
