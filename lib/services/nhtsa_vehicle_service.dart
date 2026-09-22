import 'dart:convert';

import 'package:http/http.dart' as http;

class NhtsaVehicleItem {
  final String id;
  final String brand;
  final String model;

  const NhtsaVehicleItem({
    required this.id,
    required this.brand,
    required this.model,
  });

  String get displayName => '$brand $model';
}

class NhtsaVehicleService {
  static const String _baseUrl =
      'https://vpic.nhtsa.dot.gov/api/vehicles';

  Future<List<String>> getBrands(
    String vehicleType,
  ) async {
    final String type =
        vehicleType == '2 Wheeler'
            ? 'motorcycle'
            : 'car';

    final Uri url = Uri.parse(
      '$_baseUrl/GetMakesForVehicleType/$type'
      '?format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load vehicle brands.',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final List<dynamic> results =
        data['Results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => (
            item['MakeName'] ??
                    item['Make_Name'] ??
                    '')
                .toString()
                .trim(),
        )
        .where(
          (brand) => brand.isNotEmpty,
        )
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<NhtsaVehicleItem>> getModels(
    String brand,
  ) async {
    final Uri url = Uri.parse(
      '$_baseUrl/GetModelsForMake/'
      '${Uri.encodeComponent(brand)}'
      '?format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load vehicle models.',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final List<dynamic> results =
        data['Results'] as List<dynamic>? ?? [];

    return results
        .map((item) {
          final Map<String, dynamic> result =
              Map<String, dynamic>.from(
            item as Map,
          );

          return NhtsaVehicleItem(
            id: (
              result['Model_ID'] ??
                      result['ModelId'] ??
                      '')
                .toString(),
            brand: (
              result['Make_Name'] ??
                      brand)
                .toString(),
            model: (
              result['Model_Name'] ??
                      result['ModelName'] ??
                      '')
                .toString()
                .trim(),
          );
        })
        .where(
          (item) => item.model.isNotEmpty,
        )
        .toList();
  }
}