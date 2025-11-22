import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/earthquake_model.dart';

class EarthquakeDetailScreen extends StatelessWidget {
  final EarthquakeModel earthquake;

  const EarthquakeDetailScreen({
    super.key,
    required this.earthquake,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Gempa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMagnitudeCard(context),
            const SizedBox(height: 16),
            _buildInfoCard(context),
            const SizedBox(height: 16),
            if (earthquake.shakemapUrl != null) _buildShakemapCard(context),
            if (earthquake.felt != null) ...[
              const SizedBox(height: 16),
              _buildFeltCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMagnitudeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getMagnitudeColor(earthquake.magnitude),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      earthquake.magnitude?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    earthquake.getMagnitudeCategory(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kedalaman: ${earthquake.depth} Km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    earthquake.potential ?? 'Tidak ada informasi potensi',
                    style: TextStyle(
                      color: earthquake.potential?.toLowerCase().contains('tsunami') == true
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w500,
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

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Gempa',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.location_on,
              'Lokasi',
              earthquake.region ?? 'Tidak diketahui',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Tanggal',
              earthquake.date ?? 'Tidak diketahui',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.access_time,
              'Waktu',
              earthquake.time ?? 'Tidak diketahui',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.my_location,
              'Koordinat',
              '${earthquake.latitude?.toStringAsFixed(2) ?? '-'}, ${earthquake.longitude?.toStringAsFixed(2) ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShakemapCard(BuildContext context) {
    final shakemapUrl = 'https://static.bmkg.go.id/${earthquake.shakemapUrl}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peta Guncangan (Shakemap)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: shakemapUrl,
                placeholder: (context, url) => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Gagal memuat shakemap'),
                      ],
                    ),
                  ),
                ),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeltCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Wilayah yang Merasakan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              earthquake.felt!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
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
}
