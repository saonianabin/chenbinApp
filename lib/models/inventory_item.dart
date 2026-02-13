class InventoryItem {
  // --- 外部/API 字段 ---
  final String brandName;
  final String categoryName;
  final String productCode;
  final String productId;
  final String productName;
  final String scCode;
  final String scId;
  final String scName;
  final double stockNum; // 优化：dynamic -> double
  final double taxAmount; // 优化：dynamic -> double
  final double taxPrice; // 优化：dynamic -> double

  // --- 本地/业务 字段 ---
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

  const InventoryItem({
    required this.brandName,
    required this.categoryName,
    required this.productCode,
    required this.productId,
    required this.productName,
    required this.scCode,
    required this.scId,
    required this.scName,
    this.stockNum = 0.0,
    this.taxAmount = 0.0,
    this.taxPrice = 0.0,
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.unit,
    this.currentStock = 0.0,
    this.frozenStock = 0.0,
    this.minStock = 0.0,
    this.maxStock = 0.0,
    this.location,
    this.description,
    required this.lastUpdated,
  });


  // --- CopyWith (修复了错误的赋值逻辑) ---
  InventoryItem copyWith({
    String? brandName,
    String? categoryName,
    String? productCode,
    String? productId,
    String? productName,
    String? scCode,
    String? scId,
    String? scName,
    double? stockNum,
    double? taxAmount,
    double? taxPrice,
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
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
      productCode: productCode ?? this.productCode,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      scCode: scCode ?? this.scCode,
      scId: scId ?? this.scId,
      scName: scName ?? this.scName,
      stockNum: stockNum ?? this.stockNum,
      taxAmount: taxAmount ?? this.taxAmount,
      taxPrice: taxPrice ?? this.taxPrice,
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

  // --- JSON Serialization (补全了缺失字段) ---
  Map<String, dynamic> toJson() {
    return {
      'brandName': brandName,
      'categoryName': categoryName,
      'productCode': productCode,
      'productId': productId,
      'productName': productName,
      'scCode': scCode,
      'scId': scId,
      'scName': scName,
      'stockNum': stockNum,
      'taxAmount': taxAmount,
      'taxPrice': taxPrice,
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
    // 辅助函数：安全地将 JSON 值转换为 double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }



    var inventoryItem = InventoryItem(
      brandName: json['brandName']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      productCode: json['productCode']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      scCode: json['scCode']?.toString() ?? '',
      scId: json['scId']?.toString() ?? '',
      scName: json['scName']?.toString() ?? '',
      stockNum: parseDouble(json['stockNum']),
      taxAmount: parseDouble(json['taxAmount']),
      taxPrice: parseDouble(json['taxPrice']),
      id: json['id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      currentStock: parseDouble(json['currentStock']),
      frozenStock: parseDouble(json['frozenStock']),
      minStock: parseDouble(json['minStock']),
      maxStock: parseDouble(json['maxStock']),
      location: json['location']?.toString(),
      description: json['description']?.toString(),
      // 这里的 DateTime.parse 建议加 try-catch 或者使用 tryParse，防止非法字符串崩溃
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
    return inventoryItem;
  }

  @override
  String toString() {
    return 'InventoryItem{brandName: $brandName, categoryName: $categoryName, productCode: $productCode, productId: $productId, productName: $productName, scCode: $scCode, scId: $scId, scName: $scName, stockNum: $stockNum, taxAmount: $taxAmount, taxPrice: $taxPrice, id: $id, sku: $sku, name: $name, category: $category, unit: $unit, currentStock: $currentStock, frozenStock: $frozenStock, minStock: $minStock, maxStock: $maxStock, location: $location, description: $description, lastUpdated: $lastUpdated}';
  }
}