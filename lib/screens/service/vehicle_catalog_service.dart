class VehicleCatalogItem {
  final String id;
  final String brand;
  final String model;

  const VehicleCatalogItem({
    required this.id,
    required this.brand,
    required this.model,
  });

  String get displayName => '$brand $model';
}

class VehicleCatalogService {
  Future<List<VehicleCatalogItem>> getVehicleModels(
    String vehicleType,
  ) async {
    if (vehicleType == '2 Wheeler') {
      return const [
        VehicleCatalogItem(
          id: '2w-001',
          brand: 'Bajaj',
          model: 'Pulsar 150',
        ),
        VehicleCatalogItem(
          id: '2w-002',
          brand: 'Bajaj',
          model: 'Pulsar N160',
        ),
        VehicleCatalogItem(
          id: '2w-003',
          brand: 'Bajaj',
          model: 'Pulsar NS200',
        ),
        VehicleCatalogItem(
          id: '2w-004',
          brand: 'Bajaj',
          model: 'Dominar 400',
        ),
        VehicleCatalogItem(
          id: '2w-005',
          brand: 'Hero',
          model: 'Splendor Plus',
        ),
        VehicleCatalogItem(
          id: '2w-006',
          brand: 'Honda',
          model: 'Shine',
        ),
        VehicleCatalogItem(
          id: '2w-007',
          brand: 'TVS',
          model: 'Apache RTR 160',
        ),
      ];
    }

    return const [
      VehicleCatalogItem(
        id: '4w-001',
        brand: 'Tata',
        model: 'Nexon',
      ),
      VehicleCatalogItem(
        id: '4w-002',
        brand: 'Tata',
        model: 'Punch',
      ),
      VehicleCatalogItem(
        id: '4w-003',
        brand: 'Maruti Suzuki',
        model: 'Swift',
      ),
      VehicleCatalogItem(
        id: '4w-004',
        brand: 'Hyundai',
        model: 'i20',
      ),
      VehicleCatalogItem(
        id: '4w-005',
        brand: 'Honda',
        model: 'City',
      ),
      VehicleCatalogItem(
        id: '4w-006',
        brand: 'Mahindra',
        model: 'XUV 3XO',
      ),
    ];
  }
}