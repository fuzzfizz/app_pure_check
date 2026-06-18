class MasterProduct {
  final String barcode;
  final String productName;
  final String? brand;
  final String? imageUrl;
  final String source;
  final bool isVerified;

  MasterProduct({
    required this.barcode,
    required this.productName,
    this.brand,
    this.imageUrl,
    this.source = 'user_submitted',
    this.isVerified = false,
  });

  factory MasterProduct.fromJson(Map<String, dynamic> json) {
    return MasterProduct(
      barcode: json['barcode'] as String,
      productName: json['product_name'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['image_url'] as String?,
      source: json['source'] as String? ?? 'user_submitted',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'product_name': productName,
      'brand': brand,
      'image_url': imageUrl,
      'source': source,
      'is_verified': isVerified,
    };
  }
}
