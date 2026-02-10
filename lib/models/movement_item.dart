enum MovementType { inbound, outbound }

enum MovementStatus { pending, approved, rejected }

class MovementItem {
  final String id;
  final String movementNumber; // 单据编号
  final MovementType type; // 类型：入库/出库
  final MovementStatus status; // 状态：待处理/已通过/已拒绝
  final String supplierOrCustomer; // 供应商或客户
  final String warehouse; // 仓库
  final List<MovementDetail> details; // 明细
  final String? remarks; // 备注
  final String? rejectedReason; // 拒绝原因
  final DateTime createdAt;
  final DateTime? processedAt;
  final String operator; // 操作人

  MovementItem({
    required this.id,
    required this.movementNumber,
    required this.type,
    required this.status,
    required this.supplierOrCustomer,
    required this.warehouse,
    required this.details,
    this.remarks,
    this.rejectedReason,
    required this.createdAt,
    this.processedAt,
    required this.operator,
  });

  // 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case MovementStatus.pending:
        return '待处理';
      case MovementStatus.approved:
        return '已通过';
      case MovementStatus.rejected:
        return '已拒绝';
    }
  }

  // 获取类型显示名称
  String get typeDisplayName {
    return type == MovementType.inbound ? '入库' : '出库';
  }

  // 获取状态颜色
  String get statusColor {
    switch (status) {
      case MovementStatus.pending:
        return 'orange';
      case MovementStatus.approved:
        return 'green';
      case MovementStatus.rejected:
        return 'red';
    }
  }

  // 计算总数量
  double get totalQuantity {
    return details.fold(0.0, (sum, detail) => sum + detail.finalQuantity);
  }

  // 获取总项目数
  int get itemCount {
    return details.length;
  }

  MovementItem copyWith({
    String? id,
    String? movementNumber,
    MovementType? type,
    MovementStatus? status,
    String? supplierOrCustomer,
    String? warehouse,
    List<MovementDetail>? details,
    String? remarks,
    String? rejectedReason,
    DateTime? createdAt,
    DateTime? processedAt,
    String? operator,
  }) {
    return MovementItem(
      id: id ?? this.id,
      movementNumber: movementNumber ?? this.movementNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      supplierOrCustomer: supplierOrCustomer ?? this.supplierOrCustomer,
      warehouse: warehouse ?? this.warehouse,
      details: details ?? this.details,
      remarks: remarks ?? this.remarks,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      operator: operator ?? this.operator,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movementNumber': movementNumber,
      'type': type.index,
      'status': status.index,
      'supplierOrCustomer': supplierOrCustomer,
      'warehouse': warehouse,
      'details': details.map((detail) => detail.toJson()).toList(),
      'remarks': remarks,
      'rejectedReason': rejectedReason,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'operator': operator,
    };
  }

  factory MovementItem.fromJson(Map<String, dynamic> json) {
    return MovementItem(
      id: json['id'],
      movementNumber: json['movementNumber'],
      type: MovementType.values[json['type']],
      status: MovementStatus.values[json['status']],
      supplierOrCustomer: json['supplierOrCustomer'],
      warehouse: json['warehouse'],
      details: (json['details'] as List)
          .map((detail) => MovementDetail.fromJson(detail))
          .toList(),
      remarks: json['remarks'],
      rejectedReason: json['rejectedReason'],
      createdAt: DateTime.parse(json['createdAt']),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      operator: json['operator'],
    );
  }
}

class MovementDetail {
  final String id;
  final String inventoryItemId;
  final String sku;
  final String itemName;
  final double requestedQuantity; // 申请数量
  final double? actualQuantity; // 实发/实收数量
  final String unit;
  final double? unitPrice; // 单价
  final String? remarks;

  MovementDetail({
    required this.id,
    required this.inventoryItemId,
    required this.sku,
    required this.itemName,
    required this.requestedQuantity,
    this.actualQuantity,
    required this.unit,
    this.unitPrice,
    this.remarks,
  });

  // 获取实际数量（如果未设置则返回申请数量）
  double get finalQuantity => actualQuantity ?? requestedQuantity;

  // 计算小计金额
  double get totalAmount {
    if (unitPrice == null) return 0.0;
    return finalQuantity * unitPrice!;
  }

  MovementDetail copyWith({
    String? id,
    String? inventoryItemId,
    String? sku,
    String? itemName,
    double? requestedQuantity,
    double? actualQuantity,
    String? unit,
    double? unitPrice,
    String? remarks,
  }) {
    return MovementDetail(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      sku: sku ?? this.sku,
      itemName: itemName ?? this.itemName,
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
      'sku': sku,
      'itemName': itemName,
      'requestedQuantity': requestedQuantity,
      'actualQuantity': actualQuantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'remarks': remarks,
    };
  }

  factory MovementDetail.fromJson(Map<String, dynamic> json) {
    return MovementDetail(
      id: json['id'],
      inventoryItemId: json['inventoryItemId'],
      sku: json['sku'],
      itemName: json['itemName'],
      requestedQuantity: (json['requestedQuantity'] as num).toDouble(),
      actualQuantity: json['actualQuantity'] != null
          ? (json['actualQuantity'] as num).toDouble()
          : null,
      unit: json['unit'],
      unitPrice: json['unitPrice'] != null
          ? (json['unitPrice'] as num).toDouble()
          : null,
      remarks: json['remarks'],
    );
  }
}