import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import '../common/Http.dart';
import '../models/inventory_item.dart';

class InventoryProvider extends ChangeNotifier {
  // 核心数据
  final List<InventoryItem> _items = [];
  String _searchQuery = '';

  final EasyRefreshController _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
  );

  EasyRefreshController get controller => _controller;

  // 分页参数
  int _page = 1;
  final int _pageSize = 10;
  int _total = 0;

  int get page => _page;

  // 状态控制（适配 EasyRefresh）
  bool _isLoading = false; // 是否正在加载
  bool _hasMore = true;    // 是否有更多数据

  // Getters（对外暴露不可变数据）
  List<InventoryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  /// 核心加载方法（区分刷新/加载更多）
  /// [isRefresh]：true=下拉刷新，false=上拉加载更多
  Future<void> fetchInventoryItems({bool isRefresh = true}) async {
    // 防止重复请求
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      // 发起网络请求
      var response = await Http.get(
        "/stock/product/query",
        queryParameters: {
          "productCode": null,
          "productName": _searchQuery,
          "pageIndex": _page,
          "pageSize": _pageSize
        },
      );

      // 处理响应
      if (response["code"] == 200) {
        // 解析总数和数据列表
        _total = response["data"]["totalCount"] ?? 0;
        List<dynamic> datas = response["data"]["datas"] ?? [];

        // 刷新：清空旧数据；加载更多：保留旧数据
        if (isRefresh) {
          _items.clear();
        }

        // 添加新数据
        List<InventoryItem> newItems = datas
            .map((row) => InventoryItem.fromJson(row))
            .toList();
        _items.addAll(newItems);

        // 判断是否有更多数据
        _hasMore = _items.length < _total;
      } else {
        // 接口返回错误码
        debugPrint("获取库存数据失败：${response["msg"] ?? "未知错误"}");
      }
    } catch (e) {
      // 捕获网络异常/解析异常
      debugPrint("加载库存数据异常：$e");
      _hasMore = false; // 出错时停止加载更多
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索方法（重置页码+刷新）
  void setSearchQuery(String query) {
    if (_searchQuery == query) return; // 避免重复搜索
    _searchQuery = query;
    _page = 1; // 搜索时重置页码
    fetchInventoryItems(isRefresh: true);
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    _page = 1;
    await fetchInventoryItems(isRefresh: true);
    _controller.finishRefresh();
  }

  /// 上拉加载更多
  Future<void> onLoad() async {
    if (!_hasMore || _isLoading) return; // 无更多/加载中则返回
    _page++;
    await fetchInventoryItems(isRefresh: false);
  }

  /// 重置数据（可选，如页面销毁前）
  void reset() {
    _items.clear();
    _searchQuery = '';
    _page = 1;
    _total = 0;
    _isLoading = false;
    _hasMore = true;
    notifyListeners();
  }

  List<InventoryItem> fetchList() {
    return _items;
  }
}