class InventoryItem {

  final String brandName;
  final String categoryName;
  final String productCode;
  final String productId;
  final String productName;
  final String scCode;
  final String scId;
  final String scName;
  final dynamic stockNum;
  final dynamic taxAmount;
  final dynamic taxPrice;


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
    required this.brandName, required this.categoryName, required this.productCode,
    required this.productId, required this.productName, required this.scCode, required this.scId,
    required this.scName, required this.stockNum, required this.taxAmount, required this.taxPrice,


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
      brandName: id ?? this.brandName,
      categoryName: id ?? this.categoryName,
      productCode: id ?? this.productCode,
      productId: id ?? this.productId,
      productName: id ?? this.productName,
      scCode: id ?? this.scCode,
      scId: id ?? this.scId,
      scName: id ?? this.scName,
      stockNum: id ?? this.stockNum,
      taxAmount: id ?? this.taxAmount,
      taxPrice: id ?? this.taxPrice,


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
      brandName: json['brandName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      productCode: json['productCode'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      scCode: json['scCode'] ?? '',
      scId: json['scId'] ?? '',
      scName: json['scName'] ?? '',
      stockNum: json['stockNum'] ?? '',
      taxAmount: json['taxAmount'] ?? '',
      taxPrice: json['taxPrice'] ?? '',

      id: json['id'] ?? '',
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      currentStock: (json['currentStock'] ?? 0 as num).toDouble(),
      frozenStock: (json['frozenStock'] ?? 0 as num).toDouble(),
      minStock: (json['minStock'] ?? 0  as num).toDouble(),
      maxStock: (json['maxStock'] ?? 0  as num).toDouble(),
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      //lastUpdated: DateTime.parse(json['lastUpdated']),
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