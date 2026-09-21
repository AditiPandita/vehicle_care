import 'dart:convert';
import 'dart:io';

import '../models/spare_part_model.dart';

class SparePartsService {
  SparePartsService({
    this.baseUrl = '',
  });

  /// Put your actual backend/API base URL here.
  ///
  /// Example:
  /// https://your-fastapi-server.com
  ///
  /// Do NOT put an unverified 99RPM endpoint here.
  final String baseUrl;

  /// Searches spare parts for the selected vehicle.
  ///
  /// Expected backend endpoint:
  ///
  /// GET /spare-parts/search
  ///
  /// Query parameters:
  /// brand
  /// model
  /// query
  Future<List<SparePart>> searchParts({
    required String brand,
    required String model,
    String query = '',
  }) async {
    if (baseUrl.trim().isEmpty) {
      return _demoParts(query);
    }

    final String cleanBaseUrl =
        baseUrl.replaceFirst(
      RegExp(r'/$'),
      '',
    );

    final Uri uri = Uri.parse(
      '$cleanBaseUrl/spare-parts/search',
    ).replace(
      queryParameters: {
        'brand': brand,
        'model': model,
        if (query.trim().isNotEmpty)
          'query': query.trim(),
      },
    );

    final HttpClient client = HttpClient();

    try {
      final HttpClientRequest request =
          await client.getUrl(uri);

      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/json',
      );

      final HttpClientResponse response =
          await request.close();

      final String responseBody =
          await response.transform(
        utf8.decoder,
      ).join();

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Spare parts API returned '
          '${response.statusCode}',
        );
      }

      final dynamic decoded =
          jsonDecode(responseBody);

      return _parseResponse(decoded);
    } finally {
      client.close();
    }
  }

  List<SparePart> _parseResponse(
    dynamic decoded,
  ) {
    dynamic data = decoded;

    if (decoded is Map<String, dynamic>) {
      data = decoded['parts'] ??
          decoded['spare_parts'] ??
          decoded['results'] ??
          decoded['data'] ??
          [];
    }

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => SparePart.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (part) => part.name.trim().isNotEmpty,
        )
        .toList();
  }

  /// Temporary data so that the complete UI can be
  /// tested before the real 99RPM/backend endpoint
  /// is connected.
  ///
  /// Remove this fallback once the real API is connected.
  List<SparePart> _demoParts(String query) {
    const List<SparePart> parts = [
      SparePart(
        id: 'demo-001',
        name: 'Front Brake Pad Set',
        partNumber: '36DJ010',
        price: 320,
      ),
      SparePart(
        id: 'demo-002',
        name: 'Rear Brake Pad Set',
        partNumber: '36DJ020',
        price: 340,
      ),
      SparePart(
        id: 'demo-003',
        name: 'Brake Shoe',
        partNumber: '36DJ030',
        price: 280,
      ),
      SparePart(
        id: 'demo-004',
        name: 'Air Filter',
        partNumber: '36AF010',
        price: 450,
      ),
      SparePart(
        id: 'demo-005',
        name: 'Oil Filter',
        partNumber: '36OF010',
        price: 280,
      ),
      SparePart(
        id: 'demo-006',
        name: 'Clutch Plate Set',
        partNumber: '36CP010',
        price: 1250,
      ),
    ];

    if (query.trim().isEmpty) {
      return parts;
    }

    final String search =
        query.trim().toLowerCase();

    return parts.where((part) {
      return part.name
              .toLowerCase()
              .contains(search) ||
          part.partNumber
              .toLowerCase()
              .contains(search);
    }).toList();
  }
}