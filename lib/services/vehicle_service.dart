import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle_model.dart';

class VehicleService {
  static const String _vehiclesKey = 'vehicles';

  Future<List<Vehicle>> getVehicles() async {
    final preferences = await SharedPreferences.getInstance();

    final storedVehicles = preferences.getString(_vehiclesKey);

    if (storedVehicles == null || storedVehicles.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData =
        jsonDecode(storedVehicles) as List<dynamic>;

    return decodedData
        .map(
          (item) => Vehicle.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    final vehicles = await getVehicles();

    vehicles.add(vehicle);

    await _saveAllVehicles(vehicles);
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final vehicles = await getVehicles();

    final index = vehicles.indexWhere(
      (item) => item.id == vehicle.id,
    );

    if (index == -1) {
      return;
    }

    vehicles[index] = vehicle;

    await _saveAllVehicles(vehicles);
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final vehicles = await getVehicles();

    vehicles.removeWhere(
      (vehicle) => vehicle.id == vehicleId,
    );

    await _saveAllVehicles(vehicles);
  }

  Future<void> _saveAllVehicles(
    List<Vehicle> vehicles,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      vehicles.map((vehicle) => vehicle.toJson()).toList(),
    );

    await preferences.setString(
      _vehiclesKey,
      encodedData,
    );
  }
}