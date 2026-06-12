class MasterProduct {
  final String id;
  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final String dataSource;

  MasterProduct({
    required this.id,
    required this.barcode,
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
    required this.dataSource,
  });

  factory MasterProduct.fromJson(Map<String, dynamic> json) {
    return MasterProduct(
      id: json['id'],
      barcode: json['barcode'],
      name: json['name'],
      brand: json['brand'],
      category: json['category'],
      imageUrl: json['image_url'],
      dataSource: json['data_source'] ?? 'user_crowdsourced',
    );
  }
}
