import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../utils/app_theme.dart';
import 'inventory_detail_screen.dart';
import '../widgets/search_bar.dart';
import '../widgets/inventory_item_card.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('库存管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 刷新数据
              context.read<InventoryProvider>().initializeSampleData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          const CustomSearchBar(),
          // 分类筛选
          Consumer<InventoryProvider>(
            builder: (context, inventoryProvider, child) {
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: inventoryProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = inventoryProvider.categories[index];
                    final isSelected = category == inventoryProvider.selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          inventoryProvider.setSelectedCategory(category);
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // 库存列表
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                final filteredItems = inventoryProvider.filteredItems;
                
                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '暂无库存数据',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InventoryItemCard(
                        item: item,
                        onTap: () => _navigateToDetail(context, item.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScanDialog(context),
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryDetailScreen(itemId: itemId),
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('扫码功能'),
        content: const Text('模拟扫码扫描到商品：iPhone 15 Pro (ITM001)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 模拟扫码结果
              final inventoryProvider = context.read<InventoryProvider>();
              final item = inventoryProvider.getItemBySku('ITM001');
              if (item != null) {
                _navigateToDetail(context, item.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('未找到对应商品')),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}