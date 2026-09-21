class ServiceLog {
  final String id;
  final String vehicleId;
  final DateTime serviceDate;
  final double odometerReading;
  final String serviceCenter;
  final double labourCost;
  final List<String> spareParts;
  final double sparePartsCost;
  final String notes;

  const ServiceLog({
    required this.id,
    required this.vehicleId,
    required this.serviceDate,
    required this.odometerReading,
    required this.serviceCenter,
    required this.labourCost,
    required this.spareParts,
    required this.sparePartsCost,
    required this.notes,
  });

  double get totalCost => labourCost + sparePartsCost;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceDate': serviceDate.toIso8601String(),
      'odometerReading': odometerReading,
      'serviceCenter': serviceCenter,
      'labourCost': labourCost,
      'spareParts': spareParts,
      'sparePartsCost': sparePartsCost,
      'notes': notes,
    };
  }

  factory ServiceLog.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceLog(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      serviceDate: DateTime.parse(
        json['serviceDate'] as String,
      ),
      odometerReading:
          (json['odometerReading'] as num).toDouble(),
      serviceCenter: json['serviceCenter'] as String,
      labourCost:
          (json['labourCost'] as num).toDouble(),
      spareParts: List<String>.from(
        json['spareParts'] as List<dynamic>,
      ),
      sparePartsCost:
          (json['sparePartsCost'] as num).toDouble(),
      notes: json['notes'] as String,
    );
  }
}