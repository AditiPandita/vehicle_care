class PetrolLog {
  final String id;
  final String vehicleId;
  final DateTime petrolDate;
  final double odometerReading;
  final double fuelQuantity;
  final double pricePerLitre;
  final double totalCost;
  final String petrolStation;
  final String notes;

  const PetrolLog({
    required this.id,
    required this.vehicleId,
    required this.petrolDate,
    required this.odometerReading,
    required this.fuelQuantity,
    required this.pricePerLitre,
    required this.totalCost,
    required this.petrolStation,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'petrolDate': petrolDate.toIso8601String(),
      'odometerReading': odometerReading,
      'fuelQuantity': fuelQuantity,
      'pricePerLitre': pricePerLitre,
      'totalCost': totalCost,
      'petrolStation': petrolStation,
      'notes': notes,
    };
  }

  factory PetrolLog.fromJson(
    Map<String, dynamic> json,
  ) {
    return PetrolLog(
      id: json['id']?.toString() ?? '',
      vehicleId:
          json['vehicleId']?.toString() ?? '',
      petrolDate: DateTime.tryParse(
            json['petrolDate']?.toString() ?? '',
          ) ??
          DateTime.now(),
      odometerReading:
          (json['odometerReading'] as num?)
                  ?.toDouble() ??
              0,
      fuelQuantity:
          (json['fuelQuantity'] as num?)
                  ?.toDouble() ??
              0,
      pricePerLitre:
          (json['pricePerLitre'] as num?)
                  ?.toDouble() ??
              0,
      totalCost:
          (json['totalCost'] as num?)
                  ?.toDouble() ??
              0,
      petrolStation:
          json['petrolStation']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }
}