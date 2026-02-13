import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/Http.dart';
import '../common/SnackBarUtils.dart';
import '../models/inventory_item.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).fetchInventoryItems();
    });
  }


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
              context.read<InventoryProvider>().fetchInventoryItems();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          const CustomSearchBar(),
          // 库存列表
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                List<InventoryItem> filteredItems = inventoryProvider.fetchList();
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

                return EasyRefresh(
                  controller: inventoryProvider.controller,
                  onRefresh: inventoryProvider.onRefresh,
                  onLoad: inventoryProvider.onLoad,
                  header: const ClassicHeader(
                    dragText: '下拉刷新',
                    armedText: '释放开始',
                    readyText: '正在刷新...',
                    processingText: '正在获取最新数据...',
                    processedText: '刷新成功',
                    noMoreText: '没有更多记录',
                    failedText: '获取记录失败',
                    messageText: '最后更新于 %T',
                  ),
                  footer: ClassicFooter(
                    dragText: '上拉加载',
                    armedText: '释放加载更多',
                    processingText: '正在检索历史记录...',
                    noMoreText: '已显示所有审批历史',
                    messageText: '已加载第 ${inventoryProvider.page} 页数据',
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      var item = filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InventoryItemCard(
                          rowData: item,
                          onTap: (){},
                          //onTap: () => _navigateToDetail(context, item.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showScanDialog(context),
      //   child: const Icon(Icons.qr_code_scanner),
      // ),
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
              //final item = inventoryProvider.getItemBySku('ITM001');
              // if (item != null) {
              //   _navigateToDetail(context, item.id);
              // } else {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('未找到对应商品')),
              //   );
              // }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}