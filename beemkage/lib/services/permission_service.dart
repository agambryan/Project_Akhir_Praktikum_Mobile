import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  static Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  /// Check if location service is enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check permission
      final permission = await Permission.location.status;
      if (permission.isDenied) {
        final result = await requestLocationPermission();
        if (result.isDenied) {
          throw Exception('Location permission denied.');
        }
      }

      if (permission.isPermanentlyDenied) {
        throw Exception('Location permission permanently denied.');
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      developer.log('Error getting location: $e', name: 'LocationService');
      return null;
    }
  }

  /// Get last known position
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      developer.log('Error getting last known position: $e',
          name: 'LocationService');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Get nearest city name from coordinates (simplified version)
  static String getNearestCity(double latitude, double longitude) {
    // Daftar kota besar di Indonesia dengan koordinat
    final cities = {
      'Jakarta': {'lat': -6.2088, 'lon': 106.8456},
      'Surabaya': {'lat': -7.2575, 'lon': 112.7521},
      'Bandung': {'lat': -6.9175, 'lon': 107.6191},
      'Medan': {'lat': 3.5952, 'lon': 98.6722},
      'Semarang': {'lat': -6.9667, 'lon': 110.4167},
      'Makassar': {'lat': -5.1477, 'lon': 119.4327},
      'Palembang': {'lat': -2.9761, 'lon': 104.7754},
      'Yogyakarta': {'lat': -7.7956, 'lon': 110.3695},
      'Malang': {'lat': -7.9797, 'lon': 112.6304},
      'Denpasar': {'lat': -8.6705, 'lon': 115.2126},
      'Padang': {'lat': -0.9471, 'lon': 100.4172},
      'Banjarmasin': {'lat': -3.3194, 'lon': 114.5900},
      'Pekanbaru': {'lat': 0.5071, 'lon': 101.4478},
      'Manado': {'lat': 1.4748, 'lon': 124.8421},
      'Balikpapan': {'lat': -1.2379, 'lon': 116.8529},
    };

    String nearestCity = 'Unknown';
    double minDistance = double.infinity;

    cities.forEach((city, coords) {
      final distance = calculateDistance(
        latitude,
        longitude,
        coords['lat']!,
        coords['lon']!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    });

    return nearestCity;
  }

  /// Open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}

class CameraService {
  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  static Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Check and request camera permission
  static Future<bool> checkAndRequestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    return status.isGranted;
  }
}

class StorageService {
  /// Check if storage permission is granted
  static Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// Request storage permission
  static Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  /// Check and request storage permission
  static Future<bool> checkAndRequestStoragePermission() async {
    var status = await Permission.storage.status;

    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }
}

class NotificationService {
  /// Check if notification permission is granted
  static Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission
  static Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  /// Check and request notification permission
  static Future<bool> checkAndRequestNotificationPermission() async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    return status.isGranted;
  }
}
