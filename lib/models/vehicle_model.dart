class Vehicle {
  final String id;
  final String vehicleType;
  final String registrationNumber;
  final String brand;
  final String model;
  final int year;
  final double currentOdometer;
  final DateTime createdDate;

  const Vehicle({
    required this.id,
    required this.vehicleType,
    required this.registrationNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentOdometer,
    required this.createdDate,
  });

  String get displayName {
    final combinedName = '$brand $model'.trim();

    if (combinedName.isNotEmpty) {
      return combinedName;
    }

    if (model.trim().isNotEmpty) {
      return model;
    }

    if (brand.trim().isNotEmpty) {
      return brand;
    }

    return 'My Vehicle';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'registrationNumber': registrationNumber,
      'brand': brand,
      'model': model,
      'year': year,
      'currentOdometer': currentOdometer,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] ?? '').toString(),
      vehicleType: (json['vehicleType'] ?? '').toString(),
      registrationNumber:
          (json['registrationNumber'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      model: (
        json['model'] ??
        json['vehicleName'] ??
        ''
      ).toString(),
      year: (json['year'] as num?)?.toInt() ?? 0,
      currentOdometer:
          (json['currentOdometer'] as num?)?.toDouble() ?? 0.0,

      // Old saved vehicles ke liye fallback
      // DateTime.now() use hoga agar createdDate nahi mila.
      createdDate: DateTime.tryParse(
            json['createdDate']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}