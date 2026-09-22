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

  factory SparePart.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawPrice =
        json['price'] ??
        json['selling_price'] ??
        json['sellingPrice'] ??
        json['sale_price'] ??
        json['salePrice'] ??
        json['retail_price'] ??
        json['retailPrice'] ??
        json['cost'] ??
        0;

    final String name =
        (json['name'] ??
                json['part_name'] ??
                json['partName'] ??
                json['articleName'] ??
                json['ArticleName'] ??
                json['description'] ??
                json['Description'] ??
                json['title'] ??
                'Unknown Part')
            .toString()
            .trim();

    final String partNumber =
        (json['partNumber'] ??
                json['part_number'] ??
                json['partNo'] ??
                json['part_no'] ??
                json['articleNo'] ??
                json['articleNumber'] ??
                json['ArticleNumber'] ??
                json['sku'] ??
                '')
            .toString()
            .trim();

    final String id =
        (json['id'] ??
                json['articleId'] ??
                json['ArticleId'] ??
                json['article_id'] ??
                json['part_id'] ??
                json['partId'] ??
                json['sku'] ??
                partNumber)
            .toString();

    final String? imageUrl =
        _extractImageUrl(json);

    return SparePart(
      id: id,
      name: name,
      partNumber: partNumber,
      price: _parsePrice(rawPrice),
      imageUrl: imageUrl,
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

  static String? _extractImageUrl(
    Map<String, dynamic> json,
  ) {
    final dynamic directImage =
        json['imageUrl'] ??
        json['image_url'] ??
        json['image'] ??
        json['ImageUrl'] ??
        json['ImageURL'];

    if (directImage != null &&
        directImage.toString().trim().isNotEmpty) {
      return directImage.toString().trim();
    }

    final dynamic media =
        json['media'] ??
        json['Media'] ??
        json['images'] ??
        json['Images'];

    if (media is List &&
        media.isNotEmpty) {
      for (final dynamic item in media) {
        if (item is String &&
            item.trim().isNotEmpty) {
          return item.trim();
        }

        if (item is Map) {
          final dynamic url =
              item['url'] ??
              item['URL'] ??
              item['imageUrl'] ??
              item['image_url'];

          if (url != null &&
              url.toString().trim().isNotEmpty) {
            return url.toString().trim();
          }
        }
      }
    }

    return null;
  }

  static double _parsePrice(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    final String cleaned =
        value
            .toString()
            .replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            );

    return double.tryParse(
          cleaned,
        ) ??
        0;
  }
}