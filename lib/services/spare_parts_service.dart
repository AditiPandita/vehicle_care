import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/spare_part_model.dart';

class SparePartsService {
  SparePartsService({
    String? apiKey,
  }) : _apiKey =
            apiKey ??
            const String.fromEnvironment(
              'AUTOPARTS_API_KEY',
            );

  final String _apiKey;

  static const String _baseUrl =
      'https://auto-parts-catalog.apiprofile.com';

  static const int _englishLanguageId = 4;

  static const int _countryFilterId = 63;

  /*
   * AutoPartsAPI vehicle types:
   *
   * 1 = Passenger Car
   * 2 = Commercial Vehicle
   * 3 = Motorbike
   */
  int _getTypeId(String vehicleType) {
    final String type =
        vehicleType.trim().toLowerCase();

    if (type.contains('2 wheeler')) {
      return 3;
    }

    return 1;
  }

  // ------------------------------------------------------------
  // CACHE
  // ------------------------------------------------------------

  final Map<String, List<SparePart>>
      _partsCache =
      <String, List<SparePart>>{};

  final Map<String, List<Map<String, dynamic>>>
      _manufacturerCache =
      <String, List<Map<String, dynamic>>>{};

  final Map<String, List<Map<String, dynamic>>>
      _modelCache =
      <String, List<Map<String, dynamic>>>{};

  final Map<String, List<Map<String, dynamic>>>
      _vehicleCache =
      <String, List<Map<String, dynamic>>>{};

  final Map<int, dynamic> _categoryCache =
      <int, dynamic>{};

  // ------------------------------------------------------------
  // MAIN SEARCH
  // ------------------------------------------------------------

