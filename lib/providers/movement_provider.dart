import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/Http.dart';
import '../common/SnackBarUtils.dart';
import '../models/movement_item.dart';
import '../models/inventory_item.dart';
import 'inventory_provider.dart';

class MovementProvider extends ChangeNotifier {
  final List<MovementItem> _inboundItems = [];
  final List<MovementItem> _outboundItems = [];

  late int _totalInbound = 0;
  late int _totalOutbound = 0;

  // 列表
  List<MovementItem> get fetchInboundList {
    return _inboundItems;
  }

  List<MovementItem> get fetchOutboundList {
    return _outboundItems;
  }

  // 网络请求
  Future<void> fetchNetworkLoadInboundList() async {
    _inboundItems.clear();
    _totalInbound = 0;
    var response = await Http.get("/purchase/receive/sheet/query",queryParameters: {"status ": 0});
    if (response["code"] == 200) {
      List<dynamic> datas = response["data"]["datas"] ?? [];
      List<MovementItem> newItems = datas.map((e) => MovementItem.fromJson(e)).toList();
      _inboundItems.addAll(newItems);
      _totalInbound = response["data"]["totalCount"];
    }
    notifyListeners();
  }

  // 网络请求
  Future<void> fetchNetworkLoadOutboundList() async {
    _outboundItems.clear();
    _totalOutbound = 0;
    var response = await Http.get("/sale/out/sheet/query",queryParameters: {"status": 0});
    if (response["code"] == 200) {
      List<dynamic> datas = response["data"]["datas"] ?? [];
      List<MovementItem> newItems = datas.map((e) => MovementItem.fromJson(e)).toList();
      _outboundItems.addAll(newItems);
      _totalOutbound = response["data"]["totalCount"];
    }
    notifyListeners();
  }

  // 统计
  Map get statistics {
    Map statistics = {
      'pendingInbound': _totalInbound,
      'pendingOutbound':_totalOutbound,
    };
    return statistics;
  }

}