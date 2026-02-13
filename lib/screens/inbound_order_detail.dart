import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../common/Http.dart';
import '../common/SnackBarUtils.dart';
import '../utils/app_theme.dart';
import 'movement_detail_screen.dart';

class InboundOrderDetail extends StatefulWidget {
  final int status;
  final String type;
  final String inboundOderId;

  const InboundOrderDetail(
      {super.key,
        required this.type,
        required this.inboundOderId,
        required this.status});

  @override
  State<InboundOrderDetail> createState() => _InboundOrderDetailState();
}

class _InboundOrderDetailState extends State<InboundOrderDetail> {
  var _row = {};
  bool _isProcessing = false;
  final Map<String, TextEditingController> _quantityControllers = {};

  void _fetchInData() async {
    var response;
    if ("inbound" == widget.type) {
      response = await Http.get("/purchase/receive/sheet",
          queryParameters: {"id": widget.inboundOderId});
    } else if ("outbound" == widget.type) {
      response = await Http.get("/sale/out/sheet",
          queryParameters: {"id": widget.inboundOderId});
    }
    _quantityControllers.clear();
    if (response["code"] == 200) {
      setState(() {
        _row = response["data"];
        for (var i = 0; i < response["data"]["details"].length; ++i) {
          var element = response["data"]["details"][i];
          String quantity = "0";
          if ("inbound" == widget.type) {
            quantity = element["receiveNum"]?.toString() ?? "0";
          } else if ("outbound" == widget.type) {
            quantity = element["outNum"].toString() ?? "0";
          }
          _quantityControllers[element["id"]] = TextEditingController(
            text: quantity,
          );
        }
      });
    } else {
      SnackBarUtils.showError(context, response["msg"]);
    }
  }

  void _updateInbound(productId, receiveNum) async {
    List productList = [];
    for (var i = 0; i < _row["details"].length; ++i) {
      var rowData = _row["details"][i];
      productList.add({
        "description": "",
        "productId": rowData["productId"],
        "receiveNum":
        rowData["productId"] == productId ? receiveNum : rowData["receiveNum"]
      });
    }

    var data = {
      "id": _row["id"],
      "products": productList,
      "receiveDate": _row["receiveDate"],
      "required": true,
      "scId": _row["scId"],
      "supplierId": _row["supplierId"],
      "purchaseOrderId": _row["purchaseOrderId"]
    };

    try {
      var response = await Http.put("/purchase/receive/sheet", data: data);
      SnackBarUtils.showError(context, response["msg"]);
    } catch (e) {
      SnackBarUtils.showError(context, "请联系管理员处理");
    }
  }

  void _updateOutbound(productId, outNum) async {
    List productList = [];
    for (var i = 0; i < _row["details"].length; ++i) {
      var rowData = _row["details"][i];
      productList.add({
        "description": "",
        "productId": rowData["productId"],
        "oriPrice": "1",
        "taxPrice": "1",
        "orderNum": rowData["productId"] == productId ? outNum : rowData["outNum"]
      });
    }

    var data = {
      "id": _row["id"],
      "products": productList,
      "scId": _row["scId"],
      "customerId": _row["customerId"]
    };

    try {
      var response = await Http.put("/sale/out/sheet", data: data);
      SnackBarUtils.showError(context, response["msg"]);
    } catch (e) {
      SnackBarUtils.showError(context, "请联系管理员处理");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.type == "inbound" ? "入库详情" : "出库详情")),
      body: ListView.builder(
          itemCount: _row["details"] != null ? _row["details"].length : 0,
          itemBuilder: (context, index) {
            var data = _row["details"]?[index];
            return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: Colors.white10) : null,
                  boxShadow: isDark
                      ? null
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _rowText(theme, "产品ID", "${data["productId"]}"),
                    _rowText(theme, "产品编号", "${data["productCode"]}"),
                    _rowText(theme, "产品名称", "${data["productName"]}"),
                    _rowText(theme, "产品SKU编号", "${data["skuCode"]}"),
                    _rowText(theme, "单位", "${data.containsKey("unit") ? data["unit"] : ""}"),
                    _rowText(theme, "规格", "${data.containsKey("unit") ? data["spec"] : ""}"),
                    _rowText(theme, "产品分类", "${data["categoryName"]}"),
                    _rowText(theme, "产品品牌", "${data["brandName"]}"),
                    _rowText(theme, "库存数量", "${data["stockNum"]}"),
                    Visibility(
                      visible: widget.type == "inbound",
                      child: _rowText(theme, "采购数量", "${data["orderNum"]}"),
                    ),
                    Visibility(
                      visible: widget.type == "inbound",
                      child: _rowText(theme, "剩余收货数量",
                          "${data.containsKey("remainNum") ? data["remainNum"] : "0"}"),
                    ),
                    Visibility(
                        visible: widget.status != 0,
                        child: _rowText(theme, "收货数量", "${data["receiveNum"]}")),
                    // 动态输入区域
                    if (widget.status == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text(
                                widget.type == "inbound" ? '收货数量：' : '出库数量：',
                                style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    fontSize: 14)),
                            Expanded(
                              child: TextField(
                                controller: _quantityControllers["${data["id"]}"],
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: theme.dividerColor)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
                                ),
                                onChanged: (value) {
                                  if (widget.type == "inbound") {
                                    _updateInbound("${data["productId"]}", value);
                                  } else {
                                    _updateOutbound("${data["productId"]}", value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ));
          }),
      bottomNavigationBar: Visibility(
        visible: widget.status == 0,
        child: Container(
          color: theme.cardColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: _isProcessing ? null : _showApproveDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: const Text("通过", style: TextStyle(fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: OutlinedButton(
                          onPressed: _isProcessing ? null : _showRejectDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            foregroundColor: Colors.redAccent,
                          ),
                          child: const Text("拒绝", style: TextStyle(fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRejectDialog() {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝任务'),
        backgroundColor: theme.cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请输入拒绝原因：'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: '原因内容',
                hintStyle: TextStyle(color: theme.hintColor),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: theme.hintColor)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _rejectMovement(controller.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入拒绝原因')),
                );
              }
            },
            child: const Text('确认', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _approveMovement() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      var response;
      if ("inbound" == widget.type) {
        response = await Http.patch("/purchase/receive/sheet/approve/pass",
            data: {"id": widget.inboundOderId});
      } else if ("outbound" == widget.type) {
        response = await Http.patch("/sale/out/sheet/approve/pass",
            data: {"id": widget.inboundOderId});
      }

      if (response["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('任务审核通过'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      SnackBarUtils.showError(context, '审核失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showApproveDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认审核'),
        backgroundColor: theme.cardColor,
        content: const Text('确认通过此任务？通过后将自动更新库存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: theme.hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _approveMovement();
            },
            child: const Text('确认', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _rejectMovement(String reason) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      var response;
      if ("inbound" == widget.type) {
        response = await Http.patch("/purchase/receive/sheet/approve/refuse",
            data: {"id": widget.inboundOderId, "refuseReason": reason});
      } else if ("outbound" == widget.type) {
        response = await Http.patch("/sale/out/sheet/approve/refuse",
            data: {"id": widget.inboundOderId, "refuseReason": reason});
      }

      if (response["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('任务已拒绝'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      SnackBarUtils.showError(context, '拒绝失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _rowText(ThemeData theme, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label：',
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 14)),
          Expanded(
            child: Text(value ?? "",
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _fetchInData();
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}