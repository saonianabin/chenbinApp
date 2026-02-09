class InventoryItem {
  final String id;
  final String sku;
  final String name;
  final String category;
  final String unit;
  final double currentStock; // 现有库存
  final double frozenStock; // 冻结库存
  final double minStock; // 最小库存预警
  final double maxStock; // 最大库存
  final String? location; // 库位
  final String? description;
  final DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.frozenStock,
    required this.minStock,
    required this.maxStock,
    this.location,
    this.description,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // 可用库存 = 现有库存 - 冻结库存
  double get availableStock => currentStock - frozenStock;

  // 是否库存不足
  bool get isLowStock => currentStock <= minStock;

  // 是否库存过量
  bool get isOverStock => currentStock >= maxStock;

  // 库存状态
  String get stockStatus {
    if (isLowStock) return '库存不足';
    if (isOverStock) return '库存过量';
    return '库存正常';
  }

  // 获取库存状态颜色
  String get stockStatusColor {
    if (isLowStock) return 'red';
    if (isOverStock) return 'orange';
    return 'green';
  }

  InventoryItem copyWith({
    String? id,
    String? sku,
    String? name,
    String? category,
    String? unit,
    double? currentStock,
    double? frozenStock,
    double? minStock,
    double? maxStock,
    String? location,
    String? description,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      frozenStock: frozenStock ?? this.frozenStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      location: location ?? this.location,
      description: description ?? this.description,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'unit': unit,
      'currentStock': currentStock,
      'frozenStock': frozenStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'location': location,
      'description': description,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      sku: json['sku'],
      name: json['name'],
      category: json['category'],
      unit: json['unit'],
      currentStock: (json['currentStock'] as num).toDouble(),
      frozenStock: (json['frozenStock'] as num).toDouble(),
      minStock: (json['minStock'] as num).toDouble(),
      maxStock: (json['maxStock'] as num).toDouble(),
      location: json['location'],
      description: json['description'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  String toString() {
    return 'InventoryItem{id: $id, sku: $sku, name: $name, currentStock: $currentStock, availableStock: $availableStock}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}