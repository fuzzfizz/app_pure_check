class Fridge {
  final String id;
  final String ownerId;
  final String name;

  Fridge({
    required this.id,
    required this.ownerId,
    required this.name,
  });

  factory Fridge.fromJson(Map<String, dynamic> json) {
    return Fridge(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
    );
  }
}

class InventoryItem {
  final String id;
  final String fridgeId;
  final String? masterProductId;
  final String itemName;
  final DateTime expirationDate;
  final int quantity;
  final bool isConsumed;

  InventoryItem({
    required this.id,
    required this.fridgeId,
    this.masterProductId,
    required this.itemName,
    required this.expirationDate,
    required this.quantity,
    required this.isConsumed,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      fridgeId: json['fridge_id'],
      masterProductId: json['master_product_id'],
      itemName: json['item_name'],
      expirationDate: DateTime.parse(json['expiration_date']),
      quantity: json['quantity'],
      isConsumed: json['is_consumed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fridge_id': fridgeId,
      'master_product_id': masterProductId,
      'item_name': itemName,
      'expiration_date': expirationDate.toIso8601String(),
      'quantity': quantity,
      'is_consumed': isConsumed,
    };
  }
}