  Future<List<SparePart>> searchParts({
    required String brand,
    required String model,
    String query = '',
    String vehicleType = '4 Wheeler',
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw Exception(
        'AutoPartsAPI key is missing. '
        'Run the app with '
        '--dart-define=AUTOPARTS_API_KEY=YOUR_KEY',
      );
    }

    final String cleanBrand =
        brand.trim();

    final String cleanModel =
        model.trim();

    if (cleanBrand.isEmpty) {
      throw Exception(
        'Vehicle brand is empty.',
      );
    }

    if (cleanModel.isEmpty) {
      throw Exception(
        'Vehicle model is empty.',
      );
    }

    final String cacheKey =
        '${vehicleType.toLowerCase()}|'
        '${cleanBrand.toLowerCase()}|'
        '${cleanModel.toLowerCase()}';

    /*
     * If this vehicle has already been loaded,
     * search the cached parts instead of calling
     * the API again.
     */
    if (_partsCache.containsKey(cacheKey)) {
      return _filterParts(
        _partsCache[cacheKey]!,
        query,
      );
    }

    final int typeId =
        _getTypeId(vehicleType);

    // ----------------------------------------------------------
    // STEP 1: FIND MANUFACTURER
    // ----------------------------------------------------------

    final Map<String, dynamic>
        manufacturer =
        await _findManufacturer(
      brand: cleanBrand,
      typeId: typeId,
    );

    final int? manufacturerId =
        _extractId(
      manufacturer,
      <String>[
        'manuId',
        'manufacturerId',
        'ManufacturerId',
        'manufacturerID',
        'id',
        'Id',
      ],
    );

    if (manufacturerId == null) {
      throw Exception(
        'Manufacturer "$cleanBrand" was not found '
        'in AutoPartsAPI.',
      );
    }

    // ----------------------------------------------------------
    // STEP 2: FIND MODEL
    // ----------------------------------------------------------

    final Map<String, dynamic>
        modelResult =
        await _findModel(
      typeId: typeId,
      manufacturerId: manufacturerId,
      modelName: cleanModel,
    );

    final int? modelId =
        _extractId(
      modelResult,
      <String>[
        'modelId',
        'ModelId',
        'modelID',
        'id',
        'Id',
      ],
    );

    if (modelId == null) {
      throw Exception(
        'Model "$cleanModel" does not have a '
        'valid AutoPartsAPI model ID.',
      );
    }

    // ----------------------------------------------------------
    // STEP 3: FIND VEHICLE VARIANTS
    // ----------------------------------------------------------

    final List<Map<String, dynamic>>
        vehicles =
        await _getVehicles(
      typeId: typeId,
      modelId: modelId,
    );

    if (vehicles.isEmpty) {
      throw Exception(
        'No vehicle variants were found for '
        '$cleanBrand $cleanModel.',
      );
    }

    /*
     * AutoPartsAPI can return multiple variants
     * for the same model.
     *
     * We choose the first valid variant for now.
     *
     * Later we can add engine/variant selection
     * to the UI.
     */
    final Map<String, dynamic>
        selectedVehicle =
        vehicles.first;

    final int? vehicleId =
        _extractId(
      selectedVehicle,
      <String>[
        'vehicleId',
        'VehicleId',
        'vehicleID',
        'id',
        'Id',
      ],
    );

    if (vehicleId == null) {
      throw Exception(
        'Vehicle variant ID could not be determined '
        'for $cleanBrand $cleanModel.',
      );
    }

    // ----------------------------------------------------------
    // STEP 4: GET CATEGORIES
    // ----------------------------------------------------------

    final dynamic categoryResponse =
        await _getCategories(
      typeId: typeId,
      vehicleId: vehicleId,
    );

    final List<_ApiCategory>
        categories =
        _extractCategories(
      categoryResponse,
    );

    if (categories.isEmpty) {
      throw Exception(
        'No spare-part categories were found '
        'for $cleanBrand $cleanModel.',
      );
    }

    // ----------------------------------------------------------
    // STEP 5: SELECT USEFUL CATEGORIES
    // ----------------------------------------------------------

    final List<_ApiCategory>
        selectedCategories =
        _selectUsefulCategories(
      categories,
      query,
    );

    if (selectedCategories.isEmpty) {
      throw Exception(
        'No suitable spare-part categories were found.',
      );
    }

    // ----------------------------------------------------------
    // STEP 6: GET ARTICLES
    // ----------------------------------------------------------

    final List<SparePart> allParts =
        <SparePart>[];

    for (final _ApiCategory category
        in selectedCategories) {
      try {
        final List<SparePart>
            categoryParts =
            await _getArticles(
          typeId: typeId,
          vehicleId: vehicleId,
          categoryId: category.id,
        );

        allParts.addAll(
          categoryParts,
        );

        /*
         * AutoPartsAPI has a rate limit.
         * Keep a small delay between requests.
         */
        if (selectedCategories.last !=
            category) {
          await Future<void>.delayed(
            const Duration(
              milliseconds: 1100,
            ),
          );
        }
      } catch (_) {
        /*
         * If one category fails,
         * continue with other categories.
         */
      }
    }

    // ----------------------------------------------------------
    // REMOVE DUPLICATES
    // ----------------------------------------------------------

    final Map<String, SparePart>
        uniqueParts =
        <String, SparePart>{};

    for (final SparePart part
        in allParts) {
      final String partNumber =
          part.partNumber.trim();

      final String id =
          part.id.trim();

      final String key =
          partNumber.isNotEmpty
              ? partNumber.toLowerCase()
              : id.toLowerCase();

      if (key.isEmpty) {
        continue;
      }

      uniqueParts[key] = part;
    }

    final List<SparePart> result =
        uniqueParts.values.toList();

    _partsCache[cacheKey] = result;

    return _filterParts(
      result,
      query,
    );
  }

  // ------------------------------------------------------------
  // MANUFACTURER
  // ------------------------------------------------------------

