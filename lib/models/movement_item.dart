// 移除不需要的 ffi 引用
// import 'dart:ffi';

enum MovementType { inbound, outbound }

enum MovementStatus { pending, approved, rejected }

class MovementItem {
  final String id;
  final String movementNumber; // 单据编号 (业务显示用)
  final MovementType type; // 类型
  final String status; // 状态

  // --- 业务字段 ---
  final String scCode; // 仓库编号
  final String scName; // 仓库名称
  final String supplierCode; // 供应商编号
  final String supplierName; // 供应商名称
  final String customerCode; // 客户编号
  final String customerName; // 客户名称
  final double totalNum; // 优化：String -> double

  final String operator; // 操作人 (当前登录或处理人)
  final String createBy; // 创建人 (单据创建者)
  final DateTime createTime; // 创建时间
  final DateTime? processedAt; // 处理时间 (审核时间)

  final String? remarks; // 备注
  final String? rejectedReason; // 拒绝原因

  final List<MovementDetail> details; // 明细列表

  // 单据号
  final String code;



  MovementItem({
    required this.id,
    required this.movementNumber,
    required this.type,
    required this.status,
    required this.scCode,
    required this.code,
    required this.scName,
    required this.supplierCode,
    required this.supplierName,
    required this.customerCode,
    required this.customerName,
    this.totalNum = 0.0,
    required this.operator,
    required this.createBy,
    required this.createTime,
    this.processedAt,
    this.remarks,
    this.rejectedReason,
    required this.details,
  });

  // --- Getters / 辅助方法 ---

  // 获取状态显示名称
  // String get statusDisplayName {
  //   switch (status) {
  //     case status: return '待处理';
  //     case status: return '已通过';
  //     case status: return '已拒绝';
  //   }
  // }

  // 获取类型显示名称
  String get typeDisplayName {
    return type == MovementType.inbound ? '入库' : '出库';
  }

  // 获取状态颜色
  // String get statusColor {
  //   switch (status) {
  //     case MovementStatus.pending: return 'orange';
  //     case MovementStatus.approved: return 'green';
  //     case MovementStatus.rejected: return 'red';
  //   }
  // }

  // 供应商或客户 (根据类型动态返回)
  String get supplierOrCustomerName {
    if (type == MovementType.inbound) {
      return supplierName.isNotEmpty ? supplierName : supplierCode;
    } else {
      return customerName.isNotEmpty ? customerName : customerCode;
    }
  }

  // 计算明细中的实际总数 (校验用)
  double get calculatedTotalQuantity {
    return details.fold(0.0, (sum, detail) => sum + (detail.actualQuantity ?? detail.requestedQuantity));
  }

  // --- JSON Serialization ---

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movementNumber': movementNumber, // 对应 code 或 movementNumber
      'type': type.index,
      'status': status,
      'scCode': scCode,
      'code': code,
      'scName': scName,
      'supplierCode': supplierCode,
      'supplierName': supplierName,
      'customerCode': customerCode,
      'customerName': customerName,
      'totalNum': totalNum,
      'operator': operator,
      'createBy': createBy,
      'createTime': createTime.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'remarks': remarks,
      'rejectedReason': rejectedReason,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }

  factory MovementItem.fromJson(Map<String, dynamic> json) {
    // 辅助函数：安全转 Double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return MovementItem(
      id: json['id']?.toString() ?? '',
      // 兼容 API 可能返回 'code' 或 'movementNumber'
      movementNumber: json['movementNumber']?.toString() ?? json['code']?.toString() ?? '',
      type: MovementType.values.asMap()[json['type']] ?? MovementType.inbound, // 防止越界默认入库
      status: json['status']?.toString() ?? '',

      code: json['code']?.toString() ?? '',
      scCode: json['scCode']?.toString() ?? '',
      scName: json['scName']?.toString() ?? '',
      supplierCode: json['supplierCode']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? '',
      customerCode: json['customerCode']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',

      totalNum: parseDouble(json['totalNum']),

      operator: json['operator']?.toString() ?? '',
      createBy: json['createBy']?.toString() ?? '',
      createTime: DateTime.tryParse(json['createTime']?.toString() ?? '') ?? DateTime.now(),
      processedAt: json['processedAt'] != null ? DateTime.tryParse(json['processedAt'].toString()) : null,

      remarks: json['remarks']?.toString(),
      rejectedReason: json['rejectedReason']?.toString(),

      details: (json['details'] as List?)
          ?.map((detail) => MovementDetail.fromJson(detail))
          .toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'MovementItem{id: $id, movementNumber: $movementNumber, type: $type, status: $status, scCode: $scCode, scName: $scName, supplierCode: $supplierCode, supplierName: $supplierName, customerCode: $customerCode, customerName: $customerName, totalNum: $totalNum, operator: $operator, createBy: $createBy, createTime: $createTime, processedAt: $processedAt, remarks: $remarks, rejectedReason: $rejectedReason, details: $details, code: $code}';
  }
}

class MovementDetail {
  final String id;
  final String inventoryItemId; // 库存ID
  final String productId; // 产品ID
  final String productCode; // 产品编号
  final String productName; // 产品名称
  final String sku; // SKU (Stock Keeping Unit)
  final String skuCode; // SKU编号 (冗余字段?)
  final String externalCode; // 简码/条码

  // --- 数量与价格 ---
  final double requestedQuantity; // 申请数量 (orderNum)
  final double? actualQuantity; // 实发/实收数量 (receiveNum)
  final double remainNum; // 剩余数量
  final double stockNum; // 当前库存数量

  final String unit; // 单位
  final String spec; // 规格
  final String categoryName; // 分类
  final String brandName; // 品牌

