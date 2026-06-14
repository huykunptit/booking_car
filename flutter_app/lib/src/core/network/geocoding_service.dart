import 'package:dio/dio.dart';

class GeocodingResult {
  final String address;
  final double lat;
  final double lng;
  final String? refId;

  const GeocodingResult({
    required this.address,
    required this.lat,
    required this.lng,
    this.refId,
  });
}

class GeocodingService {
  static const String _apiKey = '93f3886be392ad743f665ac2200b40b7';
  
  static final _dio = Dio(BaseOptions(
    baseUrl: 'https://maps.vietmap.vn/api',
    headers: {
      'User-Agent': 'GoRento/1.0 (vehicle.booking.system)',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get('/reverse/v4', queryParameters: {
        'apikey': _apiKey,
        'lat': lat,
        'lng': lng,
        'display_type': 6,
      });
      final data = response.data as List<dynamic>;
      if (data.isNotEmpty) {
        return data[0]['display']?.toString() ??
            '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }
      return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    } catch (_) {
      return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
  }

  static Future<List<GeocodingResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get('/autocomplete/v4', queryParameters: {
        'apikey': _apiKey,
        'text': query.trim(),
        'display_type': 6,
      });
      final data = response.data as List<dynamic>;
      return data.map((item) {
        return GeocodingResult(
          address: item['display']?.toString() ?? '',
          lat: 0.0, // Autocomplete v4 does not return lat/lng directly
          lng: 0.0,
          refId: item['ref_id']?.toString(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<GeocodingResult?> resolvePlace(String refId) async {
    try {
      final response = await _dio.get('/place/v4', queryParameters: {
        'apikey': _apiKey,
        'refid': refId,
      });
      final data = response.data as Map<String, dynamic>;
      final lat = double.tryParse(data['lat']?.toString() ?? '') ?? 0.0;
      final lng = double.tryParse(data['lng']?.toString() ?? '') ?? 0.0;
      return GeocodingResult(
        address: data['display']?.toString() ?? '',
        lat: lat,
        lng: lng,
        refId: refId,
      );
    } catch (_) {
      return null;
    }
  }
}
