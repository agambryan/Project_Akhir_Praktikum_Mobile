import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _earthquakeNotificationsEnabled = true;
  bool _autoRefreshEnabled = true;
  bool _useGPS = false;
  String _temperatureUnit = 'C';
  String _themeMode = 'system';
  String _language = 'id';
  double _minMagnitude = 5.0;
  int _refreshInterval = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = PreferencesService.getNotificationsEnabled();
      _earthquakeNotificationsEnabled =
          PreferencesService.getEarthquakeNotificationsEnabled();
      _autoRefreshEnabled = PreferencesService.getAutoRefreshEnabled();
      _useGPS = PreferencesService.getUseGPS();
      _temperatureUnit = PreferencesService.getTemperatureUnit();
      _themeMode = PreferencesService.getThemeMode();
      _language = PreferencesService.getLanguage();
      _minMagnitude = PreferencesService.getMinMagnitude();
      _refreshInterval = PreferencesService.getRefreshInterval();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          _buildSection('Notifikasi'),
          _buildSwitchTile(
            'Aktifkan Notifikasi',
            'Terima notifikasi untuk peringatan cuaca',
            _notificationsEnabled,
            (value) async {
              setState(() => _notificationsEnabled = value);
              await PreferencesService.setNotificationsEnabled(value);
            },
          ),
          _buildSwitchTile(
            'Notifikasi Gempa',
            'Terima notifikasi untuk gempa bumi',
            _earthquakeNotificationsEnabled,
            (value) async {
              setState(() => _earthquakeNotificationsEnabled = value);
              await PreferencesService.setEarthquakeNotificationsEnabled(value);
            },
          ),
          ListTile(
            title: const Text('Magnitudo Minimum'),
            subtitle: Text(
                'Notifikasi untuk gempa M ≥ ${_minMagnitude.toStringAsFixed(1)}'),
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: _minMagnitude,
                min: 3.0,
                max: 7.0,
                divisions: 8,
                label: _minMagnitude.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() => _minMagnitude = value);
                },
                onChangeEnd: (value) async {
                  await PreferencesService.setMinMagnitude(value);
                },
              ),
            ),
          ),
          const Divider(),
          _buildSection('Tampilan'),
          _buildSegmentedTile<String>(
            'Tema',
            [
              ('System', 'system'),
              ('Terang', 'light'),
              ('Gelap', 'dark'),
            ],
            _themeMode,
            (value) async {
              setState(() => _themeMode = value);
              await PreferencesService.setThemeMode(value);
            },
          ),
          _buildSegmentedTile<String>(
            'Unit Temperatur',
            [
              ('Celsius (°C)', 'C'),
              ('Fahrenheit (°F)', 'F'),
            ],
            _temperatureUnit,
            (value) async {
              setState(() => _temperatureUnit = value);
              await PreferencesService.setTemperatureUnit(value);
            },
          ),
          _buildSegmentedTile<String>(
            'Bahasa',
            [
              ('Bahasa Indonesia', 'id'),
              ('English', 'en'),
            ],
            _language,
            (value) async {
              setState(() => _language = value);
              await PreferencesService.setLanguage(value);
            },
          ),
          const Divider(),
          _buildSection('Lokasi'),
          _buildSwitchTile(
            'Gunakan GPS',
            'Deteksi lokasi otomatis menggunakan GPS',
            _useGPS,
            (value) async {
              setState(() => _useGPS = value);
              await PreferencesService.setUseGPS(value);
            },
          ),
          const Divider(),
          _buildSection('Data & Sinkronisasi'),
          _buildSwitchTile(
            'Perbarui Otomatis',
            'Perbarui data secara otomatis',
            _autoRefreshEnabled,
            (value) async {
              setState(() => _autoRefreshEnabled = value);
              await PreferencesService.setAutoRefreshEnabled(value);
            },
          ),
          ListTile(
            title: const Text('Interval Pembaruan'),
            subtitle: Text('Perbarui setiap $_refreshInterval menit'),
            trailing: DropdownButton<int>(
              value: _refreshInterval,
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 menit')),
                DropdownMenuItem(value: 30, child: Text('30 menit')),
                DropdownMenuItem(value: 60, child: Text('1 jam')),
                DropdownMenuItem(value: 120, child: Text('2 jam')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _refreshInterval = value);
                  await PreferencesService.setRefreshInterval(value);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Hapus Cache'),
            subtitle: const Text('Hapus data yang tersimpan'),
            trailing: const Icon(Icons.delete_outline),
            onTap: () => _showClearCacheDialog(),
          ),
          const Divider(),
          _buildSection('Tentang'),
          const ListTile(
            title: Text('Versi Aplikasi'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('Sumber Data'),
            subtitle: Text(
                'BMKG (Badan Meteorologi, Klimatologi, dan Geofisika)'),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _showResetDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Reset Pengaturan'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSegmentedTile<T>(
    String title,
    List<(String, T)> options,
    T selectedValue,
    ValueChanged<T> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ...options.map((option) {
          final isSelected = option.$2 == selectedValue;
          return ListTile(
            title: Text(option.$1),
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            onTap: () => onChanged(option.$2),
          );
        }),
      ],
    );
  }

  void _showClearCacheDialog() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Cache'),
        content:
            const Text('Apakah Anda yakin ingin menghapus semua data cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await LocalStorageService().clearAll();
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Cache berhasil dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text(
            'Apakah Anda yakin ingin mereset semua pengaturan ke default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await PreferencesService.resetToDefaults();
              _loadSettings();
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Pengaturan berhasil direset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
