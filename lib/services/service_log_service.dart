import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/service_log_model.dart';

class ServiceLogService {
  static const String _storageKey = 'service_logs';

  Future<List<ServiceLog>> getServiceLogs(
    String vehicleId,
  ) async {
    final preferences =
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

    final List<ServiceLog> allLogs =
        decodedData
            .whereType<Map>()
            .map(
              (item) => ServiceLog.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

    final List<ServiceLog> vehicleLogs =
        allLogs
            .where(
              (log) => log.vehicleId == vehicleId,
            )
            .toList();

    vehicleLogs.sort(
      (a, b) => b.serviceDate.compareTo(
        a.serviceDate,
      ),
    );

    return vehicleLogs;
  }

  Future<void> saveServiceLog(
    ServiceLog serviceLog,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final String? storedData =
        preferences.getString(_storageKey);

    List<ServiceLog> allLogs = [];

    if (storedData != null &&
        storedData.isNotEmpty) {
      final dynamic decodedData =
          jsonDecode(storedData);

      if (decodedData is List) {
        allLogs = decodedData
            .whereType<Map>()
            .map(
              (item) => ServiceLog.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    }

    allLogs.add(serviceLog);

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

  Future<void> deleteServiceLog(
    String logId,
  ) async {
    final preferences =
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

    final List<ServiceLog> allLogs =
        decodedData
            .whereType<Map>()
            .map(
              (item) => ServiceLog.fromJson(
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