  Future<Map<String, dynamic>>
      _findManufacturer({
    required String brand,
    required int typeId,
  }) async {
    final String cacheKey =
        typeId.toString();

    if (!_manufacturerCache
        .containsKey(cacheKey)) {
      final dynamic response =
          await _get(
        '/api/manufacturers/list/'
        'type-id/$typeId',
      );

      _manufacturerCache[cacheKey] =
          _extractList(response);
    }

    final String searchBrand =
        brand.trim().toLowerCase();

    final List<Map<String, dynamic>>
        manufacturers =
        _manufacturerCache[cacheKey]!;

    // Exact match.
    for (final Map<String, dynamic>
        manufacturer in manufacturers) {
      final String name =
          _extractString(
        manufacturer,
        <String>[
          'manuName',
          'manufacturerName',
          'ManufacturerName',
          'Make_Name',
          'makeName',
          'name',
          'Name',
        ],
      );

      if (name.toLowerCase() ==
          searchBrand) {
        return manufacturer;
      }
    }

    // Partial match.
    for (final Map<String, dynamic>
        manufacturer in manufacturers) {
      final String name =
          _extractString(
        manufacturer,
        <String>[
          'manuName',
          'manufacturerName',
          'ManufacturerName',
          'Make_Name',
          'makeName',
          'name',
          'Name',
        ],
      );

      final String lowerName =
          name.toLowerCase();

      if (lowerName.contains(searchBrand) ||
          searchBrand.contains(lowerName)) {
        return manufacturer;
      }
    }

    throw Exception(
      'Manufacturer "$brand" was not found.',
    );
  }

  // ------------------------------------------------------------
  // MODEL
  // ------------------------------------------------------------

  Future<Map<String, dynamic>>
      _findModel({
    required int typeId,
    required int manufacturerId,
    required String modelName,
  }) async {
    final String cacheKey =
        '$typeId-$manufacturerId';

    if (!_modelCache
        .containsKey(cacheKey)) {
      final dynamic response =
          await _get(
        '/api/models/list/'
        'type-id/$typeId/'
        'manufacturer-id/$manufacturerId/'
        'lang-id/$_englishLanguageId/'
        'country-filter-id/$_countryFilterId',
      );

      _modelCache[cacheKey] =
          _extractList(response);
    }

    final List<Map<String, dynamic>>
        models =
        _modelCache[cacheKey]!;

    final String searchModel =
        modelName.trim().toLowerCase();

    if (searchModel.isEmpty) {
      throw Exception(
        'Vehicle model is empty.',
      );
    }

    // ----------------------------------------------------------
    // 1. EXACT MATCH
    // ----------------------------------------------------------

    for (final Map<String, dynamic>
        model in models) {
      final String name =
          _getModelName(model);

      if (name.toLowerCase() ==
          searchModel) {
        return model;
      }
    }

    // ----------------------------------------------------------
    // 2. API NAME CONTAINS USER MODEL
    //
    // Example:
    // User model = 180
    // API model = CB 180
    // ----------------------------------------------------------

    final List<
            Map<String, dynamic>>
        containsMatches =
        <Map<String, dynamic>>[];

    for (final Map<String, dynamic>
        model in models) {
      final String name =
          _getModelName(model);

      if (name.isEmpty) {
        continue;
      }

      if (name
          .toLowerCase()
          .contains(searchModel)) {
        containsMatches.add(model);
      }
    }

    if (containsMatches.length == 1) {
      return containsMatches.first;
    }

    /*
     * If there are multiple matches, select the
     * shortest matching model name.
     *
     * Example:
     *
     * 180
     * CB 180
     * CB 180 ABS
     *
     * The shorter model is preferred.
     */
    if (containsMatches.isNotEmpty) {
      containsMatches.sort(
        (a, b) {
          return _getModelName(a)
              .length
              .compareTo(
                _getModelName(b).length,
              );
        },
      );

      return containsMatches.first;
    }

    // ----------------------------------------------------------
    // 3. NORMALIZED MATCH
    //
    // CB-180
    // CB 180
    // CB180
    //
    // become:
    //
    // cb180
    // ----------------------------------------------------------

    final String normalizedSearch =
        _normalizeModelName(
      searchModel,
    );

    for (final Map<String, dynamic>
        model in models) {
      final String name =
          _getModelName(model);

      if (name.isEmpty) {
        continue;
      }

      final String normalizedName =
          _normalizeModelName(name);

      if (normalizedName ==
          normalizedSearch) {
        return model;
      }
    }

    // ----------------------------------------------------------
    // 4. TOKEN MATCH
    // ----------------------------------------------------------

    final List<String>
        searchTokens =
        _modelTokens(searchModel);

    if (searchTokens.isNotEmpty) {
      final List<
              Map<String, dynamic>>
          tokenMatches =
          <Map<String, dynamic>>[];

      for (final Map<String, dynamic>
          model in models) {
        final String name =
            _getModelName(model);

        if (name.isEmpty) {
          continue;
        }

        final List<String>
            apiTokens =
            _modelTokens(name);

        bool allTokensPresent = true;

        for (final String token
            in searchTokens) {
          if (!apiTokens.contains(token)) {
            allTokensPresent = false;
            break;
          }
        }

        if (allTokensPresent) {
          tokenMatches.add(model);
        }
      }

      if (tokenMatches.isNotEmpty) {
        tokenMatches.sort(
          (a, b) {
            return _getModelName(a)
                .length
                .compareTo(
                  _getModelName(b).length,
                );
          },
        );

        return tokenMatches.first;
      }
    }

    // ----------------------------------------------------------
    // 5. NUMERIC MODEL FALLBACK
    //
    // Example:
    // 180
    //
    // Search for models containing the
    // numeric value as a separate/embedded token.
    // ----------------------------------------------------------

    final String numericPart =
        _extractNumbers(searchModel);

    if (numericPart.isNotEmpty) {
      final List<
              Map<String, dynamic>>
          numericMatches =
          <Map<String, dynamic>>[];

      for (final Map<String, dynamic>
          model in models) {
        final String name =
            _getModelName(model);

        if (name.isEmpty) {
          continue;
        }

        final String numbers =
            _extractNumbers(name);

        if (numbers == numericPart ||
            numbers.contains(
              numericPart,
            )) {
          numericMatches.add(model);
        }
      }

      if (numericMatches.isNotEmpty) {
        numericMatches.sort(
          (a, b) {
            return _getModelName(a)
                .length
                .compareTo(
                  _getModelName(b).length,
                );
          },
        );

        return numericMatches.first;
      }
    }

    // ----------------------------------------------------------
    // NO MATCH
    // ----------------------------------------------------------

    throw Exception(
      'Model "$modelName" was not found '
      'in the AutoPartsAPI catalogue for this manufacturer.',
    );
  }