  final double unitPrice; // 单价 (可能含税或不含税，视业务而定)
  final double purchasePrice; // 采购价
  final double taxAmount; // 税额
  final double taxCostPrice; // 含税成本价
  final double oriPrice; // 原价
  final double taxPrice; // 现价
  final double discountRate; // 折扣率
  final double taxRate; // 税率

  final bool isGift; // 是否赠品
  final String? remarks; // 备注 (description)

  // --- 关联ID ---
  final String purchaseOrderDetailId;
  final String scId;
  final String mainProductId;
  final String saleOrderDetailId;

  MovementDetail({
    required this.id,
    required this.inventoryItemId,
    required this.productId,
    this.productCode = '',
    this.productName = '',
    required this.sku,
    this.skuCode = '',
    this.externalCode = '',

    this.requestedQuantity = 0.0,
    this.actualQuantity,
    this.remainNum = 0.0,
    this.stockNum = 0.0,

    this.unit = '',
    this.spec = '',
    this.categoryName = '',
    this.brandName = '',

    this.unitPrice = 0.0,
    this.purchasePrice = 0.0,
    this.taxAmount = 0.0,
    this.taxCostPrice = 0.0,
    this.oriPrice = 0.0,
    this.taxPrice = 0.0,
    this.discountRate = 0.0,
    this.taxRate = 0.0,

    this.isGift = false,
    this.remarks,

    this.purchaseOrderDetailId = '',
    this.scId = '',
    this.mainProductId = '',
    this.saleOrderDetailId = '',
  });

  // 获取有效显示名称 (优先显示产品名，其次是 sku)
  String get displayName => productName.isNotEmpty ? productName : sku;

  // 计算小计金额
  double get totalAmount => (actualQuantity ?? requestedQuantity) * unitPrice;

  MovementDetail copyWith({
    String? id,
    String? inventoryItemId,
    String? productId,
    String? productCode,
    String? productName,
    double? requestedQuantity,
    double? actualQuantity,
    String? unit,
    double? unitPrice,
    String? remarks,
  }) {
    return MovementDetail(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      sku: this.sku, // 这里仅示例部分 copy，通常不需要 copy 所有只读字段
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'productId': productId,
      'productCode': productCode,
      'productName': productName,
      'sku': sku,
      'skuCode': skuCode,
      'externalCode': externalCode,
      'requestedQuantity': requestedQuantity,
      'actualQuantity': actualQuantity,
      'remainNum': remainNum,
      'stockNum': stockNum,
      'unit': unit,
      'spec': spec,
      'categoryName': categoryName,
      'brandName': brandName,
      'unitPrice': unitPrice,
      'purchasePrice': purchasePrice,
      'taxAmount': taxAmount,
      'taxCostPrice': taxCostPrice,
      'oriPrice': oriPrice,
      'taxPrice': taxPrice,
      'discountRate': discountRate,
      'taxRate': taxRate,
      'isGift': isGift,
      'remarks': remarks, // 对应 description 或 remarks
      'purchaseOrderDetailId': purchaseOrderDetailId,
      'scId': scId,
      'mainProductId': mainProductId,
      'saleOrderDetailId': saleOrderDetailId,
    };
  }

  factory MovementDetail.fromJson(Map<String, dynamic> json) {
    // 内部辅助：安全转 Double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return MovementDetail(
      id: json['id']?.toString() ?? '',
      inventoryItemId: json['inventoryItemId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productCode: json['productCode']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['itemName']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      skuCode: json['skuCode']?.toString() ?? '',
      externalCode: json['externalCode']?.toString() ?? '',

      requestedQuantity: parseDouble(json['requestedQuantity'] ?? json['orderNum']),
      actualQuantity: json['actualQuantity'] != null ? parseDouble(json['actualQuantity']) : parseDouble(json['receiveNum']),
      remainNum: parseDouble(json['remainNum']),
      stockNum: parseDouble(json['stockNum']),

      unit: json['unit']?.toString() ?? '',
      spec: json['spec']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      brandName: json['brandName']?.toString() ?? '',

      unitPrice: parseDouble(json['unitPrice']),
      purchasePrice: parseDouble(json['purchasePrice']),
      taxAmount: parseDouble(json['taxAmount']),
      taxCostPrice: parseDouble(json['taxCostPrice']),
      oriPrice: parseDouble(json['oriPrice']),
      taxPrice: parseDouble(json['taxPrice']),
      discountRate: parseDouble(json['discountRate']),
      taxRate: parseDouble(json['taxRate']),

      isGift: json['isGift'] == true || json['isGift'] == 'true',
      remarks: json['remarks']?.toString() ?? json['description']?.toString(),

      purchaseOrderDetailId: json['purchaseOrderDetailId']?.toString() ?? '',
      scId: json['scId']?.toString() ?? '',
      mainProductId: json['mainProductId']?.toString() ?? '',
      saleOrderDetailId: json['saleOrderDetailId']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'MovementDetail{id: $id, inventoryItemId: $inventoryItemId, productId: $productId, productCode: $productCode, productName: $productName, sku: $sku, skuCode: $skuCode, externalCode: $externalCode, requestedQuantity: $requestedQuantity, actualQuantity: $actualQuantity, remainNum: $remainNum, stockNum: $stockNum, unit: $unit, spec: $spec, categoryName: $categoryName, brandName: $brandName, unitPrice: $unitPrice, purchasePrice: $purchasePrice, taxAmount: $taxAmount, taxCostPrice: $taxCostPrice, oriPrice: $oriPrice, taxPrice: $taxPrice, discountRate: $discountRate, taxRate: $taxRate, isGift: $isGift, remarks: $remarks, purchaseOrderDetailId: $purchaseOrderDetailId, scId: $scId, mainProductId: $mainProductId, saleOrderDetailId: $saleOrderDetailId}';
  }
}