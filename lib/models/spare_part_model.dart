class SparePart {
  final String id;
  final String name;
  final String partNumber;
  final double price;
  final String? imageUrl;

  const SparePart({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.price,
    this.imageUrl,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    final dynamic rawPrice =
        json['price'] ??
        json['selling_price'] ??
        json['sale_price'] ??
        json['cost'] ??
        0;

    return SparePart(
      id: (json['id'] ??
              json['part_id'] ??
              json['sku'] ??
              json['partNumber'] ??
              json['part_number'] ??
              '')
          .toString(),
      name: (json['name'] ??
              json['part_name'] ??
              json['title'] ??
              'Unknown Part')
          .toString(),
      partNumber: (json['partNumber'] ??
              json['part_number'] ??
              json['partNo'] ??
              json['part_no'] ??
              json['sku'] ??
              '')
          .toString(),
      price: _parsePrice(rawPrice),
      imageUrl: json['imageUrl']?.toString() ??
          json['image_url']?.toString() ??
          json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'partNumber': partNumber,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  static double _parsePrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    final String cleaned =
        value.toString().replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            );

    return double.tryParse(cleaned) ?? 0;
  }
}