  // ------------------------------------------------------------
  // GET MODEL NAME
  // ------------------------------------------------------------

  String _getModelName(
    Map<String, dynamic> model,
  ) {
    return _extractString(
      model,
      <String>[
        'modelName',
        'ModelName',
        'model',
        'Model',
        'name',
        'Name',
      ],
    ).trim();
  }

  // ------------------------------------------------------------
  // NORMALIZE MODEL
  // ------------------------------------------------------------

  String _normalizeModelName(
    String value,
  ) {
    return value
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
  }

  // ------------------------------------------------------------
  // MODEL TOKENS
  // ------------------------------------------------------------

  List<String> _modelTokens(
    String value,
  ) {
    return value
        .toLowerCase()
        .split(
          RegExp(r'[^a-z0-9]+'),
        )
        .where(
          (String token) =>
              token.isNotEmpty,
        )
        .toList();
  }

  // ------------------------------------------------------------
  // EXTRACT NUMBERS
  // ------------------------------------------------------------

  String _extractNumbers(
    String value,
  ) {
    return value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
  }

  // ------------------------------------------------------------
  // VEHICLE VARIANTS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>>
      _getVehicles({
    required int typeId,
    required int modelId,
  }) async {
    final String cacheKey =
        '$typeId-$modelId';

    if (_vehicleCache
        .containsKey(cacheKey)) {
      return _vehicleCache[cacheKey]!;
    }

    final dynamic response =
        await _get(
      '/api/types/type-id/$typeId/'
      'list-vehicles-id/$modelId/'
      'lang-id/$_englishLanguageId/'
      'country-filter-id/$_countryFilterId',
    );

    final List<
            Map<String, dynamic>>
        vehicles =
        _extractList(response);

    _vehicleCache[cacheKey] =
        vehicles;

    return vehicles;
  }

  // ------------------------------------------------------------
  // CATEGORIES
  // ------------------------------------------------------------

