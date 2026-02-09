import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class InventoryProvider extends ChangeNotifier {
  final List<InventoryItem> _items = [];
  String _searchQuery = '';
  String _selectedCategory = '全部';

  // Getters
  List<InventoryItem> get items => List.unmodifiable(_items);
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // 获取过滤后的库存列表
  List<InventoryItem> get filteredItems {
    return _items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == '全部' ||
          item.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // 获取所有分类
  List<String> get categories {
    final categories = _items.map((item) => item.category).toSet().toList();
    categories.insert(0, '全部');
    return categories;
  }

  // 统计数据
  Map<String, dynamic> get statistics {
    final totalItems = _items.length;
    final lowStockItems = _items.where((item) => item.isLowStock).length;
    final overStockItems = _items.where((item) => item.isOverStock).length;
    final totalValue = _items.fold<double>(
      0.0,
      (sum, item) => sum + item.currentStock,
    );

    return {
      'totalItems': totalItems,
      'lowStockItems': lowStockItems,
      'overStockItems': overStockItems,
      'totalValue': totalValue,
    };
  }

  // 搜索方法
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 设置分类筛选
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // 添加库存商品
  void addItem(InventoryItem item) {
    _items.add(item);
    notifyListeners();
  }

  // 根据ID获取库存商品
  InventoryItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // 根据SKU获取库存商品
  InventoryItem? getItemBySku(String sku) {
    try {
      return _items.firstWhere((item) => item.sku == sku);
    } catch (e) {
      return null;
    }
  }

  // 增加库存
  void increaseStock(String itemId, double quantity, {String? reason}) {
    final item = getItemById(itemId);
    if (item != null) {
      final updatedItem = item.copyWith(
        currentStock: item.currentStock + quantity,
        lastUpdated: DateTime.now(),
      );
      _updateItem(updatedItem);
    }
  }

  // 减少库存
  void decreaseStock(String itemId, double quantity, {String? reason}) {
    final item = getItemById(itemId);
    if (item != null && item.availableStock >= quantity) {
      final updatedItem = item.copyWith(
        currentStock: item.currentStock - quantity,
        lastUpdated: DateTime.now(),
      );
      _updateItem(updatedItem);
    }
  }

  // 冻结库存
  void freezeStock(String itemId, double quantity, {String? reason}) {
    final item = getItemById(itemId);
    if (item != null && item.availableStock >= quantity) {
      final updatedItem = item.copyWith(
        frozenStock: item.frozenStock + quantity,
        lastUpdated: DateTime.now(),
      );
      _updateItem(updatedItem);
    }
  }

  // 解冻库存
  void unfreezeStock(String itemId, double quantity, {String? reason}) {
    final item = getItemById(itemId);
    if (item != null && item.frozenStock >= quantity) {
      final updatedItem = item.copyWith(
        frozenStock: item.frozenStock - quantity,
        lastUpdated: DateTime.now(),
      );
      _updateItem(updatedItem);
    }
  }

  // 更新库存商品
  void _updateItem(InventoryItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  // 删除库存商品
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  // 更新库存商品信息
  void updateItem(InventoryItem updatedItem) {
    _updateItem(updatedItem);
  }

  // 初始化示例数据
  void initializeSampleData() {
    final sampleItems = [
      InventoryItem(
        id: '1',
        sku: 'ITM001',
        name: 'iPhone 15 Pro',
        category: '手机数码',
        unit: '台',
        currentStock: 150.0,
        frozenStock: 20.0,
        minStock: 50.0,
        maxStock: 500.0,
        location: 'A1-01',
        description: '苹果最新旗舰手机',
      ),
      InventoryItem(
        id: '2',
        sku: 'ITM002',
        name: 'MacBook Pro 14寸',
        category: '电脑办公',
        unit: '台',
        currentStock: 25.0,
        frozenStock: 5.0,
        minStock: 10.0,
        maxStock: 100.0,
        location: 'B2-03',
        description: '苹果笔记本电脑',
      ),
      InventoryItem(
        id: '3',
        sku: 'ITM003',
        name: '小米13',
        category: '手机数码',
        unit: '台',
        currentStock: 80.0,
        frozenStock: 15.0,
        minStock: 30.0,
        maxStock: 300.0,
        location: 'A1-02',
        description: '小米旗舰手机',
      ),
      InventoryItem(
        id: '4',
        sku: 'ITM004',
        name: '华为MateBook X Pro',
        category: '电脑办公',
        unit: '台',
        currentStock: 8.0,
        frozenStock: 2.0,
        minStock: 20.0,
        maxStock: 80.0,
        location: 'B2-01',
        description: '华为高端笔记本',
      ),
      InventoryItem(
        id: '5',
        sku: 'ITM005',
        name: 'AirPods Pro 2',
        category: '手机数码',
        unit: '个',
        currentStock: 200.0,
        frozenStock: 30.0,
        minStock: 50.0,
        maxStock: 800.0,
        location: 'A1-03',
        description: '苹果无线耳机',
      ),
    ];

    for (final item in sampleItems) {
      addItem(item);
    }
  }
}