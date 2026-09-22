import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/petrol_log_model.dart';

class PetrolLogService {
  static const String _storageKey = 'petrol_logs';

  Future<List<PetrolLog>> getPetrolLogs(
    String vehicleId,
  ) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? storedData =
        preferences.getString(_storageKey);

    if (storedData == null ||
        storedData.isEmpty) {
      return [];
    }

    final dynamic decodedData =
        jsonDecode(storedData);

    if (decodedData is! List) {
      return [];
    }

    final List<PetrolLog> allLogs =
        decodedData
            .whereType<Map>()
            .map(
              (item) => PetrolLog.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

    final List<PetrolLog> vehicleLogs =
        allLogs
            .where(
              (log) => log.vehicleId == vehicleId,
            )
            .toList();

    // Latest petrol entry first.
    vehicleLogs.sort(
      (a, b) => b.petrolDate.compareTo(
        a.petrolDate,
      ),
    );

    return vehicleLogs;
  }

  Future<void> savePetrolLog(
    PetrolLog petrolLog,
  ) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? storedData =
        preferences.getString(_storageKey);

    List<PetrolLog> allLogs = [];

    if (storedData != null &&
        storedData.isNotEmpty) {
      final dynamic decodedData =
          jsonDecode(storedData);

      if (decodedData is List) {
        allLogs = decodedData
            .whereType<Map>()
            .map(
              (item) => PetrolLog.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    }

    allLogs.add(petrolLog);

    await preferences.setString(
      _storageKey,
      jsonEncode(
        allLogs
            .map(
              (log) => log.toJson(),
            )
            .toList(),
      ),
    );
  }

  Future<void> deletePetrolLog(
    String logId,
  ) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? storedData =
        preferences.getString(_storageKey);

    if (storedData == null ||
        storedData.isEmpty) {
      return;
    }

    final dynamic decodedData =
        jsonDecode(storedData);

    if (decodedData is! List) {
      return;
    }

    final List<PetrolLog> allLogs =
        decodedData
            .whereType<Map>()
            .map(
              (item) => PetrolLog.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where(
              (log) => log.id != logId,
            )
            .toList();

    await preferences.setString(
      _storageKey,
      jsonEncode(
        allLogs
            .map(
              (log) => log.toJson(),
            )
            .toList(),
      ),
    );
  }
}