  Future<dynamic> _getCategories({
    required int typeId,
    required int vehicleId,
  }) async {
    if (_categoryCache
        .containsKey(vehicleId)) {
      return _categoryCache[vehicleId];
    }

    final dynamic response =
        await _get(
      '/api/category/type-id/$typeId/'
      'products-groups-variant-2/'
      '$vehicleId/'
      'lang-id/$_englishLanguageId',
    );

    _categoryCache[vehicleId] =
        response;

    return response;
  }

  // ------------------------------------------------------------
  // ARTICLES
  // ------------------------------------------------------------

  Future<List<SparePart>> _getArticles({
    required int typeId,
    required int vehicleId,
    required int categoryId,
  }) async {
    final dynamic response =
        await _get(
      '/api/articles/list/'
      'type-id/$typeId/'
      'vehicle-id/$vehicleId/'
      'category-id/$categoryId/'
      'lang-id/$_englishLanguageId',
    );

    return _parseParts(
      response,
    );
  }

  // ------------------------------------------------------------
  // HTTP GET
  // ------------------------------------------------------------

  Future<dynamic> _get(
    String path,
  ) async {
    final Uri url =
        Uri.parse(
      '$_baseUrl$path',
    );

    final http.Response response =
        await http.get(
      url,
      headers: <String, String>{
        'Accept': 'application/json',
        'x-apiprofile-key': _apiKey,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String message =
          'AutoPartsAPI request failed '
          '(${response.statusCode}).';

      try {
        final dynamic decoded =
            jsonDecode(
          response.body,
        );

        if (decoded is Map) {
          final dynamic apiMessage =
              decoded['message'] ??
              decoded['Message'] ??
              decoded['error'] ??
              decoded['Error'];

          if (apiMessage != null &&
              apiMessage
                  .toString()
                  .trim()
                  .isNotEmpty) {
            message =
                apiMessage.toString();
          }
        }
      } catch (_) {
        // Keep default error message.
      }

      throw Exception(message);
    }

    if (response.body.trim().isEmpty) {
      return <dynamic>[];
    }

    return jsonDecode(
      response.body,
    );
  }

  // ------------------------------------------------------------
  // EXTRACT LIST
  // ------------------------------------------------------------

  List<Map<String, dynamic>>
      _extractList(
    dynamic decoded,
  ) {
    dynamic data = decoded;

    if (decoded is Map) {
      data =
          decoded['results'] ??
          decoded['Results'] ??
          decoded['data'] ??
          decoded['Data'] ??
          decoded['items'] ??
          decoded['Items'] ??
          decoded['manufacturers'] ??
          decoded['Manufacturers'] ??
          decoded['models'] ??
          decoded['Models'] ??
          decoded['vehicles'] ??
          decoded['Vehicles'] ??
          decoded['articles'] ??
          decoded['Articles'] ??
          decoded['parts'] ??
          decoded['Parts'] ??
          [];
    }

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (Map item) =>
              Map<String, dynamic>.from(
            item,
          ),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // PARSE PARTS
  // ------------------------------------------------------------

  List<SparePart> _parseParts(
    dynamic decoded,
  ) {
    final List<
            Map<String, dynamic>>
        rawParts =
        _extractList(decoded);

    return rawParts
        .map(
          SparePart.fromJson,
        )
        .where(
          (SparePart part) =>
              part.name
                  .trim()
                  .isNotEmpty,
        )
        .toList();
  }

  // ------------------------------------------------------------
  // CATEGORIES
  // ------------------------------------------------------------

  List<_ApiCategory>
      _extractCategories(
    dynamic decoded,
  ) {
    final List<_ApiCategory>
        categories =
        <_ApiCategory>[];

    void visit(
      dynamic node,
      String? parentName,
    ) {
      if (node is List) {
        for (final dynamic item
            in node) {
          visit(
            item,
            parentName,
          );
        }

        return;
      }

      if (node is! Map) {
        return;
      }

      final Map<String, dynamic>
          map =
          Map<String, dynamic>.from(
        node,
      );

      final int? id =
          _extractId(
        map,
        <String>[
          'categoryId',
          'CategoryId',
          'categoryID',
          'productGroupId',
          'ProductGroupId',
          'productGroupID',
          'id',
          'Id',
        ],
      );

      final String name =
          _extractString(
        map,
        <String>[
          'categoryName',
          'CategoryName',
          'productGroupName',
          'ProductGroupName',
          'name',
          'Name',
          'label',
          'Label',
        ],
      ).trim();

      if (id != null &&
          name.isNotEmpty) {
        categories.add(
          _ApiCategory(
            id: id,
            name: name,
            parentName:
                parentName,
          ),
        );
      }

      for (final MapEntry<String, dynamic>
          entry in map.entries) {
        if (entry.value is Map ||
            entry.value is List) {
          visit(
            entry.value,
            name.isNotEmpty
                ? name
                : parentName,
          );
        }
      }
    }

    visit(
      decoded,
      null,
    );

    final Map<int, _ApiCategory>
        unique =
        <int, _ApiCategory>{};

    for (final _ApiCategory category
        in categories) {
      unique[category.id] =
          category;
    }

    return unique.values.toList();
  }

  // ------------------------------------------------------------
  // SELECT USEFUL CATEGORIES
  // ------------------------------------------------------------

  List<_ApiCategory>
      _selectUsefulCategories(
    List<_ApiCategory> categories,
    String query,
  ) {
    final String search =
        query.trim().toLowerCase();

    // Search-specific categories.
    if (search.isNotEmpty) {
      final List<_ApiCategory>
          matching =
          categories.where(
        (_ApiCategory category) {
          final String text =
              '${category.name} '
                      '${category.parentName ?? ''}'
                  .toLowerCase();

          return text.contains(search);
        },
      ).toList();

      if (matching.isNotEmpty) {
        return matching
            .take(8)
            .toList();
      }
    }

    // Common service categories.
    const List<String>
        preferredKeywords = [
      'brake',
      'filter',
      'clutch',
      'engine',
      'oil',
      'ignition',
      'suspension',
      'steering',
      'belt',
      'cooling',
    ];

    final List<_ApiCategory>
        preferred =
        categories.where(
      (_ApiCategory category) {
        final String text =
            '${category.name} '
                    '${category.parentName ?? ''}'
                .toLowerCase();

        for (final String keyword
            in preferredKeywords) {
          if (text.contains(keyword)) {
            return true;
          }
        }

        return false;
      },
    ).toList();

    if (preferred.isNotEmpty) {
      return preferred
          .take(8)
          .toList();
    }

    // Fallback.
    return categories
        .take(5)
        .toList();
  }

  // ------------------------------------------------------------
  // FILTER PARTS
  // ------------------------------------------------------------

  List<SparePart> _filterParts(
    List<SparePart> parts,
    String query,
  ) {
    final String search =
        query.trim().toLowerCase();

    if (search.isEmpty) {
      return parts;
    }

    return parts.where(
      (SparePart part) {
        final String name =
            part.name.toLowerCase();

        final String partNumber =
            part.partNumber
                .toLowerCase();

        return name.contains(search) ||
            partNumber.contains(search);
      },
    ).toList();
  }

  // ------------------------------------------------------------
  // EXTRACT ID
  // ------------------------------------------------------------

  int? _extractId(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final String key
        in keys) {
      final dynamic value =
          data[key];

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      if (value != null) {
        final int? parsed =
            int.tryParse(
          value.toString(),
        );

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  // ------------------------------------------------------------
  // EXTRACT STRING
  // ------------------------------------------------------------

  String _extractString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final String key
        in keys) {
      final dynamic value =
          data[key];

      if (value != null &&
          value
              .toString()
              .trim()
              .isNotEmpty) {
        return value
            .toString()
            .trim();
      }
    }

    return '';
  }
}

// ============================================================
// API CATEGORY MODEL
// ============================================================

class _ApiCategory {
  final int id;
  final String name;
  final String? parentName;

  const _ApiCategory({
    required this.id,
    required this.name,
    this.parentName,
  });
}