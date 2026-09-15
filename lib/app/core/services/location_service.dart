import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String city;
  final String country;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.city,
    required this.country,
  });
}

class LocationSuggestion {
  final String displayName;
  final String primaryText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;

  LocationSuggestion({
    required this.displayName,
    required this.primaryText,
    required this.secondaryText,
    this.latitude,
    this.longitude,
  });
}

class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'User-Agent': 'BummpsApp/1.0 (dating-app-location)',
        'Accept': 'application/json',
      },
    ),
  );

  /// Fetch the current device GPS location and reverse geocode to readable address
  Future<LocationResult> getCurrentLocation() async {
    // 1. Check if location services are enabled on device
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled on your device. Please turn on GPS in your settings.');
    }

    // 2. Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied. Please allow location access to auto-detect your city.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in your device settings.');
    }

    // 3. Get accurate current GPS position
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );

    // 4. Reverse geocode coordinates into city and country
    String city = '';
    String country = '';
    String formattedAddress = '';

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        final locality = place.locality?.trim();
        final subAdmin = place.subAdministrativeArea?.trim();
        final admin = place.administrativeArea?.trim();
        final countryName = place.country?.trim() ?? '';

        city = (locality != null && locality.isNotEmpty)
            ? locality
            : ((subAdmin != null && subAdmin.isNotEmpty) ? subAdmin : (admin ?? ''));

        country = countryName;

        final parts = <String>[];
        if (city.isNotEmpty) parts.add(city);
        if (admin != null && admin.isNotEmpty && admin != city) parts.add(admin);
        if (country.isNotEmpty) parts.add(country);

        formattedAddress = parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
      }
    } catch (e) {
      debugPrint('[LocationService] Reverse geocode error: $e');
    }

    if (formattedAddress.isEmpty) {
      formattedAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      formattedAddress: formattedAddress,
      city: city,
      country: country,
    );
  }

  /// Search address / city autocomplete suggestions using OpenStreetMap Nominatim
  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': cleanQuery,
          'format': 'json',
          'addressdetails': '1',
          'limit': '6',
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data as List;
        final suggestions = <LocationSuggestion>[];

        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final address = item['address'] as Map<String, dynamic>? ?? {};
            final displayName = item['display_name']?.toString() ?? '';
            final lat = double.tryParse(item['lat']?.toString() ?? '');
            final lon = double.tryParse(item['lon']?.toString() ?? '');

            final city = address['city'] ??
                address['town'] ??
                address['village'] ??
                address['municipality'] ??
                address['county'] ??
                address['state_district'] ??
                address['suburb'] ??
                item['name'];

            final state = address['state'] ?? address['region'];
            final country = address['country'] ?? '';

            final primary = city?.toString() ?? item['name']?.toString() ?? '';
            final secondaryList = <String>[];
            if (state != null && state.toString().isNotEmpty && state != primary) {
              secondaryList.add(state.toString());
            }
            if (country.toString().isNotEmpty && country != primary) {
              secondaryList.add(country.toString());
            }

            final secondary = secondaryList.join(', ');
            final conciseName = secondary.isNotEmpty ? '$primary, $secondary' : (primary.isNotEmpty ? primary : displayName);

            suggestions.add(
              LocationSuggestion(
                displayName: conciseName,
                primaryText: primary.isNotEmpty ? primary : displayName,
                secondaryText: secondary,
                latitude: lat,
                longitude: lon,
              ),
            );
          }
        }
        return suggestions;
      }
    } catch (e) {
      debugPrint('[LocationService] Autocomplete suggestions error: $e');
    }
    return [];
  }
}
