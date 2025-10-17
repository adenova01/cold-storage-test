class InventoryItem {
  final String id;
  final String sku;
  final String batch;
  final DateTime expiry;
  final int quantity;
  final String locationId;
  final DateTime createdAt;

  InventoryItem({
    required this.id,
    required this.sku,
    required this.batch,
    required this.expiry,
    required this.quantity,
    required this.locationId,
    required this.createdAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      sku: json['sku'],
      batch: json['batch'],
      expiry: DateTime.parse(json['expiry']),
      quantity: json['quantity'],
      locationId: json['location_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'batch': batch,
      'expiry': expiry.toIso8601String(),
      'quantity': quantity,
      'location_id': locationId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isNearExpiry {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expiry.isBefore(thirtyDaysFromNow);
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiry.difference(now).inDays;
  }
}
